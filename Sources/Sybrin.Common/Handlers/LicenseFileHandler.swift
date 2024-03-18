//
//  LicenseFileHandler.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/10/12.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import Foundation

struct LicenseFileHandler {
    
    // MARK: Private Properties
    private var LicenseFile = LicenseFileModel()
    
    private var FolderName: String = "sybrin_mobile_sdk"
    private var FileName: String = "license.txt"
    private var Directory: String
    
    private var DirectoriesPrepared: Bool = false
    private var Initialized: Bool = false
    
    // MARK: Internal Properties
    var Valid: Bool { get { return LicenseFile.Valid } }
    var Message: String { get { return LicenseFile.Message } }
    
    // MARK: Initializers
    init() {
        Directory = "\(FolderName)/\(FileName)"
    }
    
    // MARK: Internal Methods
    mutating func Initialize(for SDKType: LicenseSDKType, in usageMode: LicenseUsageMode) -> Result<Bool, LicenseError> {
        guard !Initialized else {
            "License file already initialized".log(.ProtectedWarning)
            return .failure(.AlreadyInitialized)
        }
        
        if usageMode == .Sybrin {
            PrepareFileNameAndDirectories(for: SDKType)
        } else {
            ReadOrCreateFileAndModel(for: SDKType)
            
            if LicenseFile.Message == "Initialized" {
                "Setting initial values".log(.Debug)
                
                LicenseFile.Valid = true
                LicenseFile.Message = "Valid"
                
                SaveLicenseFile()
            }
        }
        
        "Initialized license file handler".log(.Debug)
        
        Initialized = true
        
        return .success(true)
    }
    
    mutating func UpdateLicenseFile(_ valid: Bool?, _ message: String?) -> Result<Bool, LicenseError> {
        guard Initialized else {
            "License file not initialized".log(.ProtectedError)
            return .failure(.NotInitialized)
        }
        
        let actualValid: Bool = ((valid == nil) ? Valid : valid!)
        let actualMessage: String = ((message == nil) ? Message : message!)
        
        "Updating license file contents".log(.Debug)
        "Valid changed from '\(Valid)' to '\(actualValid)'".log(.Verbose)
        "Message changed from '\(Message)' to '\(actualMessage)'".log(.Verbose)
            
        LicenseFile.Valid = actualValid
        LicenseFile.Message = actualMessage
        
        SaveLicenseFile()
        
        "Updated license file contents".log(.Debug)
        
        return .success(true)
    }
    
    func DeleteLicenseFile() {
        guard Initialized else {
            "License file not initialized".log(.ProtectedError)
            return
        }
        
        "Checking if license file exists".log(.Debug)
        if FileHandler.doesFileExist(Directory) {
            "Removing license file".log(.Debug)
            "Directory: \(Directory)".log(.Verbose)
            FileHandler.deleteDirectory(Directory)
            "Finished removing license file".log(.Debug)
        } else {
            "License file does not exist".log(.ProtectedWarning)
        }
        
    }
    
    // MARK: Private Methods
    private mutating func PrepareFileNameAndDirectories(for SDKType: LicenseSDKType) {
        
        guard !DirectoriesPrepared else { return }
        
        var sdkTypePrefix: String = "undetermined"
        
        switch SDKType {
        case .Identity:
            sdkTypePrefix = "identity"
        case .Biometrics:
            sdkTypePrefix = "biometrics"
        case .WebAPI:
            sdkTypePrefix = "webapi"
        }

        FileName = ".\(sdkTypePrefix)_\(FileName)"

        Directory = "\(FolderName)/\(FileName)"
        
        DirectoriesPrepared = true
        
    }
    
    private mutating func ReadOrCreateFileAndModel(for SDKType: LicenseSDKType) {
        
        func CreateLicenseFileAndModel() {
            "Creating license file".log(.Debug)
            "Directory: \(Directory)".log(.Verbose)
            LicenseFile = LicenseFileModel()
            
            FileHandler.createDirectory(FolderName)
            "Finished creating license file".log(.Debug)
        }
        
        PrepareFileNameAndDirectories(for: SDKType)
        "Checking for existing license file".log(.Debug)
        if FileHandler.doesFileExist(Directory) {
            if !ReadLicenseFile() {
                "Recreating license file".log(.Debug)
                DeleteLicenseFile()
                CreateLicenseFileAndModel()
            }
        } else {
            "License file not found".log(.ProtectedWarning)
            CreateLicenseFileAndModel()
        }
        
    }
    
    private mutating func ReadLicenseFile() -> Bool {
        
        "Reading license file contents".log(.Debug)
        "Directory: \(Directory)".log(.Verbose)
        let fileString = FileHandler.readFromFile(Directory)
        
        if let fileString = fileString, fileString.count >= 0 {
            guard let jsonData = fileString.data(using: .utf8) else {
                "Could not parse string to data".log(.ProtectedError)
                return false
            }
            
            do {
                "Decoding contents from JSON".log(.Debug)
                LicenseFile = try JSONDecoder().decode(LicenseFileModel.self, from: jsonData)
                "Finished reading license file contents".log(.Debug)
                return true
            } catch {
                "Failed to read contents from license file".log(.ProtectedError)
                "Error: \(error.localizedDescription)".log(.Verbose)
                return false
            }
        
        } else {
            "String read from file was empty or nil".log(.ProtectedError)
            return false
        }
        
    }
    
    private mutating func SaveLicenseFile() {
        
        do {
            "Encoding contents to JSON".log(.Debug)
            let jsonData = try JSONEncoder().encode(LicenseFile)
            
            guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                "Could not parse JSON data to string".log(.ProtectedError)
                return
            }
            
            "Writing license file contents".log(.Debug)
            FileHandler.writeToFile(Directory, jsonString)
            "Finished writing license file contents".log(.Debug)
            "Directory: \(Directory)".log(.Verbose)
            
            guard ReadLicenseFile() else { return }
        } catch {
            "Failed to write contents to license file".log(.ProtectedError)
            "Error: \(error.localizedDescription)".log(.Verbose)
        }
        
    }
    
}
