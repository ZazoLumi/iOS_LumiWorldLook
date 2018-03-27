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
    }
}

//public func createURLFromParameters() -> URLComponents {
//    
//    var components = URLComponents()
//    components.scheme = Constants.APIDetails.APIScheme
//    components.host   = Constants.APIDetails.APIHost
//    //    components.path   = Constants.APIDetails.apiPath
//    //    if let paramPath = pathparam {
//    //        components.path = Constants.APIDetails.APIPath + "\(paramPath)"
//    //    }
//    //    if !parameters.isEmpty {
//    //        components.queryItems = [URLQueryItem]()
//    //        for (key, value) in parameters {
//    //            let queryItem = URLQueryItem(name: key, value: "\(value)")
//    //            components.queryItems!.append(queryItem)
//    //        }
//    //    }
//    
//    return components
//}


//Result url= https://restcountries.eu/rest/v1/alpha/IN?fullText=true

import Foundation
class GlobalShareData {
    
    // Now Global.sharedGlobal is your singleton, no need to use nested or other classes
    static let sharedGlobal = GlobalShareData()
    public var currentUserDetails = UserData()
    var userCellNumber: String! //for debugging
    
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

