//
//  MediaPickerViewControllerExtension.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/9/18.
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
extension MediaPickerViewController: UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver,ImageBrowserDelegate, UITableViewDataSource, UITableViewDelegate {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchAllPhtos.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "header111", for: indexPath)
        return headerView
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.cellSelectImageIndex(cellIndexArray: self.cellIndexArray)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridViewCell-Asset", for: indexPath)
        if let gridCell = cell as? GridViewCell {
            let asset = fetchAllPhtos.object(at: indexPath.item)
            gridCell.representAssetIdentifier = asset.localIdentifier
            imageManager.requestImage(for: asset,
                                      targetSize: thumnailSize,
                                      contentMode: .aspectFill,
                                      options: nil) { img, _ in
                                        if gridCell.representAssetIdentifier == asset.localIdentifier {
                                            gridCell.thumbnailImage = img
                                        }
            }
            if isOnlyOne {
                gridCell.hiddenIcons()
            } else {
                gridCell.cellIsSelected = flags[indexPath.row]
                gridCell.handleSelectionAction = { isSelected in
                    if self.selectedAssets.count > self.maxCount - 1 && !gridCell.cellIsSelected {
                        self.showAlert(with: "haha")
                        gridCell.selectionIcon.isSelected = false
                        return
                    }
                    self.flags[indexPath.item] = isSelected
                    gridCell.cellIsSelected = isSelected
                    if isSelected {
                        self.selectedAssets.append(self.fetchAllPhtos.object(at: indexPath.item))
                        self.selectedImages.append(gridCell.thumbnailImage!)
                        self.cellIndexArray.append(indexPath)
                    } else {
                        let deleteIndex1 = self.selectedAssets.index(of: self.fetchAllPhtos.object(at: indexPath.item))
                        self.selectedAssets.remove(at: deleteIndex1!)
                        self.selectedImages.remove(at: deleteIndex1!)
                        self.cellIndexArray.remove(at: deleteIndex1!)
                    }
                    self.cellSelectImageIndex(cellIndexArray: self.cellIndexArray )
                }
            }
            return gridCell
        } else {
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "ImagePicker", bundle: nil)
        if let browserVC = storyboard.instantiateViewController(withIdentifier: "BrowserView") as? BrowserViewController {
            browserVC.delegate = self
            browserVC.indexImage = indexPath.row
            browserVC.number = indexPath
            browserVC.defaultImage = #imageLiteral(resourceName: "l_picNil")
            browserVC.arrayImage = self.fetchAllPhtos
            self.present(browserVC, animated: true, completion: nil)
        }
    }

    func getTheThumbnailImage(_ indexRow: Int) -> UIImage {
        let indexPath = IndexPath(row: indexRow, section: 0)
        if  let cell = collectionView.cellForItem(at: indexPath) as? GridViewCell {
            return cell.thumbnailImage!
        } else {
            return #imageLiteral(resourceName: "l_picNil")
        }
    }

    func selectedImageAction(indexItme: IndexPath) -> String? {
        collectionView.scrollToItem(at: indexItme, at: .bottom, animated: false)
        collectionView.layoutIfNeeded()
        if  let cell = collectionView.cellForItem(at: indexItme) as? GridViewCell {
            cell.selectionItemAction(cell.selectionIcon)
            if flags[indexItme.row] {
                return cell.selectionIcon.title(for: .selected)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    func imageSelectStatus(index: Int) -> String? {
        let currIndexPath = IndexPath(row: index, section: 0)
        collectionView.scrollToItem(at: currIndexPath, at: .bottom, animated: false)
        collectionView.layoutIfNeeded()
        if let cell = self.collectionView.cellForItem(at: currIndexPath) as? GridViewCell {
            if flags[index] {
                return cell.selectionIcon.title(for: .selected)
            } else {
                return nil
            }
        } else {
            return nil
        }
    }

    func showAlert(with title: String) {
        let alertVC = UIAlertController(title: "Can only choose \(maxCount) image", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
        }
    }

    func cellSelectImageIndex(cellIndexArray: [IndexPath]) {
        for index in 0..<cellIndexArray.count {
            if let cell = collectionView.cellForItem(at:cellIndexArray[index]) as? GridViewCell {
                cell.selectionIcon.setTitle(String(index+1), for: .selected)
            }
        }
    }

    // MARK: - Private
    /// Get all information with album
    func fetchAlbumsFromSystemAlbum() {
        allPhotos = PHAsset.fetchAssets(with: allOptions)
        // Get intelligence album
        smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .any, options: nil)
        for i in 0..<smartAlbums.count {
            let collection = smartAlbums.object(at: i)
            if PHAsset.fetchAssets(in: collection, options: allOptions).firstObject != nil {
                smartAlbumsArray.append(collection)
            }

        }
        userCollections = PHCollectionList.fetchTopLevelUserCollections(with: nil)
        //Monitor the data changes of the album
        PHPhotoLibrary.shared().register(self)
        // Register cell
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
            return smartAlbumsArray.count
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
                let collection = smartAlbumsArray[indexPath.row]
                albumCell.asset = PHAsset.fetchAssets(in: collection, options: allOptions).firstObject
                albumCell.albumTitleAndCount = (collection.localizedTitle,
                                                PHAsset.fetchAssets(in: collection, options: nil).count)
            case .albumUserCollection:
                if let collection = userCollections.object(at: indexPath.row) as? PHAssetCollection {
                    albumCell.asset = PHAsset.fetchAssets(in: collection, options: allOptions).firstObject
                    albumCell.albumTitleAndCount = (collection.localizedTitle, PHAsset.fetchAssets(in: collection ,
                                                                                                   options: nil).count)
                }
            }
            if self.curryIndexPath == indexPath {
                albumCell.accessoryView?.isHidden = false
            } else {
                albumCell.accessoryView?.isHidden = true
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
            assetCollection = smartAlbumsArray[indexPath.row]
            gridFetchAllPhtos = PHAsset.fetchAssets(in: assetCollection, options: allOptions)
        case .albumUserCollection:
            if let collection = userCollections.object(at: indexPath.row) as? PHAssetCollection {
                assetCollection = collection
                gridFetchAllPhtos = PHAsset.fetchAssets(in: collection, options: allOptions)
            }
        }
        if let currentCell = tableView.cellForRow(at: indexPath) as? AlbumListViewCell,
            let titleStr = currentCell.albumTitleAndCount?.0 {
            changeAlbum(gridFetchAllPhtos: gridFetchAllPhtos,
                        assetCollection: assetCollection, titleStr:titleStr)
        }
        self.curryIndexPath = indexPath
        self.mainTableView.reloadData()
    }

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
