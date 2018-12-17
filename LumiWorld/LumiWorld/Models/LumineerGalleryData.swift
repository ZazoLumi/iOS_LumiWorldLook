//
//  GetAllGalleryData.swift
//  LumiWorld
//
//  Created by Zazo on 2018/12/17.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import MBProgressHUD

class LumineerGalleryData: Object {
    @objc private(set) dynamic var id = 0
    @objc dynamic var galleryID: String? = nil
    @objc dynamic var contentTitle: String? = nil
    @objc dynamic var caption: String? = nil
    @objc dynamic var tag: String? = nil
    @objc dynamic var adMediaURL: String? = nil
    @objc dynamic var urlClip: String? = nil
    @objc dynamic var lumineerId: Double = 0
    @objc dynamic var contentFileType: String? = nil
    @objc dynamic var contentFilePath: String? = nil
    @objc dynamic var contentPackageId: Double = 0
    @objc dynamic var strCreatedDate: String? = nil
    @objc dynamic var strUpdatedDate: String? = nil
    @objc dynamic var Sponsor: String? = nil
    @objc dynamic var thumbnail: String? = nil
    @objc dynamic var adType: Double = 0
    @objc dynamic var adPackageName: Double = 0
    @objc dynamic var lumiDetails: String? = nil
    @objc dynamic var enterpriseName: Double = 0
    @objc dynamic var contentFileName: String? = nil
    @objc dynamic var galleryType: String? = nil
    @objc dynamic var contentType: String? = nil
    @objc dynamic var likeCount: Double = 0
    @objc dynamic var commentCount: Double = 0
    @objc dynamic var isFileDownloaded = false
    @objc dynamic var isGlrSaved = false
    @objc dynamic var isGlrLiked = false
    @objc dynamic var videoThumbFile: String? = nil
    @objc dynamic var lumineerName: String? = nil
    @objc dynamic var lumineerRegnNumber: String? = nil
    @objc dynamic var fileExt: String? = nil
    var glrComments = List<ContentComments>()
    override static func primaryKey() -> String? {
        return "id"
    }
    func getLumineerGetAllGallaryContents(param:[String:String],completionHandler: @escaping (_ objData: Results<LumineerGalleryData>) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            // let cellNumber = param["lumiMobile"]!
            let originalString = Date().getFormattedTimestamp(key: UserDefaultsKeys.gallaryTimeStamp)
            let lastViewDate = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var urlString : String!
            if lastViewDate != "" {
                print("test1")
                urlString = Constants.APIDetails.APIGetAllLumineerGallery + "?date=\(lastViewDate)" + "&lumiMobile=\(GlobalShareData.sharedGlobal.userCellNumber!)"}
            else {
                print("test0")
                urlString = Constants.APIDetails.APIGetAllLumineerGallery + "?lumiMobile=\((GlobalShareData.sharedGlobal.objCurrentUserDetails.cell)!)" }
            do {
                AFWrapper.requestGETURL(urlString, success: { (json) in
                    let tempArray = json.arrayValue
                    
                    guard tempArray.count != 0 else {
                        let realm = try! Realm()
                        var result : Results<LumineerGalleryData>
                        result  = realm.objects(LumineerGalleryData.self)
                        if result.count > 0 {
                            completionHandler(result)
                        }
                        return
                    }
                    for index in 0...tempArray.count-1 {
                        let aObject = tempArray[index]
                        let realm = try! Realm()
                        let newContentData = self.getGallaryObject(aObject: aObject)
                        let recordExist = realm.objects(LumineerGalleryData.self).filter("galleryID = '\(newContentData.galleryID!)'")
                        if recordExist.count == 0 {
                            try! realm.write {
                                realm.add(newContentData, update: true)
                            }
                            if aObject["url"].string != nil, (aObject["url"].string?.count)! > 0 {
                                // let url = self.appdel.fileName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                                let filePath = newContentData.adMediaURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                                
                                self.downloadFileFromServer(newAdvertiseData: newContentData)

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
                                self.downloadFileFromServer(newAdvertiseData: newContentData)
                            }
                            newContentData.isGlrSaved = recordExist[0].isGlrSaved
                            newContentData.isGlrLiked = recordExist[0].isGlrLiked
                            newContentData.contentType = recordExist[0].contentType
                            
                            try! realm.write {
                                realm.add(newContentData, update: true)
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
    
    func getGallaryObject(aObject:JSON) -> LumineerGalleryData {
        let newContentData = LumineerGalleryData()
        newContentData.id = self.incrementGallaryID()
        newContentData.galleryID = aObject["id"].stringValue
        newContentData.contentFileName = aObject["contentFileName"].stringValue
        newContentData.adMediaURL = aObject["url"].stringValue
        newContentData.contentFilePath = aObject["url"].stringValue
        newContentData.urlClip = aObject["urlClip"].stringValue

        newContentData.caption = aObject["caption"].stringValue
        newContentData.contentTitle = aObject["contentTitle"].stringValue
        newContentData.tag = aObject["tag"].stringValue
        newContentData.Sponsor = aObject["Sponsor"].stringValue
        newContentData.thumbnail = aObject["thumbnail"].stringValue
        newContentData.galleryType = aObject["galleryType"].stringValue
        newContentData.strCreatedDate = aObject["postedDateTime"].stringValue
        newContentData.strUpdatedDate = aObject["strUpdatedDate"].stringValue
        newContentData.lumineerId = aObject["lumineerId"].doubleValue
        newContentData.lumineerName = aObject["enterpriseName"].stringValue
        newContentData.fileExt = aObject["fileExt"].stringValue
        if aObject["adType"].stringValue == "Audio Clips" {
            newContentData.contentType = "audio"
        }
        else {
            newContentData.contentType = aObject["contentFileType"].stringValue
        }
        newContentData.contentFileType = aObject["contentType"].stringValue
        
        var commnets : [JSON] = []
        if aObject["galleryType"].stringValue == "Content" {
            if aObject["contentComments"].array != nil && (aObject["contentComments"].array?.count)! > 0 {
                commnets = aObject["contentComments"].array!}
            newContentData.likeCount = aObject["lumiLikeCountContent"].doubleValue
            newContentData.commentCount = aObject["lumiCommentsCountContent"].doubleValue
        }
        else {
            if aObject["lumiAdCommentList"].array != nil && (aObject["lumiAdCommentList"].array?.count)! > 0 {
                commnets = aObject["lumiAdCommentList"].array!}
            newContentData.likeCount = aObject["lumiAdCLikeCount"].doubleValue
            newContentData.commentCount = aObject["lumiAdCommentsCount"].doubleValue

        }
        newContentData.isGlrSaved = false
        newContentData.isGlrLiked = false
        
        
        
        
        if ((commnets.count) > 0) {
            let realm = try! Realm()
            for cObject in commnets {
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
                    realm.add(newCtnCommnetsData, update: true)
                    newContentData.glrComments.append(newCtnCommnetsData)
                }
            }
        }
        return newContentData
    }
    func downloadFileFromServer(newAdvertiseData:LumineerGalleryData) {
        // let url = self.appdel.fileName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let filePath = newAdvertiseData.adMediaURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        DownloadManager.shared().startFileDownloads(FileDownloadInfo.init(fileTitle: Int32(newAdvertiseData.id), andDownloadSource: filePath), withCompletionBlock: { (response,url) in
            DispatchQueue.main.async {
                let realm = try! Realm()
                let advData = realm.objects(LumineerGalleryData.self).filter("id = \(response)")
                if advData.count > 0 {
                    var fileName : String!
                    let objCurrentAdv = advData[0] as LumineerGalleryData
                    if objCurrentAdv.contentType == "video" {
                        var thumbnail1 = url?.thumbnail()
                        thumbnail1 = url?.thumbnail(fromTime: 5)
                        if let data = UIImageJPEGRepresentation(thumbnail1!, 0.8) {
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
                        realm.add(objCurrentAdv, update: true)
                        
                    }
                }
            }
            
            
        })
    }
    
    
    func incrementGallaryID() -> Int {
        let realm = try! Realm()
        return (realm.objects(LumineerGalleryData.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }
    func incrementContentCommentID() -> Int {
        let realm = try! Realm()
        return (realm.objects(ContentComments.self).max(ofProperty: "id") as Int? ?? 0) + 1
    }

}
