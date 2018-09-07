//
//  AdvertiseData.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/07/12.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import MBProgressHUD

class AdvertiseData: Object {
    @objc private(set) dynamic var advertiseId = 0
    @objc dynamic var lumineerId: Double = 0
    @objc dynamic var adPackageId: Double = 0
    @objc dynamic var lumiCount: Double = 0
    @objc dynamic var prices: Double = 0
    @objc dynamic var advertiseDate: Double = 0
    @objc dynamic var likeCount: Double = 0
    @objc dynamic var createdDate: Double = 0
    @objc dynamic var updatedDate: Double = 0


    @objc dynamic var adFileName: String? = nil
    @objc dynamic var adFilePath: String? = nil
    @objc dynamic var adType: String? = nil
    @objc dynamic var strAdvertiseDate: String? = nil
    @objc dynamic var caption: String? = nil
    @objc dynamic var contentTitle: String? = nil
    @objc dynamic var tag: String? = nil
    @objc dynamic var upto100Charges: String? = nil
    @objc dynamic var upto1000Charges: String? = nil
    @objc dynamic var upto10000Charges: String? = nil
    @objc dynamic var upto50000Charges: String? = nil
    @objc dynamic var upto200000Charges: String? = nil
    @objc dynamic var upto10000000Charges: String? = nil
    @objc dynamic var upto20000000Charges: String? = nil
    @objc dynamic var over20000000Charges: String? = nil

    @objc dynamic var lumineerName: String? = nil
    @objc dynamic var lumineerRegnNumber: String? = nil
    @objc dynamic var lumiDetails: String? = nil
    @objc dynamic var lumiList: String? = nil
    @objc dynamic var lumineerAdLumis: String? = nil
    @objc dynamic var fileExt: String? = nil
    @objc dynamic var contentType: String? = nil
    @objc dynamic var videoThumbFile: String? = nil

    @objc dynamic var compaignWindow: String? = nil
    @objc dynamic var frequency: String? = nil
    @objc dynamic var packageName: String? = nil
    @objc dynamic var timeOfDayTimeSlot: String? = nil
    @objc dynamic var airingAllotment: String? = nil
    @objc dynamic var isFileDownloaded = false
    @objc dynamic var isAdsSaved = false
    @objc dynamic var isAdsLiked = false

    var advComments = List<AdvComments>()

    override static func primaryKey() -> String? {
        return "advertiseId"
    }
    
