//
//  LumineerContent.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/09/26.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import MBProgressHUD

class LumineerContent: Object {
    @objc private(set) dynamic var id = 0
    
    @objc dynamic var contentID: String? = nil
    @objc dynamic var lumineerId: Double = 0
    @objc dynamic var contentPackageId: Double = 0
    @objc dynamic var adMediaURL: String? = nil
    @objc dynamic var contentFilePath: String? = nil

    @objc dynamic var contentType: String? = nil
    @objc dynamic var contentTitle: String? = nil
    @objc dynamic var caption: String? = nil
    @objc dynamic var tag: String? = nil
    @objc dynamic var adPackageId: Double = 0
    @objc dynamic var lumiCount: Double = 0
    @objc dynamic var prices: Double = 0
    @objc dynamic var advertiseDate: Double = 0
    @objc dynamic var likeCount: Double = 0
    @objc dynamic var lumiDetails: String? = nil
    @objc dynamic var upto100Charges: String? = nil
    @objc dynamic var upto1000Charges: String? = nil
    @objc dynamic var upto10000Charges: String? = nil
    @objc dynamic var upto50000Charges: String? = nil
    @objc dynamic var upto200000Charges: String? = nil
    @objc dynamic var upto10000000Charges: String? = nil
    @objc dynamic var upto20000000Charges: String? = nil
    @objc dynamic var over20000000Charges: String? = nil
    @objc dynamic var strContentDate: String? = nil
    @objc dynamic var contentPackageName: String? = nil
    @objc dynamic var companyLogo: String? = nil
    @objc dynamic var airingAllotment: String? = nil
    @objc dynamic var isFileDownloaded = false
    @objc dynamic var isCtsSaved = false
    @objc dynamic var isCtsLiked = false
    @objc dynamic var videoThumbFile: String? = nil
    @objc dynamic var contentFileName: String? = nil
    @objc dynamic var strCreatedDate: String? = nil
    @objc dynamic var strUpdatedDate: String? = nil
    @objc dynamic var lumineerName: String? = nil
    @objc dynamic var lumineerRegnNumber: String? = nil
    @objc dynamic var fileExt: String? = nil
    @objc dynamic var compaignWindow: String? = nil
    @objc dynamic var contentFileType: String? = nil

    var ctnComments = List<ContentComments>()

    override static func primaryKey() -> String? {
        return "id"
    }
    
