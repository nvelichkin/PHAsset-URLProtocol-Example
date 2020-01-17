//
//  AssetService.swift
//  
//
//  Created by Nikita Velichkin on 18/01/2020.
//  Copyright © 2020 Nikita Velichkin. All rights reserved.
//

import Foundation
import Photos

class AssetService {
    func fetch(width: Int, height: Int, onFetchCompleted: @escaping (([URL]) -> Void)) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        if status != .authorized {
            requestAuthorization { [weak self] isAuthorized in
                guard isAuthorized else { return }
                self?.fetch(width: width, height: height, onFetchCompleted: onFetchCompleted)
            }
        }
        
        
        let imageURLs = (try? getPhotos(width: width, height: height)) ?? []
        onFetchCompleted(imageURLs)
    }
}

extension AssetService {
    private func requestAuthorization(_ isAuthorized: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { isAuthorized($0 == .authorized) }
    }
    
    private func getAssets() -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false),
                                   NSSortDescriptor(key: "modificationDate", ascending: true)]
        
        return PHAsset.fetchAssets(with: options)
    }
    
    private func getPhotos(width: Int, height: Int) throws -> [URL] {
        let urlBuilder = PHAssetURLBuilder()
        let fetchResults = getAssets()
        
        return (0..<fetchResults.count)
            .map(fetchResults.object(at:))
            .compactMap { try? urlBuilder.buildURL(asset: $0, width: width, height: height) }
    }
}

extension AssetService {
    enum Error: Swift.Error {
        case denied
    }
}
