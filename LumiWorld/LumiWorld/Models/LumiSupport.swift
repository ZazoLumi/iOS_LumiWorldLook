//
//  LumiSupport.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/05/24.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import MBProgressHUD

class LumiSupport : Object {
    @objc private(set) dynamic var supportId = 0
    @objc dynamic var messageSubjectId: Double = 0
    @objc dynamic var isArchivedByLumiWorld = false
    @objc dynamic var isDeletedByLumi = false
    @objc dynamic var isDeletedByLumiWorld = false
    @objc dynamic var isReadByLumi = false
    @objc dynamic var isReadByLumiWorld = false
    @objc dynamic var isRespReqdFromLumi = false
    @objc dynamic var isRespReqdFromLumiWorld = false
    @objc dynamic var repliedBy: String? = nil
    @objc dynamic var repliedOn: Double = 0
    @objc dynamic var sentBy: String? = nil
    @objc dynamic var sentOn: Double = 0
    @objc dynamic var sentTo: String? = nil
    @objc dynamic var supportMessageBody: String? = nil
    @objc dynamic var supportMessageSubject: String? = nil
    @objc dynamic var supportSubjectId: Double = 0
    @objc dynamic var isFileDownloaded = false
    @objc dynamic var imageURL: String? = nil

    @objc dynamic var messageStatus: String? = nil
    @objc dynamic var sentDate: String? = nil

    @objc dynamic var repliedDate: String? = nil
    @objc dynamic var strResponseReq: String? = nil
    @objc dynamic var supportFileName: String? = nil
    @objc dynamic var contentType: String? = nil
    @objc dynamic var supportFilePath: String? = nil

