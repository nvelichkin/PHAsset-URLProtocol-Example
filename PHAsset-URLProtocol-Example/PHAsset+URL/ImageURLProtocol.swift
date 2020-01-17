//
//  ImageURLProtocol.swift
//  
//
//  Created by Velichkin Nikita on 08/10/2019.
//  Copyright © 2019 Nikita Velichkin. All rights reserved.
//

import Foundation
import Photos

let phAssetSchemeName = "nvelichkin"

/// Example url: nvelichkin://?id=123&width=1920&height=1280
class ImageURLProtocol: URLProtocol {
    
    enum Error: Swift.Error {
        case badURL
        case badImage
        case assetNotFound
    }
    
    private var thread: Thread!
    private var isCancelled: Bool = false
    
    override class func canInit(with request: URLRequest) -> Bool {
        return request.url?.scheme == phAssetSchemeName
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let url = request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems
            else {
                fail(with: .badURL)
                return
        }
        
        thread = Thread.current
        
        if let cachedResponse = cachedResponse {
            complete(with: cachedResponse)
        } else {
            load(with: queryItems)
        }
    }
    
    override func stopLoading() {
        isCancelled = true
    }
    
    func load(with queryItems: [URLQueryItem]) {
        let (id, width, height) = PHAssetURLBuilder.fetchParams(queryItems: queryItems)
        let imageSize = CGSize(width: Int(width) ?? 150,
                               height: Int(height) ?? 150)
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        
        guard let asset = PHAsset.fetchAssets(withLocalIdentifiers: [id], options: nil).firstObject else {
            fail(with: .assetNotFound)
            return
        }
        
        manager.requestImage(for: asset, targetSize: imageSize, contentMode: .aspectFill, options: options) { image, _ in
            guard let imageData = image?.jpegData(compressionQuality: 1.0) else {
                self.fail(with: .badImage)
                return
            }
            
            self.complete(with: imageData)
        }
    }
}

// MARK: Completion

extension ImageURLProtocol {
    func fail(with error: Error) {
        client?.urlProtocol(self, didFailWithError: error)
    }
    
    func complete(with cachedResponse: CachedURLResponse) {
        complete(with: cachedResponse.data)
    }
    
    func complete(with data: Data) {
        guard let url = request.url, let client = client else {
            return
        }
        
        let response = URLResponse(
            url: url,
            mimeType: "image/jpeg",
            expectedContentLength: data.count,
            textEncodingName: nil
        )
        
        client.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        client.urlProtocol(self, didLoad: data)
        client.urlProtocolDidFinishLoading(self)
    }
}
