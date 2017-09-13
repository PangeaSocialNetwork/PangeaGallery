//
//  ImageBrowser.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/28.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit
import Photos

/*
 *Get Gao Qinghe thumbnail images agent
 */

protocol  ImageBrowserDelegate: NSObjectProtocol {
    func getTheThumbnailImage(_ indexRow: Int) -> UIImage
    func selectedImageAction(indexItme: IndexPath) -> String?
    func imageSelectStatus(index: Int) -> String?
}

class ImageBrowser: UIView, UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumnailSize = CGSize()
    weak var  delegate: ImageBrowserDelegate?
    var bottomView: UIView!
    var isShow: Bool!
    var defaultImage: UIImage!
    var indexImage: Int!
    var number: IndexPath!
    var arrayImage: PHFetchResult<PHAsset>!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var bottomLeftButton: UIImageView!
    @IBOutlet var bottomRightButton: UIButton!
    override func awakeFromNib() {
        creatUI()
    }
    @IBAction func selcetAction(_ sender: UIButton) {
        if let selectStr =  self.delegate?.selectedImageAction(indexItme:number) {
            bottomRightButton.setTitle(selectStr, for: .selected)
            bottomRightButton.isSelected = true
        } else {
            bottomRightButton.isSelected = false
        }
    }
}
extension ImageBrowser {
    func  creatUI() {
        isShow = false
        creatCollectionView()
    }
    func  creatCollectionView() {
        let fowLayout = UICollectionViewFlowLayout.init()
        fowLayout.minimumLineSpacing = 0
        fowLayout.scrollDirection = .horizontal
        fowLayout.itemSize = CGSize(width: screenWidth,
                                    height: screenHeight)
        collectionView.setCollectionViewLayout(fowLayout, animated: true)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib.init(nibName: "BrowserCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "cellId")
        let singleTap = UITapGestureRecognizer.init(target: self,
                                                    action: #selector(BrowserCell.oneTouch(_:)))
        singleTap.numberOfTapsRequired = 1
        bottomLeftButton.addGestureRecognizer(singleTap)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if isShow == false {
            self.collectionView.contentOffset =
                CGPoint(x: self.frame.size.width  *  CGFloat(self.indexImage), y: 0)
            isShow = true
            let  tempView = UIImageView.init()
            var ima = UIImage.init()
            self.addSubview(tempView)
            if (self.delegate?.getTheThumbnailImage(self.indexImage)) != nil {
                ima = (self.delegate?.getTheThumbnailImage(self.indexImage))!
            } else {
                if self.defaultImage != nil {
                    ima = self.defaultImage!
                } else {
                    ima = getColorImageWithColor()
                }
            }
            tempView.image = ima
            var ve = UIView()
            if self.bottomView.isKind(of: UICollectionView.classForCoder()) {
                if let view = self.bottomView as? UICollectionView {
                    let path = IndexPath.init(row: self.indexImage, section: 0)
                    ve = view.cellForItem(at: path)!
                }
            } else {
                ve = self.bottomView.subviews[indexImage]
            }
            let rect = self.bottomView.convert(ve.frame, to: self)
            tempView.frame = rect
            self.collectionView.isHidden = true
            self.collectionView.alpha = 1
            let heightS = (ima.size.height)/(ima.size.width)*screenWidth
            let widthS = (ima.size.width)/(ima.size.height)*heightS
            UIView.animate(withDuration: animationTime, animations: {
                tempView.frame = CGRect(x: 0, y: 0, width: widthS, height: heightS)
                if heightS < screenHeight {
                    tempView.center = self.center
                }
            }, completion: { (_) in
                tempView.removeFromSuperview()
                self.collectionView.isHidden = false
            })
        }
    }
    internal func show() {
        if let selectStatus = self.delegate?.imageSelectStatus(index: indexImage) {
            self.bottomRightButton.isSelected = true
            self.bottomRightButton.setTitle(selectStatus, for: .selected)
        } else {
            self.bottomRightButton.isSelected = false
        }
        let window = UIApplication.shared.keyWindow
        self.frame = (window?.bounds)!
        window?.addSubview(self)
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        if let browserCell = cell as? BrowserCell {
            browserCell.bottomView = self.bottomView
            if (self.delegate?.getTheThumbnailImage(indexPath.row)) != nil {
                let asset = arrayImage.object(at: indexPath.item)
                thumnailSize = CGSize(width: screenWidth * UIScreen.main.scale,
                                      height: screenWidth * UIScreen.main.scale)
                imageManager.requestImage(for: asset,
                                          targetSize: thumnailSize,
                                          contentMode: .aspectFill,
                                          options: nil) { img, _ in
                                            browserCell.setImageWithImage(img!,
                                                                          placeholderImage: self.defaultImage,
                                                                          defaultImage: self.defaultImage)
                }
            } else {
                if self.defaultImage == nil {
                    self.defaultImage = UIImage.init()
                }
                let asset = arrayImage.object(at: indexPath.item)
                thumnailSize = CGSize(width: screenWidth * UIScreen.main.scale,
                                      height: screenWidth * UIScreen.main.scale)
                imageManager.requestImage(for: asset, targetSize: thumnailSize,
                                          contentMode: .aspectFill, options: nil) { img, _ in
                                            browserCell.setImageWithImage(img!,
                                                                          placeholderImage: self.defaultImage,
                                                                          defaultImage: self.defaultImage)
                }
            }
            return browserCell
        } else {
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayImage.count
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        let firstIndexPath = self.collectionView.indexPathsForVisibleItems.first
        indexImage = firstIndexPath?.row
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        number = self.collectionView.indexPathForItem(at: self.collectionView.contentOffset)
        if let itemNumber = number?.item, let selectStatus = self.delegate?.imageSelectStatus(index: itemNumber) {
            self.bottomRightButton.isSelected = true
            self.bottomRightButton.setTitle(selectStatus, for: .selected)
        } else {
            self.bottomRightButton.isSelected = false
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }
}
// The Tools Tools
import Foundation
// The screen height
let screenHeight = UIScreen.main.bounds.size.height
// The width of the screen
let screenWidth = UIScreen.main.bounds.size.width
// Animation time
let animationTime = 0.5
// The default color to get and set background image
func getColorImageWithColor() -> (UIImage) {
    let color = UIColor.brown
    let rect = CGRect(x: 0, y: 0, width: screenWidth, height: 200)
    UIGraphicsBeginImageContext(rect.size)
    let context = UIGraphicsGetCurrentContext()
    context!.setFillColor(color.cgColor)
    context!.fill(rect)
    let img = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return img!
}
