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

class MediaPickerViewController: UIViewController,AlbumListTableViewControllerDelegate{
    
    // MARK: - Properties
    fileprivate var collectionView: UICollectionView!
    fileprivate let albumListVC = AlbumListTableViewController()
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumnailSize = CGSize()
    fileprivate var previousPreheatRect = CGRect.zero
    
    // 展示选择数量
    fileprivate var titleView = UIView()
    fileprivate var titleLable = UILabel()
    fileprivate var titleImageView = UIImageView()
    fileprivate var countView: UIView!
    fileprivate var countLabel: UILabel!
    fileprivate var countButton: UIButton!
    fileprivate let countViewHeight: CGFloat = 50
    fileprivate var isShowCountView = false
    fileprivate var isOpen = false
    
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
    
    fileprivate  var index:Double = 1.00
    // itemSize
    fileprivate let shape: CGFloat = 3
    fileprivate let numbersInSingleLine: CGFloat = 4
    fileprivate var cellWidth: CGFloat? {
        return (UIScreen.main.bounds.width - (numbersInSingleLine - 1) * shape) / numbersInSingleLine
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLable.text = "这TM是相册"
        titleImageView.image = #imageLiteral(resourceName: "n_icon")
        titleLable.sizeToFit()
        titleLable.textAlignment = .right
        titleView.frame = CGRect.init(x: 0, y: 0, width: 200, height: 64)
        titleView.addSubview(titleLable)
        titleView.addSubview(titleImageView)
        
        automaticallyAdjustsScrollViewInsets = false
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        
        // 设置回调
        count = HandleSelectionPhotosManager.share.maxCount
        handlePhotos = HandleSelectionPhotosManager.share.callbackPhotos
        isOnlyOne = count == 1 ? true : false
        
        setupUI()
        // 添加数量视图
        addCountView()
        
        // 监测数据源
        if fetchAllPhtos == nil {
            let allOptions = PHFetchOptions()
            allOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            allOptions.includeAssetSourceTypes = [.typeUserLibrary,.typeCloudShared,.typeiTunesSynced]
            fetchAllPhtos = PHAsset.fetchAssets(with: allOptions)
            collectionView.reloadData()
        }
        
        (0 ..< fetchAllPhtos.count).forEach { _ in
            flags.append(false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let barItem = UIBarButtonItem(title: nil, style: .plain, target: self, action: #selector(dismissAction))
        barItem.image = #imageLiteral(resourceName: "c_close").withRenderingMode(.alwaysOriginal)
        navigationItem.leftBarButtonItem = barItem
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        //设置手势点击数,双击：点2下
        tapGesture.numberOfTapsRequired = 1
        navigationItem.titleView = titleView
        titleLable.center = titleView.center
        titleImageView.frame = CGRect.init(x: titleLable.frame.maxX, y: titleLable.frame.midY-4, width: titleLable.frame.height-3, height: titleLable.frame.height-8)
        titleView.addGestureRecognizer(tapGesture)
        
        // 定义缓存照片尺寸
        thumnailSize = CGSize(width: cellWidth! * UIScreen.main.scale, height: cellWidth! * UIScreen.main.scale)
        // collectionView 滑动到最底部
        guard fetchAllPhtos.count > 0 else { return }
        let indexPath = IndexPath(item: fetchAllPhtos.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }
    
    
    func changeAlbum(gridFetchAllPhtos: PHFetchResult<PHAsset>, assetCollection: PHAssetCollection, titleStr: String) {
        fetchAllPhtos = gridFetchAllPhtos
        titleLable.text = titleStr
        titleLable.sizeToFit()
        collectionView.reloadData()
        handleTapGesture()
        guard fetchAllPhtos.count > 0 else { return }
        let indexPath = IndexPath(item: fetchAllPhtos.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
        titleImageView.frame = CGRect.init(x: titleLable.frame.maxX, y: titleLable.frame.midY-4, width: titleLable.frame.height-3, height: titleLable.frame.height-8)
    }
    
    func handleTapGesture(){
        startAnimation()
    }
    
    func startAnimation() -> Void {
        UIView.animate(withDuration: 0.35, animations: {
            if !self.isOpen{
                self.titleImageView.transform = CGAffineTransform(rotationAngle: .pi)
                self.albumListVC.mainViewTopOffset = 1
                self.albumListVC.view.isHidden = self.isOpen
            }else{
                self.titleImageView.transform = .identity
                self.albumListVC.mainViewTopOffset = 0
            }
        }) { (finished) in
            if finished {
                self.albumListVC.view.isHidden = self.isOpen
                self.isOpen = !self.isOpen
            }
        }
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 更新
        updateCachedAssets()
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    // MARK: - Public
    // 所有图片
    internal var fetchAllPhtos: PHFetchResult<PHAsset>!
    // 单个相册
    internal var assetCollection: PHAssetCollection!
    
    // MARK: - Private
    
    /// 展示
    private func setupUI() {
        let cvLayout = UICollectionViewFlowLayout()
        cvLayout.itemSize = CGSize(width: cellWidth!, height: cellWidth!)
        cvLayout.minimumLineSpacing = shape
        cvLayout.minimumInteritemSpacing = shape
        
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 64, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 64 - countViewHeight), collectionViewLayout: cvLayout)
        view.addSubview(collectionView)
        collectionView.register(GridViewCell.self, forCellWithReuseIdentifier: GridViewCell.cellIdentifier)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        view.addSubview(collectionView)
        
        addChildViewController(albumListVC)
        view.addSubview(albumListVC.view)
        albumListVC.didMove(toParentViewController: self)
        albumListVC.mainViewTopOffset = 0
        albumListVC.view.isHidden = true
        albumListVC.albumListDelegate = self
    }
    
    /// count
    private func addCountView() {
        countView = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.height-countViewHeight, width: UIScreen.main.bounds.width, height: countViewHeight))
        countView.backgroundColor = UIColor(white: 0.85, alpha: 1)
        view.addSubview(countView)
        
        countLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        countLabel.backgroundColor = .green
        countLabel.layer.masksToBounds = true
        countLabel.layer.cornerRadius = countLabel.bounds.width / 2
        countLabel.textColor = .white
        countLabel.textAlignment = .center
        countLabel.font = UIFont.systemFont(ofSize: 17)
        countLabel.center = CGPoint(x: countView.bounds.width / 2, y: countView.bounds.height / 2)
        countView.addSubview(countLabel)
        
        countButton = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 2, height: countViewHeight))
        countButton.center = CGPoint(x: countView.bounds.width / 2, y: countView.bounds.height / 2)
        countButton.backgroundColor = .clear
        countButton.addTarget(self, action: #selector(selectedOverAction), for: .touchUpInside)
        countView.addSubview(countButton)
    }
    
    
    /// 照片选择结束
    func selectedOverAction() {
        handlePhotos?(selectedAssets, selectedImages)
        dismissAction()
    }
    
    
    /// 根据选择照片数量动态展示CountView
    ///
    /// - Parameter photoCount: photoCount description
    private func updateCountView(with photoCount: Int) {
        countLabel.text = String(describing: photoCount)
        
        if isShowCountView && photoCount != 0 {
            return
        }
        /*
        if photoCount == 0 {
            isShowCountView = false
            UIView.animate(withDuration: 0.3, animations: {
                self.countView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height)
                self.collectionView.contentOffset = CGPoint(x: 0, y: self.collectionView.contentOffset.y - self.countViewHeight)
            })
        } else {
            isShowCountView = true
            UIView.animate(withDuration: 0.3, animations: {
                self.countView.frame.origin = CGPoint(x: 0, y: UIScreen.main.bounds.height - self.countViewHeight)
                self.collectionView.contentOffset = CGPoint(x: 0, y: self.collectionView.contentOffset.y + self.countViewHeight)
            })
        }*/
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
    
    
    /// 更新图片缓存设置
    fileprivate func updateCachedAssets() {
        // 视图可访问时才更新
        guard isViewLoaded && view.window != nil else {
            return
        }
        
        // 预加载视图的高度是可见视图的两倍，这样滑动时才不会有阻塞
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let preheatRect = visibleRect.insetBy(dx: 0, dy: -0.5 * visibleRect.height)
        
        // 只有可见视图与预加载视图有明显不同时，才会更新
        let delta = abs(preheatRect.maxY - previousPreheatRect.maxY)
        guard delta > view.bounds.height / 3 else {
            return
        }
        
        
        // 计算 assets 用来开始和结束缓存
        let (addedRects, removeRects) = differencesBetweenRects(previousPreheatRect, preheatRect)
        let addedAssets = addedRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect)}
            .map { indexPath in fetchAllPhtos.object(at: indexPath.item) }
        let removedAssets = removeRects
            .flatMap { rect in collectionView.indexPathsForElements(in: rect) }
            .map { indexPath in fetchAllPhtos.object(at: indexPath.item) }
        
        // 更新图片缓存
        imageManager.startCachingImages(for: addedAssets, targetSize: thumnailSize, contentMode: .aspectFill, options: nil)
        imageManager.stopCachingImages(for: removedAssets, targetSize: thumnailSize, contentMode: .aspectFill, options: nil)
        
        // 保存最新的预加载尺寸用来和后面的对比
        previousPreheatRect = preheatRect
    }
    
    
    /// 计算新旧位置的差值
    ///
    /// - Parameters:
    ///   - old: old description
    ///   - new: new description
    /// - Returns: return value description
    private func differencesBetweenRects(_ old: CGRect, _ new: CGRect) -> (added: [CGRect], removed: [CGRect]) {
        
        // 新旧有交集
        if old.intersects(new) {
            
            // 增加值
            var added = [CGRect]()
            if new.maxY > old.maxY {
                added += [CGRect(x: new.origin.x, y: old.maxY, width: new.width, height: new.maxY - old.maxY)]
            }
            if new.minY < old.minY {
                added += [CGRect(x: new.origin.x, y: new.minY, width: new.width, height: old.minY - new.minY)]
            }
            
            // 移除值
            var removed = [CGRect]()
            if new.maxY < old.maxY {
                removed += [CGRect(x: new.origin.x, y: new.maxY, width: new.width, height: old.maxY - new.maxY)]
            }
            if new.minY > old.minY {
                removed += [CGRect(x: new.origin.x, y: old.minY, width: new.width, height: new.minY - old.minY)]
            }
            
            return (added, removed)
        }
        
        // 没有交集
        return ([new], [old])
    }
    
}

