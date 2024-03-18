//
//  GalleryHandler.swift
//  Sybrin.iOS.Common
//
//  Created by Nico Celliers on 2020/08/17.
//  Copyright © 2020 Sybrin Systems. All rights reserved.
//

import UIKit
import Photos

public struct GalleryHandler {
    
    // MARK: Private Properties
    private static let AlbumName = "Sybrin"
    private static var AssetCollection: PHAssetCollection!
    private static let SaveInFileStore = true
    private static let SaveInPhotoLibrary = false

    // MARK: Public Methods
    public static func saveImage(_ image: UIImage, name: String, inCustomDirectory: String? = nil, completion: @escaping (_ path: String) -> ()) {
        if SaveInPhotoLibrary {
            var PermissionStatus: PHAuthorizationStatus = .notDetermined
            
            AccessHandler.checkPhotoLibraryAccess { (result) in
                PermissionStatus = (result) ? .authorized : .denied
            }
            
            guard PermissionStatus == .authorized else {
                "Library permission denied".log(.Error)
                return
            }
            
            InitializePhotoLibrary()
        }
        
        let FileDirectory: String = inCustomDirectory ?? AlbumName
        
        InitializeFileStore(at: FileDirectory)
        
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            "Could not find document directory".log(.Error)
            return
        }
        let fileName = "\(FileDirectory)/\(Date().timeIntervalSinceReferenceDate)_\(name).jpeg"
        let path = documentDirectory.appendingPathComponent(fileName)
        
        DispatchQueue.global(qos: .background).async {
            if let path = SaveImageToFileStore(image, path: path) {
                completion(path)
            }
            
            if SaveInPhotoLibrary {
                SaveImageToPhotoLibrary(image: image)
            }
        }
        
    }

    // MARK: Private Methods
    private static func SaveImageToFileStore(_ image: UIImage, path: URL) -> String? {
        guard let jpegData = image.jpegData(compressionQuality: 1) else {
            "Could not get jpeg data".log(.Error)
            return nil
        }
        
        "Checking for duplicate file".log(.Debug)
        if FileHandler.doesFileExist(path.path) {
            FileHandler.deleteDirectory(path.path)
        }
        
        do {
            "Writing image to file store".log(.Debug)
            try jpegData.write(to: path)
            "Finished writing image to file store".log(.Information)
            return path.path
        } catch {
            "Failed to write image to file store".log(.Error)
            "Error: \(error.localizedDescription)".log(.Verbose)
            return nil
        }
    }
    
    private static func InitializeFileStore(at directory: String) {
        "Looking for existing folder".log(.Debug)
        if !FileHandler.doesFolderExist(directory) {
            "Creating folder".log(.Debug)
            FileHandler.createDirectory(directory)
        }
    }
    
    private static func SaveImageToPhotoLibrary(image: UIImage) {
        if AssetCollection == nil {
            "Asset collection is nil".log(.Error)
            return
        }
        
        "Saving image to photo library".log(.Debug)
        PHPhotoLibrary.shared().performChanges({
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: AssetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)

        }, completionHandler: nil)
        
        PHPhotoLibrary.shared().performChanges {
            let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: image)
            let assetPlaceHolder = assetChangeRequest.placeholderForCreatedAsset
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: AssetCollection)
            let enumeration: NSArray = [assetPlaceHolder!]
            albumChangeRequest!.addAssets(enumeration)
        } completionHandler: { (success, error) in
            if let error = error {
                "Failed to save image to photo library".log(.Error)
                "Error: \(error.localizedDescription)".log(.Verbose)
            } else if success {
                "Finished saving image to photo library".log(.Information)
            }
        }

    }
    
    private static func InitializePhotoLibrary() {
        "Looking for existing album".log(.Debug)
        if let assetCollection = FetchAssetCollectionForAlbum() {
            AssetCollection = assetCollection
            return
        }

        "Creating Album".log(.Debug)
        PHPhotoLibrary.shared().performChanges({
            PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: AlbumName)
        }, completionHandler: { success, _ in
            if success {
                "Successfully created album".log(.Debug)
                AssetCollection = FetchAssetCollectionForAlbum()
            } else {
                "Failed to create album".log(.Error)
            }
        })
    }
    
    private static func FetchAssetCollectionForAlbum() -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", AlbumName)
        
        let collection = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        
        if let _: AnyObject = collection.firstObject {
            return collection.firstObject
        }
        
        return nil
    }
    
}
