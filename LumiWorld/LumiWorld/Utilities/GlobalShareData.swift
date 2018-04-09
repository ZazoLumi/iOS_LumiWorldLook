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
        static let APISetLumineerAddRelationship = ":11108/addrelationshippropertiesbyid"
        static let APISetLumineerRating = ":13004/enterprise/saveEnterpriseRating"
        static let APIGetLumineerSocialMediaDetails = ":13004/enterprise/getSocialMediaDtlsOfEnterprise"
        static let APIGetLumineerFollowingCounts = ":13004/pushNotif/getNoOfFollowers"
        static let APIGetLumineerUnReadMessageCounts = ":13004/instantMsg/getUnreadMsgCountLumineerWise"
        static let APIGetLumineerAllRatings = ":13004/enterprise/getOverAllRatingOfEnterprise"
    }
}


import Foundation
class GlobalShareData {
    
    // Now Global.sharedGlobal is your singleton, no need to use nested or other classes
    static let sharedGlobal = GlobalShareData()
    public var currentUserDetails = UserData()
    var userCellNumber: String! //for debugging
    var realmManager = RealmManager()

    //var member:[Info] = []
    func isDebug() -> Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
        return true
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

