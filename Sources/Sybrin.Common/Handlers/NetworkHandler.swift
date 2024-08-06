//
//  NetworkHandler.swift
//  Sybrin.iOS.Common
//
//
//  Created by Rhulani Ndhlovu on 2021/12/26.
//

import SystemConfiguration
import Network
import Foundation

public final class NetworkHandler {
    
    // MARK: Private Properties
    private final var InternetAvailable: Bool = false
    private final var URLSessionShared = URLSession.shared
    
    // MARK: Public Properties
    public static let shared: NetworkHandler = NetworkHandler()
    public final var isInternetAccessAvailable: Bool { get { return InternetAvailable } }
    
    // MARK: Initializers
    private init() {
        // Configuring the Network Monitor on the main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.ConfigureNetworkMonitor()
        }
    }
    
    // MARK: Public Methods
    // This method does not work in all cases
    public final func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachabilityOptional = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        guard let defaultRouteReachability = defaultRouteReachabilityOptional else { return false }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) == false {
            return false
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
    }
    
    public final func sendRequest(request: URLRequest, validateResponseCode: Int? = nil, completion: @escaping(Result<(data: Data, response: URLResponse), NetworkError>) -> Void) {
        let networkCallID = UUID().uuidString
        
        guard let url = request.url else {
            completion(.failure(.BadRequest))
            "[\(networkCallID)] Invalid Request URL".log(.ProtectedError)
            return
        }
        
        "[\(networkCallID)] Sending network request".log(.Debug)
        "[\(networkCallID)] URL: \(url.absoluteString)".log(.Verbose)
        
        URLSessionShared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(.Error))
                "[\(networkCallID)] Network error".log(.ProtectedError)
                "[\(networkCallID)] Error: \(error.localizedDescription)".log(.Verbose)
                return
            }
            
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.NilResponse))
                "[\(networkCallID)] Network response is nil".log(.ProtectedError)
                return
            }
            
            guard validateResponseCode == nil || (validateResponseCode == response.statusCode) else {
                completion(.failure(.IncorrectResponseCode))
                "[\(networkCallID)] Network invalid response code".log(.ProtectedError)
                "[\(networkCallID)] Response code: \(response.statusCode)".log(.Verbose)
                "[\(networkCallID)] Expected code: \(validateResponseCode!)".log(.Verbose)
                return
            }
            
            guard let data = data else {
                completion(.failure(.NilData))
                "[\(networkCallID)] Network data is nil".log(.ProtectedError)
                return
            }
            
            "[\(networkCallID)] Network request success".log(.Debug)
            completion(.success((data, response)))
            return
            
        }.resume()
        
    }
    
    // MARK: Private Methods
    /// Used to check the network for internet access and keeps running in the background
    private final func ConfigureNetworkMonitor() {
        
        let networkMonitor: NWPathMonitor = NWPathMonitor()
        
        // Checking for network path updates
        networkMonitor.pathUpdateHandler = { [weak self] path in
            if let self = self {
                if path.status == .satisfied {
                    "Network accessible...".log(.Debug)
                    self.InternetAvailable = true
                } else {
                    "Network unavailable...".log(.Warning)
                    self.InternetAvailable = false
                }
            }
        }
        
        // Creating a queue so that our monitor is running in the background
        let monitorQueue = DispatchQueue(label: "Monitor", qos: .background)
        networkMonitor.start(queue: monitorQueue)
        
    }
    
}
