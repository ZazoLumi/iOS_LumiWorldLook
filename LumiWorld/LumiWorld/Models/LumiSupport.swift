//
//  LumiSupport.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/05/24.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import MBProgressHUD

class LumiSupport : Object {
    @objc private(set) dynamic var supportId = 0
    @objc dynamic var name: String? = nil
    @objc dynamic var messageSubjectId: Double = 0
    @objc dynamic var isArchivedByLumiWorld = false
    @objc dynamic var isDeletedByLumi = false
    @objc dynamic var isDeletedByLumiWorld = false
    @objc dynamic var isReadByLumi = false
    @objc dynamic var isReadByLumiWorld = false
    @objc dynamic var isRespReqdFromLumi = false
    @objc dynamic var isRespReqdFromLumiWorld = false
    @objc dynamic var repliedBy: String? = nil
    @objc dynamic var repliedOn: Double = 0
    @objc dynamic var sentBy: String? = nil
    @objc dynamic var sentOn: Double = 0
    @objc dynamic var sentTo: String? = nil
    @objc dynamic var supportMessageBody: String? = nil
    @objc dynamic var supportMessageSubject: String? = nil
    @objc dynamic var supportSubjectId: Double = 0

    @objc dynamic var messageStatus: String? = nil
    @objc dynamic var sentDate: String? = nil

    @objc dynamic var repliedDate: String? = nil
    @objc dynamic var strResponseReq: String? = nil
    @objc dynamic var supportFileName: String? = nil
    @objc dynamic var contentType: String? = nil
    @objc dynamic var supportFilePath: String? = nil

    override static func primaryKey() -> String? {
        return "supportId"
    }
    func getLumiSupportMessages(cellNumber:String,completionHandler: @escaping (_ objData: Results<LumiSupport>) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIGetAllSupportMessagesOfLumi)" + "?cellNumber=\(cellNumber)"
            do {
                AFWrapper.requestGETURL(urlString, success: { (json) in
                    let tempArray = json.arrayValue

                    defer {
                        let realm = try! Realm()
                        var result : Results<LumiSupport>
                        result  = realm.objects(LumiSupport.self)
                        if result.count > 0 {
                            completionHandler(result)
                        }
                    }
                    for index in 0...tempArray.count-1 {
                        let aObject = tempArray[index]
                        let realm = try! Realm()
                        let supportId : Int = aObject["supportId"].intValue
                        
                            let objNewLumiSupport = LumiSupport()
                            objNewLumiSupport.supportId = supportId
                            objNewLumiSupport.isArchivedByLumiWorld = aObject["isArchivedByLumiWorld"].boolValue
                            objNewLumiSupport.isDeletedByLumi = aObject["isDeletedByLumi"].boolValue
                            objNewLumiSupport.isDeletedByLumiWorld = aObject["isDeletedByLumiWorld"].boolValue
                            objNewLumiSupport.isReadByLumi = aObject["isReadByLumi"].boolValue
                            objNewLumiSupport.isReadByLumiWorld = aObject["isReadByLumiWorld"].boolValue
                            objNewLumiSupport.isRespReqdFromLumi = aObject["isRespReqdFromLumi"].boolValue
                            objNewLumiSupport.isRespReqdFromLumiWorld = aObject["isRespReqdFromLumiWorld"].boolValue
                            objNewLumiSupport.repliedBy = aObject["repliedBy"].stringValue
                            objNewLumiSupport.repliedOn = aObject["repliedOn"].doubleValue
                            objNewLumiSupport.sentBy = aObject["sentBy"].stringValue
                            objNewLumiSupport.sentOn = aObject["sentOn"].doubleValue
                            objNewLumiSupport.sentTo = aObject["sentTo"].stringValue
                            objNewLumiSupport.supportMessageBody = aObject["supportMessageBody"].stringValue
                            objNewLumiSupport.supportMessageSubject = aObject["supportMessageSubject"].stringValue
                            objNewLumiSupport.supportSubjectId = aObject["supportSubjectId"].doubleValue
                            objNewLumiSupport.messageStatus = aObject["messageStatus"].stringValue
                            objNewLumiSupport.sentDate = aObject["sentDate"].stringValue
                            objNewLumiSupport.repliedDate = aObject["repliedDate"].stringValue
                            objNewLumiSupport.strResponseReq = aObject["strResponseReq"].stringValue
                            objNewLumiSupport.supportFileName = aObject["supportFileName"].stringValue
                            objNewLumiSupport.contentType = aObject["contentType"].stringValue
                            objNewLumiSupport.supportFilePath = aObject["supportFilePath"].stringValue
                            
                        let result = realm.objects(LumiSupport.self).filter("supportId = \(supportId)")
                        if result.count>0 {
                            GlobalShareData.sharedGlobal.realmManager.editObjects(objs: objNewLumiSupport)
                        }
                        else {
                            GlobalShareData.sharedGlobal.realmManager.saveObjects(objs: objNewLumiSupport)
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
}
