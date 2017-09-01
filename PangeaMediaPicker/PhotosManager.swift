//
//  PhotosManager.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/28.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

/// 选择照片方式

import UIKit

class PhotosManager: NSObject {
    static let share = PhotosManager()
    private override init() {
        super.init()
    }
    
    /// 添加图片
    /// - Parameters:
    ///   - phtotsCount: 几张
    ///   - showAlbum: 是否相册
    ///   - _completeHandler: 回调
    func takePhotos(_ photosCount: Int, _ completeHandler: @escaping ([Data?]) -> Void) {
        let pickerVC = MediaPickerViewController()
        pickerVC.title = "所有图片"
        UIApplication.shared.keyWindow?.currentViewController()?.navigationController?.pushViewController(pickerVC, animated: true)
        HandleSelectionPhotosManager.share.getSelectedPhotos(with: photosCount) { (assets, images) in
            var datas = [Data?]()
            images.forEach({ img in
                let imgData = UIImageJPEGRepresentation(img, 0.2)
                datas.append(imgData)
            })
            completeHandler(datas)
        }
    }
    
}


// 获取当前UIViewController
/** @abstract UIWindow hierarchy category.  */
public extension UIWindow {
    
    /** @return Returns the current Top Most ViewController in hierarchy.   */
    public func topMostController()->UIViewController? {
        
        var topController = rootViewController
        
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        
        return topController
    }
    
    /** @return Returns the topViewController in stack of topMostController.    */
    public func currentViewController()->UIViewController? {
        
        var currentViewController = topMostController()
        
        while currentViewController != nil && currentViewController is UINavigationController && (currentViewController as! UINavigationController).topViewController != nil {
            currentViewController = (currentViewController as! UINavigationController).topViewController
        }
        
        return currentViewController
    }
}
