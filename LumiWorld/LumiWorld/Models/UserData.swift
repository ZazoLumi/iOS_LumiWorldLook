//
//  UserData.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/23.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import Foundation
import SwiftyJSON
import  RealmSwift

class UserData : Object{
    
   @objc private(set) dynamic var id = 0
    @objc dynamic var createDate: String? = nil
   @objc dynamic var password: String? = nil
   @objc dynamic var status: String? = nil
   @objc dynamic var cell: String? = nil
   @objc dynamic var appVersion: String? = nil
   @objc dynamic var lastName: String? = nil
    @objc dynamic var updateDate: String? = nil
    @objc dynamic var token: String? = nil
    @objc dynamic var profilePic: String? = nil
   @objc dynamic var gcmId: String? = nil
    @objc dynamic var firstName: String? = nil
    @objc dynamic var displayName: String? = nil
    @objc dynamic var emailAddress: String? = nil

//    init(json : JSON){
//        self.id = json["id"].intValue
//        self.gcmId = json["gcmId"].stringValue
//        self.profilePic = json["profilePic"].stringValue
//        self.token = json["token"].stringValue
//        self.updateDate = json["updateDate"].stringValue
//        self.lastName = json["lastName"].stringValue
//        self.appVersion = json["appVersion"].stringValue
//        self.cell = json["cell"].stringValue
//        self.status = json["status"].stringValue
//        self.password = json["password"].stringValue
//        self.createDate = json["createDate"].stringValue
//        self.displayName = json["displayName"].stringValue
//        self.firstName = json["firstName"].stringValue
//    }
    override static func primaryKey() -> String? {
        return "id"
    }

    convenience init(id : Int, gcmId: String?, profilePic : String? , token: String?, updateDate: String?, lastName: String?, appVersion: String?, cell: String?, status: String?, password: String?, createDate: String?, displayName: String?, firstName: String?,emailAddress:String?) {
        self.init()
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.gcmId = gcmId
        self.profilePic = profilePic
        self.token = token
        self.updateDate = updateDate
        self.lastName = lastName
        self.appVersion = appVersion
        self.cell = cell
        self.status = status
        self.password = password
        self.createDate = createDate
        self.displayName = displayName
        self.emailAddress = emailAddress

    }
}
