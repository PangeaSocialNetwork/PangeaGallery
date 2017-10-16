//
//  ViewController.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/8/28.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit
import Photos
class ViewController: UIViewController ,PangeaMediaPickerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func touchButton(_ sender: Any) {
        let build = BuildMediePicker()
        let mediePicker = build.getNewMediePicker()
        mediePicker?.pangeaMediaPickerDelegate = self
        mediePicker?.maxCount = 8
        self.navigationController?.pushViewController(mediePicker!, animated: true)
    }
   public func callBackSelectImages(selectAssets: [PHAsset], selectImages: [UIImage]) {
        for imges in 0..<selectImages.count {
            let imgaeView = UIImageView()
            imgaeView.frame = CGRect(x: imges*50, y: 64, width: 50, height: 50)
            self.view.addSubview(imgaeView)
            imgaeView.image = selectImages[imges]
        }
    }

}