extension MediaPickerViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,ImageBrowserDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchAllPhtos.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GridViewCell.cellIdentifier, for: indexPath) as! GridViewCell
        
        let asset = fetchAllPhtos.object(at: indexPath.item)
        cell.representAssetIdentifier = asset.localIdentifier
        // 从缓存中取出图片
        imageManager.requestImage(for: asset, targetSize: thumnailSize, contentMode: .aspectFill, options: nil) { img, _ in
            
            // 代码执行到这里时cell可能已经被重用了，所以设置标识用来展示
            if cell.representAssetIdentifier == asset.localIdentifier {
                cell.thumbnailImage = img
            }
        }
        
        // 防止重复
        if isOnlyOne {
            cell.hiddenIcons()
        } else {
            cell.cellIsSelected = flags[indexPath.item]
            cell.handleSelectionAction = { isSelected in
                
                // 判断是否超过最大值
                if self.selectedAssets.count > self.count - 1 && !cell.cellIsSelected {
                    self.showAlert(with: "haha")
                    cell.selectionIcon.isSelected = false
                    return
                }
                
                self.flags[indexPath.item] = isSelected
                cell.cellIsSelected = isSelected
                if isSelected{
                    self.selectedAssets.append(self.fetchAllPhtos.object(at: indexPath.item))
                    self.selectedImages.append(cell.thumbnailImage!)
                } else {
                    let deleteIndex1 = self.selectedAssets.index(of: self.fetchAllPhtos.object(at: indexPath.item))
                    self.selectedAssets.remove(at: deleteIndex1!)
                    self.selectedImages.remove(at: deleteIndex1!)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let bview = ImageBrowser()
        bview.delegate = self
        bview.bottomView = self.collectionView
        bview.indexImage = indexPath.row
        bview.number = indexPath
        bview.defaultImage = getColorImageWithColor()
        bview.arrayImage = self.fetchAllPhtos
        bview.show()
//        guard isOnlyOne else {
//            return
//        }
//        let currentCell = collectionView.cellForItem(at: indexPath) as! GridViewCell
//        handlePhotos?([fetchAllPhtos.object(at: indexPath.item)], [currentCell.thumbnailImage!])
//        dismissAction()
    }
    
    func getTheThumbnailImage(_ indexRow: Int) -> UIImage {
        let indexPath = IndexPath.init(row: indexRow, section: 0)
        if  let cell = collectionView.cellForItem(at: indexPath) as? GridViewCell {
           return cell.thumbnailImage!
        }else{
            return getColorImageWithColor()
        }
    }
    
    func selectedImageAction(indexItme: IndexPath) {
        NSLog("\(flags[indexItme.item])")
    }
    
    func imageSelectStatus(index:Int) -> Bool {
        return flags[index]
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateCachedAssets()
    }
    
    func showAlert(with title: String) {
        let alertVC = UIAlertController(title: "最多只能选择 \(count) 张图片", message: nil, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alertVC, animated: true, completion: nil)
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
    
    /// 获取可见视图内的所有对象，用于更高效刷新
    ///
    /// - Parameter rect: rect description
    /// - Returns: return value description
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
