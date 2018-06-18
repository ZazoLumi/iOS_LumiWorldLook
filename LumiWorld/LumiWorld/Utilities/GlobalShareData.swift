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
        static let APIGetAllUnreadMsgCountOfLumi = ":13004/instantMsg/getAllUnreadMsgCountOfLumi"

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
    var userCellNumber: String! //for debugging
    var realmManager = RealmManager()
    var objCurrentLumineer : LumineerList!
    var objCurrentLumiMessage : LumiMessage!
    var objCurrentSupport : LumiSupport!
    var objCurretnVC : UIViewController!
    var objCurrentUserDetails = UserData()
    var aryAttachUrls : [URL] = []
    var currentScreenValue : String = currentScreen.messageThread.rawValue
    var strImagePath : String = ""

    lazy var applicationDocumentsDirectory: URL = {
        
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
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
                    NotificationCenter.default.post(name: Notification.Name("attachmentPopupRemoved"), object: nil)
                }
            })
        }
        deleteAction.setValue(UIColor.lumiGreen, forKey: "titleTextColor")

        let deleteAllAction = UIAlertAction(title: "Delete All Messages", style: .default) { (action) in
            objLumiMessage.setLumiSubjectThreadDelete(enterpriseId: objLumiMessage.enterpriseID, messageSubjectId: objLumiMessage.messageSubjectId, completionHandler: { (result) in
                if result {
                    NotificationCenter.default.post(name: Notification.Name("attachmentPopupRemoved"), object: nil) 
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

    
}


//// Use the singleton like this
//let singleton = Global.sharedGlobal
//
//// Let's create an instance of the info struct
//let infoJane = Info(firstname: "Jane", lastname: "Doe", status: "some status")
//
//// Add the struct instance to your array in the singleton
//singleton.member.append(infoJane)

