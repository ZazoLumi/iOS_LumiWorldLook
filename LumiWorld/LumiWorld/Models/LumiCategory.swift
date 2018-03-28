//
//  LumiCategory.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/03/28.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift
import MBProgressHUD

class LumineerList : Object{
    @objc private(set) dynamic var id = 0
    @objc dynamic var name: String? = nil
    @objc dynamic var sectorID: String? = nil

    @objc dynamic var sectorName: String? = nil
    @objc dynamic var shortDescription: String? = nil
    @objc dynamic var status: String? = nil
    @objc dynamic var contactNumber: String? = nil
    @objc dynamic var emailAddress : String? = nil
    @objc dynamic var companyRegistrationNumber : String? = nil
    @objc dynamic var firstName : String? = nil
    @objc dynamic var surname : String? = nil
    @objc dynamic var enterpriseLogo : String? = nil
    @objc dynamic var enterpriseCoverPage : String? = nil
    @objc dynamic var displayName : String? = nil
    @objc dynamic var logoURL : String? = nil
    @objc dynamic var parentid : String? = nil
    
    public func getLumineerCompany(completionHandler: @escaping (_ objData: List<LumiCategory>) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIGetLumineerCompany)"
            do {
                
                AFWrapper.requestGETURL(urlString, success: { (json) in
                    let tempArray = json.arrayValue
                    for index in 0...tempArray.count-1 {
                        let aObject = tempArray[index]
                        let realm = try! Realm()
                        let id : Int = aObject["id"].intValue
                        let objCategory  = realm.objects(LumiCategory.self).filter("id == %d", id)
                        
                        let newLumineerObj = LumineerList()
                        newLumineerObj.id = id
                        newLumineerObj.name = aObject["name"].string
                        newLumineerObj.sectorID = aObject["sectorID"].string
                        newLumineerObj.sectorName = aObject["sectorName"].string
                        newLumineerObj.shortDescription = aObject["shortDescription"].string
                        newLumineerObj.status = aObject["status"].string
                        newLumineerObj.contactNumber = aObject["contactNumber"].string
                        newLumineerObj.emailAddress = aObject["emailAddress"].string
                        newLumineerObj.companyRegistrationNumber = aObject["companyRegistrationNumber"].string
                        newLumineerObj.firstName = aObject["firstName"].string
                        newLumineerObj.surname = aObject["surname"].string
                        newLumineerObj.enterpriseLogo = aObject["enterpriseLogo"].string
                        newLumineerObj.enterpriseCoverPage = aObject["enterpriseCoverPage"].string
                        newLumineerObj.displayName = aObject["displayName"].string
                        newLumineerObj.logoURL = aObject["logoURL"].string
                        newLumineerObj.parentid = aObject["parentid"].string
                        
                        
                        let lumineerList = objCategory[0].lumineerList
                        lumineerList.append(newLumineerObj)
                        objCategory[0].lumineerList = lumineerList
                        if objCategory.count>0 {
                            GlobalShareData.sharedGlobal.realmManager.editObjects(objs: objCategory[0])
                        }
                        
                    }
//                    let objCategory  = realm?.objects(LumiCategory.self)
//                    completionHandler(objCategory)
                    print(json)
                }, failure: { (Error) in
                })
                
            } catch let jsonError{
                print(jsonError)
                
            }
            
        }else{
            print("Internet Connection not Available!")
        }
        
    }

}

class LumiCategory : Object{
    
    @objc private(set) dynamic var id = 0
    @objc dynamic var name: String? = nil
    @objc dynamic var status: String? = nil
    @objc dynamic var categoryDescription: String? = nil
    @objc dynamic var originalImage: String? = nil
    @objc dynamic var visitedImage: String? = nil
    var lumineerList = List<LumineerList>()

    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(id : Int, name: String?, status : String? , categoryDescription: String?, originalImage: String?, visitedImage: String?) {
        self.init()
        self.id = id
        self.name = name
        self.status = status
        self.categoryDescription = categoryDescription
        self.originalImage = originalImage
        self.visitedImage = visitedImage

    }
    
    
    public func getLumiCategory(viewCtrl:UIViewController, completionHandler: @escaping (_ objData: [LumiCategory]) -> Void) {
        var aryCategory : [LumiCategory] = []
    if Reachability.isConnectedToNetwork(){
        print("Internet Connection Available!")
        let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIGetLumiCategory)"
        do {
            let hud = MBProgressHUD.showAdded(to: (viewCtrl.view)!, animated: true)
            hud.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")
            
            AFWrapper.requestGETURL(urlString, success: { (json) in
                let tempArray = json.arrayValue
                hud.hide(animated: true)
                for index in 0...tempArray.count-1 {
                    let aObject = tempArray[index]
                    let realm = try! Realm()
                    let id : Int = aObject["id"].intValue
                    let data  = realm.objects(LumiCategory.self).filter("id == %d", id)
                    let newObj = LumiCategory(id : id , name : aObject["name"].string,status : aObject["status"].string,categoryDescription : aObject["categoryDescription"].string,originalImage:aObject["originalImage"].string,visitedImage:aObject["visitedImage"].string)
                    if data.count>0 {
                        GlobalShareData.sharedGlobal.realmManager.editObjects(objs: newObj)
                    }
                    else {
                        GlobalShareData.sharedGlobal.realmManager.saveObjects(objs: newObj)
                    }
                    aryCategory.append(newObj)
                }
                completionHandler(aryCategory)
                print(json)
            }, failure: { (Error) in
                hud.hide(animated: true)
                viewCtrl.showCustomAlert(strTitle: "", strDetails: Error.localizedDescription, completion: { (str) in
                    print(Error.localizedDescription)
                })
            })

        } catch let jsonError{
            print(jsonError)
            
        }

    }else{
        print("Internet Connection not Available!")
    }

    }
}
