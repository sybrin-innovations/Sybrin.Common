//
//  LicenseHandler.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/12.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import UIKit
import Foundation

public final class LicenseHandler {
    
    // MARK: Private Properties
    private static var UseFile = true
    
    private var SDKType: LicenseSDKType?
    private var LicenseModelObj: EncryptedLicenseModel!
    private var Initialized = false
    private var LicenseFileHandlerObj = LicenseFileHandler()
    private var Authorization: String?
    
    // MARK: Public Properties
    public var sdkType: LicenseSDKType? {
        get { return SDKType }
        set {
            if DeveloperSettings.developerAccessGranted {
                SDKType = newValue
            }
            else {
                "Developer access is required to set SDK type".log(.Error)
            }
        }
    }
    public var initialized: Bool { get { return Initialized } }
    public var licenseID: String? { get { return LicenseModelObj?.OrganisationID } }
    
    // MARK: Initializers
    public init() { }
    
    // MARK: Public Initialize Method
    public func initialize(with key: String) -> Result<Bool, LicenseError> {
        
        guard !Initialized else {
            "License already initialized".log(.ProtectedWarning)
            return .failure(.AlreadyInitialized)
        }
        
        "Initializing license".log(.Information)
        
        LicenseModelObj = InitializeLicenseModel(key: key)
        
        guard let licenseModel = self.LicenseModelObj else {
            "License model object is nil".log(.ProtectedError)
            return .failure(.DecodingKeyFailed)
        }
        
        "License loaded".log(.Debug)
        "UsageMode: \(licenseModel.UsageMode)".log(.Verbose)
        
        if LicenseHandler.UseFile {
            switch LicenseFileHandlerObj.Initialize(for: licenseModel.SDKType, in: licenseModel.UsageMode) {
            case .success(_):
                switch licenseModel.UsageMode {
                case .Client:
                    Timer.scheduledTimer(withTimeInterval: 60 * 3, repeats: true) { [weak self] timer in
                        guard let self = self else { return }
                        
                        let _ = self.LicenseAuthorize(timer: timer)
                    }
                    if !IsExpiryDateValid() {
                        "License has expired".log(.Warning)
                        
                        if case .failure(let reason) = LicenseFileHandlerObj.UpdateLicenseFile(false, "Expired") {
                            "Failed to update license file".log(.ProtectedError)
                            "Error: \(reason)".log(.Verbose)
                            return .failure(.InternalError)
                        }
                    }
                case .Sybrin:
                    LicenseFileHandlerObj.DeleteLicenseFile()
                }
            case .failure(let reason):
                "Failed to initialize license file".log(.ProtectedError)
                "Error: \(reason)".log(.Verbose)
                return .failure(.InternalError)
            }
        }
        
        "License successfully initialized".log(.Information)
        Initialized = true
        return .success(true)
        
    }
    
    // MARK: Public Validate Method
    public func validateLicense(forceOnlineValidation: Bool = false) -> Result<Bool, LicenseError> {
        
        guard Initialized else {
            "License not initialized".log(.ProtectedError)
            return .failure(.NotInitialized)
        }
        
        guard let licenseModel = self.LicenseModelObj else {
            "License model object is nil".log(.ProtectedError)
            return .failure(.InternalError)
        }
        
        "Validating license".log(.Information)
        
        switch licenseModel.UsageMode {
        case .Client:
            switch ValidateLocally() {
            case .success(_):
                if LicenseHandler.UseFile && LicenseFileHandlerObj.Valid && !forceOnlineValidation {
                    "License successfully validated".log(.Information)
                    return .success(true)
                } else if IsExpiryDateValid() {
                    if NetworkHandler.shared.isConnectedToNetwork() {
                        return LicenseValidateOnline(licenseID: licenseModel.OrganisationID)
                    } else {
                        "No internet access".log(.Error)
                        if LicenseHandler.UseFile {
                            if case .failure(let reason) = LicenseFileHandlerObj.UpdateLicenseFile(false, "NoInternet") {
                                "Failed to update license file".log(.ProtectedError)
                                "Error: \(reason)".log(.Verbose)
                                return .failure(.InternalError)
                            }
                        }
                        return .failure(.NoInternet)
                    }
                } else {
                    "License is expired".log(.Error)
                    return .failure(.Expired)
                }
            case .failure(let reason):
                "Local validation failed".log(.Error)
                "Error: \(reason)".log(.Verbose)
                return .failure(reason)
            }
        case .Sybrin:
            "License successfully validated".log(.Information)
            return .success(true)
        }
        
    }
    
