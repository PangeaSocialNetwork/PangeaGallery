//
//  GridViewCell.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/28.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit

class GridViewCell: UICollectionViewCell {
    // MARK: - Properties
    var cellImageView: UIImageView!
    var selectionIcon: UIButton!
    var indexCount = 0
    
    private let slectionIconWidth: CGFloat = 25
    
    static let cellIdentifier = "GridViewCell-Asset"
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
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
    private func setupUI() {
        // 图片
        cellImageView = UIImageView(frame: bounds)
        cellImageView?.clipsToBounds = true
        cellImageView?.contentMode = .scaleAspectFill
        contentView.addSubview(cellImageView!)
        // 选择图标
        selectionIcon = UIButton(frame: CGRect(x: 0, y: 0, width: slectionIconWidth, height: slectionIconWidth))
        selectionIcon.center = CGPoint(x: bounds.width - 2 - selectionIcon.bounds.width / 2, y: selectionIcon.bounds.height / 2)
        selectionIcon.setBackgroundImage(#imageLiteral(resourceName: "l_unselected"), for: .normal)
        selectionIcon.setBackgroundImage(#imageLiteral(resourceName: "l_selected"), for: .selected)
        selectionIcon.addTarget(self, action: #selector(selectionItemAction(btn:)), for: .touchUpInside)
        contentView.addSubview(selectionIcon)
        
    }
    
    func selectionItemAction(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        handleSelectionAction?(btn.isSelected)
    }
}
