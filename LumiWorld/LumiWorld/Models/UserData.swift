//
//  UserData.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/23.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import Foundation
import SwiftyJSON
import  RealmSwift
import MBProgressHUD

class UserData : Object{
    
   @objc private(set) dynamic var id = 0
    @objc dynamic var createDate: String? = nil
   @objc dynamic var password: String? = nil
   @objc dynamic var status: String? = nil
   @objc dynamic var cell: String? = nil
   @objc dynamic var appVersion: String? = nil
   @objc dynamic var lastName: String? = nil
    @objc dynamic var updateDate: String? = nil
    @objc dynamic var token: String? = nil
    @objc dynamic var profilePic: String? = nil
   @objc dynamic var gcmId: String? = nil
    @objc dynamic var firstName: String? = nil
    @objc dynamic var displayName: String? = nil
    @objc dynamic var emailAddress: String? = nil

//    init(json : JSON){
//        self.id = json["id"].intValue
//        self.gcmId = json["gcmId"].stringValue
//        self.profilePic = json["profilePic"].stringValue
//        self.token = json["token"].stringValue
//        self.updateDate = json["updateDate"].stringValue
//        self.lastName = json["lastName"].stringValue
//        self.appVersion = json["appVersion"].stringValue
//        self.cell = json["cell"].stringValue
//        self.status = json["status"].stringValue
//        self.password = json["password"].stringValue
//        self.createDate = json["createDate"].stringValue
//        self.displayName = json["displayName"].stringValue
//        self.firstName = json["firstName"].stringValue
//    }
    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(id : Int, gcmId: String?, profilePic : String? , token: String?, updateDate: String?, lastName: String?, appVersion: String?, cell: String?, status: String?, password: String?, createDate: String?, displayName: String?, firstName: String?,emailAddress:String?) {
        self.init()
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.gcmId = gcmId
        self.profilePic = profilePic
        self.token = token
        self.updateDate = updateDate
        self.lastName = lastName
        self.appVersion = appVersion
        self.cell = cell
        self.status = status
        self.password = password
        self.createDate = createDate
        self.displayName = displayName
        self.emailAddress = emailAddress

    }
    
    func loginUserDetails(param:[String:AnyObject],completionHandler: @escaping (_ result: UserData) -> Void) {
        let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APILogin)"
        AFWrapper.requestPOSTURL(urlString, params: param as [String : AnyObject], headers: nil, success: { (json) in
            //                let userObj = UserData(json:json)
            let tempDict = json.dictionary
            MBProgressHUD.hide(for: (appDelInstance().window?.rootViewController?.view)!, animated: true)
            guard let code = tempDict!["responsCode"]?.intValue, code != 0 else {
                let message = tempDict!["response"]?.string
                (appDelInstance().window?.rootViewController)?.showCustomAlert(strTitle: "", strDetails: message!, completion: { (str) in
                })
                return
            }
            let realm = try! Realm()
            let id : Int = json["id"].intValue
            let data  = realm.objects(UserData.self).filter("id == %d", id)
            let newObj = UserData(id : id , gcmId : json["gcmId"].string,profilePic : json["profilePic"].string,token : json["token"].string,updateDate : json["updateDate"].string,lastName : json["lastName"].string,appVersion : json["appVersion"].string,cell : json["cell"].string,status : json["status"].string,password : json["password"].string,createDate : json["createDate"].string,displayName : json["displayName"].string,firstName : json["firstName"].string,emailAddress: json["email"].string)
            
            GlobalShareData.sharedGlobal.objCurrentUserDetails = newObj
            GlobalShareData.sharedGlobal.userCellNumber = newObj.cell
            if data.count>0 {
                GlobalShareData.sharedGlobal.realmManager.editObjects(objs: newObj)
            }
            else {
                GlobalShareData.sharedGlobal.realmManager.saveObjects(objs: newObj)
            }
            if json["profilePic"].string != nil, ((json["profilePic"].string)?.count)! > 0 {
                self.downloadNewProfilePic(newObj: newObj)}
            completionHandler(newObj)
            print(json)
        }, failure: { (Error) in
            MBProgressHUD.hide(for: (appDelInstance().window?.rootViewController?.view)!, animated: true)
            (appDelInstance().window?.rootViewController)?.showCustomAlert(strTitle: "", strDetails: Error.localizedDescription, completion: { (str) in
                print(Error.localizedDescription)
            })
        })
    }
    func updateUserProfileData(param:[String:AnyObject],filePath:String,completionHandler: @escaping (_ result: UserData) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let jsonData = try? JSONSerialization.data(withJSONObject: param, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let urlString: String!
            if filePath.count > 0 {
                urlString = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIUpdateUserProfileWithPhoto)"
                print("Photo")
            }
            else {
                urlString = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIUpdateUserProfile)"
                print("Data")
            }
            
            let param = ["userDtls":jsonString!, "url":urlString,"filePath":filePath]
            do {
                let multiAPI : multipartAPI = multipartAPI()
                multiAPI.call(param, withCompletionBlock: { (dict, error) in

                    guard dict?.count != 0 else {
                        completionHandler(UserData())
                        return
                    }
                    
                    guard (dict?.keys.contains("responseCode"))!, dict?.count != 0 , dict!["responseCode"] as! Int != 0 else {
                        DispatchQueue.main.async {
                            let message = dict!["response"] as! String
                            GlobalShareData.sharedGlobal.objCurretnVC.showCustomAlert(strTitle: "", strDetails: message, completion: { (str) in
                            })
                        }
                        completionHandler(UserData())
                        return
                        }
                    let realm = try! Realm()
                    let id  = dict?["id"] as? String
                    let data  = realm.objects(UserData.self).filter("id == %d", Int(id!)!)
                    let newObj = UserData(id : Int(id!)!, gcmId : dict?["gcmId"] as? String,profilePic : dict?["profilePic"] as? String,token : dict?["token"] as? String,updateDate : dict?["updateDate"] as? String,lastName : dict?["lastName"] as? String,appVersion : dict?["appVersion"] as? String,cell : dict?["cell"] as? String,status : dict?["status"] as? String,password : dict?["password"] as? String,createDate : dict?["createDate"] as? String,displayName : dict?["displayName"] as? String,firstName : dict?["firstName"] as? String,emailAddress: dict?["email"] as? String)
                    GlobalShareData.sharedGlobal.objCurrentUserDetails = newObj
                    GlobalShareData.sharedGlobal.userCellNumber = newObj.cell
                    
                    if dict?["profilePic"] as? String != nil, ((dict?["profilePic"] as? String)?.count)! > 0 {
                        self.downloadNewProfilePic(newObj: newObj)
                    }
                    completionHandler(newObj)
                })
            } catch let jsonError {
                print(jsonError)
            }
        }else{
            print("Internet Connection not Available!")
        }
    }
    
    func downloadNewProfilePic(newObj:UserData) {
        DownloadManager.shared().startFileDownloads(FileDownloadInfo.init(fileTitle: 1, andDownloadSource: newObj.profilePic), withCompletionBlock: { (response,url) in
            DispatchQueue.main.async {
                let realm = try! Realm()
                let data  = realm.objects(UserData.self).filter("id == %d",newObj.id)
                if data.count > 0 {
                    let objUser = data[0] as UserData
                    try! realm.write {
                        objUser.profilePic = url?.absoluteString
                        realm.add(objUser, update: true)
                    }
                }
            }
        })
    }
}
