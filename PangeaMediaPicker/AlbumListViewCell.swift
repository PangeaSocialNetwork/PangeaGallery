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
    
    private var firstImageView: UIImageView?
    private var albumTitleLabel: UILabel?
    private var albumCountLabel: UILabel?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateUI()
    }
    
    private func updateUI() {
        let width = bounds.height-10
        firstImageView?.frame = CGRect(x: 15, y: 5, width: width, height: width)
        albumTitleLabel?.frame = CGRect(x: firstImageView!.frame.maxX + 15, y: firstImageView!.center.y - 20, width: 200, height: 30)
        albumCountLabel?.frame = CGRect(x: firstImageView!.frame.maxX + 15, y: albumTitleLabel!.frame.maxY, width: 200, height: 10)
    }
    
    
    private func setupUI() {
        firstImageView = UIImageView()
        addSubview(firstImageView!)
        firstImageView?.clipsToBounds = true
        firstImageView?.contentMode = .scaleAspectFill
        
        albumTitleLabel = UILabel()
        albumCountLabel = UILabel()
        albumTitleLabel?.font = UIFont.systemFont(ofSize: 15)
        albumCountLabel?.font = UIFont.systemFont(ofSize: 12)
        addSubview(albumTitleLabel!)
        addSubview(albumCountLabel!)
    }
    
    
    // 展示第一张图片和标题
    var asset: PHAsset? {
        willSet {
            
            if newValue == nil {
                firstImageView?.image = #imageLiteral(resourceName: "l_picNil")
                return
            }
            let defaultSize = CGSize(width: UIScreen.main.scale + bounds.height, height: UIScreen.main.scale + bounds.height)
            PHCachingImageManager.default().requestImage(for: newValue!, targetSize: defaultSize, contentMode: .aspectFill, options: nil, resultHandler: { (img, _) in
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
