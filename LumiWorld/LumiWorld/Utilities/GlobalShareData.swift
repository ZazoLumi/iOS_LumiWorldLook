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

   }
}

import Foundation
import RealmSwift
import Realm
import AVKit

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
    
    func extractAllFile(atPath path: String, withExtension fileExtension:String) -> [String] {
        var allFiles: [String] = []
        let url = applicationDocumentsDirectory
        
        let fileManager = FileManager.default
        let enumerator: FileManager.DirectoryEnumerator = fileManager.enumerator(atPath: url.path)!
        while let element = enumerator.nextObject() as? String {
            // do something
            allFiles.append(element)
            
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
    
}


//// Use the singleton like this
//let singleton = Global.sharedGlobal
//
//// Let's create an instance of the info struct
//let infoJane = Info(firstname: "Jane", lastname: "Doe", status: "some status")
//
//// Add the struct instance to your array in the singleton
//singleton.member.append(infoJane)

