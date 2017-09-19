//
//  MediaPickerViewController.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/28.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit
import Photos
protocol PangeaMediaPickerDelegate: class {
    func callBackSelectImages(selectAssets:[PHAsset], selectImages: [UIImage])
}

class MediaPickerViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    // MARK: - Properties
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet var tableViewBotton: NSLayoutConstraint!
    let screenHeight = UIScreen.main.bounds.size.height
    // The width of the screen
    let screenWidth = UIScreen.main.bounds.size.width
    var allPhotos: PHFetchResult<PHAsset>!
    var smartAlbums: PHFetchResult<PHAssetCollection>!
    var userCollections: PHFetchResult<PHCollection>!
    var handleSelectionAction: (([String], [String]) -> Void)?
    let imageManager = PHCachingImageManager()
    var thumnailSize = CGSize()
    fileprivate var previousPreheatRect = CGRect.zero
    @IBOutlet var countView: UIView!
    @IBOutlet var countLable: UILabel!
    @IBOutlet var countButton: UIButton!
    @IBOutlet var navTitleLable: UILabel!
    @IBOutlet var navImageView: UIImageView!
    fileprivate var isShowCountView = false
    fileprivate var isOpen = false
    var cellIndexArray = [IndexPath]()
    var isOnlyOne = true
    // Select max count
    var maxCount: Int = 0
    weak var pangeaMediaPickerDelegate: PangeaMediaPickerDelegate?
    var selectedAssets = [PHAsset]() {
        willSet {
            updateCountView(with: newValue.count)
        }
    }
    var selectedImages = [UIImage]()
    var flags = [Bool]()
    fileprivate  var index: Double = 1.00
    fileprivate let shape: CGFloat = 3
    fileprivate let numbersInSingleLine: CGFloat = 4
    fileprivate var cellWidth: CGFloat? {
        return (UIScreen.main.bounds.width - (numbersInSingleLine - 1) * shape) / numbersInSingleLine
    }

    // All images
    internal var fetchAllPhtos: PHFetchResult<PHAsset>!
    // Only one album
    internal var assetCollection: PHAssetCollection!

    private func setupUI() {
        let cvLayout = UICollectionViewFlowLayout()
        cvLayout.itemSize = CGSize(width: cellWidth!, height: cellWidth!)
        cvLayout.minimumLineSpacing = shape
        cvLayout.minimumInteritemSpacing = shape
//        self.view.translatesAutoresizingMaskIntoConstraints = false
        collectionView.setCollectionViewLayout(cvLayout, animated: false)
        collectionView.dataSource = self
        collectionView.delegate = self
        mainTableView.delegate = self
        mainTableView.dataSource = self
        tableViewBotton.constant = screenHeight
    }
    // Image select end
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        isOnlyOne = maxCount == 1 ? true : false
        setupUI()
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
        fetchAlbumsFromSystemAlbum()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.isHidden = true
        thumnailSize = CGSize(width: cellWidth! * UIScreen.main.scale, height: cellWidth! * UIScreen.main.scale)
        let indexPath = IndexPath(item: fetchAllPhtos.count - 1, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: false)
    }

    func changeAlbum(gridFetchAllPhtos: PHFetchResult<PHAsset>, assetCollection: PHAssetCollection, titleStr: String) {
        fetchAllPhtos = gridFetchAllPhtos
        navTitleLable.text = titleStr
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

    @IBAction func backButtonAction(_ sender: UIButton) {
        dismissAction()
    }

    @IBAction func titleLableAcion(_ sender: UIButton) {
        handleTapGesture()
    }

    @IBAction func selectedOverAction(_ sender: Any) {
        pangeaMediaPickerDelegate?.callBackSelectImages(selectAssets: selectedAssets, selectImages: selectedImages)
        dismissAction()
    }

    func startAnimation() {
        UIView.animate(withDuration: 0.35, animations: {
            if !self.isOpen {
                self.navImageView.transform = CGAffineTransform(rotationAngle: .pi)
                self.tableViewBotton.constant = 0
            } else {
                self.navImageView.transform = .identity
                self.tableViewBotton.constant = self.screenHeight
            }
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                self.isOpen = !self.isOpen
            }
        }
        countViewHides(isHides: !self.isOpen)
    }

    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }

    // - Parameter photoCount: photoCount description
    private func updateCountView(with photoCount: Int) {

        countLable.text = String(describing: photoCount)
        if isShowCountView && photoCount != 0 {
            return
        }
    }
    //Add back button
    func dismissAction() {
        self.navigationController?.popViewController(animated: true)
    }

    // MARK: PHAsset Caching
    private func resetCachedAssets() {
        imageManager.stopCachingImagesForAllAssets()
        previousPreheatRect = .zero
    }
}
// MARK: - UICollectionView Extension
private extension UICollectionView {
    func indexPathsForElements(in rect: CGRect) -> [IndexPath] {
        let allLayoutAttributes = collectionViewLayout.layoutAttributesForElements(in: rect)!
        return allLayoutAttributes.map { $0.indexPath }
    }
}
