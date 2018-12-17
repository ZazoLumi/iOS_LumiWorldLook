//
//  GlobalShareData.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/23.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//
struct Constants {
    struct APIDetails {
        static let APIScheme = "http://196.223.97.152"
        static let APILogin = ":13004/pushNotif/userLogin"
        static let APICreateAccount = ":13004/pushNotif/verifyUser"
        static let APIForgotPassword = ":13004/consumer/resetPassword"
        static let APIValidateCode = ":13004/pushNotif/userLogin"
        static let APIChangePassword = ":13004/consumer/changePassword"
        static let APIVerifyAccount = ":13004/pushNotif/validateVerificationCode"
        static let APIGetLumiCategory = ":13004/sectors/getAllSectors"
        //static let APIGetLumineerCompany = ":13004/enterprise/getAllActiveLumineerList"
        static let APIGetLumineerCompany = ":13004/enterprise/getActiveLumineerListByLastViewedDate"
        
        static let APIGetLumineerFollowingCompany = ":11014/getnodebyrelationship"
        static let APISetLumineerCreateRelationship = ":11103/createRelationship"
        static let APISetLumineerCreateEnterpriseRelationship = ":13004/instantMsg/createEnterpriseRelation"

        static let APISetLumineerAddRelationship = ":11108/addrelationshippropertiesbyid"
        static let APISetLumineerRating = ":13004/enterprise/saveEnterpriseRating"
        static let APIGetLumineerSocialMediaDetails = ":13004/enterprise/getSocialMediaDtlsOfEnterprise"
        static let APIGetLumineerFollowingCounts = ":13004/pushNotif/getNoOfFollowers"
        static let APIGetLumineerUnReadMessageCounts = ":13004/instantMsg/getUnreadMsgCountLumineerWise"
        static let APIGetLumineerAllRatings = ":13004/enterprise/getOverAllRatingOfEnterprise"
        static let APIGetLumineerMessages = ":13004/instantMsg/getAllNewsFeedsOfLumi"
        static let APISendLumineerTextMessages = ":13004/instantMsg/instantMessagingByLumi"
        static let APISendLumineerAttachmentMessages = ":13004/instantMsg/replyToIMByLumiWithMedia"
        static let APIViewMessagesByLumi = ":13004/instantMsg/viewMessagesByLumi"
        static let APIGetAllSupportMessagesOfLumi = ":13004/lumisupport/getSupportMessagesOfLumiByLastViewedDate"
        static let APIReplyToLumiWorldWithMediaByLumi = ":13004/lumisupport/replyToLumiWorldWithMediaByLumi"
        static let APISendSupportQueryWithMediaByLumi = ":13004/lumisupport/sendSupportQueryWithMediaByLumi"
        static let APISendSupportQueryToLumiAdmin = ":13004/lumisupport/sendSupportQueryToLumiAdmin"
        static let APIReplyToLumiWorldByLumin = ":13004/lumisupport/replyToLumiWorldByLumi"
        static let APIMarkSupportMsgAsReadByLumi = ":13004/lumisupport/markSupportMsgAsReadByLumi"
        static let APIMarkSupportMsgAsDeletedByLumi = ":13004/lumisupport/markSupportMsgAsDeletedByLumi"
        static let APIGetDefaultFAQsForLumiumi = ":13004/lumiadmin/getDefaultFAQsForLumi"
        static let APIDeleteNewsFeedsOfLumiByMessageSubject = ":13004/newsfeed/deleteNewsFeedsOfLumiByMessageSubject"
        static let APIDeleteNewsFeedsOfLumiAndLumineer = ":13004/newsfeed/deleteNewsFeedsOfLumiAndLumineer"
        static let APIDeleteNewsFeedByLumi = ":13004/newsfeed/deleteNewsFeedByLumi"
        static let APIUpdateUserProfileWithPhoto = ":13004/pushNotif/updateUserProfileWithPhoto";
        static let APIUpdateUserProfile = ":13004/pushNotif/updateUserProfile"
        static let APIInviteAFriendToLumiWorld = ":13004/invite/inviteAFriendToLumiWorld"
        static let APISuggestACompany = ":13004/invite/suggestACompany"
        static let APISuggestALumineer = ":13004/invite/suggestLumineerToLumi"
        static let APIGetAllLumiWorldMessagesOfLumi = ":13004/invite/getAllLumiWorldMessagesOfLumi"
        static let APIGetAllUnreadMsgCountOfLumi = ":13004/instantMsg/getAllUnreadMsgCountOfLumi/v2"
        
