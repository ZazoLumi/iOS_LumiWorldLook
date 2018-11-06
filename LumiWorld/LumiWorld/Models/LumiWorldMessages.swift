//
//  LumiWorldMessages.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/06/19.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import MBProgressHUD

class LumiWorldMessages: Object {
    @objc private(set) dynamic var messageId = 0
    @objc dynamic var sentOn: Double = 0
    @objc dynamic var messageSubjectId: Double = 0
    @objc dynamic var messageSubject: String? = nil
    @objc dynamic var messageBody: String? = nil
    @objc dynamic var sentBy: String? = nil
    @objc dynamic var sentTo: String? = nil
    @objc dynamic var msgSentDate: String? = nil
    @objc  dynamic var selectedLumiMobiles = 0
    @objc dynamic var strResponseReq: String? = nil
    @objc dynamic var readByLumiWorld = false
    @objc dynamic var readByLumi = false
    @objc dynamic var deletedByLumi = false
    @objc dynamic var deletedByLumiWorld = false
    @objc dynamic var archivedByLumiWorld = false
    @objc dynamic var respReqdFromLumi = false
    @objc dynamic var respReqdFromLumiWorld = false
    
        override static func primaryKey() -> String? {
            return "messageId"
        }
}

