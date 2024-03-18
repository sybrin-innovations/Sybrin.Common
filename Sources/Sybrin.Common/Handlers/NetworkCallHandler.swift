//
//  NetworkCallHandler.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/14.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import Foundation
import UIKit

struct NetworkCallHandler {
    
    // MARK: Internal Methods
    static func ValidateLicenseLegacy(organisationID: String, syncCount: Int, sdkDate: Date, feature: String, phoneModel: String = UIDevice.modelName, osVersion: String = UIDevice.current.systemVersion, licenseURL: String? = nil, completion: @escaping(Result<ValidateLicenseLegacyResponseModel, LicenseNetworkError>) -> Void) {
        
        guard let endpoint: URL = URL(string: ((licenseURL != nil) ? licenseURL! : FrameworkConfiguration.EnvironmentObj?.licenseLegacyURL ?? "https://licensing.sybrin.co.za/license/api/license/ValidateLicenses")) else {
            completion(.failure(.NetworkError(error: .BadRequest)))
            return
        }
        
        var request: URLRequest = URLRequest(url: endpoint)
        
        request.httpMethod = "POST"
        
        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        let Body: [String: Any?] = [
            "OrganisationID": organisationID,
            "SyncCount": syncCount,
            "Feature": feature,
            "PhoneModel": phoneModel,
            "OSVersion": osVersion,
            "SDKDate": sdkDate.dateToString(withFormat: "yyyy-MM-dd HH:mm:ss", timezone: TimeZone(abbreviation: "UTC"))
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: Body, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            NetworkHandler.shared.sendRequest(request: request) { (result) in
                switch result {
                case .success((let data, _)):
                    do {
                        let responseObject = try JSONDecoder().decode(ValidateLicenseLegacyResponseModel.self, from: data)
                        completion(.success(responseObject))
                    } catch {
                        completion(.failure(.NetworkError(error: .Parsing)))
                    }
                case .failure(let error):
                    completion(.failure(.NetworkError(error: error)))
                }
            }
        } catch {
            "Request body parse error".log(.ProtectedError)
            "Error: \(error.localizedDescription)".log(.Verbose)
            completion(.failure(.NetworkError(error: .BadRequest)))
        }
        
    }
    
