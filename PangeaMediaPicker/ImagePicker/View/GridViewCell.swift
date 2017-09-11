//
//  GridViewCell.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/28.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit

class GridViewCell: UICollectionViewCell {
    @IBOutlet var selectionIcon: UIButton!
    @IBOutlet var cellImageView: UIImageView!
    var indexCount = 0
    // MARK: - Public
    var representAssetIdentifier: String!
    var thumbnailImage: UIImage? {
        willSet {
            cellImageView?.image = newValue
        }
    }
    var cellIsSelected: Bool = false {
        willSet {
            selectionIcon.isSelected = newValue
        }
    }
    /// 隐藏选择按钮和图标
    func hiddenIcons() {
        selectionIcon.isHidden = true
    }
    // 点击选择回调
    var handleSelectionAction: ((Bool) -> Void)?
    // MARK: - Private
    @IBAction func selectionItemAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        handleSelectionAction?(sender.isSelected)
    }

}
