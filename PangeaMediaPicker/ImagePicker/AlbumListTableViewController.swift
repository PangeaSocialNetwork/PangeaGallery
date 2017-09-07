//
//  AlbumListTableViewController.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/28.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit
import Photos


/* 相册类型
 
 - albumAllPhotos: 所有
 - albumSmartAlbums: 智能
 - albumUserCollection: 收藏*/
enum AlbumSession: Int {
    case albumAllPhotos = 0
    case albumSmartAlbums
    case albumUserCollection
    static let count = 2
}

protocol AlbumListTableViewControllerDelegate:class{
    func changeAlbum(gridFetchAllPhtos:PHFetchResult<PHAsset>,assetCollection:PHAssetCollection,titleStr:String)
}

class AlbumListTableViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    
    // MARK: - Properties
    fileprivate var allPhotos: PHFetchResult<PHAsset>!
    fileprivate var smartAlbums: PHFetchResult<PHAssetCollection>!
    fileprivate var userCollections: PHFetchResult<PHCollection>!
    fileprivate var MaxCount: Int = 0
    fileprivate var handleSelectionAction: (([String], [String]) -> Void)?
    var mainTableView = UITableView()
    weak var albumListDelegate:AlbumListTableViewControllerDelegate?
    var mainViewTopOffset:Float = 0{
        didSet{
            if mainViewTopOffset == 0 {
                mainTableView.frame = CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.width, height: 0)
            }else{
                mainTableView.frame =  CGRect.init(x: 0, y: 64, width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height)
            }
        }
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mainTableView)
        mainTableView.frame = CGRect.init(x: 0, y: 64, width: view.frame.width, height: view.frame.height)
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.separatorStyle = .none
        fetchAlbumsFromSystemAlbum()
    }
    
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    // MARK: - Private
    /// 获取所有系统相册概览信息
    private func fetchAlbumsFromSystemAlbum() {
        let allPhotoOptions = PHFetchOptions()
        // 时间排序
        allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotoOptions.includeAssetSourceTypes = [.typeUserLibrary,.typeCloudShared,.typeiTunesSynced]
        allPhotos = PHAsset.fetchAssets(with: allPhotoOptions)
        // 获取智能相册
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        
        // 监测系统相册增加，即使用期间是否拍照
        PHPhotoLibrary.shared().register(self)
        
        // 注册cell
        mainTableView.register(AlbumListViewCell.self, forCellReuseIdentifier: AlbumListViewCell.cellIdentifier)
    }
    
    
    
    // MARK: - UITableViewDelegate & UITableViewDataSource
     func numberOfSections(in tableView: UITableView) -> Int {
        return AlbumSession.count
    }
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch AlbumSession(rawValue: section)! {
        case .albumAllPhotos:
            return 1
        case .albumSmartAlbums:
            return smartAlbums.count
        case .albumUserCollection:
            return userCollections.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AlbumListViewCell.cellIdentifier, for: indexPath) as! AlbumListViewCell
        cell.selectionStyle = .none
        
        switch AlbumSession(rawValue: indexPath.section)! {
        case .albumAllPhotos:
            cell.asset = allPhotos.firstObject
            cell.albumTitleAndCount = ("Camera Roll", allPhotos.count)
        case .albumSmartAlbums:
            let collection = smartAlbums.object(at: indexPath.row)
            cell.asset = PHAsset.fetchAssets(in: collection, options: nil).firstObject
            cell.albumTitleAndCount = (collection.localizedTitle, PHAsset.fetchAssets(in: collection, options: nil).count)
        case .albumUserCollection:
            let collection = userCollections.object(at: indexPath.row)
            cell.asset = PHAsset.fetchAssets(in: collection as! PHAssetCollection, options: nil).firstObject
            cell.albumTitleAndCount = (collection.localizedTitle, PHAsset.fetchAssets(in: collection as! PHAssetCollection, options: nil).count)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let gridVC = MediaPickerViewController()
        var gridFetchAllPhtos = PHFetchResult<PHAsset>()
        var assetCollection = PHAssetCollection()
        switch AlbumSession(rawValue: indexPath.section)! {
        case .albumAllPhotos:
            gridFetchAllPhtos = allPhotos
        case .albumSmartAlbums:
            assetCollection = smartAlbums.object(at: indexPath.row)
            gridFetchAllPhtos = PHAsset.fetchAssets(in: smartAlbums.object(at: indexPath.row), options: nil)
        case .albumUserCollection:
            assetCollection = (userCollections.object(at: indexPath.row) as? PHAssetCollection)!
            gridFetchAllPhtos = PHAsset.fetchAssets(in: userCollections.object(at: indexPath.row) as! PHAssetCollection, options: nil)
        }
        if let currentCell = tableView.cellForRow(at: indexPath) as? AlbumListViewCell,let titleStr = currentCell.albumTitleAndCount?.0{
            albumListDelegate?.changeAlbum(gridFetchAllPhtos: gridFetchAllPhtos, assetCollection: assetCollection, titleStr:titleStr)
        }

    }
    
}

// MARK: - PHPhotoLibraryChangeObserver
extension AlbumListTableViewController: PHPhotoLibraryChangeObserver {
    /// 系统相册改变
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
                allPhotos = changeDetails.fetchResultAfterChanges
            }
            
            if let changeDetail = changeInstance.changeDetails(for: smartAlbums) {
                smartAlbums = changeDetail.fetchResultAfterChanges
                mainTableView.reloadSections(IndexSet(integer: AlbumSession.albumSmartAlbums.rawValue), with: .automatic)
            }
            
            if let changeDetail = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetail.fetchResultAfterChanges
                mainTableView.reloadSections(IndexSet(integer: AlbumSession.albumUserCollection.rawValue), with: .automatic)
            }
        }
    }
}

