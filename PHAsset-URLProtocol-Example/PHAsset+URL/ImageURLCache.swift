//
//  ImageURLCache.swift
//  
//
//  Created by Velichkin Nikita on 08/10/2019.
//  Copyright © 2019 Nikita Velichkin. All rights reserved.
//

import Foundation

class ImageURLCache: URLCache {
    static var current = ImageURLCache()
    
    override init() {
        let MB = 1_024 * 1_024
        super.init(memoryCapacity: 2 * MB, diskCapacity: 100 * MB, diskPath: "phAssetURLCache")
    }
    
    private static let accessQueue = DispatchQueue(label: "phAssetURLCache")
    
    public override func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
        return ImageURLCache.accessQueue.sync {
            return super.cachedResponse(for: request)
        }
    }
    
    public override func storeCachedResponse(_ response: CachedURLResponse, for request: URLRequest) {
        ImageURLCache.accessQueue.sync {
            super.storeCachedResponse(response, for: request)
        }
    }
}
