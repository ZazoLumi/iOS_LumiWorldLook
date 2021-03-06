//
//  CameraHandler.swift
//  theappspace.com
//
//  Created by Dejan Atanasov on 26/06/2017.
//  Copyright © 2017 Dejan Atanasov. All rights reserved.
//
import Foundation
import UIKit
import Photos
import MobileCoreServices
import YPImagePicker
import AVFoundation

class CameraHandler: NSObject{
    static let shared = CameraHandler()
    var isFromchat = false
    var isVideoCapturing = false
    var isFromProfile = false
    var isGallary = false
    fileprivate var currentVC: UIViewController!
    
    //MARK: Internal Properties
    var didFinishCapturingImage: ((UIImage,URL?) -> Void)?
    var didFinishCapturingVideo: ((_ videoURL: URL,UIImage) -> Void)?

    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            myPickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            currentVC?.navigationController?.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func photoLibrary() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            myPickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            myPickerController.navigationController?.setNavigationBarHidden(false, animated: true)
            myPickerController.navigationController?.hidesBarsOnSwipe = false
            myPickerController.navigationController?.navigationBar.barTintColor = UIColor.blue // Background color
            myPickerController.navigationController?.navigationBar.isHidden = false
            myPickerController.navigationController?.navigationBar.tintColor = UIColor.black
            myPickerController.navigationController?.navigationBar.titleTextAttributes = [
                kCTForegroundColorAttributeName as NSAttributedString.Key : UIColor.white]
            currentVC?.navigationController?.navigationBar.isHidden = false