        static let APIGetAllAdsPostedToLumiByALumineer = ":13004/adposting/getAllAdsPostedToLumiByALumineer"
        static let APIGetAllAdsPostedToLumi = "http://lumiimportupload20180622023528.azurewebsites.net/api/AdWrapper"
        static let APIPOSTAdvertiseComments = ":13004/adposting/postCommentsToLumineerAdByLumi"
        static let APIPOSTAdvertiseReports = ":13004/adposting/postReportsToLumineerAdByLumi"
        static let APIPOSTAdvertiseLike = ":13004/adposting/likeOrDislikeLumineerAd"
        static let APIGetAllLumineerContent = "http://lumiimportupload20180622023528.azurewebsites.net/api/GetAllContent"
        static let APIPostLumineerContentComments = "http://lumiimportupload20180622023528.azurewebsites.net/api/PostContentComment"
        static let APIPostLumineerContentLikes = "http://lumiimportupload20180622023528.azurewebsites.net/api/LikeContent"
        static let APIGetAllLumineerGallery = "http://lumiimportupload20180622023528.azurewebsites.net/api/GetAllGallery"

   }
}

import Foundation
import RealmSwift
import Realm
import AVKit
import Zip
import MBProgressHUD

class GlobalShareData {
    
    // Now Global.sharedGlobal is your singleton, no need to use nested or other classes
    static let sharedGlobal = GlobalShareData()
    var isContactPicked = false
    var isVideoPlaying = false
    var userCellNumber: String! //for debugging
    var realmManager = RealmManager()
    var objCurrentLumineer : LumineerList!
    var objCurrentAdv : AdvertiseData!
    var objCurrentContent : LumineerContent!
    var objCurrentLumiMessage : LumiMessage!
    var objCurrentSupport : LumiSupport!
    var objCurretnVC : UIViewController!
    var objCurrentUserDetails = UserData()
    var aryAttachUrls : [URL] = []
    var currentScreenValue : String = currentScreen.messageThread.rawValue
    var strImagePath : String = ""
    var sagmentViewHeight : NSInteger = 0
    
    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        print(urls)
        let documentDirectoryURL = urls[urls.count - 1] as URL
        let dbDirectoryURL = documentDirectoryURL.appendingPathComponent("Docs")
        