    override static func primaryKey() -> String? {
        return "supportId"
    }
    func sendSupportTextMessage(urlString:String,param:[String:AnyObject],completionHandler: @escaping () -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let jsonData = try? JSONSerialization.data(withJSONObject: param, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            //let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APISendSupportQueryToLumiAdmin)"
            
            let paramCreateRelationship = ["supportMsgDtls":jsonString!, "url":urlString,"filePath":"","fileName":""]
            do {
                let multiAPI : multipartAPI = multipartAPI()
                multiAPI.call(paramCreateRelationship, withCompletionBlock: { (dict, error) in
                    guard dict?.count != 0, (dict?.keys.contains("responseCode"))!, dict!["responseCode"] as! Int != 0 else {
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: (appDelInstance().window?.rootViewController?.navigationController?.view)!, animated: true)}
                        return
                    }
                    completionHandler()
                })
            } catch let jsonError {
                print(jsonError)
            }
        }else{
            print("Internet Connection not Available!")
        }
    }
    
    func sendSupportAttachmentMessage(urlString:String,param:[String:AnyObject],filePath:String,completionHandler: @escaping (_ error: Error?) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let jsonData = try? JSONSerialization.data(withJSONObject: param, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            
            let paramCreateRelationship = ["supportMsgDtls":jsonString!, "url":urlString,"filePath":filePath]
            do {
                let multiAPI : multipartAPI = multipartAPI()
                multiAPI.call(paramCreateRelationship, withCompletionBlock: { (dict, error) in
                    if error != nil {
                        completionHandler(error!)
                        return
                    }
                    guard dict?.count != 0, (dict?.keys.contains("responseCode"))!, dict!["responseCode"] as! Int != 0 else {
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: (appDelInstance().window?.rootViewController?.navigationController?.view)!, animated: true)}
                        return
                    }
                    completionHandler(error)
                })
            } catch let jsonError {
                print(jsonError)
            }
        }else{
            print("Internet Connection not Available!")
        }
    }

    func getLumiSupportMessages(cellNumber:String,lastViewDate:String,completionHandler: @escaping (_ objData: Results<LumiSupport>) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIGetAllSupportMessagesOfLumi)" + "?cellNumber=\(cellNumber)" + "&lastViewedDate=\(lastViewDate)"

            do {
                AFWrapper.requestGETURL(urlString, success: { (json) in
                    let tempArray = json.arrayValue

                    defer {
                        let realm = try! Realm()
                        var result : Results<LumiSupport>
                        result  = realm.objects(LumiSupport.self)
                        if result.count > 0 {
                            completionHandler(result)
                        }
                    }
                    if tempArray.count != 0 {
                    for index in 0...tempArray.count-1 {
                        let aObject = tempArray[index]
                        let realm = try! Realm()
                        let supportId : Int = aObject["supportId"].intValue
                        
                            let objNewLumiSupport = LumiSupport()
                            objNewLumiSupport.supportId = supportId
                            objNewLumiSupport.isArchivedByLumiWorld = aObject["isArchivedByLumiWorld"].boolValue
                            objNewLumiSupport.isDeletedByLumi = aObject["isDeletedByLumi"].boolValue
                            objNewLumiSupport.isDeletedByLumiWorld = aObject["isDeletedByLumiWorld"].boolValue
                            objNewLumiSupport.isReadByLumi = aObject["isReadByLumi"].boolValue
                            objNewLumiSupport.isReadByLumiWorld = aObject["isReadByLumiWorld"].boolValue
                            objNewLumiSupport.isRespReqdFromLumi = aObject["isRespReqdFromLumi"].boolValue
                            objNewLumiSupport.isRespReqdFromLumiWorld = aObject["isRespReqdFromLumiWorld"].boolValue
                            objNewLumiSupport.repliedBy = aObject["repliedBy"].stringValue
                            objNewLumiSupport.repliedOn = aObject["repliedOn"].doubleValue
                            objNewLumiSupport.sentBy = aObject["sentBy"].stringValue
                            objNewLumiSupport.sentOn = aObject["sentOn"].doubleValue
                            objNewLumiSupport.sentTo = aObject["sentTo"].stringValue
                            objNewLumiSupport.supportMessageBody = aObject["supportMessageBody"].stringValue
                            objNewLumiSupport.supportMessageSubject = aObject["supportMessageSubject"].stringValue
                            objNewLumiSupport.supportSubjectId = aObject["supportSubjectId"].doubleValue
                            objNewLumiSupport.messageStatus = aObject["messageStatus"].stringValue
                            objNewLumiSupport.sentDate = aObject["sentDate"].stringValue
                            objNewLumiSupport.repliedDate = aObject["repliedDate"].stringValue
                            objNewLumiSupport.strResponseReq = aObject["strResponseReq"].stringValue
                            objNewLumiSupport.supportFileName = aObject["supportFileName"].stringValue
                            objNewLumiSupport.contentType = aObject["contentType"].stringValue
                            objNewLumiSupport.supportFilePath = aObject["supportFilePath"].stringValue
                            
                        let result = realm.objects(LumiSupport.self).filter("supportId = \(supportId)")
                        if result.count>0 {
                            GlobalShareData.sharedGlobal.realmManager.editObjects(objs: objNewLumiSupport)
                        }
                        else {
                            GlobalShareData.sharedGlobal.realmManager.saveObjects(objs: objNewLumiSupport)
                            if aObject["supportFilePath"].string != nil, (aObject["supportFilePath"].string?.count)! > 0 {
                                DownloadManager.shared().startFileDownloads(FileDownloadInfo.init(fileTitle: Int32(objNewLumiSupport.supportId), andDownloadSource: objNewLumiSupport.supportFilePath), withCompletionBlock: { (response,url) in
                                    DispatchQueue.main.async {
                                        let messages = realm.objects(LumiSupport.self).filter("supportId = \(response)")
                                        if messages.count > 0 {
                                            var fileName : String!
                                            let objLumiMsg = messages[0] as LumiSupport
                                            if objLumiMsg.contentType == "Video" {
                                                var thumbnail1 = url?.thumbnail()
                                                thumbnail1 = url?.thumbnail(fromTime: 5)
                                                if let data = thumbnail1?.compressedData(quality: 0.8) {
                                                    fileName = url?.lastPathComponent
                                                    fileName = fileName?.deletingPathExtension
                                                    fileName = fileName?.appendingPathExtension("png")
                                                    let _ = GlobalShareData.sharedGlobal.storeGenericfileinDocumentDirectory(fileContent: data as NSData, fileName: fileName!)
                                                }
                                                
                                            }
                                            try! realm.write {
                                                if objLumiMsg.contentType == "Video" {
                                                    objLumiMsg.imageURL = fileName
                                                }
                                                objLumiMsg.supportFilePath = url?.absoluteString
                                                objLumiMsg.isFileDownloaded = true
                                                realm.add(objLumiMsg, update: .all)
                                                if index == tempArray.count-1 {
                                                    print("Download post")
                                                    NotificationCenter.default.post(name: Notification.Name("attachmentPopupRemoved"), object: nil) }
                                                
                                            }
                                        }
                                    }
                                })
                            }
                        }
                        }
                                            }
                }, failure: { (Error) in
                    print(Error.localizedDescription)
                })
            } catch let jsonError{
                print(jsonError)
            }
            
        }else{
            print("Internet Connection not Available!")
        }

    }
    
    func setSupportMessageReadByLumi(strSupportID:String,completionHandler: @escaping (_ objData: Results<Object>) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            do {
                let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIMarkSupportMsgAsReadByLumi)" + "?supportId=\(strSupportID)"
                AFWrapper.requestPOSTURL(urlString, params:[:], headers: nil, success: { (json) in
                    print(json)
                    let tempDict = json.dictionary
                    guard tempDict?.count != 0, (tempDict?.keys.contains("responseCode"))!, let code = tempDict!["responseCode"]?.intValue, code != 0 else {
                        return
                    }
                    let realm = try! Realm()
                    let result = realm.objects(LumiSupport.self).filter("supportId = \(strSupportID)")
                    
                    let objSupport = result[0] as LumiSupport
                    try! realm.write {
                        objSupport.isReadByLumi = true
                        realm.add(objSupport, update: .all)
                    }
                    
                }, failure: { (Error) in
                    print(Error.localizedDescription)
                })
                
            } catch let jsonError{
                print(jsonError)
            }
            
            
        }else{
            print("Internet Connection not Available!")
        }
    }
    
    func setSupportMessageDelete(strSupportID:String,completionHandler: @escaping (_ objData: Results<Object>) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            do {
                let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIMarkSupportMsgAsDeletedByLumi)" + "?supportId=\(strSupportID)"
                AFWrapper.requestPOSTURL(urlString, params:[:], headers: nil, success: { (json) in
                    print(json)
                    let tempDict = json.dictionary
                    guard tempDict?.count != 0, (tempDict?.keys.contains("responseCode"))!, let code = tempDict!["responseCode"]?.intValue, code != 0 else {
                        return
                    }
                    let realm = try! Realm()
                    let result = realm.objects(LumiSupport.self).filter("supportId = \(strSupportID)")
                    
                    let objSupport = result[0] as LumiSupport
                    GlobalShareData.sharedGlobal.realmManager.deleteObject(objs: objSupport)
                    
                }, failure: { (Error) in
                    print(Error.localizedDescription)
                })
                
            } catch let jsonError{
                print(jsonError)
            }
            
            
        }else{
            print("Internet Connection not Available!")
        }
    }
}
