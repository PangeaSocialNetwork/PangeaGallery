//
//  BrowserCell.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/31.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit

class BrowserCell: UICollectionViewCell {
    let screenHeight = UIScreen.main.bounds.size.height
    // The width of the screen
    let screenWidth = UIScreen.main.bounds.size.width
    // Animation time
    let animationTime = 0.5
    @IBOutlet var bigImage: UIImageView!

    var firstIndex:IndexPath = []

    internal func setImageWithImage(_ image: UIImage, placeholderImage: UIImage, defaultImage: UIImage) {
        self.setBigImageTheSizeOfThe(image, defaultImage:defaultImage)
    }

    func setBigImageTheSizeOfThe(_ bImage: UIImage, defaultImage: UIImage) {
//                self.bottomScroll.contentOffset = CGPoint.zero
//        self.bottomScroll.contentSize = CGSize.zero
//        self.bottomScroll.contentInset = UIEdgeInsets.zero
//        self.bottomScroll.zoomScale = 1
//        let heightS = (bImage.size.height)/(bImage.size.width)*screenWidth
//        let widthS = (bImage.size.width)/(bImage.size.height)*screenHeight
//        self.bigImage.bounds = CGRect(x: 0, y: 0, width: widthS, height: heightS)
//        self.bigImage.center = self.center
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
