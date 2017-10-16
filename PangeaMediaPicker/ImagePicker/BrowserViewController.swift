//
//  BrowserViewController.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/9/26.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit
import Photos
protocol  ImageBrowserDelegate: NSObjectProtocol {
    func getTheThumbnailImage(_ indexRow: Int) -> UIImage
    func selectedImageAction(indexItme: IndexPath) -> String?
    func imageSelectStatus(index: Int) -> String?
}
class BrowserViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout {
    @IBOutlet var mainCollectionView: UICollectionView!
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumnailSize = CGSize()
    // The screen height
    var screenHeight = UIScreen.main.bounds.size.height
    // The width of the screen
    var screenWidth = UIScreen.main.bounds.size.width
    // Animation time
    let animationTime = 0.5
    weak var  delegate: ImageBrowserDelegate?
    var bottomView: UIView!
    var isShow = false
    var defaultImage: UIImage!
    var indexImage: Int!
    var number: IndexPath!
    var arrayImage: PHFetchResult<PHAsset>!
    @IBOutlet var bottomLeftButton: UIButton!
    @IBOutlet var bottomRightButton: UIButton!
    @IBAction func selcetAction(_ sender: UIButton) {
        if let selectStr =  self.delegate?.selectedImageAction(indexItme:number) {
            bottomRightButton.setTitle(selectStr, for: .selected)
            bottomRightButton.isSelected = true
        } else {
            bottomRightButton.isSelected = false
        }
    }
    @IBAction func cancelAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if screenWidth != UIScreen.main.bounds.width {
            screenWidth = UIScreen.main.bounds.width
            screenHeight = UIScreen.main.bounds.height
            isShow = false
            creatCollectionView()
        }
        if isShow == false {
            self.mainCollectionView.contentOffset =
                CGPoint(x: screenWidth  *  CGFloat(self.indexImage), y: 0)
            isShow = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        creatCollectionView()
    }

    deinit {
        self.mainCollectionView = nil
    }
}
extension BrowserViewController {

    func  creatCollectionView() {
        let fowLayout = UICollectionViewFlowLayout()
        fowLayout.minimumLineSpacing = 0
        fowLayout.minimumInteritemSpacing = 0
        fowLayout.scrollDirection = .horizontal
        fowLayout.itemSize = CGSize(width: screenWidth,
                                    height: screenHeight)
        mainCollectionView.setCollectionViewLayout(fowLayout, animated: false)
        mainCollectionView.isPagingEnabled = true
        mainCollectionView.delegate = self
        mainCollectionView.dataSource = self
        if let selectStatus = self.delegate?.imageSelectStatus(index: indexImage) {
            self.bottomRightButton.isSelected = true
            self.bottomRightButton.setTitle(selectStatus, for: .selected)
        } else {
            self.bottomRightButton.isSelected = false
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        if let browserCell = cell as? BrowserCell {
            thumnailSize = CGSize(width: screenWidth * UIScreen.main.scale,
                                  height: screenWidth * UIScreen.main.scale)
            if (self.delegate?.getTheThumbnailImage(indexPath.row)) != nil {
                let asset = arrayImage.object(at: indexPath.item)
                let options = PHImageRequestOptions()
                options.isNetworkAccessAllowed = true
                imageManager.requestImage(for: asset,
                                          targetSize: thumnailSize,
                                          contentMode: .aspectFit,
                                          options: options) { img, _ in
                                            browserCell.setImageWithImage(img!,
                                                                          placeholderImage: self.defaultImage,
                                                                          defaultImage: self.defaultImage)
                }
            } else {
                if self.defaultImage == nil {
                    self.defaultImage = UIImage()
                }
                let asset = arrayImage.object(at: indexPath.item)
                imageManager.requestImage(for: asset, targetSize: thumnailSize,
                                          contentMode: .aspectFit, options: nil) { img, _ in
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
        let firstIndexPath = self.mainCollectionView.indexPathsForVisibleItems.first
        indexImage = firstIndexPath?.row
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        number = self.mainCollectionView.indexPathsForVisibleItems.first
        if let itemNumber = number?.item, let selectStatus = self.delegate?.imageSelectStatus(index: itemNumber) {
            self.bottomRightButton.isSelected = true
            self.bottomRightButton.setTitle(selectStatus, for: .selected)
        } else {
            self.bottomRightButton.isSelected = false
        }
    }
}
