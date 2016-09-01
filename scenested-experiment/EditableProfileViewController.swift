//
//  EditableProfileViewController.swift
//  scenested-experiment
//
//  Created by Xie kesong on 6/28/16.
//  Copyright © 2016 ___Scenested___. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

class EditableProfileViewController: StrechableHeaderViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
  
    // MARK:: Avator, Cover tap gesture configuration
    func tapAvator(sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Change Profile Picture", message: nil, preferredStyle: .ActionSheet)
        let chooseExistingAction = UIAlertAction(title: "Choose from Library", style: .Default, handler: { (action) -> Void in
            self.chooseFromLibarary()
        })
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler:
            {(action) -> Void in
                self.takePhoto()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (action) -> Void in
            self.finishImagePicker()
        })
        
        alert.addAction(takePhotoAction)
        alert.addAction(chooseExistingAction)
        alert.addAction(cancelAction)
        imagePickerUploadPhotoFor = UploadPhotoFor.profileAvator
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func tapCover(sender: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Change Profile Cover", message: nil, preferredStyle: .ActionSheet)
        let chooseExistingAction = UIAlertAction(title: "Choose from Library", style: .Default, handler: { (action) -> Void in
            self.chooseFromLibarary()
        })
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {
            (action) -> Void in
            self.takePhoto()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        alert.addAction(takePhotoAction)
        alert.addAction(chooseExistingAction)
        alert.addAction(cancelAction)
        imagePickerUploadPhotoFor = UploadPhotoFor.profileCover
        self.presentViewController(alert, animated: true, completion: nil)
    }
 
}