    // MARK: Public Update Count Method
    // Explicitly setting the function labels to acronyms
    public func updateCount(f feature: String = "", pM phoneModel: String = UIDevice.modelName, oV osVersion: String = UIDevice.current.systemVersion) -> Result<Bool, LicenseError> {
        
        guard Initialized else {
            "License not initialized".log(.ProtectedError)
            return .failure(.NotInitialized)
        }
        
        guard let licenseModel = self.LicenseModelObj else {
            "License model object is nil".log(.ProtectedError)
            return .failure(.InternalError)
        }
        
        "Updating license count".log(.Information)
        
        switch validateLicense() {
        case .success(_):
            switch licenseModel.UsageMode {
            case .Client:
                if NetworkHandler.shared.isConnectedToNetwork() {
                    DispatchQueue.global(qos: .utility).async { [weak self] in
                        guard let self = self else { return }
                        
                        "Updating license count online".log(.Debug)
                        if case .failure(let reason) = self.LicenseUpdateCountOnline(licenseID: licenseModel.OrganisationID, count: 1, date: Date(), feature: feature, phoneModel: phoneModel, osVersion: osVersion) {
                            "Updating license count failed".log(.ProtectedError)
                            "Error: \(reason)".log(.Verbose)
                        }
                    }
                    return .success(true)
                } else {
                    "No internet access".log(.Error)
                    if LicenseHandler.UseFile {
                        if case .failure(let reason) = LicenseFileHandlerObj.UpdateLicenseFile(false, "NoInternet") {
                            "Failed to update license file".log(.ProtectedError)
                            "Error: \(reason)".log(.Verbose)
                            return .failure(.InternalError)
                        }
                    }
                    return .failure(.NoInternet)
                }
            case .Sybrin:
                "Update license count successful, sybrin license".log(.Information)
                return .success(true)
            }
        case .failure(let reason):
            "Updating license count failed".log(.ProtectedError)
            "Error: \(reason)".log(.Verbose)
            return .failure(reason)
        }
        
    }
    
    // MARK: Private Methods
    private func InitializeLicenseModel(key: String) -> EncryptedLicenseModel? {
        
        "Decrypting License key".log(.Debug)
        let aes = AES()
        let jsonString = aes.Decrypt(message: key)
        
        guard jsonString != nil, let jsonData = jsonString?.data(using: .utf8) else {
            "Invalid License key".log(.Error)
            return nil
        }

        "License key decrypted".log(.Debug)

        do {
            return try JSONDecoder().decode(EncryptedLicenseModel.self, from: jsonData)
        } catch {
            "Failed to decode JSON to license model".log(.ProtectedError)
            "Error: \(error.localizedDescription)".log(.Verbose)
            return nil
        }
        
    }
    
    // MARK: Network Methods
    private func ValidateLicenseLegacyOnline(organisationID: String, syncCount: Int, sdkDate: Date = Date(), feature: String, phoneModel: String = UIDevice.modelName, osVersion: String = UIDevice.current.systemVersion, licenseURL: String?) -> Result<Bool, LicenseError> {
        
        var returnValue: Result<Bool, LicenseError> = .failure(.FailedInternet(reason: nil))
        guard let licenseModel = LicenseModelObj else { return .failure(.InternalError) }
        
        let Semaphore = DispatchSemaphore(value: 0)
        
        NetworkCallHandler.ValidateLicenseLegacy(organisationID: organisationID, syncCount: syncCount, sdkDate: sdkDate, feature: feature, phoneModel: phoneModel, osVersion: osVersion, licenseURL: licenseURL) { [weak self] (result) in
            guard let self = self else { return }
                
            switch result {
            case .success(let response):
                if response.StatusCode {
                    returnValue = .success(true)
                    if LicenseHandler.UseFile && licenseModel.UsageMode != .Sybrin {
                        if case .failure(let reason) = self.LicenseFileHandlerObj.UpdateLicenseFile(true, "Valid") {
                            "Failed to update license file".log(.ProtectedError)
                            "Error: \(reason)".log(.Verbose)
                            returnValue = .failure(.InternalError)
                        }
                    }
                    "Successfully validated  license online (Legacy)".log(.Debug)
                    "Sync Count: \(syncCount)".log(.Verbose)
                } else {
                    returnValue = .failure(.FailedInternet(reason: nil))
                    if LicenseHandler.UseFile && licenseModel.UsageMode != .Sybrin {
                        if case .failure(let reason) = self.LicenseFileHandlerObj.UpdateLicenseFile(false, response.Message) {
                            "Failed to update license file".log(.ProtectedError)
                            "Error: \(reason)".log(.Verbose)
                            returnValue = .failure(.InternalError)
                        }
                    }
                    "Failed to validate license online. Received failure response from the server (Legacy)".log(.Error)
                    "Message: \(response.Message)".log(.Verbose)
                }
            case .failure(let error):
                returnValue = .failure(.FailedInternet(reason: nil))
                if LicenseHandler.UseFile && licenseModel.UsageMode != .Sybrin {
                    if case .failure(let reason) = self.LicenseFileHandlerObj.UpdateLicenseFile(false, "NetworkError") {
                        "Failed to update license file".log(.ProtectedError)
                        "Error: \(reason)".log(.Verbose)
                        returnValue = .failure(.InternalError)
                    }
                }
                "Failed to validate license online (Legacy)".log(.Error)
                "Error: \(error.localizedDescription)".log(.Verbose)
            }
            
            Semaphore.signal()
        }
        
        Semaphore.wait()
        
        return returnValue
        
    }
    
