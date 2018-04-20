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
        static let APIGetLumineerCompany = ":13004/enterprise/getAllActiveLumineerList"
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

    }
}


import Foundation
import RealmSwift
import Realm

class GlobalShareData {
    
    // Now Global.sharedGlobal is your singleton, no need to use nested or other classes
    static let sharedGlobal = GlobalShareData()
    
    var userCellNumber: String! //for debugging
    var realmManager = RealmManager()
    var objCurrentLumineer : LumineerList!
    var objCurrentUserDetails = UserData()
    var messageSubjectId :Double!
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


    

    
}


//// Use the singleton like this
//let singleton = Global.sharedGlobal
//
//// Let's create an instance of the info struct
//let infoJane = Info(firstname: "Jane", lastname: "Doe", status: "some status")
//
//// Add the struct instance to your array in the singleton
//singleton.member.append(infoJane)