    static func LicenseAuthorize(username: String = FrameworkConfiguration.EnvironmentObj?.licenseAuthorizeUsername ?? "LicenseUser", apiKey: String = FrameworkConfiguration.EnvironmentObj?.licenseAuthorizeAPIKey ?? "ZTk2Y2RjNzctYWQzNi00NWU4LWEzYjktZTc5ZGE5NGRkNWYzLjRlZDU1NmQyLWU2OWQtNGExYi04ZjhhLTk1MTcxYWYxOWRkMQ==", completion: @escaping (Result<LicenseAuthorizeResponseModel, LicenseNetworkError>) -> Void) {
        
        guard let endpoint: URL = URL(string: FrameworkConfiguration.EnvironmentObj?.licenseAuthorizeURL ?? "https://licensing.sybrin.co.za/license/api/Authorize") else {
            completion(.failure(.NetworkError(error: .BadRequest)))
            return
        }
        
        var request: URLRequest = URLRequest(url: endpoint)
        
        request.httpMethod = "POST"
        
        request.addValue(username, forHTTPHeaderField: "Username")
        request.addValue(apiKey, forHTTPHeaderField: "APIKey")
        
        NetworkHandler.shared.sendRequest(request: request) { (result) in
            switch result {
            case .success((let data, let response)):
                
                guard let responseStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                    "Received an unknown response code".log(.ProtectedError)
                    completion(.failure(.NetworkError(error: .IncorrectResponseCode)))
                    return
                }
                
                guard responseStatusCode == 200 else {
                    do {
                        "Received an invalid (not 200) response code".log(.ProtectedError)
                        "Response Code: \(responseStatusCode)".log(.Verbose)
                        if let rawResponse = String(data: data, encoding: .utf8) {
                            "Raw Response: \(rawResponse)".log(.Verbose)
                        }
                        let errorObject = try JSONDecoder().decode(LicenseErrorResponseModel.self, from: data)
                        "Error Message: \(errorObject.ErrorMessage)".log(.Verbose)
                        if let errorDetails = errorObject.ErrorDetails {
                            "Error Details: \(errorDetails)".log(.Verbose)
                            if let commonError = ParseLicenseErrorDetails(errorDetails: errorDetails) {
                                completion(.failure(commonError))
                                return
                            }
                        }
                        completion(.failure(.Error(message: errorObject.ErrorMessage, details: errorObject.ErrorDetails)))
                    } catch {
                        "Failed to decode to error object".log(.ProtectedError)
                        "Error: \(error.localizedDescription)".log(.Verbose)
                        completion(.failure(.NetworkError(error: .IncorrectResponseCode)))
                    }
                    return
                }
                
                do {
                    let responseObject = try JSONDecoder().decode(LicenseAuthorizeResponseModel.self, from: data)
                    completion(.success(responseObject))
                } catch {
                    do {
                        "Failed to decode JSON object".log(.ProtectedError)
                        if let rawResponse = String(data: data, encoding: .utf8) {
                            "Raw Response: \(rawResponse)".log(.Verbose)
                        }
                        let errorObject = try JSONDecoder().decode(LicenseErrorResponseModel.self, from: data)
                        "Error Message: \(errorObject.ErrorMessage)".log(.Verbose)
                        if let errorDetails = errorObject.ErrorDetails {
                            "Error Details: \(errorDetails)".log(.Verbose)
                            if let commonError = ParseLicenseErrorDetails(errorDetails: errorDetails) {
                                completion(.failure(commonError))
                                return
                            }
                        }
                        completion(.failure(.Error(message: errorObject.ErrorMessage, details: errorObject.ErrorDetails)))
                    } catch {
                        "Failed to decode to error object".log(.ProtectedError)
                        "Error: \(error.localizedDescription)".log(.Verbose)
                        completion(.failure(.NetworkError(error: .Parsing)))
                    }
                }
            case .failure(let error):
                completion(.failure(.NetworkError(error: error)))
            }
        }
        
    }
    
    static func LicenseValidate(licenseID: String, authorization: String, completion: @escaping(Result<LicenseValidateResponseModel, LicenseNetworkError>) -> Void) {
        
        guard let endpoint: URL = URL(string: FrameworkConfiguration.EnvironmentObj?.licenseValidateURL ?? "https://licensing.sybrin.co.za/license/api/license/Validate") else {
            completion(.failure(.NetworkError(error: .BadRequest)))
            return
        }
        
        var request: URLRequest = URLRequest(url: endpoint)
        
        request.httpMethod = "POST"
        
        request.addValue(authorization, forHTTPHeaderField: "Authorization")
        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        let Body: [String: Any?] = [
            "LicenseID": licenseID
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: Body, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            NetworkHandler.shared.sendRequest(request: request) { (result) in
                switch result {
                case .success((let data, let response)):
                    
                    guard let responseStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                        "Received an unknown response code".log(.ProtectedError)
                        completion(.failure(.NetworkError(error: .IncorrectResponseCode)))
                        return
                    }
                    
                    guard responseStatusCode == 200 else {
                        do {
                            "Received an invalid (not 200) response code".log(.ProtectedError)
                            "Response Code: \(responseStatusCode)".log(.Verbose)
                            if let rawResponse = String(data: data, encoding: .utf8) {
                                "Raw Response: \(rawResponse)".log(.Verbose)
                            }
                            let errorObject = try JSONDecoder().decode(LicenseErrorResponseModel.self, from: data)
                            "Error Message: \(errorObject.ErrorMessage)".log(.Verbose)
                            if let errorDetails = errorObject.ErrorDetails {
                                "Error Details: \(errorDetails)".log(.Verbose)
                                if let commonError = ParseLicenseErrorDetails(errorDetails: errorDetails) {
                                    completion(.failure(commonError))
                                    return
                                }
                            }
                            completion(.failure(.Error(message: errorObject.ErrorMessage, details: errorObject.ErrorDetails)))
                        } catch {
                            "Failed to decode to error object".log(.ProtectedError)
                            "Error: \(error.localizedDescription)".log(.Verbose)
                            completion(.failure(.NetworkError(error: .IncorrectResponseCode)))
                        }
                        return
                    }
                    
                    do {
                        let responseObject = try JSONDecoder().decode(LicenseValidateResponseModel.self, from: data)
                        completion(.success(responseObject))
                    } catch {
                        do {
                            "Failed to decode JSON object".log(.ProtectedError)
                            if let rawResponse = String(data: data, encoding: .utf8) {
                                "Raw Response: \(rawResponse)".log(.Verbose)
                            }
                            let errorObject = try JSONDecoder().decode(LicenseErrorResponseModel.self, from: data)
                            "Error Message: \(errorObject.ErrorMessage)".log(.Verbose)
                            if let errorDetails = errorObject.ErrorDetails {
                                "Error Details: \(errorDetails)".log(.Verbose)
                                if let commonError = ParseLicenseErrorDetails(errorDetails: errorDetails) {
                                    completion(.failure(commonError))
                                    return
                                }
                            }
                            completion(.failure(.Error(message: errorObject.ErrorMessage, details: errorObject.ErrorDetails)))
                        } catch {
                            "Failed to decode to error object".log(.ProtectedError)
                            "Error: \(error.localizedDescription)".log(.Verbose)
                            completion(.failure(.NetworkError(error: .Parsing)))
                        }
                    }
                case .failure(let error):
                    completion(.failure(.NetworkError(error: error)))
                }
            }
        } catch {
            "Request body parse error".log(.ProtectedError)
            "Error: \(error.localizedDescription)".log(.Verbose)
            completion(.failure(.NetworkError(error: .BadRequest)))
        }
        
    }
    
    static func LicenseUpdateCount(licenseID: String, count: Int = 1, date: Date, feature: String, phoneModel: String = UIDevice.modelName, osVersion: String = UIDevice.current.systemVersion, authorization: String, completion: @escaping(Result<LicenseUpdateCountResponseModel, LicenseNetworkError>) -> Void) {
        
        guard let endpoint: URL = URL(string: FrameworkConfiguration.EnvironmentObj?.licenseUpdateCountURL ?? "https://licensing.sybrin.co.za/license/api/license/UpdateCount") else {
            completion(.failure(.NetworkError(error: .BadRequest)))
            return
        }
        
        var request: URLRequest = URLRequest(url: endpoint)
        
        request.httpMethod = "POST"
        
        request.addValue(authorization, forHTTPHeaderField: "Authorization")
        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        
        let Body: [String: Any?] = [
            "LicenseID": licenseID,
            "Count": count,
            "Date": date.dateToString(withFormat: "yyyy-MM-dd HH:mm:ss", timezone: TimeZone(abbreviation: "UTC")),
            "Feature": feature,
            "PhoneModel": phoneModel,
            "OSVersion": osVersion
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: Body, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            NetworkHandler.shared.sendRequest(request: request) { (result) in
                switch result {
                case .success((let data, let response)):
                    
                    guard let responseStatusCode = (response as? HTTPURLResponse)?.statusCode else {
                        "Received an unknown response code".log(.ProtectedError)
                        completion(.failure(.NetworkError(error: .IncorrectResponseCode)))
                        return
                    }
                    
                    guard responseStatusCode == 200 else {
                        do {
                            "Received an invalid (not 200) response code".log(.ProtectedError)
                            "Response Code: \(responseStatusCode)".log(.Verbose)
                            if let rawResponse = String(data: data, encoding: .utf8) {
                                "Raw Response: \(rawResponse)".log(.Verbose)
                            }
                            let errorObject = try JSONDecoder().decode(LicenseErrorResponseModel.self, from: data)
                            "Error Message: \(errorObject.ErrorMessage)".log(.Verbose)
                            if let errorDetails = errorObject.ErrorDetails {
                                "Error Details: \(errorDetails)".log(.Verbose)
                                if let commonError = ParseLicenseErrorDetails(errorDetails: errorDetails) {
                                    completion(.failure(commonError))
                                    return
                                }
                            }
                            completion(.failure(.Error(message: errorObject.ErrorMessage, details: errorObject.ErrorDetails)))
                        } catch {
                            "Failed to decode to error object".log(.ProtectedError)
                            "Error: \(error.localizedDescription)".log(.Verbose)
                            completion(.failure(.NetworkError(error: .IncorrectResponseCode)))
                        }
                        return
                    }
                    
                    do {
                        let responseObject = try JSONDecoder().decode(LicenseUpdateCountResponseModel.self, from: data)
                        completion(.success(responseObject))
                    } catch {
                        do {
                            "Failed to decode JSON object".log(.ProtectedError)
                            if let rawResponse = String(data: data, encoding: .utf8) {
                                "Raw Response: \(rawResponse)".log(.Verbose)
                            }
                            let errorObject = try JSONDecoder().decode(LicenseErrorResponseModel.self, from: data)
                            "Error Message: \(errorObject.ErrorMessage)".log(.Verbose)
                            if let errorDetails = errorObject.ErrorDetails {
                                "Error Details: \(errorDetails)".log(.Verbose)
                                if let commonError = ParseLicenseErrorDetails(errorDetails: errorDetails) {
                                    completion(.failure(commonError))
                                    return
                                }
                            }
                            completion(.failure(.Error(message: errorObject.ErrorMessage, details: errorObject.ErrorDetails)))
                        } catch {
                            "Failed to decode to error object".log(.ProtectedError)
                            "Error: \(error.localizedDescription)".log(.Verbose)
                            completion(.failure(.NetworkError(error: .Parsing)))
                        }
                    }
                case .failure(let error):
                    completion(.failure(.NetworkError(error: error)))
                }
            }
        } catch {
            "Request body parse error".log(.ProtectedError)
            "Error: \(error.localizedDescription)".log(.Verbose)
            completion(.failure(.NetworkError(error: .BadRequest)))
        }
        
    }
    
    // MARK: Private Methods
    private static func ParseLicenseErrorDetails(errorDetails: String) -> LicenseNetworkError? {
        if errorDetails == "Could not find license from server" {
            return .CouldNotFindLicense
        }
        
        return nil
    }
    
}