            currentVC?.present(myPickerController, animated: true, completion: nil)
        }
    }
    
    func showPicker() {
        
        // Configuration
        var config = YPImagePickerConfiguration()
        
        // Uncomment and play around with the configuration 👨‍🔬 🚀
        
        //        /// Set this to true if you want to force the  library output to be a squared image. Defaults to false
        //        config.onlySquareImagesFromLibrary = true
        //
        //        /// Set this to true if you want to force the camera output to be a squared image. Defaults to true
        //        config.onlySquareImagesFromCamera = false
        //
        //        /// Ex: cappedTo:1024 will make sure images from the library will be
        //        /// resized to fit in a 1024x1024 box. Defaults to original image size.
        //        config.libraryTargetImageSize = .cappedTo(size: 1024)
        //
        //        /// Enables videos within the library. Defaults to false
       // config.library.mediaType = YPlibraryMediaType.video
        config.library.mediaType = .photoAndVideo

        //
        //        /// Enables selecting the front camera by default, useful for avatars. Defaults to false
        //        config.usesFrontCamera = true
        //
        //        /// Adds a Filter step in the photo taking process.  Defaults to true
        config.showsPhotoFilters = true
        //
        //        /// Enables you to opt out from saving new (or old but filtered) images to the
        //        /// user's photo library. Defaults to true.
        //        config.shouldSaveNewPicturesToAlbum = false
        //
        //        /// Choose the videoCompression.  Defaults to AVAssetExportPresetHighestQuality
        config.video.compression = AVAssetExportPreset640x480
        //
        //        /// Defines the name of the album when saving pictures in the user's photo library.
        //        /// In general that would be your App name. Defaults to "DefaultYPImagePickerAlbumName"
        //        config.albumName = "ThisIsMyAlbum"
        //
        //        /// Defines which screen is shown at launch. Video mode will only work if `showsVideo = true`.
        //        /// Default value is `.photo`
        if isVideoCapturing {config.startOnScreen = .library }
        else {config.startOnScreen = .photo}
        //
        //        /// Defines which screens are shown at launch, and their order.
        //        /// Default value is `[.library, .photo]`
        if isFromProfile {
            if isGallary{
                config.screens = [.library,]
                config.startOnScreen = .library
            }
            else {
                config.screens = [.photo,]
                config.startOnScreen = .photo

            }
        }
        else {
            config.screens = [.library, .photo, .video] }
        //
        //        /// Defines the time limit for recording videos.
        //        /// Default is 30 seconds.
        config.video.recordingTimeLimit = 15.0
        //
        //        /// Defines the time limit for videos from the library.
        //        /// Defaults to 60 seconds.
        config.video.libraryTimeLimit = 600.0
        //
        //        /// Adds a Crop step in the photo taking process, after filters.  Defaults to .none
      //  config.showsCrop = .rectangle(ratio: (10/8))
        
        //        /// Defines the overlay view for the camera.
        //        /// Defaults to UIView().
        //        let overlayView = UIView()
        //        overlayView.backgroundColor = .red
        //        overlayView.alpha = 0.3
        //        config.overlayView = overlayView
        
        // Customize wordings
        config.wordings.libraryTitle = "Gallery"
        
        /// Defines if the status bar should be hidden when showing the picker. Default is true
        config.hidesStatusBar = false
        
        // Set it the default conf for all Pickers
        //      YPImagePicker.setDefaultConfiguration(config)
        // And then use the default configuration like so:
        //      let picker = YPImagePicker()
        
        // Here we use a per picker configuration.
        let picker = YPImagePicker(configuration: config)
        
        // unowned is Mandatory since it would create a retain cycle otherwise :)

//        picker.didSelectImage = { [unowned picker] img in
//            // image picked
//            print(img.size)
//            if let data = UIImageJPEGRepresentation(img, 1.0) {
//                let strFilePath = GlobalShareData.sharedGlobal.storeGenericfileinDocumentDirectory(fileContent: data as NSData, fileName:"temp.png")
//                self.didFinishCapturingImage?(img, URL.init(string: strFilePath))
//            }
//
//           // self.imageView.image = img
//            picker.dismiss(animated: true, completion: nil)
//        }
//        picker.didSelectVideo = { [unowned picker] videoData, videoThumbnailImage, url in
//            // video picked
//           // self.imageView.image = videoThumbnailImage
//            self.didFinishCapturingVideo?(url,videoThumbnailImage)
//            picker.dismiss(animated: true, completion: nil)
//        }
        

        picker.didFinishPicking { [unowned picker] items, cancelled in
            if let photo = items.singlePhoto {
                if let data = photo.image.jpegData(compressionQuality: 1.0) {
                    let strFilePath = GlobalShareData.sharedGlobal.storeGenericfileinDocumentDirectory(fileContent: data as NSData, fileName:"temp.png")
                    if !self.checkFileSize(strFilePath: strFilePath) {
                        return
                    }

                    self.didFinishCapturingImage?(photo.image, URL.init(string: strFilePath))
                }
            }

           else if let video = items.singleVideo {
                print(video.fromCamera)
                print(video.thumbnail)
                print(video.url)
                let fileUrl = video.url.absoluteString.replacingOccurrences(of: "file://", with: "")
                if !self.checkFileSize(strFilePath: fileUrl) {
                    return
                }
                
                self.didFinishCapturingVideo?(video.url,video.thumbnail)
            }

           else if cancelled {
                print("Picker was canceled")
            }
            picker.dismiss(animated: true, completion: nil)
        }
        picker.navigationItem.addBackButtonOnLeft()
        picker.navigationBar.tintColor = UIColor.lumiGreen
        #if swift(>=4.0)
        picker.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.init(red: 38/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1.0), NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16.0)]
        #elseif swift(>=3.0)
        picker.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.init(red: 38/255.0, green: 38/255.0, blue: 38/255.0, alpha: 1.0), NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16.0)];
        #endif

        currentVC?.present(picker, animated: true, completion: nil)
    }

    func showCamera(vc: UIViewController) {
        currentVC = vc
        self.showPicker()
    }
    func showPhotoLibrary(vc: UIViewController) {
        currentVC = vc
        self.showPicker()
    }
    func showProfileActionSheet(vc: UIViewController,withDeletePhoto :Bool) {
        currentVC = vc
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if withDeletePhoto {
        let deleteAction = UIAlertAction(title: "Delete Photo", style: .default) { (alert:UIAlertAction!) -> Void in
            let img = UIImage.init(named: "whiteBG")
            if let data = img?.jpegData(compressionQuality: 0.8) {
                let path = GlobalShareData.sharedGlobal.storeGenericfileinDocumentDirectory(fileContent: data as NSData, fileName: "whiteBG.png")
                self.didFinishCapturingImage?(img!, URL.init(string: path))
            }
        }
        deleteAction.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheet.addAction(deleteAction)
        }
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.isGallary = false
            self.showCamera(vc: vc)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.isGallary = true
            self.showPhotoLibrary(vc: vc)
        }))
        
        let cancelAction = UIAlertAction(title:"Cancel", style:.cancel)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        actionSheet.addAction(cancelAction)
        
        vc.present(actionSheet, animated: true, completion: nil)
    }

    func showActionSheet(vc: UIViewController) {
        currentVC = vc
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))
        
        let cancelAction = UIAlertAction(title:"Cancel", style:.cancel)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")

        actionSheet.addAction(cancelAction)

        vc.present(actionSheet, animated: true, completion: nil)
    }
    
    func checkFileSize(strFilePath : String) -> Bool {
        do {
            let fileSize = try (FileManager.default.attributesOfItem(atPath: strFilePath) as NSDictionary).fileSize() as NSNumber
            let totalSpace = fileSize.uint64Value
            print("Total MB \((totalSpace/1024)/1024)")
            let sizeInMB = (totalSpace/1024)/1024
            if sizeInMB > 10 {
                let actionSheet = UIAlertController(title: "File size", message: "The file size must be less then 10MB", preferredStyle: .actionSheet)
                actionSheet.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (alert:UIAlertAction!) -> Void in
                }))
                currentVC.present(actionSheet, animated: true, completion: nil)
                return false
            }
        }
         catch let error {
            print(error)
        }
        return true
    }
}


extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! String
        
        if mediaType == kUTTypeImage as String {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                if #available(iOS 11.0, *) {
                    if let imgUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL{
                        let imgName = imgUrl.lastPathComponent
                        print(imgName)
                        self.didFinishCapturingImage?(image, imgUrl)
                    }
                    else {
                        if let data = image.jpegData(compressionQuality: 1.0) {
                            let strFilePath = GlobalShareData.sharedGlobal.storeGenericfileinDocumentDirectory(fileContent: data as NSData, fileName:"temp.png")
                            self.didFinishCapturingImage?(image, URL.init(string: strFilePath))
                            
                        }
                    }
                } else {
                    // Fallback on earlier versions
                }
            }
        } else if mediaType == kUTTypeMovie as String {
            if  let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                self.didFinishCapturingVideo?(videoURL,UIImage.init())
            }
        }
        
        //        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
        //            if let imgUrl = info[UIImagePickerControllerImageURL] as? URL{
        //                 let imgName = imgUrl.lastPathComponent
        //                    print(imgName)
        //                    self.didFinishCapturingImage?(image, imgName)
        //            }
        //            else {
        //                self.didFinishCapturingImage?(image, "test.png")
        //            }
        //        }else{
        //            print("Something went wrong")
        //        }
        currentVC.dismiss(animated: true, completion: nil)

    }
    
}
