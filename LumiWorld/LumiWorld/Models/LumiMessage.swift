//
//  Message.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/04/13.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import MBProgressHUD

class LumiMessage : Object {
    
    @objc private(set) dynamic var id = 0
    @objc dynamic var createdTime: Double = 0
    @objc dynamic var expiryTime: Double = 0
    @objc dynamic var publishedTime: Double = 0
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var messageSubjectId: Double = 0

    @objc dynamic var guid: String? = nil
    @objc dynamic var isArchived = false
    @objc dynamic var isReadByLumineer = false
    @objc dynamic var isSentByLumi = false
    @objc dynamic var isSentByLumineer = false
    @objc dynamic var isReadByLumi = false
    @objc dynamic var isDeletedByLumi = false
    @objc dynamic var isFileDownloaded = false

    @objc dynamic var reachedConsumers: String? = nil
    @objc dynamic var sentBy: String? = nil
    @objc dynamic var newsfeedPostedTime: String? = nil
    @objc dynamic var fileName: String? = nil
    @objc dynamic var messageCategory: String? = nil
    @objc dynamic var messageSubject: String? = nil
    @objc dynamic var imageURL: String? = nil
    @objc dynamic var newsFeedBody: String? = nil
    @objc dynamic var newsFeedHeader: String? = nil
    @objc dynamic var tags: String? = nil
    @objc dynamic var contentType: String? = nil

    @objc  dynamic var searchID = 0
    @objc  dynamic var status = 0
    @objc  dynamic var enterpriseID = 0
    @objc  dynamic var categoryId = 0
    @objc  dynamic var messageType = 0
    @objc  dynamic var messageTypeId = 0

    override static func primaryKey() -> String? {
            return "id"
    }
    
