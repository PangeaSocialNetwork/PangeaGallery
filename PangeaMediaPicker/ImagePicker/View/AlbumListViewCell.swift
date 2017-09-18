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
                firstImageView?.image = #imageLiteral(resourceName: "l_picNil")
                return
            }
            let defaultSize = CGSize(width: UIScreen.main.scale + bounds.height,
                                     height: UIScreen.main.scale + bounds.height)
            PHCachingImageManager.default().requestImage(for: newValue!,
                                                         targetSize: defaultSize,
                                                         contentMode: .aspectFill,
                                                         options: nil,
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
        }
    }
}