    func getLumineerAdvertise(param:[String:String],completionHandler: @escaping (_ objData: Results<AdvertiseData>) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let cellNumber = param["lumiMobile"]!
            let lumineerId = param["lumineerId"]!
            var urlString: String = ""
            let originalString = Date().getFormattedTimestamp(key: UserDefaultsKeys.advertiseTimeStamp)
            let lastViewDate = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!

            if lumineerId != "0" {
                urlString = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIGetAllAdsPostedToLumiByALumineer)" + "?lumiMobile=\(cellNumber)" + "&lumineerId=\(lumineerId)" + "&lastViewedTS=\(lastViewDate)"
            }
            else {
                urlString = Constants.APIDetails.APIGetAllAdsPostedToLumi +  "?lumiMobile=\(cellNumber)" + "&lastViewedTS=\(lastViewDate)"
            }
            do {
                AFWrapper.requestGETURL(urlString, success: { (json) in
                    let tempArray = json.arrayValue
                    
                    guard tempArray.count != 0 else {
                        let realm = try! Realm()
                        var result : Results<AdvertiseData>
                            result  = realm.objects(AdvertiseData.self)
                            if result.count > 0 {
                                completionHandler(result)
                            }
                        return
                    }
                    for index in 0...tempArray.count-1 {
                        let aObject = tempArray[index]
                        let realm = try! Realm()
                        let newAdvertiseData = self.getAdvertiseObject(aObject: aObject)
                        let recordExist = realm.objects(AdvertiseData.self).filter("advertiseId = \(newAdvertiseData.advertiseId)")
                            if recordExist.count == 0 {
                                try! realm.write {
                                    realm.add(newAdvertiseData, update: true)
                                }
                                if aObject["adFileName"].string != nil, (aObject["adFileName"].string?.count)! > 0 {
                                   // let url = self.appdel.fileName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
                                    let filePath = newAdvertiseData.adFilePath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

                                    DownloadManager.shared().startFileDownloads(FileDownloadInfo.init(fileTitle: Int32(newAdvertiseData.advertiseId), andDownloadSource: filePath), withCompletionBlock: { (response,url) in
                                        DispatchQueue.main.async {
                                            let advData = realm.objects(AdvertiseData.self).filter("advertiseId = \(response)")
                                            if advData.count > 0 {
                                                var fileName : String!
                                                let objCurrentAdv = advData[0] as AdvertiseData
                                                if objCurrentAdv.contentType == "Video" {
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
                                                    if objCurrentAdv.contentType == "Video" {
                                                        objCurrentAdv.videoThumbFile = fileName
                                                    }
                                                    objCurrentAdv.adFilePath = url?.absoluteString.removingPercentEncoding
                                                    objCurrentAdv.isFileDownloaded = true
                                                    realm.add(objCurrentAdv, update: true)
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
                                if recordExist[0].isFileDownloaded {
                                    newAdvertiseData.isFileDownloaded = true
                                    newAdvertiseData.adFilePath = recordExist[0].adFilePath
                                    newAdvertiseData.adFileName = recordExist[0].adFileName
                                }
                                else {
                                    self.downloadFileFromServer(newAdvertiseData: newAdvertiseData)
                                }
                                newAdvertiseData.isAdsSaved = recordExist[0].isAdsSaved
                                newAdvertiseData.isAdsLiked = recordExist[0].isAdsLiked
                                newAdvertiseData.contentType = recordExist[0].contentType

                                try! realm.write {
                                    realm.add(newAdvertiseData, update: true)
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
    
    func sendAdvertiseComments(param:[String:AnyObject],completionHandler: @escaping (_ result:Bool) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let jsonData = try? JSONSerialization.data(withJSONObject: param, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIPOSTAdvertiseComments)"
            
            let paramCreateRelationship = ["commentDtls":jsonString!, "url":urlString,"filePath":"","fileName":""]
            do {
                let multiAPI : multipartAPI = multipartAPI()
                multiAPI.call(paramCreateRelationship, withCompletionBlock: { (aObject, error) in
                    guard aObject?.count != 0, (aObject?.keys.contains("responseCode"))!, aObject!["responseCode"] as! Int != 0 else {
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: (appDelInstance().window?.rootViewController?.navigationController?.view)!, animated: true)}
                        completionHandler(false)
                        return
                    }
                    let aObject = JSON(aObject!)
                    let realm = try! Realm()
                    let newAdvertiseData = self.getAdvertiseObject(aObject: aObject)
                    let recordExist = realm.objects(AdvertiseData.self).filter("advertiseId = \(newAdvertiseData.advertiseId)")
                    if recordExist.count > 0 {
                        if recordExist[0].isFileDownloaded {
                            newAdvertiseData.isFileDownloaded = true
                            newAdvertiseData.adFilePath = recordExist[0].adFilePath
                            newAdvertiseData.adFileName = recordExist[0].adFileName
                        }
                        else {
                            self.downloadFileFromServer(newAdvertiseData: newAdvertiseData)
                        }
                        newAdvertiseData.isAdsSaved = recordExist[0].isAdsSaved
                        newAdvertiseData.isAdsLiked = recordExist[0].isAdsLiked
                        newAdvertiseData.contentType = recordExist[0].contentType

                        try! realm.write {
                            realm.add(newAdvertiseData, update: true)
                        }
                    }
                    completionHandler(true)
                })
            } catch let jsonError {
                print(jsonError)
            }
        }else{
            print("Internet Connection not Available!")
        }
    }
    
    func sendAdvertiseReports(param:[String:AnyObject],completionHandler: @escaping (_ result:Bool) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let jsonData = try? JSONSerialization.data(withJSONObject: param, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIPOSTAdvertiseReports)"
            
            let paramCreateRelationship = ["reportDtls":jsonString!, "url":urlString,"filePath":"","fileName":""]
            do {
                let multiAPI : multipartAPI = multipartAPI()
                multiAPI.call(paramCreateRelationship, withCompletionBlock: { (aObject, error) in
                    guard aObject?.count != 0, (aObject?.keys.contains("responseCode"))!, aObject!["responseCode"] as! Int != 0 else {
                        DispatchQueue.main.async {
                            MBProgressHUD.hide(for: (appDelInstance().window?.rootViewController?.navigationController?.view)!, animated: true)}
                        completionHandler(false)
                        return
                    }
                    completionHandler(true)
                })
            } catch let jsonError {
                print(jsonError)
            }
        }else{
            print("Internet Connection not Available!")
        }
    }

    
    func getAdvertiseObject(aObject:JSON) -> AdvertiseData {
        let newAdvertiseData = AdvertiseData()
        let id : Int = aObject["advertiseId"].intValue
        newAdvertiseData.advertiseId = id
        newAdvertiseData.adFileName = aObject["adFileName"].stringValue
        newAdvertiseData.adFilePath = aObject["adFilePath"].stringValue
        newAdvertiseData.adType = aObject["adType"].stringValue
        newAdvertiseData.advertiseDate = aObject["advertiseDate"].doubleValue
        newAdvertiseData.strAdvertiseDate = aObject["strAdvertiseDate"].stringValue
        newAdvertiseData.caption = aObject["caption"].stringValue
        newAdvertiseData.contentTitle = aObject["contentTitle"].stringValue
        newAdvertiseData.tag = aObject["tag"].stringValue
        newAdvertiseData.upto100Charges = aObject["upto100Charges"].stringValue
        newAdvertiseData.upto1000Charges = aObject["upto1000Charges"].stringValue
        newAdvertiseData.upto10000Charges = aObject["upto10000Charges"].stringValue
        newAdvertiseData.upto50000Charges = aObject["upto50000Charges"].stringValue
        newAdvertiseData.upto200000Charges = aObject["upto200000Charges"].stringValue
        newAdvertiseData.upto10000000Charges = aObject["upto1000000Charges"].stringValue
        newAdvertiseData.upto200000Charges = aObject["upto2000000Charges"].stringValue
        newAdvertiseData.over20000000Charges = aObject["over20000000Charges"].stringValue
        newAdvertiseData.createdDate = aObject["createdDate"].doubleValue
        newAdvertiseData.updatedDate = aObject["updatedDate"].doubleValue
        
        newAdvertiseData.lumineerId = aObject["lumineerId"].doubleValue
        newAdvertiseData.lumineerName = aObject["lumineerName"].stringValue
        newAdvertiseData.lumineerRegnNumber = aObject["lumineerRegnNumber"].stringValue
        newAdvertiseData.adPackageId = aObject["adPackageId"].doubleValue
        newAdvertiseData.lumiDetails = aObject["lumiDetails"].stringValue
        newAdvertiseData.lumiList = aObject["lumiList"].stringValue
        newAdvertiseData.lumineerAdLumis = aObject["lumineerAdLumis"].stringValue
        newAdvertiseData.fileExt = aObject["fileExt"].stringValue
        newAdvertiseData.contentType = aObject["contentType"].stringValue
        newAdvertiseData.lumiCount = aObject["lumiCount"].doubleValue
        newAdvertiseData.compaignWindow = aObject["compaignWindow"].stringValue
        newAdvertiseData.frequency = aObject["frequency"].stringValue
        newAdvertiseData.packageName = aObject["packageName"].stringValue
        newAdvertiseData.prices = aObject["prices"].doubleValue
        newAdvertiseData.timeOfDayTimeSlot = aObject["timeOfDayTimeSlot"].stringValue
        newAdvertiseData.airingAllotment = aObject["airingAllotment"].stringValue
        newAdvertiseData.likeCount = aObject["likeCount"].doubleValue
        newAdvertiseData.isAdsSaved = false
        newAdvertiseData.isAdsLiked = false
        let commnets = aObject["lumiAdCommentList"].array
        let realm = try! Realm()
        for cObject in commnets! {
            let newAdvCommnetsData = AdvComments()
            newAdvCommnetsData.commentId = cObject["commentId"].intValue
            newAdvCommnetsData.commentPostedDate = cObject["commentPostedDate"].doubleValue
            newAdvCommnetsData.comments = cObject["comments"].stringValue
            newAdvCommnetsData.isPostedByLumi = cObject["isPostedByLumi"].boolValue
            newAdvCommnetsData.isPostedByLumineer = cObject["isPostedByLumineer"].boolValue
            newAdvCommnetsData.advertiseId = cObject["advertiseId"].doubleValue
            newAdvCommnetsData.lumineerId = cObject["lumineerId"].doubleValue
            newAdvCommnetsData.strCommentPostedDate = cObject["strCommentPostedDate"].stringValue
            newAdvCommnetsData.lumiMobile = cObject["lumiMobile"].doubleValue
            newAdvCommnetsData.lumiName = cObject["lumiName"].stringValue
            newAdvCommnetsData.lumiName = cObject["lumiName"].stringValue
            try! realm.write {
                realm.add(newAdvCommnetsData, update: true)
                newAdvertiseData.advComments.append(newAdvCommnetsData)
            }
        }
        return newAdvertiseData
    }
    func setLikeAdvertiseByLumi(param:[String:AnyObject],completionHandler: @escaping (_ result: Bool) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            do {
                let jsonData = try? JSONSerialization.data(withJSONObject: param, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)
                let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIPOSTAdvertiseLike)"
                
                let paramCreateRelationship = ["likeDislikeDtls":jsonString!, "url":urlString,"filePath":"","fileName":""]
                do {
                    let multiAPI : multipartAPI = multipartAPI()
                    multiAPI.call(paramCreateRelationship, withCompletionBlock: { (dict, error) in
                        guard dict?.count != 0, (dict?.keys.contains("responseCode"))!, dict!["responseCode"] as! Int != 0 else {
                            DispatchQueue.main.async {
                                MBProgressHUD.hide(for: (appDelInstance().window?.rootViewController?.navigationController?.view)!, animated: true)}
                            completionHandler(false)
                            return
                        }
                        completionHandler(true)
                    })
                } catch let jsonError {
                    print(jsonError)
                }

            } catch let jsonError{
                print(jsonError)
            }
            
            
        }else{
            print("Internet Connection not Available!")
        }
    }
    
    func downloadFileFromServer(newAdvertiseData:AdvertiseData) {
        // let url = self.appdel.fileName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        let filePath = newAdvertiseData.adFilePath?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)

        DownloadManager.shared().startFileDownloads(FileDownloadInfo.init(fileTitle: Int32(newAdvertiseData.advertiseId), andDownloadSource: filePath), withCompletionBlock: { (response,url) in
            DispatchQueue.main.async {
                let realm = try! Realm()
                let advData = realm.objects(AdvertiseData.self).filter("advertiseId = \(response)")
                if advData.count > 0 {
                    var fileName : String!
                    let objCurrentAdv = advData[0] as AdvertiseData
                    if objCurrentAdv.contentType == "Video" {
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
                        if objCurrentAdv.contentType == "Video" {
                            objCurrentAdv.videoThumbFile = fileName
                        }
                        objCurrentAdv.adFilePath = url?.absoluteString.removingPercentEncoding
                        objCurrentAdv.isFileDownloaded = true
                        realm.add(objCurrentAdv, update: true)
                       
                    }
                }
            }
            
            
        })
    }

}

class AdvComments : Object {
    
    @objc dynamic var commentId = 0

    @objc dynamic var commentPostedDate: Double = 0
    @objc dynamic var advertiseId: Double = 0
    @objc dynamic var lumiMobile: Double = 0
    @objc dynamic var lumineerId: Double = 0
    @objc dynamic var comments: String? = nil
    @objc dynamic var strCommentPostedDate: String? = nil
    @objc dynamic var lumiName: String? = nil
    @objc dynamic var lumineerName: String? = nil
    @objc dynamic var isPostedByLumi = false
    @objc dynamic var isPostedByLumineer = false
    
    override static func primaryKey() -> String? {
        return "commentId"
    }

}

