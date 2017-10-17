//
//  buildMediePicker.swift
//  PangeaMediaPicker
//
//  Created by Roger Li on 2017/10/16.
//  Copyright © 2017年 Roger Li. All rights reserved.
//

import UIKit

open class BuildMediePicker: NSObject {
    open class func getNewMediePicker() -> MediaPickerViewController? {
        let bundle = Bundle.init(identifier: "org.cocoapods.PangeaMediaPicker")
        let storyboard = UIStoryboard(name: "ImagePicker", bundle: bundle)
        if let pickerVC = storyboard.instantiateViewController(withIdentifier: "PickerView") as? MediaPickerViewController {
            return pickerVC
        } else {
            return nil
        }
    }
}
