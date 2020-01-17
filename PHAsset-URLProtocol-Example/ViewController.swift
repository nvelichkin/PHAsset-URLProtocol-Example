//
//  ViewController.swift
//  
//
//  Created by Nikita Velichkin on 18/01/2020.
//  Copyright © 2020 Nikita Velichkin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var imageURLs = [URL]()
    private let assetService = AssetService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        fetchImages()
    }

    private func fetchImages() {
        assetService.fetch(width: 1024, height: 1024) { [weak self] images in
            self?.imageURLs = images
            self?.collectionView.reloadData()
        }
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        let screenSize = UIScreen.main.bounds
        
        layout.itemSize = CGSize(width: screenSize.width / 2.5,
                                 height: screenSize.width / 2.5)
        
        layout.minimumLineSpacing = 15
        layout.minimumInteritemSpacing = 10
        
        collectionView.contentInset = .init(top: 15, left: 15, bottom: 15, right: 15)
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        
        ImageCollectionViewCell.register(for: collectionView)
    }
    @IBAction func reloadPageDidPressed(_ sender: Any) {
        fetchImages()
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as! ImageCollectionViewCell
        cell.imageURL = imageURLs[indexPath.row]
        return cell
    }
}

