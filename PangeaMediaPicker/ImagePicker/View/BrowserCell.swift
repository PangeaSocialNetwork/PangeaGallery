//
//  BrowserCell.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/31.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit

class BrowserCell: UICollectionViewCell, UIScrollViewDelegate, UIActionSheetDelegate {
    static let cellId = "HJCell"
    var bigImage: UIImageView!
    var bottomScroll: UIScrollView!
    var bottomView: UIView!
    override init(frame: CGRect) {
        super.init(frame: frame)
        creatUI()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func creatUI() {
        bottomScroll = UIScrollView.init(frame: CGRect(x: 0,
                                                       y: 0,
                                                       width: screenWidth,
                                                       height: screenHeight))
        bottomScroll.delegate = self
        bottomScroll.maximumZoomScale = 2.0
        bottomScroll.minimumZoomScale = 1.0
        bottomScroll.backgroundColor = viewTheBackgroundColor
        bigImage
            = UIImageView.init()
        bigImage.isUserInteractionEnabled = true
        bottomScroll.addSubview(bigImage)
        self.addSubview(bottomScroll)
        let singleTap = UITapGestureRecognizer.init(target: self,
                                                    action: #selector(self.oneTouch(_:)))
        let doubleTap = UITapGestureRecognizer.init(target: self,
                                                    action: #selector(self.twoTouch(_:)))
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        bottomScroll.addGestureRecognizer(singleTap)
        bottomScroll.addGestureRecognizer(doubleTap)
            }
    internal func setImageWithImage(_ image: UIImage, placeholderImage: UIImage, defaultImage: UIImage) {
        self.setBigImageTheSizeOfThe(image, defaultImage:defaultImage)
    }
    func setBigImageTheSizeOfThe(_ bImage: UIImage, defaultImage: UIImage) {
                self.bottomScroll.contentOffset = CGPoint.zero
        self.bottomScroll.contentSize = CGSize.zero
        self.bottomScroll.contentInset = UIEdgeInsets.zero
        self.bottomScroll.zoomScale = 1
        var heightS = (bImage.size.height)/(bImage.size.width)*self.bottomScroll.frame.size.width
        var widthS = (bImage.size.width)/(bImage.size.height)*heightS
        if heightS.isNaN || widthS.isNaN {
            let image = defaultImage
            heightS = (image.size.height)/(image.size.width)*self.bottomScroll.frame.size.width
            widthS = (image.size.width)/(image.size.height)*heightS
            if heightS.isNaN || widthS.isNaN {
                let imageI = getColorImageWithColor()
                heightS = (imageI.size.height)/(imageI.size.width)*self.bottomScroll.frame.size.width
                widthS = (imageI.size.width)/(imageI.size.height)*heightS
                self.bigImage.image = imageI
            } else {
                heightS = (image.size.height)/(image.size.width)*self.bottomScroll.frame.size.width
                widthS = (image.size.width)/(image.size.height)*heightS
                self.bigImage.image = image
            }
        }
        self.bigImage.frame = CGRect(x: 0, y: 0, width: widthS, height: heightS)
        if heightS > screenHeight {
                        self.bottomScroll.contentInset = UIEdgeInsets.zero
            self.bottomScroll.contentSize = CGSize(width: widthS, height: heightS)
        } else {
            self.bottomScroll.contentInset.top = (self.bottomScroll.frame.size.height - heightS)/2
        }
        self.bigImage.image = bImage
    }
    func oneTouch(_ sender: UITapGestureRecognizer) {
        let  tempView = UIImageView.init()
        var ima = UIImage()
        if let imaV = (sender.view?.subviews[0] as? UIImageView)?.image {
            ima = imaV
            tempView.image = ima
        }
        self.superview?.superview?.addSubview(tempView)
        var ve = UIView()
        if self.bottomView.isKind(of: UICollectionView.classForCoder()) {
            if let view = self.bottomView as? UICollectionView {
                let path = IndexPath.init(row: self.indexPath().row, section: 0)
                ve = view.cellForItem(at: path)!
            }
        } else {
            ve = self.bottomView.subviews[self.indexPath().row]
        }/*
        if ve == nil {
            UIView.animate(withDuration: animationTime, animations: {
                self.superCollectionView().alpha = 0
                self.superview?.superview?.alpha = 0
            }, completion: { (_) in
                self.superview?.superview?.removeFromSuperview()
            })
            return
        }*/
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
        self.superCollectionView()?.alpha = 0.5
        self.superview?.superview?.backgroundColor = UIColor.clear
        UIView.animate(withDuration: animationTime, animations: {
            self.superCollectionView()?.alpha = 0
            tempView.center = poin
            tempView.bounds = rect
        }, completion: { (_) in
            self.superview?.superview?.removeFromSuperview()
        })
    }
    func twoTouch(_ sender: UITapGestureRecognizer) {
        let touchPoint = sender.location(in: sender.view)
        if let scroll =  sender.view as? UIScrollView {
            let imageView = scroll.subviews[0]
            let zs = scroll.zoomScale
            UIView.animate(withDuration: 0.5, animations: {
                scroll.zoomScale = (zs == 1.0) ? 2.0 : 0.0
            })
            UIView.animate(withDuration: 0.5, animations: {
                if scroll.zoomScale==2.0 {
                    let rectHeight = (self.frame.size.height)/scroll.zoomScale
                    let rectWidth = self.frame.size.width/scroll.zoomScale
                    let rectX = touchPoint.x-rectWidth/2.0
                    let rectY = touchPoint.y-rectHeight/2.0
                    let zoomRect = CGRect(x: rectX, y: rectY, width: rectWidth, height: rectHeight)
                    scroll.zoom(to: zoomRect, animated: false)
                    if imageView.frame.size.height > screenHeight {
                        self.bottomScroll.contentInset = UIEdgeInsets.zero
                    } else {
                        self.bottomScroll.contentInset.top =
                            (self.bottomScroll.frame.size.height - (imageView.frame.size.height))/2
                    }
                } else {
                    if imageView.frame.size.height > screenHeight {
                        self.bottomScroll.contentInset = UIEdgeInsets.zero
                    } else {
                        self.bottomScroll.contentInset.top =
                            (self.bottomScroll.frame.size.height - (imageView.frame.size.height))/2
                    }
                }
            })
        }
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let image = scrollView.subviews[0]
        if image.frame.size.height > screenHeight {
            UIView.animate(withDuration: 0.2, animations: {
                self.bottomScroll.contentInset = UIEdgeInsets.zero
            })
        } else {
            UIView.animate(withDuration: 0.2, animations: {
                self.bottomScroll.contentInset.top =
                    (self.bottomScroll.frame.size.height - image.frame.size.height)/2
            })
        }
    }
    func indexPath() -> IndexPath {
        let collectionView = self.superCollectionView
        let indexPath = collectionView()?.indexPath(for: self)
        return indexPath!
    }
    func superCollectionView() -> UICollectionView? {
        if let collection = self.findSuperViewWithClass(UICollectionView.classForCoder()) as? UICollectionView {
            return collection
        } else {
            return nil
        }
    }
    func findSuperViewWithClass(_ superViewClass: AnyClass) -> UIView {
        var superView = self.superview
        var foundSuperView: UIView?
        while superView != nil && foundSuperView == nil {
            if (superView?.isKind(of: superViewClass)) != nil {
                foundSuperView = superView
            } else {
                superView = superView!.superview
            }
        }
        return foundSuperView!
    }
}
