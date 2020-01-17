//
//  PHAssetURLBuilder.swift
//  Go Book
//
//  Created by Velichkin Nikita on 08/10/2019.
//  Copyright © 2019 Bytepace. All rights reserved.
//

import Foundation
import Photos

class PHAssetURLBuilder {
    
    private enum Key: String {
        case id
        case width
        case height
    }
    
    func buildURL(asset: PHAsset, width: Int, height: Int) throws -> URL {
        var components = URLComponents()
        components.scheme = phAssetSchemeName
        components.queryItems = [
            item(key: .id, value: asset.localIdentifier),
            item(key: .width, value: String(width)),
            item(key: .height, value: String(height))
        ]
        
        guard let url = components.url else {
            throw ImageURLProtocol.Error.badURL
        }
        
        return url
    }
    
    static func fetchParams(queryItems: [URLQueryItem]) -> (id: String, width: String, height: String) {
        var id = ""
        var width = ""
        var height = ""
        
        queryItems.reduce(()) { prevResult, queryItem in
            guard let key = Key(rawValue: queryItem.name), let value = queryItem.value else { return }
            switch key {
            case .id:
                id = value
            case .width:
                width = value
            case .height:
                height = value
            }
        }
        
        return (id, width, height)
    }
    
    private func item(key: Key, value: String) -> URLQueryItem {
        return URLQueryItem(name: key.rawValue, value: value)
    }
}
