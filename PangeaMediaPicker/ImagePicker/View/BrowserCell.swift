//
//  BrowserCell.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/31.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit

class BrowserCell: UICollectionViewCell {
    // Animation time
    let animationTime = 0.5
    @IBOutlet var bigImage: UIImageView!

    var firstIndex:IndexPath = []

    internal func setImageWithImage(_ image: UIImage, placeholderImage: UIImage, defaultImage: UIImage) {
        self.setBigImageTheSizeOfThe(image, defaultImage:defaultImage)
    }

    func setBigImageTheSizeOfThe(_ bImage: UIImage, defaultImage: UIImage) {
        self.bigImage.image = bImage
    }

    func indexPath() -> IndexPath? {
         if let collectionView = self.superview as? UICollectionView {
            let indexPath = collectionView.indexPath(for: self)
            return indexPath
        } else {
            return nil
        }
    }
}
