//
//  BrowserCell.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/31.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit

class BrowserCell: UICollectionViewCell,UIScrollViewDelegate,UIActionSheetDelegate {
    static let cellId = "HJCell"
    var BigImage: UIImageView!
    var BottomScroll: UIScrollView!
    var bottomView:UIView!
    override init(frame: CGRect) {

        super.init(frame: frame)
        creatUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func creatUI(){
        BottomScroll = UIScrollView.init(frame: CGRect(x: 0,
                                                       y: 0,
                                                       width: ScreenWidth,
                                                       height: ScreenHeight))
        
        BottomScroll.delegate = self
        BottomScroll.maximumZoomScale = 2.0;
        BottomScroll.minimumZoomScale = 1.0;
        BottomScroll.backgroundColor = viewTheBackgroundColor
        BigImage = UIImageView.init()
        BigImage.isUserInteractionEnabled = true
        BottomScroll.addSubview(BigImage)
        self.addSubview(BottomScroll)
        let singleTap = UITapGestureRecognizer.init(target: self,
                                                    action: #selector(self.oneTouch(_:)))
        let doubleTap = UITapGestureRecognizer.init(target: self,
                                                    action: #selector(self.twoTouch(_:)))
        
        doubleTap.numberOfTapsRequired = 2
        singleTap.require(toFail: doubleTap)
        BottomScroll.addGestureRecognizer(singleTap)
        BottomScroll.addGestureRecognizer(doubleTap)
        

        
        
    }
    
    
    internal func setImageWithImage(_ image:UIImage, placeholderImage:UIImage, defaultImage:UIImage){
        self.setBigImageTheSizeOfThe(image, defaultImage:defaultImage)
    }
    
    func setBigImageTheSizeOfThe(_ bImage:UIImage, defaultImage:UIImage){
        
        self.BottomScroll.contentOffset = CGPoint.zero
        self.BottomScroll.contentSize = CGSize.zero
        self.BottomScroll.contentInset = UIEdgeInsets.zero
        self.BottomScroll.zoomScale = 1
        var heightS = (bImage.size.height)/(bImage.size.width)*self.BottomScroll.frame.size.width
        var widthS = (bImage.size.width)/(bImage.size.height)*heightS
        
        if heightS.isNaN || widthS.isNaN {
            let image = defaultImage
            heightS = (image.size.height)/(image.size.width)*self.BottomScroll.frame.size.width
            widthS = (image.size.width)/(image.size.height)*heightS
            
            if heightS.isNaN || widthS.isNaN {
                let imageI = getColorImageWithColor()
                heightS = (imageI.size.height)/(imageI.size.width)*self.BottomScroll.frame.size.width
                widthS = (imageI.size.width)/(imageI.size.height)*heightS
                self.BigImage.image = imageI
            }else{
                
                heightS = (image.size.height)/(image.size.width)*self.BottomScroll.frame.size.width
                widthS = (image.size.width)/(image.size.height)*heightS
                self.BigImage.image = image
            }
            
        }
        
        self.BigImage.frame = CGRect(x: 0, y: 0, width: widthS, height: heightS)
        
        if heightS > ScreenHeight {
            
            self.BottomScroll.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            
            self.BottomScroll.contentSize = CGSize(width: widthS, height: heightS)
            
        }else{
            
            self.BottomScroll.contentInset = UIEdgeInsetsMake((self.BottomScroll.frame.size.height - heightS)/2, 0, 0, 0)
            
        }
        self.BigImage.image = bImage
    }
    
    func oneTouch(_ sender: UITapGestureRecognizer){
        
        let  tempView = UIImageView.init()
        let imaV = sender.view?.subviews[0] as! UIImageView
        let ima = imaV.image
        tempView.image = ima
        self.superview?.superview?.addSubview(tempView)
        let ve:UIView!
        
        if self.bottomView.isKind(of: UICollectionView.classForCoder()) {
            let view = self.bottomView as! UICollectionView
            let path = IndexPath.init(row: self.indexPath().row, section: 0)
            ve = view.cellForItem(at: path)
            
        }else{
            
            ve = self.bottomView.subviews[self.indexPath().row]
            
        }
        
        if ve == nil {
            
            UIView.animate(withDuration: animationTime, animations: {
                self.superCollectionView().alpha = 0
                self.superview?.superview?.alpha = 0
            }, completion: { (callBack) in
                self.superview?.superview?.removeFromSuperview()
            })
            
            return
        }
        
        let rect = self.bottomView.convert(ve.frame, to: self)
        
        let poin = self.bottomView.convert(ve.center, to: self)
        if let height = ima?.size.height,let width = ima?.size.width{
            let heightS = height/width*ScreenWidth
            let widthS = width/height*heightS
            tempView.frame = CGRect(x: 0, y: 0, width: widthS, height: heightS)
            if height < ScreenHeight {
                tempView.center = (self.superview?.superview?.center)!
            }
        }
        self.superCollectionView().alpha = 0.5
        self.superview?.superview?.backgroundColor = UIColor.clear
        
        UIView.animate(withDuration: animationTime, animations: {
            self.superCollectionView().alpha = 0
            tempView.center = poin
            tempView.bounds = rect
        }, completion: { (callBack) in
            self.superview?.superview?.removeFromSuperview()
        })
    }
    
    func twoTouch(_ sender: UITapGestureRecognizer){
        
        let touchPoint = sender.location(in: sender.view)
        
        let scroll =  sender.view as! UIScrollView
        
        let imageView = scroll.subviews[0]
        
        let zs = scroll.zoomScale
        
        UIView.animate(withDuration: 0.5, animations: {
            
            scroll.zoomScale = (zs == 1.0) ? 2.0 : 0.0
            
        })
        
        UIView.animate(withDuration: 0.5, animations: {
            
            if scroll.zoomScale==2.0{
                
                let rectHeight = (self.frame.size.height)/scroll.zoomScale
                
                let rectWidth = self.frame.size.width/scroll.zoomScale
                
                let rectX = touchPoint.x-rectWidth/2.0
                
                let rectY = touchPoint.y-rectHeight/2.0
                
                let zoomRect = CGRect(x: rectX, y: rectY, width: rectWidth, height: rectHeight)
                
                scroll.zoom(to: zoomRect, animated: false)
                
                if imageView.frame.size.height > ScreenHeight {
                    
                    self.BottomScroll.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    
                }else{
                    
                    self.BottomScroll.contentInset = UIEdgeInsetsMake((self.BottomScroll.frame.size.height - (imageView.frame.size.height))/2, 0, 0, 0)
                    
                }
                
            }else{
                
                if imageView.frame.size.height > ScreenHeight {
                    
                    self.BottomScroll.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                    
                }else{
                    
                    self.BottomScroll.contentInset = UIEdgeInsetsMake((self.BottomScroll.frame.size.height - (imageView.frame.size.height))/2, 0, 0, 0)
                    
                }
                
            }
        })
    }
    
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollView.subviews[0]
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        let image = scrollView.subviews[0]
        
        if image.frame.size.height > ScreenHeight {
            
            UIView.animate(withDuration: 0.2, animations: {
                self.BottomScroll.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
            })
            
        }else{
            
            UIView.animate(withDuration: 0.2, animations: {
                
                self.BottomScroll.contentInset = UIEdgeInsetsMake((self.BottomScroll.frame.size.height - image.frame.size.height)/2, 0, 0, 0)
                
            })
        }
    }
    
    func indexPath() ->IndexPath{
        
        let collectionView = self.superCollectionView
        
        let indexPath = collectionView().indexPath(for: self)
        
        return indexPath!;
        
    }
    
    func superCollectionView() ->UICollectionView{
        
        return self.findSuperViewWithClass(UICollectionView.classForCoder()) as! UICollectionView
        
    }
    
    func findSuperViewWithClass(_ superViewClass:AnyClass) ->UIView{
        
        var superView = self.superview
        
        var foundSuperView:UIView?
        
        while (superView != nil && foundSuperView == nil) {
            
            if ((superView?.isKind(of: superViewClass)) != nil) {
                
                foundSuperView = superView
                
            }else{
                
                superView = superView!.superview;
                
            }
            
        }
        
        return foundSuperView!
    }
}
