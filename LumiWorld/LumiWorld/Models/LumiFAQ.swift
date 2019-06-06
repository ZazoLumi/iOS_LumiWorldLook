//
//  LumiFAQ.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/05/29.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift
import MBProgressHUD

class LumiFAQ: Object {
    @objc private(set) dynamic var id = 0
    @objc dynamic var createdOn: Double = 0
    @objc dynamic var faq: String? = nil
    @objc dynamic var faqAnswer: String? = nil
    @objc dynamic var strCreatedDate: String? = nil
    override static func primaryKey() -> String? {
        return "id"
    }
    func getLumiFAQMessages(completionHandler: @escaping (_ objData: Results<LumiFAQ>) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIGetDefaultFAQsForLumiumi)"
            
            do {
                AFWrapper.requestGETURL(urlString, success: { (json) in
                    let tempArray = json.arrayValue
                    
                    defer {
                        let realm = try! Realm()
                        var result : Results<LumiFAQ>
                        result  = realm.objects(LumiFAQ.self)
                        if result.count > 0 {
                            completionHandler(result)
                        }
                    }
                    if tempArray.count != 0 {
                        for index in 0...tempArray.count-1 {
                            let aObject = tempArray[index]
                            let realm = try! Realm()
                            let nId : Int = aObject["id"].intValue
                            
                            let objNewLumiFAQ = LumiFAQ()
                            objNewLumiFAQ.id = nId
                            objNewLumiFAQ.createdOn = aObject["createdOn"].doubleValue
                            objNewLumiFAQ.faq = aObject["faq"].string
                            objNewLumiFAQ.faqAnswer = aObject["faqAnswer"].string
                            objNewLumiFAQ.strCreatedDate = aObject["strCreatedDate"].string
                            let result = realm.objects(LumiFAQ.self).filter("id = \(nId)")
                            if result.count>0 {
                                GlobalShareData.sharedGlobal.realmManager.editObjects(objs: objNewLumiFAQ)
                            }
                            else {
                                GlobalShareData.sharedGlobal.realmManager.saveObjects(objs: objNewLumiFAQ)
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
}
