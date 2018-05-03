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

class CameraHandler: NSObject{
    static let shared = CameraHandler()
    var isFromchat = false
    
    fileprivate var currentVC: UIViewController!
    
    //MARK: Internal Properties
    var didFinishCapturingImage: ((UIImage,URL?) -> Void)?
    var didFinishCapturingVideo: ((_ videoURL: URL) -> Void)?

    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .camera
            myPickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]

            currentVC.navigationController?.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func photoLibrary()
    {
        
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let myPickerController = UIImagePickerController()
            myPickerController.delegate = self;
            myPickerController.sourceType = .photoLibrary
            myPickerController.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
            currentVC.navigationController?.present(myPickerController, animated: true, completion: nil)
        }
        
    }
    
    func showCamera(vc: UIViewController) {
        currentVC = vc
        self.camera()
    }
    func showPhotoLibrary(vc: UIViewController) {
        currentVC = vc
        self.photoLibrary()
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
}


extension CameraHandler: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        currentVC.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        if mediaType == kUTTypeImage as String {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                if let imgUrl = info[UIImagePickerControllerImageURL] as? URL{
                    let imgName = imgUrl.lastPathComponent
                    print(imgName)
                    self.didFinishCapturingImage?(image, imgUrl)
                    }
                else {
                    if let data = UIImageJPEGRepresentation(image, 1.0) {
                        let strFilePath = GlobalShareData.sharedGlobal.storeGenericfileinDocumentDirectory(fileContent: data as NSData, fileName:"temp.png")
                        self.didFinishCapturingImage?(image, URL.init(string: strFilePath))

                    }
                }
            }
        } else if mediaType == kUTTypeMovie as String {
            if  let videoURL = info[UIImagePickerControllerMediaURL] as? URL {
                self.didFinishCapturingVideo?(videoURL)
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
