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
    var createdTime: Double? = 0
    var expiryTime: Double? = 0
    var publishedTime: Double? = 0
    var latitude: Double? = 0
    var longitude: Double? = 0

    @objc dynamic var guid: String? = nil
    var isArchived: Bool?
    var isReadByLumineer: Bool?
    var isSentByLumi: Bool?
    var isSentByLumineer: Bool?
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
    
    var isReadByLumi: Bool?
    var isDeletedByLumi: Bool?


    @objc  dynamic var searchID = 0
    @objc  dynamic var status = 0
    @objc  dynamic var enterpriseID = 0
    @objc  dynamic var categoryId = 0
    @objc  dynamic var messageType = 0
    @objc  dynamic var messageTypeId = 0

        override static func primaryKey() -> String? {
            return "id"
    }
    
    func getLumiMessage(param:[String:String],completionHandler: @escaping (_ objData: LumineerList) -> Void) {
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
                        return
                    }
                    for index in 0...tempArray.count-1 {
                        let aObject = tempArray[index]
                        let realm = try! Realm()
                        let id : Int = aObject["id"].intValue
                        let result  = realm.objects(LumiCategory.self).filter("id == %d", GlobalShareData.sharedGlobal.objCurrentLumineer.parentid)
                        if result.count > 0 {
                            let objCategory = result[0] as LumiCategory
                            let objLumineer = objCategory.lumineerList.filter("id == %d", aObject["enterpriseID"].intValue)
                            
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
                            
                            if objLumineer.count > 0 {
                                let objLumineerMessageList = objLumineer[0].lumiMessages
                                try! realm.write {
                                    realm.add(newLumiMessage, update: true)
                                    objLumineerMessageList.append(newLumiMessage)
                                }
                            objLumineer[0].lumiMessages = objLumineerMessageList
                            GlobalShareData.sharedGlobal.realmManager.editObjects(objs: objCategory)

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
    func sendLumiTextMessage(param:[String:String],completionHandler: @escaping (_ objData: LumineerList) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let jsonData = try? JSONSerialization.data(withJSONObject: param, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let paramCreateRelationship = ["newsFeed":jsonString!]
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APISendLumineerTextMessages)"
            do {
                AFWrapper.requestPOSTURL(urlString, params: paramCreateRelationship as [String : AnyObject], headers: nil, success: { (json) in
                    let tempArray = json.arrayValue
                    guard tempArray.count != 0 else {
                        return
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
            } catch let jsonError {
                print(jsonError)
            }
        }else{
            print("Internet Connection not Available!")
        }
    }
    
    func sendLumiAttachmentMessage(param:[String:String],completionHandler: @escaping (_ objData: LumineerList) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let jsonData = try? JSONSerialization.data(withJSONObject: param, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let paramCreateRelationship = ["newsFeed":jsonString!]
            
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APISendLumineerAttachmentMessages)"
            do {
                AFWrapper.requestPOSTURLWITHIMAGEAUTHWITHPARAM(urlString, params: param as [String : AnyObject]
                    , headers: nil, image: UIImage(), success:{ (json) in
                    let tempArray = json.arrayValue
                    guard tempArray.count != 0 else {
                        return
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

}
