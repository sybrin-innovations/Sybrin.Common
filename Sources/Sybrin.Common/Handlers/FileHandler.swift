//
//  FileHandler.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/17.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import Foundation

public struct FileHandler {
    
    // MARK: Public Methods
    public static func doesFileExist(_ fileName: String) -> Bool {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            "Could not find document directory".log(.Error)
            return false
        }
        let path = documentDirectory.appendingPathComponent(fileName)
        
        let filePath = path.path
        let fileManager = FileManager.default
        
        return fileManager.fileExists(atPath: filePath)
    }
    
    public static func doesFolderExist(_ folderName: String) -> Bool {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            "Could not find document directory".log(.Error)
            return false
        }
        let path = documentDirectory.appendingPathComponent(folderName)
        
        let filePath = path.path
        let fileManager = FileManager.default
        
        return fileManager.fileExists(atPath: filePath)
    }
    
    public static func createDirectory(_ directoryName: String) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            "Could not find document directory".log(.Error)
            return
        }
        let path = documentDirectory.appendingPathComponent(directoryName)
        
        do {
            try FileManager.default.createDirectory(atPath: path.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            "Unable to create directory".log(.ProtectedError)
            "Directory name: \(directoryName)".log(.Verbose)
            "Error: \(error.localizedDescription)".log(.Verbose)
        }
    }
    
    public static func deleteDirectory(_ directoryName: String) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            "Could not find document directory".log(.Error)
            return
        }
        let path = documentDirectory.appendingPathComponent(directoryName)
        
        do {
            try FileManager.default.removeItem(atPath: path.path)
        } catch {
            "Unable to delete directory".log(.ProtectedError)
            "Directory name: \(directoryName)".log(.Verbose)
            "Error: \(error.localizedDescription)".log(.Verbose)
        }
    }
    
    public static func writeToFile(_ pathToFile: String, _ data: String, _ encodeBase64: Bool = true) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            "Could not find document directory".log(.Error)
            return
        }
        let path = documentDirectory.appendingPathComponent(pathToFile)
        
        do {
            var stringToSave: String!
            
            if encodeBase64 {
                guard let encodedData = Base64.encodeBase64String(data) else {
                    "Could not encode to base64".log(.ProtectedError)
                    return
                }
                stringToSave = String(data: encodedData, encoding: .utf8)
            } else {
                stringToSave = data
            }
            
            guard stringToSave != nil else {
                "Base64 encoded string was nil".log(.ProtectedError)
                return
            }
            
            try stringToSave.write(to: path, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            "Unable to write to file".log(.ProtectedError)
            "Path: \(pathToFile)".log(.Verbose)
            "Error: \(error.localizedDescription)".log(.Verbose)
        }
    }
    
    public static func readFromFile(_ pathToFile: String, _ decodeBase64: Bool = true) -> String? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            "Could not find document directory".log(.Error)
            return nil
        }
        let path = documentDirectory.appendingPathComponent(pathToFile)
        
        do {
            let data = try String(contentsOf: path, encoding: .utf8)
            
            if decodeBase64 {
                guard let dataData = data.data(using: .utf8) else {
                    "String data was nil".log(.ProtectedError)
                    return nil
                }
                return Base64.decodeBase64Data(dataData)
            } else {
                return data
            }
        } catch {
            "Unable to read from file".log(.ProtectedError)
            "Path: \(pathToFile)".log(.Verbose)
            "Error: \(error.localizedDescription)".log(.Verbose)
            return nil
        }
    }
    
}
