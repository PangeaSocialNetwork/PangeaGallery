//
//  AlbumListTableViewController.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/28.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit
import Photos
enum AlbumSession: Int {
    case albumAllPhotos = 0
    case albumSmartAlbums
    case albumUserCollection
    static let count = 2
}

protocol AlbumListTableViewControllerDelegate: class {
    func changeAlbum(gridFetchAllPhtos: PHFetchResult<PHAsset>, assetCollection: PHAssetCollection, titleStr: String)
}

class AlbumListTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // MARK: - Properties
    let screenHeight = UIScreen.main.bounds.size.height
    // The width of the screen
    let screenWidth = UIScreen.main.bounds.size.width
    fileprivate var allPhotos: PHFetchResult<PHAsset>!
    fileprivate var smartAlbums: PHFetchResult<PHAssetCollection>!
    fileprivate var userCollections: PHFetchResult<PHCollection>!
    fileprivate var maxCount: Int = 0
    fileprivate var handleSelectionAction: (([String], [String]) -> Void)?
    @IBOutlet var tableBotton: NSLayoutConstraint!
    @IBOutlet var mainTableView: UITableView!
    weak var albumListDelegate: AlbumListTableViewControllerDelegate?
    var mainViewTopOffset: Float = 0 {
        didSet {
            if mainViewTopOffset == 0 {
                tableBotton.constant = screenHeight
            } else {
                tableBotton.constant = 0
            }
        }
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        mainTableView.separatorStyle = .none
        fetchAlbumsFromSystemAlbum()
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    // MARK: - Private
    /// Get all information with album
    private func fetchAlbumsFromSystemAlbum() {
        let allPhotoOptions = PHFetchOptions()
        allPhotoOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        allPhotoOptions.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
        allPhotos = PHAsset.fetchAssets(with: allPhotoOptions)
        // Get intelligence album
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: nil)
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        //Monitor the data changes of the album
        PHPhotoLibrary.shared().register(self)
        // Register cell
        let nib = UINib(nibName: "AlbumListViewCell", bundle: nil)
        mainTableView.register(nib, forCellReuseIdentifier: "AlbumListTableViewCellIdentifier")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumListTableViewCellIdentifier",
                                                 for: indexPath)
        if let albumCell: AlbumListViewCell = cell as? AlbumListViewCell {
            albumCell.selectionStyle = .none
            switch AlbumSession(rawValue: indexPath.section)! {
            case .albumAllPhotos:
                albumCell.asset = allPhotos.firstObject
                albumCell.albumTitleAndCount = ("Camera Roll", allPhotos.count)
            case .albumSmartAlbums:
                let collection = smartAlbums.object(at: indexPath.row)
                albumCell.asset = PHAsset.fetchAssets(in: collection, options: nil).firstObject
                albumCell.albumTitleAndCount = (collection.localizedTitle,
                                           PHAsset.fetchAssets(in: collection, options: nil).count)
            case .albumUserCollection:
                if let collection = userCollections.object(at: indexPath.row) as? PHAssetCollection {
                    albumCell.asset = PHAsset.fetchAssets(in: collection, options: nil).firstObject
                    albumCell.albumTitleAndCount = (collection.localizedTitle, PHAsset.fetchAssets(in: collection ,
                                                                                                   options: nil).count)
                }
            }
            return albumCell
        } else {
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var gridFetchAllPhtos = PHFetchResult<PHAsset>()
        var assetCollection = PHAssetCollection()
        switch AlbumSession(rawValue: indexPath.section)! {
        case .albumAllPhotos:
            gridFetchAllPhtos = allPhotos
        case .albumSmartAlbums:
            assetCollection = smartAlbums.object(at: indexPath.row)
            gridFetchAllPhtos = PHAsset.fetchAssets(in: smartAlbums.object(at: indexPath.row), options: nil)
        case .albumUserCollection:
            if let collection = userCollections.object(at: indexPath.row) as? PHAssetCollection {
                assetCollection = collection
                gridFetchAllPhtos = PHAsset.fetchAssets(in: collection, options: nil)
            }
        }
        if let currentCell = tableView.cellForRow(at: indexPath) as? AlbumListViewCell,
            let titleStr = currentCell.albumTitleAndCount?.0 {
            albumListDelegate?.changeAlbum(gridFetchAllPhtos: gridFetchAllPhtos,
                                           assetCollection: assetCollection, titleStr:titleStr)
        }
    }
}

// MARK: - PHPhotoLibraryChangeObserver
extension AlbumListTableViewController: PHPhotoLibraryChangeObserver {
    // System  album change
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.sync {
            if let changeDetails = changeInstance.changeDetails(for: allPhotos) {
                allPhotos = changeDetails.fetchResultAfterChanges
            }
            if let changeDetail = changeInstance.changeDetails(for: smartAlbums) {
                smartAlbums = changeDetail.fetchResultAfterChanges
                mainTableView.reloadSections(IndexSet(integer: AlbumSession.albumSmartAlbums.rawValue),
                                             with: .automatic)
            }
            if let changeDetail = changeInstance.changeDetails(for: userCollections) {
                userCollections = changeDetail.fetchResultAfterChanges
                mainTableView.reloadSections(IndexSet(integer: AlbumSession.albumUserCollection.rawValue),
                                             with: .automatic)
            }
        }
    }
}
