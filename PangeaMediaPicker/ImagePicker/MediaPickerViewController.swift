//
//  MediaPickerViewController.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/28.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit
import Photos
public protocol PangeaMediaPickerDelegate: class {
    func callBackSelectImages(selectAssets:[PHAsset], selectImages: [UIImage])
}

open class MediaPickerViewController: UIViewController {
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var imageCountView: UIView!
    // MARK: - Properties
    @IBOutlet var mainTableView: UITableView!
    @IBOutlet var tableViewBotton: NSLayoutConstraint!
    let screenHeight = UIScreen.main.bounds.size.height
    // The width of the screen
    let screenWidth = UIScreen.main.bounds.size.width
    let allOptions = PHFetchOptions()
    var allPhotos: PHFetchResult<PHAsset>!
    var smartAlbums: PHFetchResult<PHAssetCollection>!
    var userCollections: PHFetchResult<PHCollection>!
    var smartAlbumsArray = [PHAssetCollection]()
    var handleSelectionAction: (([String], [String]) -> Void)?
    let imageManager = PHCachingImageManager()
    var thumnailSize = CGSize()
    fileprivate var previousPreheatRect = CGRect.zero
    @IBOutlet var countView: UIView!
    @IBOutlet var countLable: UILabel!
    @IBOutlet var countButton: UIButton!
    @IBOutlet var navTitleLable: UILabel!
    @IBOutlet var navImageView: UIImageView!
    fileprivate var isOpen = false
    var cellIndexArray = [IndexPath]()
    var curryIndexPath = IndexPath(row: 0, section: 0)
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
    fileprivate let shape: CGFloat = 1
    fileprivate var numbersInSingleLine: CGFloat = 4
    fileprivate var cellWidth: CGFloat?

    // All images
    internal var fetchAllPhtos: PHFetchResult<PHAsset>!
    // Only one album
    internal var assetCollection: PHAssetCollection!

    private func setupUI() {
        let cvLayout = UICollectionViewFlowLayout()
        cvLayout.itemSize = CGSize(width: cellWidth!, height: cellWidth!)
        cvLayout.minimumLineSpacing = shape
        cvLayout.minimumInteritemSpacing = shape
        cvLayout.headerReferenceSize = CGSize(width: screenWidth, height: 1)
        collectionView.setCollectionViewLayout(cvLayout, animated: false)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    private func setupTableView() {
        mainTableView.delegate = self
        mainTableView.dataSource = self
        tableViewBotton.constant = screenHeight
    }
    // Image select end
    override open func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.uiReSet), name:NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        automaticallyAdjustsScrollViewInsets = false
        resetCachedAssets()
        PHPhotoLibrary.shared().register(self)
        isOnlyOne = maxCount == 1 ? true : false
        cellWidth =  (min(screenWidth, screenHeight) - numbersInSingleLine+1)/numbersInSingleLine
        setupUI()
        setupTableView()
        if fetchAllPhtos == nil {
            allOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            allOptions.includeAssetSourceTypes = [.typeUserLibrary, .typeCloudShared, .typeiTunesSynced]
            fetchAllPhtos = PHAsset.fetchAssets(with: allOptions)
            collectionView.reloadData()
        }
        (0 ..< fetchAllPhtos.count).forEach { _ in
            flags.append(false)
        }
        fetchAlbumsFromSystemAlbum()
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        thumnailSize = CGSize(width: cellWidth! * UIScreen.main.scale, height: cellWidth! * UIScreen.main.scale)
    }

    @objc func uiReSet() {
        if screenWidth <  UIScreen.main.bounds.size.width {
            numbersInSingleLine = 7
            cellWidth =  (UIScreen.main.bounds.size.width - numbersInSingleLine+1)/numbersInSingleLine
        } else {
            numbersInSingleLine = 4
            cellWidth =  (min(screenWidth, screenHeight) - numbersInSingleLine+1)/numbersInSingleLine
        }
        setupUI()
        if tableViewBotton.constant != 0 {
            tableViewBotton.constant = UIScreen.main.bounds.size.height
        }
    }

    func changeAlbum(gridFetchAllPhtos: PHFetchResult<PHAsset>, assetCollection: PHAssetCollection, titleStr: String) {
        fetchAllPhtos = gridFetchAllPhtos
        navTitleLable.text = titleStr
        collectionView.reloadData()
        handleTapGesture()
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
                self.tableViewBotton.constant = UIScreen.main.bounds.height
            }
            self.view.layoutIfNeeded()
        }) { (finished) in
            if finished {
                self.isOpen = !self.isOpen
            }
        }
    }

    deinit {
        self.mainTableView = nil
        self.collectionView = nil
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
        NotificationCenter.default.removeObserver(self)
    }

    // - Parameter photoCount: photoCount description
    private func updateCountView(with photoCount: Int) {
        countLable.text = String(describing: photoCount)
        if photoCount == 0 {
            imageCountView.backgroundColor = UIColor(red: 107/255, green: 107/255, blue: 107/255, alpha: 1)
        } else {
            imageCountView.backgroundColor = UIColor(red: 91/255, green: 175/255, blue: 56/255, alpha: 1)
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
