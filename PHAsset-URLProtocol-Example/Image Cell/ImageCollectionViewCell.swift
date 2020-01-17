//
//  ImageCollectionViewCell.swift
//  
//
//  Created by Nikita Velichkin on 18/01/2020.
//  Copyright © 2020 Nikita Velichkin. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    static var identifier: String { return String(describing: Self.self) }
    
    @IBOutlet weak var imageView: UIImageView!
    
    var imageURL: URL! { didSet { downloadImage() }}

    static func register(for collectionView: UICollectionView) {
        let nib = UINib(nibName: identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: identifier)
    }
    
    func downloadImage() {
        imageURL.downloadImage { [weak self] data in
            guard let data = data else { return }
            DispatchQueue.main.async {
                self?.imageView.image = UIImage(data: data)
            }
        }
    }
}