    func getLumineerContents(param:[String:String],completionHandler: @escaping (_ objData: Results<LumineerContent>) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
           // let cellNumber = param["lumiMobile"]!
            let originalString = Date().getFormattedTimestamp(key: UserDefaultsKeys.contentTimeStamp)
            let lastViewDate = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var urlString : String!
            if lastViewDate != "" {
                print("test1")
                urlString = Constants.APIDetails.APIGetAllLumineerContent + "?date=\(lastViewDate)" + "&lumiMobile=\(GlobalShareData.sharedGlobal.userCellNumber!)"}
            else {
                print("test0")
                urlString = Constants.APIDetails.APIGetAllLumineerContent + "?lumiMobile=\((GlobalShareData.sharedGlobal.objCurrentUserDetails.cell)!)" }
            do {
                AFWrapper.requestGETURL(urlString, success: { (json) in
                    let tempArray = json.arrayValue
                    
                    guard tempArray.count != 0 else {
                        let realm = try! Realm()
                        var result : Results<LumineerContent>
                        result  = realm.objects(LumineerContent.self)
                        if result.count > 0 {
                            completionHandler(result)
                        }
                        return
                    }
                    for index in 0...tempArray.count-1 {
                        let aObject = tempArray[index]
                        let realm = try! Realm()
                        let newContentData = self.getContentObject(cObject: aObject)
                        let recordExist = realm.objects(LumineerContent.self).filter("contentID = '\(newContentData.contentID!)'")
                        if recordExist.count == 0 {
                            try! realm.write {
                                realm.add(newContentData, update: .all)
                            }
                            if aObject["adMediaURL"].string != nil, (aObject["adMediaURL"].string?.count)! > 0, newContentData.contentType != "image" {
                                // let url = self.appdel.fileName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                                let filePath = newContentData.adMediaURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                
                                DownloadManager.shared().startFileDownloads(FileDownloadInfo.init(fileTitle: Int32(newContentData.id), andDownloadSource: filePath), withCompletionBlock: { (response,url) in
                                    DispatchQueue.main.async {
                                        let advData = realm.objects(LumineerContent.self).filter("id = \(response)")
                                        if advData.count > 0 {
                                            var fileName : String!
                                            let objCurrentAdv = advData[0] as LumineerContent
                                            if objCurrentAdv.contentType == "video" {
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
                                                if objCurrentAdv.contentType == "video" {
                                                    objCurrentAdv.videoThumbFile = fileName
                                                }
                                                objCurrentAdv.adMediaURL = url?.absoluteString.removingPercentEncoding
                                                objCurrentAdv.isFileDownloaded = true
                                                realm.add(objCurrentAdv, update: .all)
                                                if index == tempArray.count-1 {
                                                    print("Download post")
                                                    NotificationCenter.default.post(name: Notification.Name("attachmentPopupRemoved"), object: nil) }
                                                
                                            }
                                        }
                                    }
                                    
                                    
                                })
                            }
                        }
                        else {
                            newContentData.id = recordExist[0].id

                            if recordExist[0].isFileDownloaded {
                                newContentData.isFileDownloaded = true
                                newContentData.adMediaURL = recordExist[0].adMediaURL
                                newContentData.contentFileName = recordExist[0].contentFileName
                            }
                            else {
                                if newContentData.contentType != "image" {
                                    self.downloadFileFromServer(newAdvertiseData: newContentData) }
                            }
                            newContentData.isCtsSaved = recordExist[0].isCtsSaved
                            newContentData.isCtsLiked = recordExist[0].isCtsLiked
                            newContentData.contentType = recordExist[0].contentType
                            
                            try! realm.write {
                                realm.add(newContentData, update: .all)
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
    
    func getContentObject(cObject:JSON) -> LumineerContent {
        let newContentData = LumineerContent()
        let aObject = cObject["adDetails"]
        newContentData.id = self.incrementContentID()
        newContentData.contentID = aObject["contentID"].stringValue
        newContentData.contentFileName = aObject["contentFileName"].stringValue
        newContentData.adMediaURL = cObject["adMediaURL"].stringValue
        newContentData.contentFilePath = cObject["adMediaURL"].stringValue
        newContentData.strContentDate = aObject["strContentDate"].stringValue
        newContentData.caption = aObject["caption"].stringValue
        newContentData.contentTitle = aObject["contentTitle"].stringValue
        newContentData.tag = aObject["tag"].stringValue
        newContentData.upto100Charges = aObject["upto100Charges"].stringValue
        newContentData.upto1000Charges = aObject["upto1000Charges"].stringValue
        newContentData.upto10000Charges = aObject["upto10000Charges"].stringValue
        newContentData.upto50000Charges = aObject["upto50000Charges"].stringValue
        newContentData.upto200000Charges = aObject["upto200000Charges"].stringValue
        newContentData.upto10000000Charges = aObject["upto1000000Charges"].stringValue
        newContentData.upto200000Charges = aObject["upto2000000Charges"].stringValue
        newContentData.over20000000Charges = aObject["over20000000Charges"].stringValue
        
        newContentData.strCreatedDate = aObject["strCreatedDate"].stringValue
        newContentData.strUpdatedDate = aObject["strUpdatedDate"].stringValue

//        if aObject["strCreatedDate"].stringValue.range(of:".") != nil {
//            let result = aObject["strCreatedDate"].stringValue.split(separator: ".")
//            newContentData.strCreatedDate = String(result[0]) as String
//        }
//        if aObject["strUpdatedDate"].stringValue.range(of:".") != nil {
//            let result = aObject["strUpdatedDate"].stringValue.split(separator: ".")
//            newContentData.strUpdatedDate = String(result[0]) as String
//        }
        newContentData.contentPackageId = aObject["contentPackageId"].doubleValue
        newContentData.lumineerId = aObject["lumineerId"].doubleValue
        newContentData.lumineerName = aObject["enterpriseName"].stringValue
        newContentData.lumineerRegnNumber = aObject["lumineerRegnNumber"].stringValue
        newContentData.adPackageId = aObject["adPackageId"].doubleValue
        newContentData.fileExt = aObject["fileExt"].stringValue
        if aObject["contentType"].stringValue == "Audio Clips" {
            newContentData.contentType = "audio"
        }
        else {
            newContentData.contentType = aObject["contentFileType"].stringValue
        }
        newContentData.contentFileType = aObject["contentType"].stringValue

        newContentData.lumiCount = aObject["lumiCount"].doubleValue
        newContentData.compaignWindow = aObject["compaignWindow"].stringValue
        newContentData.contentPackageName = aObject["contentPackageName"].stringValue
        newContentData.prices = aObject["prices"].doubleValue
        newContentData.airingAllotment = aObject["airingAllotment"].stringValue
        newContentData.likeCount = aObject["likeCount"].doubleValue
        newContentData.isCtsSaved = false
        newContentData.isCtsLiked = false
        newContentData.likeCount = 0

        if let likeObject = cObject["likes"].dictionary {
            let likes = likeObject["likes"]?.array
            if likes != nil && ((likes?.count) != nil) {
                newContentData.likeCount = Double((likes?.count)!)
            }
        }

        
        let newObject = cObject["comments"]

        let commnets = newObject["comments"].array
        if commnets != nil && ((commnets?.count) != nil) {
        let realm = try! Realm()
        for cObject in commnets! {
            let newCtnCommnetsData = ContentComments()
            newCtnCommnetsData.id = self.incrementContentCommentID()
            newCtnCommnetsData.commentId = cObject["commentID"].stringValue
            newCtnCommnetsData.commentBody = cObject["commentBody"].stringValue
            newCtnCommnetsData.isPostedByLumi = cObject["isPostedByLumi"].boolValue
            newCtnCommnetsData.isPostedByLumineer = cObject["isPostedByLumineer"].boolValue
            newCtnCommnetsData.contentID = cObject["contentID"].stringValue
            let lumineerDetails = aObject["lumineerDetails"]
            newCtnCommnetsData.lumineerId = lumineerDetails["lumineerId"].doubleValue
            newCtnCommnetsData.strCreatedDate = cObject["createdDate"].stringValue
            newCtnCommnetsData.strUpdatedDate = cObject["updatedDate"].stringValue
            let lumiDetails = aObject["lumiDetails"]
            newCtnCommnetsData.lumiMobile = lumiDetails["cell"].doubleValue
            newCtnCommnetsData.lumiName = cObject["lumiName"].stringValue
            newCtnCommnetsData.lumiName = cObject["lumiName"].stringValue
            try! realm.write {
                realm.add(newCtnCommnetsData, update: .all)
                newContentData.ctnComments.append(newCtnCommnetsData)
            }
            }
        }
        return newContentData
    }
    
    func downloadFileFromServer(newAdvertiseData:LumineerContent) {
        // let url = self.appdel.fileName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let filePath = newAdvertiseData.adMediaURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        DownloadManager.shared().startFileDownloads(FileDownloadInfo.init(fileTitle: Int32(newAdvertiseData.id), andDownloadSource: filePath), withCompletionBlock: { (response,url) in
            DispatchQueue.main.async {
                let realm = try! Realm()
                let advData = realm.objects(LumineerContent.self).filter("id = \(response)")
                if advData.count > 0 {
                    var fileName : String!
                    let objCurrentAdv = advData[0] as LumineerContent
                    if objCurrentAdv.contentType == "video" {
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
                        if objCurrentAdv.contentType == "video" {
                            objCurrentAdv.videoThumbFile = fileName
                        }
                        objCurrentAdv.adMediaURL = url?.absoluteString.removingPercentEncoding
                        objCurrentAdv.isFileDownloaded = true
                        realm.add(objCurrentAdv, update: .all)
                    }
                }
            }
        })
    }
    
    func sendContentComments(param:[String:AnyObject],completionHandler: @escaping (_ result:Bool) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let paramObj = ["contentFilePath":param["contentFilePath"]! as Any,"lumiDetails":["cell":GlobalShareData.sharedGlobal.objCurrentUserDetails.cell!,"firstName":GlobalShareData.sharedGlobal.objCurrentUserDetails.firstName!,"lastName":GlobalShareData.sharedGlobal.objCurrentUserDetails.lastName!,"displayName":GlobalShareData.sharedGlobal.objCurrentUserDetails.displayName!],"lumineerDetails":["lumineerId":param["lumineerId"]! as Any,"lumineerName":param["lumineerName"]! as Any],"contentID":param["contentID"]! as Any,"commentID":"" as Any,"commentBody":param["commentBody"]! as Any,"commentType":"0" as Any ] as [String : Any]
            do {
            let urlString: String = Constants.APIDetails.APIPostLumineerContentComments
            AFWrapper.requestPOSTURL(urlString, params:paramObj as [String : AnyObject], headers: nil, success: { (json) in
                print(json)
                if json.rawString()?.uppercased() == "COMMENT SEND" {
                    completionHandler(true)
                }
                else {
                    completionHandler(false)
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
    
    func sendContentLikes(param:[String:AnyObject],completionHandler: @escaping (_ result:Bool) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let paramObj = ["contentFilePath":param["contentFilePath"]! as Any,"lumiDetails":["cell":GlobalShareData.sharedGlobal.objCurrentUserDetails.cell!,"firstName":GlobalShareData.sharedGlobal.objCurrentUserDetails.firstName!,"lastName":GlobalShareData.sharedGlobal.objCurrentUserDetails.lastName!,"displayName":GlobalShareData.sharedGlobal.objCurrentUserDetails.displayName!],"lumineerDetails":["lumineerId":param["lumineerId"]! as Any,"lumineerName":param["lumineerName"]! as Any],"contentID":param["contentID"]! as Any,"likeID":"" as Any,"likeBody":"" as Any,"like":param["like"]! as Any,"likeType":"0" as Any ] as [String : Any]
            do {
                let urlString: String = Constants.APIDetails.APIPostLumineerContentLikes
                AFWrapper.requestPOSTURL(urlString, params:paramObj as [String : AnyObject], headers: nil, success: { (json) in
                    print(json)
                    if json.rawString()?.uppercased() == "LIKE SEND" {
                        completionHandler(true)
                    }
                    else {
                        completionHandler(false)
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

    
    func incrementContentID() -> Int {
        let realm = try! Realm()
        return (realm.objects(LumineerContent.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
        func incrementContentCommentID() -> Int {
            let realm = try! Realm()
            return (realm.objects(ContentComments.self).max(ofProperty: "id") as Int? ?? 0) + 1
        }
}

class ContentComments : Object {
    @objc dynamic var id = 0
    @objc dynamic var commentId: String? = nil
    @objc dynamic var strCreatedDate: String? = nil
    @objc dynamic var strUpdatedDate: String? = nil
    @objc dynamic var contentID: String? = nil
    @objc dynamic var lumiMobile: Double = 0
    @objc dynamic var lumineerId: Double = 0
    @objc dynamic var commentBody: String? = nil
    @objc dynamic var lumiName: String? = nil
    @objc dynamic var lumineerName: String? = nil
    @objc dynamic var isPostedByLumi = false
    @objc dynamic var isPostedByLumineer = false
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