        if FileManager.default.fileExists(atPath: dbDirectoryURL.path) == false{
            do{
                try FileManager.default.createDirectory(at: dbDirectoryURL, withIntermediateDirectories: false, attributes: nil)
            }catch{
            }
        }
        return dbDirectoryURL
    }()
    
    lazy var exportDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectoryURL = urls[urls.count - 1] as URL
        let dbDirectoryURL = documentDirectoryURL.appendingPathComponent("Export")
        if FileManager.default.fileExists(atPath: dbDirectoryURL.path) == false{
            do{
                try FileManager.default.createDirectory(at: dbDirectoryURL, withIntermediateDirectories: false, attributes: nil)
            }catch{
            }
        }
        return dbDirectoryURL
    }()
    
    func updateExportedDocumentDirectory() {
        let urls = exportDocumentsDirectory
        if FileManager.default.fileExists(atPath: urls.path){
            try? FileManager.default.removeItem(at:urls)
        }
        do{
            try FileManager.default.createDirectory(at: exportDocumentsDirectory, withIntermediateDirectories: false, attributes: nil)
        }catch{
        }

    }



    
    func isDebug() -> Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
        return true
    }
    
    init() {
//        let realm = try! Realm()
//        let realmObjects = realm.objects(UserData.self)
//        objCurrentUserDetails = realmObjects[0]
    }
    
    func getDocumentDirectorypath()->String {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                           .userDomainMask, true)
        return  dirPaths[0]

    }
    
    func extractAllFile(atPath path: String,url: URL, withExtension fileExtension:String) -> [URL] {
        var allFiles: [URL] = []
        
        let fileManager = FileManager.default
        let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: url.path)!
        while let element = enumerator.nextObject() as? String {
            // do something
            allFiles.append(URL.init(string: url.path.appendingPathComponent(element))!)
            
        }
        return allFiles
    }
    
    func storeGenericfileinDocumentDirectory(fileContent:NSData,fileName:String) -> String{
        let docDirectory = applicationDocumentsDirectory.appendingPathComponent(fileName)
        try? fileContent.write(to: docDirectory)
        return docDirectory.absoluteString
    }
    
    func removeFilefromDocumentDirectory(fileName:String) {
        let docDirectory = applicationDocumentsDirectory.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at:docDirectory)
    }
    
    func clearDiskCache() {
        let fileManager = FileManager.default
        let myDocuments = applicationDocumentsDirectory
        guard let filePaths = try? fileManager.contentsOfDirectory(at: myDocuments, includingPropertiesForKeys: nil, options: []) else { return }
        for filePath in filePaths {
            try? fileManager.removeItem(at: filePath)
        }
    }

    func getVisibleViewController(_ rootViewController: UIViewController?) -> UIViewController? {
        
        var rootVC = rootViewController
        if rootVC == nil {
            rootVC = UIApplication.shared.keyWindow?.rootViewController
        }
        
        if rootVC?.presentedViewController == nil {
            return rootVC
        }
        
        if let presented = rootVC?.presentedViewController {
            if presented.isKind(of: UINavigationController.self) {
                let navigationController = presented as! UINavigationController
                return navigationController.viewControllers.last!
            }
            
            if presented.isKind(of: UITabBarController.self) {
                let tabBarController = presented as! UITabBarController
                return tabBarController.selectedViewController!
            }
            
            return getVisibleViewController(presented)
        }
        return nil
    }
    
    func handleChatActionsheet(lumiMessageID:Int) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let lumiMessage = objCurrentLumineer.lumiMessages.filter("id = \(lumiMessageID)")
        var objLumiMessage = LumiMessage()

        if lumiMessage.count > 0 {
            objLumiMessage = lumiMessage[0] as LumiMessage
        }
        let deleteAction = UIAlertAction(title: "Delete Message", style: .default) { (action) in
            objLumiMessage.setLumiMessageDelete(strGuid: objLumiMessage.guid!, completionHandler: { (result) in
                if result {
                    let realm = try! Realm()
                    let result = realm.objects(LumineerList.self).filter("id = \(self.objCurrentLumineer.id)").filter("ANY lumiMessages.id > 0")
                    if  result.count > 0{
                        NotificationCenter.default.post(name: Notification.Name("attachmentPopupRemoved"), object: nil)
                    }
                    else {
                        self.objCurretnVC.navigationController?.popViewController()
                    }
                }
            })
        }
        deleteAction.setValue(UIColor.lumiGreen, forKey: "titleTextColor")

        let deleteAllAction = UIAlertAction(title: "Delete All Messages", style: .default) { (action) in
            objLumiMessage.setLumiSubjectThreadDelete(enterpriseId: objLumiMessage.enterpriseID, messageSubjectId: objLumiMessage.messageSubjectId, completionHandler: { (result) in
                if result {
                    let hud = MBProgressHUD.showAdded(to: (self.objCurretnVC.navigationController?.view)!, animated: true)
                    hud.mode = .text
                    hud.label.text = NSLocalizedString("All messages are deleted successfully.", comment: "HUD message title")
                    hud.label.font = UIFont.init(name: "HelveticaNeue", size: 14)
                    hud.offset = CGPoint(x: 0.0, y: 120)
                    hud.hide(animated: true, afterDelay: 2.0)

                    //NotificationCenter.default.post(name: Notification.Name("attachmentPopupRemoved"), object: nil)
                    self.objCurretnVC.navigationController?.popViewController()
                }
            })
        }
        deleteAllAction.setValue(UIColor.lumiGreen, forKey: "titleTextColor")

        let exportAction = UIAlertAction(title: "Export Messages", style: .default) { (action) in
            self.exportChatDataFile(messageSubjectId: objLumiMessage.messageSubjectId)
        }
        exportAction.setValue(UIColor.lumiGreen, forKey: "titleTextColor")

        let cancelAction = UIAlertAction(title:"Cancel", style:.cancel)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(deleteAllAction)
        actionSheet.addAction(exportAction)
        actionSheet.addAction(cancelAction)

        objCurretnVC.present(actionSheet, animated: true, completion: nil)
    }
    
    func exportChatDataFile(messageSubjectId: Double) {
        let filemgr = FileManager.default
        let hud = MBProgressHUD.showAdded(to: (objCurretnVC.navigationController?.view)!, animated: true)
        hud.label.text = NSLocalizedString("Exporting...", comment: "Exporting chat")
        updateExportedDocumentDirectory()
        let lumiMessages = objCurrentLumineer.lumiMessages.filter("messageSubjectId = \(messageSubjectId)")
        var content = ""
        for objLumiMessage in lumiMessages {
            if content.count > 0 {
                content.append("\n")
            }
            var messageCont = ""
            if objLumiMessage.newsFeedBody != nil {
                messageCont = objLumiMessage.newsFeedBody!
            }
            let stringData = "[\(objLumiMessage.newsfeedPostedTime!)] " + "\(objLumiMessage.sentBy!):" + "\(messageCont)"
            content.append(stringData)
            
            if objLumiMessage.contentType == "Image" ||  objLumiMessage.contentType == "Video" || objLumiMessage.contentType == "Location"{
                do {
                    let fileName = objLumiMessage.fileName?.lastPathComponent
                    let url = applicationDocumentsDirectory.appendingPathComponent(fileName!)
                    let destUrl = exportDocumentsDirectory.appendingPathComponent(fileName!)

                    if !filemgr.fileExists(atPath: destUrl.path ) {
                        try filemgr.copyItem(atPath: url.path, toPath: destUrl.path)
                    }

                }catch{
                    hud.hide(animated: true)
                    print("Error for file write123")
                }
            }
        }
        defer {
            let filePath = exportDocumentsDirectory.appendingPathComponent("chat.txt")

        //    let filePath = exportDocumentsDirectory.absoluteString.appendingPathComponent("chat.txt")
            print(content)
            do{
                try content.write(toFile: filePath.path, atomically: false, encoding: String.Encoding.utf8)
            }catch _ {
                hud.hide(animated: true)
                print("Error for file write")
            }
            
            do{

                let zipFilePath = applicationDocumentsDirectory.appendingPathComponent("lumiWorld.zip")
                if filemgr.fileExists(atPath: zipFilePath.path ) {
                    if zipFilePath.isFileURL {
                        try? filemgr.removeItem(at: zipFilePath)
                    }
                }
                var isZipPrepared = false
                let filesPath = extractAllFile(atPath: "", url: exportDocumentsDirectory, withExtension: "")
                try Zip.zipFiles(paths: filesPath, zipFilePath: zipFilePath, password: nil, progress: { (progress) -> () in
                    if progress == 1.0 && !isZipPrepared {
                        hud.hide(animated: true)
                        isZipPrepared = true
                        NotificationCenter.default.post(name: Notification.Name("openDocumentInterationController"), object: nil, userInfo: ["url":zipFilePath])

                    }
                    print(progress)
                })
            }catch _ {
                hud.hide(animated: true)
                print("Error for zip files")
            }
        }
    }

    func getCurrentAdvertise() -> [[String:AnyObject]]{
        let realm = try! Realm()
        let result  = realm.objects(AdvertiseData.self)
        var aryAdsData: [[String:AnyObject]] = []
        if result.count > 0 {
            let currentDate = Date()
            for objAdv in result {
                let creteatedData = objAdv.strAdvertiseDate
                
                let cDate = Date().getDateFromString(strCurrentDate: creteatedData!, curFormatter: "yyyy-MM-dd HH:mm", expFormatter: "yyyy-MM-dd'T'HH:mm:ssZZZ")
                let date1 = currentDate
                let date2 = cDate
                let calendar = Calendar.current
                let dateComponents = calendar.dateComponents([.minute], from: date2, to: date1)
                print("Difference between times since midnight is", dateComponents.minute as Any)
                let allowMinuntes = objAdv.airingAllotment?.components(separatedBy: " ").first?.int
                let diffValue = dateComponents.minute!
                if diffValue >= 0 && diffValue <= allowMinuntes! {
                    let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",objAdv.lumineerId.int)
                    if objsLumineer.count > 0 {
                        let lumineer = objsLumineer[0]
                        let section = ["title":lumineer.name as Any,"createdTime":objAdv.updatedDate as Any, "message":objAdv as Any,"profileImg":lumineer.enterpriseLogo as Any,"lumineer":lumineer as Any,"type":"adv","lumineerId":lumineer.id] as [String : Any]
                        aryAdsData.append(section as [String : AnyObject])
                    }
                }
            }
            
            print("Count:\(aryAdsData.count)")
        }
        return aryAdsData
    }
    
    func saveAdsRecord() {
        var msgText : String = ""
        let realm = try! Realm()
        
        let type = GlobalShareData.sharedGlobal.objCurrentAdv.contentType?.uppercased()
        if GlobalShareData.sharedGlobal.objCurrentAdv.isAdsSaved {
            msgText =  "\(type!) IS ALREADY SAVED"
        }
        else {
            try! realm.write({
                GlobalShareData.sharedGlobal.objCurrentAdv.isAdsSaved = true})
            msgText =  "\(type!) SAVED TO WATCH LATER"
            
        }
        let hud = MBProgressHUD.showAdded(to: objCurretnVC.view!, animated: true)
        hud.mode = .text
        hud.label.text = NSLocalizedString(msgText, comment: "HUD message title")
        hud.label.font = UIFont.init(name: "HelveticaNeue", size: 14)
        hud.offset = CGPoint(x:0, y: UIScreen.main.bounds.height/2)// CGPoint(x: (super.view.width/2)-50, y: super.view.height/2)
        hud.hide(animated: true, afterDelay: 3.0)
    }
    
    func geCurrentLumineersAdvertise() -> [[String:AnyObject]]{
        let realm = try! Realm()
        let result  = realm.objects(AdvertiseData.self).filter("id == %d",objCurrentLumineer.id)
        var aryAdsData: [[String:AnyObject]] = []
        if result.count > 0 {
            for objAdv in result {
                let creteatedData = objAdv.strAdvertiseDate
                let cDate = Date().getDateFromString(strCurrentDate: creteatedData!, curFormatter: "yyyy-MM-dd HH:mm", expFormatter: "yyyy-MM-dd'T'HH:mm:ssZZZ")
                let currentDate = Date()
                if currentDate.isGreaterThanDate(dateToCompare: cDate as NSDate) {
                    let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",objAdv.lumineerId.int)
                    if objsLumineer.count > 0 {
                        let lumineer = objsLumineer[0]
                        let section = ["title":lumineer.name as Any,"createdTime":objAdv.updatedDate as Any, "message":objAdv as Any,"profileImg":lumineer.enterpriseLogo as Any,"lumineer":lumineer as Any,"type":"adv"] as [String : Any]
                        aryAdsData.append(section as [String : AnyObject])
                    }
                }
                
            }
            
            print("Count:\(aryAdsData.count)")
        }
        return aryAdsData
    }

    
    func getAllAdvertise() -> [[String:AnyObject]]{
        let realm = try! Realm()
        let result  = realm.objects(AdvertiseData.self)
        var aryAdsData: [[String:AnyObject]] = []
        if result.count > 0 {
            for objAdv in result {
                let creteatedData = objAdv.strAdvertiseDate
                let cDate = Date().getDateFromString(strCurrentDate: creteatedData!, curFormatter: "yyyy-MM-dd HH:mm", expFormatter: "yyyy-MM-dd'T'HH:mm:ssZZZ")
                let currentDate = Date()
                if currentDate.isGreaterThanDate(dateToCompare: cDate as NSDate) {
                    let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",objAdv.lumineerId.int)
                    if objsLumineer.count > 0 {
                        let lumineer = objsLumineer[0]
                        let section = ["title":lumineer.name as Any,"createdTime":objAdv.updatedDate as Any, "message":objAdv as Any,"profileImg":lumineer.enterpriseLogo as Any,"lumineer":lumineer as Any,"type":"adv"] as [String : Any]
                        aryAdsData.append(section as [String : AnyObject])
                    }
                }
                
            }
            
            print("Count:\(aryAdsData.count)")
        }
        return aryAdsData
    }

    func getAllContents(isCurrentLumineer:Bool) -> [[String:AnyObject]]{
        let realm = try! Realm()
        var result  = realm.objects(LumineerContent.self)
        if isCurrentLumineer {
           result  = realm.objects(LumineerContent.self).filter("lumineerId == %d", objCurrentLumineer.id)
        }
        else {
            result  = realm.objects(LumineerContent.self)
        }
        var aryContentData: [[String:AnyObject]] = []
        if result.count > 0 {
            for objContent in result {
                let creteatedData = objContent.strCreatedDate
                let cDate = Date().getDateFromString(strCurrentDate: creteatedData!, curFormatter: "yyyy-MM-dd HH:mm", expFormatter: "yyyy-MM-dd HH:mm")
                let currentDate = Date()
                if currentDate.isGreaterThanDate(dateToCompare: cDate as NSDate) {
                    let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",objContent.lumineerId.int)
                    if objsLumineer.count > 0 {
                        let lumineer = objsLumineer[0]
                        let section = ["title":lumineer.name as Any, "message":objContent as Any,"profileImg":lumineer.enterpriseLogo as Any,"lumineer":lumineer as Any,"type":"content","isSelected":"false"] as [String : Any]
                        aryContentData.append(section as [String : AnyObject])
                    }
                }
            }
            print("Count:\(aryContentData.count)")
        }
        return aryContentData
    }
    
    func getAllGallaryContents() -> [[String:AnyObject]]{
        let realm = try! Realm()
        let result  = realm.objects(LumineerGalleryData.self)
        var aryContentData: [[String:AnyObject]] = []
        if result.count > 0 {
            for objContent in result {
                    let objsLumineer = realm.objects(LumineerList.self).filter("id == %d",objContent.lumineerId.int)
                    if objsLumineer.count > 0 {
                        let lumineer = objsLumineer[0]
                        let section = ["title":lumineer.name as Any, "message":objContent as Any,"profileImg":lumineer.enterpriseLogo as Any,"lumineer":lumineer as Any,"type":"content","isSelected":"false"] as [String : Any]
                        aryContentData.append(section as [String : AnyObject])
                }
            }
            print("Count:\(aryContentData.count)")
        }
        return aryContentData
    }
    
    func getlatestCategoriesAndData (completionHandler: @escaping (_ response: Bool) -> Void) {
        let objLumiCate = LumiCategory()
        DispatchQueue.global(qos: .userInitiated).async {
            objLumiCate.getLumiCategory(viewCtrl: self.objCurretnVC) { (aryCategory) in
                guard aryCategory.count != 0 else {
                    completionHandler(false)
                    return
                }
                let objLumineerList = LumineerList()
                let originalString = Date().getFormattedTimestamp(key: UserDefaultsKeys.lumineerTimeStamp)
                let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
                objLumineerList.getLumineerCompany(lastViewDate:escapedString!,completionHandler: { (List) in
                    guard List.count != 0 else {
                        completionHandler(false)
                        return
                    }
                    completionHandler(true)
                })
            }
        }
    }
    
    func deleteExpiredAds() {
        let realm = try! Realm()
        let result  = realm.objects(AdvertiseData.self)
        if result.count > 0 {
            for objAdv in result {
                let creteatedData = objAdv.strAdvertiseDate
                let weeksDay = (objAdv.compaignWindow?.components(separatedBy: " ").first?.int)! * 7
                let calendar = Calendar.current
                let cDate = Date().getDateFromString(strCurrentDate: creteatedData!, curFormatter: "yyyy-MM-dd HH:mm", expFormatter: "yyyy-MM-dd'T'HH:mm:ssZZZ")
                
                let nextWeeksDate = calendar.date(byAdding: .day, value: weeksDay, to: cDate)
                
                
                let currentDate = Date()
                
                if currentDate.isGreaterThanDate(dateToCompare: nextWeeksDate! as NSDate) {
                    let comments = realm.objects(AdvComments.self).filter("advertiseId == %d",objAdv.advertiseId)
                    try! realm.write {
                        realm.delete(comments)
                        realm.delete(objAdv)
                        try! realm.commitWrite()
                    }

                }

            }
            
        }
    }
    
    func getAllLatestLumineerData() {
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        let objAdv = AdvertiseData()
        
        objAdv.getLumineerAdvertise(param: ["lumiMobile" :GlobalShareData.sharedGlobal.userCellNumber,"lumineerId":"0"]) { (result) in
            dispatchGroup.leave()
            GlobalShareData.sharedGlobal.deleteExpiredAds()
        }
        
        dispatchGroup.enter()
        let objContent = LumineerContent()
        
        objContent.getLumineerContents(param:["lumiMobile" :GlobalShareData.sharedGlobal.userCellNumber,"lumineerId":"0"]) { (result) in
            dispatchGroup.leave()
        }
        
        let objGallary = LumineerGalleryData()
        
        objGallary.getLumineerGetAllGallaryContents(param:["lumiMobile" :GlobalShareData.sharedGlobal.userCellNumber,"lumineerId":"0"]) { (result) in
            dispatchGroup.leave()
        }

        
        dispatchGroup.notify(queue: .main) {
            print("Both functions complete 👍")
        }
    }
}

extension Date {
    func isGreaterThanDate(dateToCompare: NSDate) -> Bool {
        //Declare Variables
        var isGreater = false
        
        //Compare Values
        if self.compare(dateToCompare as Date) == ComparisonResult.orderedDescending {
            isGreater = true
        }
        
        //Return Result
        return isGreater
    }
}
//// Use the singleton like this
//let singleton = Global.sharedGlobal
//
//// Let's create an instance of the info struct
//let infoJane = Info(firstname: "Jane", lastname: "Doe", status: "some status")
//
//// Add the struct instance to your array in the singleton
//singleton.member.append(infoJane)