    private func LicenseAuthorize(timer: Timer?) -> Result<Bool, LicenseError> {
        
        var returnValue: Result<Bool, LicenseError> = .failure(.FailedInternet(reason: nil))
        
        let Semaphore = DispatchSemaphore(value: 0)
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            NetworkCallHandler.LicenseAuthorize() { [weak self] (result) in
                guard let self = self else { return }
                
                switch result {
                case .success(let response):
                    
                    if let authorization = response.AuthToken {
                        self.Authorization = authorization
                        returnValue = .success(true)
                        "Successfully authorized with licensing server".log(.Debug)
                    } else if let error = response.Message {
                        "Failed to authorize with licensing server. Received failure response from the server".log(.Error)
                        "Message: \(error)".log(.Verbose)
                    }
                    
                case .failure(let error):
                    "Failed to authorize with licensing server".log(.Error)
                    "Error: \(error.localizedDescription)".log(.Verbose)
                    
                }
                
                Semaphore.signal()
            }
        }
        
        Semaphore.wait()
        
        return returnValue
        
    }
    
    private func LicenseValidateOnline(licenseID: String) -> Result<Bool, LicenseError> {
        
        var returnValue: Result<Bool, LicenseError> = .failure(.FailedInternet(reason: nil))
        guard let licenseModel = LicenseModelObj else { return .failure(.InternalError) }
        
        if Authorization == nil {
            guard case .success(_) = self.LicenseAuthorize(timer: nil) else { return .failure(.InternalError) }
        }
        
        guard let authorization = Authorization else { return .failure(.InternalError) }
        
        let Semaphore = DispatchSemaphore(value: 0)
        
        var RetryOnLegacy = false
        
        NetworkCallHandler.LicenseValidate(licenseID: licenseID, authorization: authorization) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.Valid {
                    returnValue = .success(true)
                    if LicenseHandler.UseFile && licenseModel.UsageMode != .Sybrin {
                        if case .failure(let reason) = self.LicenseFileHandlerObj.UpdateLicenseFile(true, "Valid") {
                            "Failed to update license file".log(.ProtectedError)
                            "Error: \(reason)".log(.Verbose)
                            returnValue = .failure(.InternalError)
                        }
                    }
                    "Successfully validated  license online".log(.Debug)
                } else {
                    returnValue = .failure(.FailedInternet(reason: nil))
                    if response.Message == "Suspended" {
                        returnValue = .failure(.Suspended)
                    }
                    if response.Message == "Expired" {
                        returnValue = .failure(.Expired)
                    }
                    if response.Message == "Exceeded MaxUsageCount" {
                        returnValue = .failure(.MaxUsageCountReached)
                    }
                    if LicenseHandler.UseFile && licenseModel.UsageMode != .Sybrin {
                        if case .failure(let reason) = self.LicenseFileHandlerObj.UpdateLicenseFile(false, response.Message) {
                            "Failed to update license file".log(.ProtectedError)
                            "Error: \(reason)".log(.Verbose)
                            returnValue = .failure(.InternalError)
                        }
                    }
                    "Failed to validate license online. Received failure response from the server".log(.Error)
                    "Message: \(response.Message)".log(.Verbose)
                }
            case .failure(let error):
                if case .CouldNotFindLicense = error {
                    RetryOnLegacy = true
                } else {
                    returnValue = .failure(.FailedInternet(reason: nil))
                    if LicenseHandler.UseFile && licenseModel.UsageMode != .Sybrin {
                        if case .failure(let reason) = self.LicenseFileHandlerObj.UpdateLicenseFile(false, "NetworkError") {
                            "Failed to update license file".log(.ProtectedError)
                            "Error: \(reason)".log(.Verbose)
                            returnValue = .failure(.InternalError)
                        }
                    }
                    "Failed to validate license online".log(.Error)
                    "Error: \(error)".log(.Verbose)
                }
            }
            
            Semaphore.signal()
        }
        
        Semaphore.wait()
        
        if RetryOnLegacy {
            "Retrying on legacy".log(.Warning)
            let legacyResult = self.ValidateLicenseLegacyOnline(organisationID: licenseID, syncCount: 0, feature: "", licenseURL: self.LicenseModelObj.LicenseURL)
            returnValue = legacyResult
            "Legacy retry done".log(.Debug)
        }
        
        return returnValue
        
    }
    
    private func LicenseUpdateCountOnline(licenseID: String, count: Int, date: Date = Date(), feature: String, phoneModel: String = UIDevice.modelName, osVersion: String = UIDevice.current.systemVersion) -> Result<Bool, LicenseError> {
        
        var returnValue: Result<Bool, LicenseError> = .failure(.FailedInternet(reason: nil))
        guard let licenseModel = LicenseModelObj else { return .failure(.InternalError) }
        
        if Authorization == nil {
            guard case .success(_) = self.LicenseAuthorize(timer: nil) else { return .failure(.InternalError) }
        }
        
        guard let authorization = Authorization else { return .failure(.InternalError) }
        
        let Semaphore = DispatchSemaphore(value: 0)
        
        var RetryOnLegacy = false
        
        NetworkCallHandler.LicenseUpdateCount(licenseID: licenseID, count: count, date: date, feature: feature, phoneModel: phoneModel, osVersion: osVersion, authorization: authorization) { [weak self] (result) in
            guard let self = self else { return }
            
            switch result {
            case .success(let response):
                if response.Successful {
                    returnValue = .success(true)
                    if LicenseHandler.UseFile && licenseModel.UsageMode != .Sybrin {
                        if case .failure(let reason) = self.LicenseFileHandlerObj.UpdateLicenseFile(true, "Valid") {
                            "Failed to update license file".log(.ProtectedError)
                            "Error: \(reason)".log(.Verbose)
                            returnValue = .failure(.InternalError)
                        }
                    }
                    "Successfully updated license count online".log(.Debug)
                    "Count: \(count)".log(.Verbose)
                    "Feature: \(feature)".log(.Verbose)
                    "Phone Model: \(phoneModel)".log(.Verbose)
                    "OS Version: \(osVersion)".log(.Verbose)
                } else {
                    returnValue = .failure(.FailedInternet(reason: nil))
                    if LicenseHandler.UseFile && licenseModel.UsageMode != .Sybrin {
                        if case .failure(let reason) = self.LicenseFileHandlerObj.UpdateLicenseFile(false, "UpdateCountFailed") {
                            "Failed to update license file".log(.ProtectedError)
                            "Error: \(reason)".log(.Verbose)
                            returnValue = .failure(.InternalError)
                        }
                    }
                    "Failed to update license count online".log(.Error)
                }
            case .failure(let error):
                if case .CouldNotFindLicense = error {
                    RetryOnLegacy = true
                } else {
                    returnValue = .failure(.FailedInternet(reason: nil))
                    if LicenseHandler.UseFile && licenseModel.UsageMode != .Sybrin {
                        if case .failure(let reason) = self.LicenseFileHandlerObj.UpdateLicenseFile(false, "NetworkError") {
                            "Failed to update license file".log(.ProtectedError)
                            "Error: \(reason)".log(.Verbose)
                            returnValue = .failure(.InternalError)
                        }
                    }
                    "Failed to update license count online".log(.Error)
                    "Error: \(error)".log(.Verbose)
                }
            }
            
            Semaphore.signal()
        }
        
        Semaphore.wait()
        
        if RetryOnLegacy {
            "Retrying on legacy".log(.Warning)
            let legacyResult = self.ValidateLicenseLegacyOnline(organisationID: licenseID, syncCount: count, sdkDate: date, feature: feature, phoneModel: phoneModel, osVersion: osVersion, licenseURL: self.LicenseModelObj.LicenseURL)
            returnValue = legacyResult
            "Legacy retry done".log(.Debug)
        }
        
        return returnValue
        
    }
    
    // MARK: Validation Methods
    private func ValidateLocally() -> Result<Bool, LicenseError> {
        
        if !IsStartDateValid() {
            "License hasn't started yet".log(.Warning)
            return .failure(.NotStarted)
        }
        
        if !IsExpiryDateValid() {
            "License is expired".log(.Warning)
            return .failure(.Expired)
        }
        
        if !IsSDKTypeValid() {
            "License is not valid for this SDK".log(.Warning)
            return .failure(.IncorrectSDK)
        }

        "License successfully validated locally".log(.Information)
        return .success(true)
        
    }

    private func IsStartDateValid() -> Bool {
        
        guard let licenseModel = LicenseModelObj else { return false }
        return (licenseModel.StartDate < Date())
        
    }
    
    private func IsExpiryDateValid() -> Bool {
        
        guard let licenseModel = LicenseModelObj else { return false }
        return (licenseModel.ExpiryDate > Date())
        
    }
    
    private func IsSDKTypeValid() -> Bool {
        
        guard let licenseModel = LicenseModelObj else { return false }
        return (licenseModel.SDKType == SDKType)
        
    }
    
}
