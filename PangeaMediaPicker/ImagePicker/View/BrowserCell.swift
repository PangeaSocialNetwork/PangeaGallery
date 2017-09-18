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
    @IBOutlet var bottomScroll: UIScrollView!
    @IBOutlet var bigImage: UIImageView!
    var bottomView: UIView!
    var firstIndex:IndexPath = []

    override func awakeFromNib() {
        creatUI()
    }

    func creatUI() {
        let singleTap = UITapGestureRecognizer.init(target: self,
                                                    action: #selector(self.oneTouch(_:)))
        bottomScroll.addGestureRecognizer(singleTap)
            }

    internal func setImageWithImage(_ image: UIImage, placeholderImage: UIImage, defaultImage: UIImage) {
        self.setBigImageTheSizeOfThe(image, defaultImage:defaultImage)
    }

    func setBigImageTheSizeOfThe(_ bImage: UIImage, defaultImage: UIImage) {
                self.bottomScroll.contentOffset = CGPoint.zero
        self.bottomScroll.contentSize = CGSize.zero
        self.bottomScroll.contentInset = UIEdgeInsets.zero
        self.bottomScroll.zoomScale = 1
        let heightS = (bImage.size.height)/(bImage.size.width)*self.bottomScroll.frame.size.width
        let widthS = (bImage.size.width)/(bImage.size.height)*heightS
        self.bigImage.bounds = CGRect(x: 0, y: 0, width: widthS, height: heightS)
        self.bigImage.center = bottomScroll.center
        self.bigImage.image = bImage
    }

    func oneTouch(_ sender: UITapGestureRecognizer) {
        let  tempView = UIImageView.init()
        var ima = UIImage()
        if let imaV = (sender.view?.subviews[0] as? UIImageView)?.image {
            ima = imaV
            tempView.image = bigImage.image
        }
        self.superview?.superview?.addSubview(tempView)
        var ve = UIView()
        if self.bottomView.isKind(of: UICollectionView.classForCoder()),let indexRow = self.indexPath()?.row {
            let path = IndexPath.init(row: indexRow, section: 0)
            if let view = self.bottomView as? UICollectionView,let currView = view.cellForItem(at: path) {
                ve = currView
            } else {
                 tempView.image = ima
            }
        } else {
            if let indexRow = self.indexPath()?.row {
                 ve = self.bottomView.subviews[indexRow]
            }
        }
        let rect = self.bottomView.convert(ve.frame, to: self)
        let poin = self.bottomView.convert(ve.center, to: self)
        let height = ima.size.height
        let width = ima.size.width
        let heightS = height/width*screenWidth
        let widthS = width/height*heightS
        tempView.frame = CGRect(x: 0, y: 0, width: widthS, height: heightS)

        if height < screenHeight {
            tempView.center = (self.superview?.superview?.center)!
        }
        self.superview?.alpha = 0.5
        self.superview?.superview?.backgroundColor = UIColor.clear
        UIView.animate(withDuration: animationTime, animations: {
            self.superview?.alpha = 0
            tempView.center = poin
            tempView.bounds = rect
        }, completion: { (_) in
            self.superview?.superview?.removeFromSuperview()
        })
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
