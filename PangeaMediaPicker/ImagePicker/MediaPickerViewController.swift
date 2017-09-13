//
//  MediaPickerViewController.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/28.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit
import Photos
typealias HandlePhotos = ([PHAsset], [UIImage]) -> Void
class HandleSelectionPhotosManager: NSObject {
    static let share = HandleSelectionPhotosManager()
    var maxCount: Int = 0
    var callbackPhotos: HandlePhotos?
    private override init() {
        super.init()
    }
    func getSelectedPhotos(with count: Int, callback completeHandle: HandlePhotos? ) {
        // 限制图片数量
        maxCount = count < 1 ? 1 : (count > 9 ? 9 : count)
        self.callbackPhotos = completeHandle
    }
}
class MediaPickerViewController: UIViewController,
AlbumListTableViewControllerDelegate {
    @IBOutlet var collectionView: UICollectionView!
    // MARK: - Properties
    fileprivate var albumListVC = AlbumListTableViewController()
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumnailSize = CGSize()
    fileprivate var previousPreheatRect = CGRect.zero
    // 展示选择数量
    fileprivate var titleView = NavTitleView()
    @IBOutlet var countView: UIView!
    @IBOutlet var countLable: UILabel!
    @IBOutlet var countButton: UIButton!
    fileprivate var isShowCountView = false
    fileprivate var isOpen = false
    fileprivate var cellIndexArray = [IndexPath]()
    // 是否只选择一张，如果是，则每个图片不显示选择图标
    fileprivate var isOnlyOne = true
    // 选择图片数
    fileprivate var count: Int = 0
    // 选择回调
    fileprivate var handlePhotos: HandlePhotos?
    // 回调Asset
    fileprivate var selectedAssets = [PHAsset]() {
        willSet {
            updateCountView(with: newValue.count)
        }
    }
    // 回调Image
    fileprivate var selectedImages = [UIImage]()
    // 选择标识
    fileprivate var flags = [Bool]()
    fileprivate  var index: Double = 1.00
    // itemSize
    fileprivate let shape: CGFloat = 3
    fileprivate let numbersInSingleLine: CGFloat = 4
    fileprivate var cellWidth: CGFloat? {
        return (UIScreen.main.bounds.width - (numbersInSingleLine - 1) * shape) / numbersInSingleLine
    }
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        // 设置回调
        count = HandleSelectionPhotosManager.share.maxCount
        handlePhotos = HandleSelectionPhotosManager.share.callbackPhotos
        isOnlyOne = count == 1 ? true : false
        setNav()
        setupUI()
        // 监测数据源
        if fetchAllPhtos == nil {
            let allOptions = PHFetchOptions()
            allOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            allOptions.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
            fetchAllPhtos = PHAsset.fetchAssets(with: allOptions)
            collectionView.reloadData()
        }
        (0 ..< fetchAllPhtos.count).forEach { _ in
            flags.append(false)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // 定义缓存照片尺寸
        thumnailSize = CGSize(width: cellWidth! * UIScreen.main.scale, height: cellWidth! * UIScreen.main.scale)
        // collectionView 滑动到最底部
        let indexPath = IndexPath(item: fetchAllPhtos.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }
    func setNav() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        tapGesture.numberOfTapsRequired = 1
        if let navTitleView = Bundle.main.loadNibNamed("NavTitleView", owner: nil, options: nil)?.first as? NavTitleView {
            titleView = navTitleView
        }
        titleView.titleLable.sizeToFit()
        titleView.addGestureRecognizer(tapGesture)
        navigationItem.titleView = titleView
        let button = UIButton.init(type: .custom)
        button.bounds = CGRect.init(x: 0, y: 0, width: 25, height: 25)
        button.setImage(#imageLiteral(resourceName: "c_close"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "c_close_w"), for: .selected)
        button.addTarget(self, action: #selector(dismissAction), for: .touchUpInside)
        let barItem = UIBarButtonItem.init(customView: button)
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.barTintColor =  UIColor(red: 8.0 / 255.0,
                                                                         green: 8.0 / 255.0,
                                                                         blue: 8.0 / 255.0,
                                                                         alpha: 1.0)
        navigationItem.leftBarButtonItem = barItem
    }
    func changeAlbum(gridFetchAllPhtos: PHFetchResult<PHAsset>, assetCollection: PHAssetCollection, titleStr: String) {
        fetchAllPhtos = gridFetchAllPhtos
        titleView.titleLable.text = titleStr
        collectionView.reloadData()
        handleTapGesture()
        let indexPath = IndexPath(item: fetchAllPhtos.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }
    func countViewHides(isHides: Bool) {
        countView.isHidden = isHides
    }
    func handleTapGesture() {
        startAnimation()
    }
    func startAnimation() {
        UIView.animate(withDuration: 0.35, animations: {
            if !self.isOpen {
                self.titleView.titleImageView.transform = CGAffineTransform(rotationAngle: .pi)
                self.albumListVC.mainViewTopOffset = 1
                self.albumListVC.view.isHidden = self.isOpen
            } else {
                self.titleView.titleImageView.transform = .identity
                self.albumListVC.mainViewTopOffset = 0
            }
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                self.albumListVC.view.isHidden = self.isOpen
                self.isOpen = !self.isOpen
            }
        }
        countViewHides(isHides: !self.isOpen)
    }
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    // MARK: - Public
    // 所有图片
    internal var fetchAllPhtos: PHFetchResult<PHAsset>!
    // 单个相册
    internal var assetCollection: PHAssetCollection!
    // MARK: - Privat
    /// 展示
    private func setupUI() {
        let cvLayout = UICollectionViewFlowLayout()
        cvLayout.itemSize = CGSize(width: cellWidth!, height: cellWidth!)
        cvLayout.minimumLineSpacing = shape
        cvLayout.minimumInteritemSpacing = shape
        collectionView.setCollectionViewLayout(cvLayout, animated: false)
        let nib = UINib.init(nibName: "GridViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "GridViewCell-Asset")
        collectionView.dataSource = self
        collectionView.delegate = self
        let storyboard = UIStoryboard.init(name: "ImagePicker", bundle: nil)
        if let currListVC = storyboard.instantiateViewController(withIdentifier: "pickerList") as? AlbumListTableViewController {
            albumListVC = currListVC
        }
        addChildViewController(albumListVC)
        view.addSubview(albumListVC.view)
        albumListVC.didMove(toParentViewController: self)
        albumListVC.mainViewTopOffset = 0
        albumListVC.view.isHidden = true
        albumListVC.albumListDelegate = self
    }
    /// count
    /// 照片选择结束
    @IBAction func selectedOverAction(_ sender: Any) {
        handlePhotos?(selectedAssets, selectedImages)
        dismissAction()
    }
    /// 根据选择照片数量动态展示CountView
    ///
    /// - Parameter photoCount: photoCount description
    private func updateCountView(with photoCount: Int) {

        countLable.text = String(describing: photoCount)
        if isShowCountView && photoCount != 0 {
            return
        }
    }
    /// 添加取消按钮
    func dismissAction() {
        self.navigationController?.popViewController(animated: true)
    }
    // 展示选择数量的视图
    // MARK: PHAsset Caching
    /// 重置图片缓存
    private func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }

}
extension MediaPickerViewController: UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout,
ImageBrowserDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchAllPhtos.count
    }
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        self.cellSelectImageIndex(cellIndexArray: self.cellIndexArray)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GridViewCell-Asset", for: indexPath)
        if let gridCell = cell as? GridViewCell {
            let asset = fetchAllPhtos.object(at: indexPath.item)
            gridCell.representAssetIdentifier = asset.localIdentifier
            // 从缓存中取出图片
            imageManager.requestImage(for: asset,
                                      targetSize: thumnailSize,
                                      contentMode: .aspectFill,
                                      options: nil) { img, _ in
                                        // 代码执行到这里时cell可能已经被重用了，所以设置标识用来展示
                                        if gridCell.representAssetIdentifier == asset.localIdentifier {
                                            gridCell.thumbnailImage = img
                                        }
            }
            // 防止重复
            if isOnlyOne {
                gridCell.hiddenIcons()
            } else {
                gridCell.cellIsSelected = flags[indexPath.row]
                gridCell.handleSelectionAction = { isSelected in
                    // 判断是否超过最大值
                    if self.selectedAssets.count > self.count - 1 && !gridCell.cellIsSelected {
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
        if let bview = Bundle.main.loadNibNamed("ImageBrowser", owner: nil, options: nil)?.first as? ImageBrowser {
            bview.delegate = self
            bview.bottomView = self.collectionView
            bview.indexImage = indexPath.row
            bview.number = indexPath
            bview.defaultImage = #imageLiteral(resourceName: "l_picNil")
            bview.arrayImage = self.fetchAllPhtos
            bview.show()
        }
    }
    func getTheThumbnailImage(_ indexRow: Int) -> UIImage {
        let indexPath = IndexPath.init(row: indexRow, section: 0)
        if  let cell = collectionView.cellForItem(at: indexPath) as? GridViewCell {
           return cell.thumbnailImage!
        } else {
            return #imageLiteral(resourceName: "l_picNil")
        }
    }
    func selectedImageAction(indexItme: IndexPath) -> String? {
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
        let currIndexPath = IndexPath.init(row: index, section: 0)
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
        let alertVC = UIAlertController(title: "Can only choose \(count) image", message: nil, preferredStyle: .alert)
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
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let nc = self.navigationController {
            NSLog("The controller is still running\(nc)")
        } else {
            self.collectionView = nil
            self.albumListVC.willMove(toParentViewController: self)
            self.countButton = nil
            self.countLable = nil
            self.fetchAllPhtos  = nil
            self.view = nil
        }
    }
}
// MARK: - PHPhotoLibraryChangeObserver
extension MediaPickerViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
    }
}
// MARK: - UICollectionView Extension
private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
