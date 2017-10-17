//
//  AlbumListViewCell.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/28.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit
import Photos

class AlbumListViewCell: UITableViewCell {
    static let cellIdentifier = "AlbumListTableViewCellIdentifier"
    let bundle = Bundle.init(identifier: "org.cocoapods.PangeaMediaPicker")
    @IBOutlet var firstImageView: UIImageView!
    @IBOutlet var albumTitleLabel: UILabel!
    @IBOutlet var albumCountLabel: UILabel!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // Show first image and name

    var asset: PHAsset? {
        willSet {
            if newValue == nil {
                firstImageView?.image = UIImage.init(named: "l_picNil", in:bundle, compatibleWith: nil)
                return
            }
            let defaultSize = CGSize(width: UIScreen.main.scale + bounds.height,
                                     height: UIScreen.main.scale + bounds.height)
            let options = PHImageRequestOptions()
            options.isNetworkAccessAllowed = true
            PHCachingImageManager.default().requestImage(for: newValue!,
                                                         targetSize: defaultSize,
                                                         contentMode: .aspectFill,
                                                         options: options,
                                                         resultHandler: { (img, _) in
                self.firstImageView?.image = img
            })
        }
    }

    var albumTitleAndCount: (String?, Int)? {
        willSet {
            if newValue == nil {
                return
            }
            self.albumTitleLabel?.text = (newValue!.0 ?? "")
            self.albumCountLabel?.text =  String(describing: newValue!.1)
            self.accessoryView?.isHidden = true
            self.accessoryView? = UIImageView(image: UIImage(named: "checkMark", in: bundle, compatibleWith: nil))
        }
    }
}
