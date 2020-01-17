//
//  URL+ImageDownloader.swift
//  
//
//  Created by Nikita Velichkin on 18/01/2020.
//  Copyright © 2020 Nikita Velichkin. All rights reserved.
//
import Foundation

fileprivate let config: URLSessionConfiguration = {
    let config = URLSessionConfiguration.ephemeral
    config.urlCache = ImageURLCache.current
    config.protocolClasses = [ImageURLProtocol.self]
    return config
}()

fileprivate let session = URLSession(
    configuration: config,
    delegate: nil,
    delegateQueue: nil
)

extension URL {
    func downloadImage(completion: @escaping (Data?) -> Void) {
        let request = URLRequest(url: self, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        request.downloadImage(completion: completion)
    }
}

private extension URLRequest {
    func downloadImage(completion: @escaping (Data?) -> Void) {
        let urlSession = url?.scheme == phAssetSchemeName ? session : URLSession.shared
        urlSession.dataTask(with: self) { (data, response, error) in
            if let error = error { print(error.localizedDescription) }
            guard let response = response,
                let responseURL = response.url,
                let mimeType = response.mimeType else { return }
            
            #if DEBUG
            if ImageURLCache.shared.cachedResponse(for: self) == nil {
                print("Return cached asset with URL \(responseURL)")
            } else {
                print("Download asset from URL \(responseURL)")
            }
            #endif
            
            guard mimeType.contains("image") else { return }
            completion(data)
        }.resume()
    }
}
