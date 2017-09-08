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
 *获取高清和缩略图图片代理
 *Get Gao Qinghe thumbnail images agent
 */

protocol  ImageBrowserDelegate: NSObjectProtocol {
    ///  获取缩略图图片 && Getting thumbnail images
    ///  - parameter indexRow: 当前是第几个cell && The current is which a cell
    ///  - returns: 获取的缩略图图片 && Getting thumbnail images
    func getTheThumbnailImage(_ indexRow: Int) -> UIImage
    func selectedImageAction(indexItme: IndexPath) -> String?
    func imageSelectStatus(index: Int) -> String?
}

class ImageBrowser: UIView, UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumnailSize = CGSize()

    /// 获取高清和缩略图图片代理 && Get Gao Qinghe thumbnail images agent
    weak var  delegate: ImageBrowserDelegate?
        /// 承载view  父视图view && Bearing the view parent view view
    var bottomView: UIView!
    /// 是否让走预加载图片 && If let go preload picture
    var isShow: Bool!
    /* 如果没有缩略图则显示这张图片 && If there is no thumbnail drawings show the picture
     如果这张图片也没有则什么也不显示 && If they aren't in the picture is what also don't show
     */
    var defaultImage: UIImage!
    /// 当前显示的是第几张图片 && How many pictures of the currently displayed
    var indexImage: Int!
    var number: IndexPath!
    /// 高清图片数组 && High-resolution image array
    var arrayImage: PHFetchResult<PHAsset>!
    /// 图片展示View && Pictures show the View
    var collectionView: UICollectionView!
    var bottomLeftButton: UIImageView!
    var bottomRightButton: UIButton!
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatUI()
    }
        required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
extension ImageBrowser {
    func  creatUI() {
        self.backgroundColor = viewTheBackgroundColor
        isShow = false
        creatCollectionView()
        creatBottomUI()
    }
    func creatBottomUI() {
        bottomLeftButton = UIImageView(frame: CGRect(x: 10, y: screenHeight-60, width: 45, height: 45))
        bottomLeftButton.image  = #imageLiteral(resourceName: "btn_CircleCancel")
        let singleTap = UITapGestureRecognizer.init(target: self,
                                                    action: #selector(BrowserCell.oneTouch(_:)))
        singleTap.numberOfTapsRequired = 1
        bottomLeftButton.addGestureRecognizer(singleTap)
        self.addSubview(bottomLeftButton)
                bottomRightButton = UIButton.init(frame: CGRect.init(x: screenWidth-60,
                                                                     y: screenHeight-60, width: 45, height: 45))
        bottomRightButton.addTarget(self, action: #selector(selcetAction), for: .touchUpInside)
        bottomRightButton.setBackgroundImage(#imageLiteral(resourceName: "btn_CircleCheck"), for: .normal)
        bottomRightButton.setBackgroundImage(#imageLiteral(resourceName: "l_selected"), for: .selected)
        self.addSubview(bottomRightButton)
    }
        func selcetAction() {
       if let selectStr =  self.delegate?.selectedImageAction(indexItme:number) {
            bottomRightButton.setTitle(selectStr, for: .selected)
            bottomRightButton.isSelected = true
       } else {
            bottomRightButton.isSelected = false
        }
    }
    func  creatCollectionView() {
        let fowLayout = UICollectionViewFlowLayout.init()
        fowLayout.minimumLineSpacing = 0
        fowLayout.scrollDirection = .horizontal
        fowLayout.itemSize = CGSize(width: screenWidth + imageInterval,
                                        height: screenHeight)
        collectionView = UICollectionView.init(frame: CGRect(x: 0,
            y: 0,
            width: screenWidth + imageInterval,
            height: screenHeight),
                                               collectionViewLayout: fowLayout)

        collectionView.allowsMultipleSelection = true
        collectionView.register(BrowserCell.self, forCellWithReuseIdentifier: "cellId")
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alpha = 0
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.backgroundColor = viewTheBackgroundColor
        self.addSubview(collectionView)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        if isShow == false {
            self.collectionView.contentOffset =
                CGPoint(x: (self.frame.size.width + imageInterval) *  CGFloat(self.indexImage), y: 0)
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
        if let selectStatus = self.delegate?.imageSelectStatus(index: number.item) {
            self.bottomRightButton.isSelected = true
            self.bottomRightButton.setTitle(selectStatus, for: .selected)
        } else {
            self.bottomRightButton.isSelected = false
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    }
}
/// Tools 工具类 && The Tools Tools
import Foundation
///屏幕高度 && The screen height
let screenHeight = UIScreen.main.bounds.size.height

///屏幕宽度 && The width of the screen
let screenWidth = UIScreen.main.bounds.size.width

///图片与图片之间的间隔 && The interval between images and pictures
let imageInterval = CGFloat(20)

///视图的背景颜色 && The background color of the view
let viewTheBackgroundColor = UIColor.black

/// 动画时间 && Animation time
let animationTime = 0.5

/// 默认背景图片颜色获取和设置 && The default color to get and set background image
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