    func getLumiMessage(param:[String:String],nParentId:Int,completionHandler: @escaping (_ objData: LumineerList) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let cellNumber = param["cellNumber"]!
            let startIndex = param["startIndex"]!
            let endIndex = param["endIndex"]!
            let lastViewDate = param["lastViewDate"]!


            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIGetLumineerMessages)" + "?cellNumber=\(cellNumber)" + "&startIndex=\(startIndex)" + "&endIndex=\(endIndex)" + "&lastViewDate=\(lastViewDate)"
            do {
                AFWrapper.requestGETURL(urlString, success: { (json) in
                    let tempArray = json.arrayValue

                    guard tempArray.count != 0 else {
                        let realm = try! Realm()
                        let parentId : Int = nParentId
                        var result : Results<LumiCategory>
                        
                        if parentId != -1 { result  = realm.objects(LumiCategory.self).filter("id == %d", parentId)
                            if result.count > 0 {
                                let objCategory = result[0] as LumiCategory
                                let id : Int = GlobalShareData.sharedGlobal.objCurrentLumineer.id
                                let objLumineer = objCategory.lumineerList.filter("id == %d", id)
                                completionHandler(objLumineer[0])
                            }
                        }
                        else {
                            result  = realm.objects(LumiCategory.self)
                            if result.count > 0 {
                                let objCategory = result[0] as LumiCategory
                                completionHandler(objCategory.lumineerList[0])
                            }
                        }
                        return
                    }
                    for index in 0...tempArray.count-1 {
                        let aObject = tempArray[index]
                        let realm = try! Realm()
                        let id : Int = aObject["id"].intValue
                        let result = realm.objects(LumineerList.self).filter("id = \(aObject["enterpriseID"].intValue)")

                        if result.count > 0 {
                            let objLumineer = result[0] as LumineerList
                            let newLumiMessage = LumiMessage()
                            newLumiMessage.id = id
                            newLumiMessage.createdTime = aObject["createdTime"].doubleValue
                            newLumiMessage.expiryTime = aObject["expiryTime"].doubleValue
                            newLumiMessage.guid = aObject["guid"].string
                            newLumiMessage.isArchived = aObject["isArchived"].boolValue
                            newLumiMessage.isReadByLumi = aObject["isReadByLumi"].boolValue
                            newLumiMessage.isReadByLumineer = aObject["isReadByLumineer"].boolValue
                            newLumiMessage.isSentByLumi = aObject["isSentByLumi"].boolValue
                            newLumiMessage.isSentByLumineer = aObject["isSentByLumineer"].boolValue
                            newLumiMessage.publishedTime = aObject["publishedTime"].doubleValue
                            newLumiMessage.reachedConsumers = aObject["reachedConsumers"].string
                            newLumiMessage.searchID = aObject["searchID"].intValue
                            newLumiMessage.sentBy = aObject["sentBy"].string
                            newLumiMessage.status = aObject["status"].intValue
                            newLumiMessage.enterpriseID = aObject["enterpriseID"].intValue
                            newLumiMessage.categoryId = aObject["categoryId"].intValue
                            newLumiMessage.messageTypeId = aObject["messageTypeId"].intValue
                            newLumiMessage.newsfeedPostedTime = aObject["newsfeedPostedTime"].string
                            newLumiMessage.fileName = aObject["fileName"].string
                            newLumiMessage.latitude = aObject["latitude"].doubleValue
                            newLumiMessage.longitude = aObject["longitude"].doubleValue
                            newLumiMessage.messageCategory = aObject["messageCategory"].string
                            newLumiMessage.messageType = aObject["messageType"].intValue
                            newLumiMessage.isDeletedByLumi = aObject["isDeletedByLumi"].boolValue
                            newLumiMessage.messageSubject = aObject["messageSubject"].string
                            newLumiMessage.imageURL = aObject["imageURL"].string
                            newLumiMessage.newsFeedBody = aObject["newsFeedBody"].string
                            newLumiMessage.newsFeedHeader = aObject["newsFeedHeader"].string
                            newLumiMessage.tags = aObject["tags"].string
                            newLumiMessage.contentType = aObject["contentType"].string
                            newLumiMessage.messageSubjectId = aObject["messageSubjectId"].doubleValue
                            newLumiMessage.isFileDownloaded = false
                            let recordExist = objLumineer.lumiMessages.filter("guid = '\(aObject["guid"].string!)'")
                            if recordExist.count == 0 {
                                let objLumineerMessageList = objLumineer.lumiMessages
                                try! realm.write {
                                    realm.add(newLumiMessage, update: true)
                                    objLumineerMessageList.append(newLumiMessage)
                                }
                                if aObject["fileName"].string != nil, (aObject["fileName"].string?.count)! > 0 {
                                    DownloadManager.shared().startFileDownloads(FileDownloadInfo.init(fileTitle: Int32(newLumiMessage.id), andDownloadSource: newLumiMessage.fileName), withCompletionBlock: { (response,url) in
                                    DispatchQueue.main.async {
                                        let messages = objLumineerMessageList.filter("id == %d", response)
                                            if messages.count > 0 {
                                                try! realm.write {
                                                let objLumiMsg = messages[0] as LumiMessage
                                                objLumiMsg.fileName = url?.absoluteString
                                                objLumiMsg.isFileDownloaded = true
                                                realm.add(objLumiMsg, update: true)
                                            }
                                        }
                                    }
                                    
                                    
                                })
                                }
                            }
                        }
                    }
                    let realm = try! Realm()
                    let parentId : Int = GlobalShareData.sharedGlobal.objCurrentLumineer.parentid
                    let result  = realm.objects(LumiCategory.self).filter("id == %d", parentId)
                    if result.count > 0 {
                        let objCategory = result[0] as LumiCategory
                        let id : Int = GlobalShareData.sharedGlobal.objCurrentLumineer.id
                        let objLumineer = objCategory.lumineerList.filter("id == %d", id)
                        completionHandler(objLumineer[0])
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
    func sendLumiTextMessage(param:[String:AnyObject],completionHandler: @escaping () -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let jsonData = try? JSONSerialization.data(withJSONObject: param, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APISendLumineerTextMessages)"

            let paramCreateRelationship = ["newsFeed":jsonString!, "url":urlString,"filePath":"","fileName":""]
            do {
                let multiAPI : multipartAPI = multipartAPI()
                multiAPI.call(paramCreateRelationship, withCompletionBlock: { (dict, error) in
                    guard dict?.count != 0 else {
                        return
                    }

                    let strResponseCode = dict!["responseCode"] as! Int
                    guard strResponseCode != 0 else {
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
    
    func sendLumiAttachmentMessage(param:[String:AnyObject],filePath:String,completionHandler: @escaping (_ error: Error?) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let jsonData = try? JSONSerialization.data(withJSONObject: param, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APISendLumineerAttachmentMessages)"
            
            let paramCreateRelationship = ["newsFeed":jsonString!, "url":urlString,"filePath":filePath]
            do {
                let multiAPI : multipartAPI = multipartAPI()
                multiAPI.call(paramCreateRelationship, withCompletionBlock: { (dict, error) in
                    if error != nil {
                        completionHandler(error!)
                        return
                    }
                    let strResponseCode = dict!["responseCode"] as! Int
                    guard strResponseCode != 0 else {
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
    func setLumineerMessageReadByLumi(strGUID:String,completionHandler: @escaping (_ objData: Results<Object>) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            do {
                let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIViewMessagesByLumi)"
                
                AFWrapper.requestPOSTURL(urlString, params:["cellNumber":GlobalShareData.sharedGlobal.userCellNumber as AnyObject,"guid":strGUID as AnyObject], headers: nil, success: { (json) in
                    print(json)
                    let tempDict = json.dictionary
                    guard let code = tempDict!["responseCode"]?.intValue, code != 0 else {
                        return
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
    
}


