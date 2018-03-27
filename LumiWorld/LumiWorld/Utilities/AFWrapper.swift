//
//  AFWrapper.swift
//  PlayersPathway
//
//  Created by Impero-Azharhussain on 29/05/17.
//  Copyright © 2016 Impero It. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import L10n_swift
//MARK: - GlobalUse
class AFWrapper: NSObject  {
    
     //Bearer
     class func requestGETURL(_ strURL: String, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void) {
        
          Alamofire.request(strURL).responseJSON { (responseObject) -> Void in
            
            if GlobalShareData.sharedGlobal.isDebug(){
                debugPrint(#line)
                debugPrint(#function)
                debugPrint(responseObject)
            }
               if responseObject.result.isSuccess {
                    let resJson = JSON(responseObject.result.value!)
                    success(resJson)
               }
               if responseObject.result.isFailure {
                    let error : Error = responseObject.result.error!
                    failure(error)
               }
          }
     }
     
     class func requestPOSTURL(_ strURL : String, params : [String : AnyObject]?, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
          
        let heder : HTTPHeaders = ["Accept-Language":L10n.shared.language]
          Alamofire.request(strURL, method: .post, parameters: params, headers: heder).responseJSON { (responseObject) -> Void in
            
            if GlobalShareData.sharedGlobal.isDebug(){
                debugPrint(#line)
                debugPrint(#function)
                debugPrint(responseObject)
            }
            
               if responseObject.result.isSuccess {
                    let resJson = JSON(responseObject.result.value!)
                    success(resJson)
               }
               if responseObject.result.isFailure {
                    let error : Error = responseObject.result.error!
                    failure(error)
               }
          }
     }
    class func requestPOSTURLAq(_ strURL : String, params : [String : AnyObject]?, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        
        let token = UserDefaults.standard.string(forKey: "authtoken")
        let heder : HTTPHeaders = ["Authorization": "Bearer " + token!,
                                   "Accept-Language":L10n.shared.language]
        Alamofire.request(strURL, method: .post, parameters: params, encoding: JSONEncoding.default, headers: heder).responseJSON { (responseObject) -> Void in
            if GlobalShareData.sharedGlobal.isDebug(){
                debugPrint(#line)
                debugPrint(#function)
                debugPrint(responseObject)
            }
            guard responseObject.result.isSuccess else {
                
                failure(NSError())
                return;
            }
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
    class func requestPOSTURLAuth(_ strURL : String, params : [String : AnyObject]?, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
         let token = UserDefaults.standard.string(forKey: "authtoken")
        let heder : HTTPHeaders = ["Authorization": "Bearer " + token!,
                                   "Accept-Language":L10n.shared.language]
        
        Alamofire.request(strURL, method: .post, parameters: params, headers: heder).responseJSON { (responseObject) -> Void in
            
            if GlobalShareData.sharedGlobal.isDebug(){
                debugPrint(#line)
                debugPrint(#function)
                debugPrint(responseObject)
            }
            
            if responseObject.result.isSuccess {
                let resJson = JSON(responseObject.result.value!)
                success(resJson)
            }
            if responseObject.result.isFailure {
                let error : Error = responseObject.result.error!
                failure(error)
            }
        }
    }
     class func requestGETAuthURL(_ strURL : String, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        let token = UserDefaults.standard.string(forKey: "authtoken")
        let heder : HTTPHeaders = ["Authorization": "Bearer " + token!,
                                   "Accept-Language":L10n.shared.language]
        
          Alamofire.request(strURL, method: .get, headers: heder).responseJSON { (responseObject) -> Void in
               
            if GlobalShareData.sharedGlobal.isDebug(){
                debugPrint(#line)
                debugPrint(#function)
                debugPrint(responseObject)
            }
               
               if responseObject.result.isSuccess {
                    let resJson = JSON(responseObject.result.value!)
                    success(resJson)
               }
               if responseObject.result.isFailure {
                    let error : Error = responseObject.result.error!
                    failure(error)
               }
          }
     }
     
     
     
     class func requestPUTURL(_ strURL : String, params : [String : AnyObject]?, headers : [String : String]?, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
          
          Alamofire.request(strURL, method: .put, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON { (responseObject) -> Void in
               
            if GlobalShareData.sharedGlobal.isDebug(){
                debugPrint(#line)
                debugPrint(#function)
                debugPrint(responseObject)
            }
               
               if responseObject.result.isSuccess {
                    let resJson = JSON(responseObject.result.value!)
                    success(resJson)
               }
               if responseObject.result.isFailure {
                    let error : Error = responseObject.result.error!
                    failure(error)
               }
          }
     }
    class func requestPOSTURLWITHIMAGEAUTH(_ strURL : String, headers : [String : String]?, image: UIImage, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        
        let token = UserDefaults.standard.string(forKey: "authtoken")
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImageJPEGRepresentation(image, 0.5)!, withName: "file", fileName: "file.png", mimeType: "image/png")
        }, to:strURL,headers:["Authorization": "Bearer " + token!,
                            "Accept-Language":L10n.shared.language])
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    if GlobalShareData.sharedGlobal.isDebug(){
                        debugPrint(#line)
                        debugPrint(#function)
                        debugPrint(response)
                    }
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                    else {
                        failure(NSError())
                    }
                    let resJson = JSON(response.result.value!)
                    success(resJson)
                }
                
                
            case .failure(let encodingError):
                //self.delegate?.showFailAlert()
                
                
                failure(encodingError)
                print(encodingError)
            }
            
        }
        
    }
    class func requestPOSTURLWITHOUTHAUTHPARAM(_ strURL : String, params : [String : AnyObject]?, headers : [String : String]?, image: UIImage, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImageJPEGRepresentation(image, 0.5)!, withName: "file", fileName: "file.png", mimeType: "image/png")
            for (key, value) in params! {
                multipartFormData.append("\(value)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }
        }, to:strURL,headers:["Accept-Language":L10n.shared.language])
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                upload.responseJSON { response in
                    if GlobalShareData.sharedGlobal.isDebug(){
                        debugPrint(#line)
                        debugPrint(#function)
                        debugPrint(response)
                    }
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                    else {
                        failure(NSError())
                    }
                    let resJson = JSON(response.result.value!)
                    success(resJson)
                }
                
                
            case .failure(let encodingError):
                //self.delegate?.showFailAlert()
                
                
                failure(encodingError)
                print(encodingError)
            }
            
        }
        
    }
    class func requestPOSTURLWITHIMAGEAUTHWITHPARAM(_ strURL : String, params : [String : AnyObject]?, headers : [String : String]?, image: UIImage, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        
        let token = UserDefaults.standard.string(forKey: "authtoken")
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(UIImageJPEGRepresentation(image, 0.5)!, withName: "file", fileName: "file.png", mimeType: "image/png")
            for (key, value) in params! {
                multipartFormData.append("\(value)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }
        }, to:strURL,headers:["Authorization": "Bearer " + token!,"Accept-Language":L10n.shared.language])
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    if GlobalShareData.sharedGlobal.isDebug(){
                        debugPrint(#line)
                        debugPrint(#function)
                        debugPrint(response)
                    }
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                    else {
                        failure(NSError())
                    }
                    let resJson = JSON(response.result.value!)
                    success(resJson)
                }
                
                
            case .failure(let encodingError):
                //self.delegate?.showFailAlert()
                
                
                failure(encodingError)
                print(encodingError)
            }
            
        }
        
    }
    class func requestPOSTURLWITHVIDEOANDIMAGE(_ strURL : String, params : [String : AnyObject]?, headers : [String : String]?,image:UIImage, Url: URL, success:@escaping (JSON) -> Void, failure:@escaping (Error) -> Void){
        let token = UserDefaults.standard.string(forKey: "authtoken")
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(Url, withName: "", fileName: "video.mp4", mimeType: "video/mp4")
            multipartFormData.append(UIImageJPEGRepresentation(image, 0.5)!, withName: "file", fileName: "file.png", mimeType: "image/png")
            // here you can upload any type of video
            //multipartFormData.append(self.selectedVideoURL!, withName: "File1")
          //  multipartFormData.append(("VIDEO".data(using: String.Encoding.utf8, allowLossyConversion: false))!, withName: "Type")
            
           // multipartFormData.append(UIImageJPEGRepresentation(image, 0.5)!, withName: "file", fileName: "file.png", mimeType: "image/png")
            for (key, value) in params! {
                multipartFormData.append("\(value)".data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
            }
        }, to:strURL , headers:["Authorization": "Bearer " + token!])
        { (result) in
            switch result {
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (Progress) in
                    print("Upload Progress: \(Progress.fractionCompleted)")
                })
                
                upload.responseJSON { response in
                    
                    if GlobalShareData.sharedGlobal.isDebug(){
                        debugPrint(#line)
                        debugPrint(#function)
                        debugPrint(response)
                    }
                    
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
                    else {
                        failure(NSError())
                    }
                    let resJson = JSON(response.result.value!)
                    success(resJson)
                }
                
                
            case .failure(let encodingError):
                //self.delegate?.showFailAlert()
                failure(encodingError)
                print(encodingError)
            }
            
        }
        
    }
     
     
}
