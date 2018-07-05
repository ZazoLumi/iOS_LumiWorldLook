
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

class LumineerList : Object {
    @objc private(set) dynamic var id = 0
    @objc dynamic var name: String? = nil
    @objc dynamic var sectorName: String? = nil
    @objc dynamic var shortDescription: String? = nil
    @objc dynamic var detailedDescription: String? = nil
    @objc dynamic var contactNumber: String? = nil
    @objc dynamic var emailAddress : String? = nil
    @objc dynamic var companyRegistrationNumber : String? = nil
    @objc dynamic var firstName : String? = nil
    @objc dynamic var surname : String? = nil
    @objc dynamic var enterpriseLogo : String? = nil
    @objc dynamic var enterpriseLogoOpt : String? = nil
    @objc dynamic var enterpriseCoverPage : String? = nil
    @objc dynamic var displayName : String? = nil
    @objc dynamic var logoURL : String? = nil
    @objc private(set) dynamic var parentid = 0
    @objc private(set) dynamic var sectorID = 0
    @objc private(set) dynamic var status = 0
    @objc  dynamic var followersCount = 0
    @objc  dynamic var ratings = 0
    @objc  dynamic var unreadCount = 0
    var lumiMessages = List<LumiMessage>()

    override static func primaryKey() -> String? {
        return "id"
    }

    public func getLumineerCompany(lastViewDate:String, completionHandler: @escaping (_ objData: Results<Object>) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIGetLumineerCompany)" + "?lastViewedDate=\(lastViewDate)"

            do {
                self.getLumineerCompanyFollowingData(completionHandler: { (aryFollowdata) in
                    AFWrapper.requestGETURL(urlString, success: { (json) in
                        let tempArray = json.arrayValue
                        let realm = try! Realm()

                        guard tempArray.count != 0 else {
                            let objCategory  = GlobalShareData.sharedGlobal.realmManager.getObjects(type: LumiCategory.self)
                            completionHandler(objCategory!)
                            return
                        }

                        for index in 0...tempArray.count-1 {
                            let aObject = tempArray[index]
                            let id : Int = aObject["id"].intValue
                            let objCategory = realm.objects(LumiCategory.self).filter("id == %d", aObject["parentid"].intValue)
                            
                            let newLumineerObj = LumineerList()
                            newLumineerObj.id = id
                            newLumineerObj.name = aObject["name"].string
                            newLumineerObj.sectorID = aObject["sectorID"].intValue
                            newLumineerObj.sectorName = aObject["sectorName"].string
                            newLumineerObj.shortDescription = aObject["shortDescription"].string
                            newLumineerObj.detailedDescription = aObject["detailedDescription"].string

                            let filteredData = aryFollowdata.filter{
                                let string = $0["ID"] as! String
                                return string.contains(aObject["companyRegistrationNumber"].string!)
                            }
                            
                            
                            if filteredData.count>0 {
                                if let stringvalue = filteredData[0]["status"] as? String {
                                    if let myInteger = Int(stringvalue) {
                                        newLumineerObj.status = Int(truncating: NSNumber(value:myInteger))
                                    }
                                }
                                else if let numberValue = filteredData[0]["status"] as? NSNumber {
                                    newLumineerObj.status = numberValue as! Int
                                }

                            }
                            else {
                                newLumineerObj.status = aObject["status"].intValue
                            }
                            newLumineerObj.contactNumber = aObject["contactNumber"].string
                            newLumineerObj.emailAddress = aObject["emailAddress"].string
                            newLumineerObj.companyRegistrationNumber = aObject["companyRegistrationNumber"].string
                            newLumineerObj.firstName = aObject["firstName"].string
                            newLumineerObj.surname = aObject["surname"].string
                            newLumineerObj.enterpriseLogo = aObject["enterpriseLogo"].string
                            newLumineerObj.enterpriseLogoOpt = aObject["enterpriseLogoOpt"].string
                            newLumineerObj.enterpriseCoverPage = aObject["enterpriseCoverPage"].string
                            newLumineerObj.displayName = aObject["displayName"].string
                            newLumineerObj.logoURL = aObject["logoURL"].string
                            newLumineerObj.parentid = aObject["parentid"].intValue
                            
                            let aryMessages = realm.objects(LumiMessage.self).filter("enterpriseID == %d", id)
                            if aryMessages.count > 0 {
                                for index in 0...aryMessages.count-1 {
                                    let objMessages = aryMessages[index] as LumiMessage
                                    newLumineerObj.lumiMessages.append(objMessages)
                                }
                            }
                            
                            if objCategory.count>0 {
                                
                                let lumineerList = objCategory[0].lumineerList
                                try! realm.write {
                                    realm.add(newLumineerObj, update: true)
                                    lumineerList.append(newLumineerObj)
                                }
                            }
                        }
                        let objCategory  = GlobalShareData.sharedGlobal.realmManager.getObjects(type: LumiCategory.self)
                        completionHandler(objCategory!)
                        print(json)
                    }, failure: { (Error) in
                    })
                })
            } catch let jsonError{
                print(jsonError)
                
            }
            
        }else{
            print("Internet Connection not Available!")
        }
        
    }
    func getLumineerCompanyFollowingData(completionHandler: @escaping (_ objData: [[String:Any]]) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIGetLumineerFollowingCompany)"
            do {
                //todo
                let strCellNumber : String  =  GlobalShareData.sharedGlobal.userCellNumber!
                let dictionary = ["cell": strCellNumber]
                let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)

                let param = ["params": jsonString]
                
                AFWrapper.requestPOSTURL(urlString, params: param as [String : AnyObject], headers: nil, success: { (json) in
                    print(json)
                    let tempDict = json.arrayObject
                    completionHandler(tempDict as! [[String : Any]])
                }, failure: { (Error) in
                })
            } catch let jsonError{
                print(jsonError)
                
            }
        }else{
            print("Internet Connection not Available!")
        }
    }
    
    func setLumineerCompanyFollowUnFollowData(id:String,companyregistrationnumber: String,uniqueID:String,status:String,completionHandler: @escaping (_ objData: LumineerList) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            do {
                /*let currentDate = getLocalFormatedCurrentData()
                let dictionary = ["date": currentDate,"status":status,"ID":uniqueID] as [String : String]
                let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
                let jsonString = String(data: jsonData!, encoding: .utf8)
                let paramCreateRelationship = ["uniqueKey": "ID","uniqueKeyValue":uniqueID,"fromNodeLabel":"Consumer","fromNodeKey":"cell","toNodeLabel":"Enterprise","toNodeKey":"companyregistrationnumber","toNodeKeyValue":companyregistrationnumber,"fromNodeKeyValue":id,"relationshipType":"Connected","properties": jsonString!]

                let paramAddRelationship = ["uniqueKey": "ID","uniqueKeyValue":uniqueID,"relationshipType":"Connected","properties": dictionary] as [String : Any]
                
                AFWrapper.requestPOSTURL(urlString, params: paramCreateRelationship as [String : AnyObject], headers: nil, success: { (json) in
                    print(json)
                    let urlString1: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APISetLumineerAddRelationship)"
                    
                    let jsonData = try? JSONSerialization.data(withJSONObject: paramAddRelationship, options: [])
                    let jsonString = String(data: jsonData!, encoding: .utf8)
                    let param = ["params": jsonString]

                    AFWrapper.requestPOSTURL(urlString1, params: param as [String : AnyObject], headers: nil, success: { (json) in
                        print(json)
                        
//                        let tempDict = json.arrayObject
//                        let objCategory  = GlobalShareData.sharedGlobal.realmManager.getObjects(type: LumiCategory.self)
                        
                        let realm = try! Realm()
                        let realmObjects = realm.objects(LumiCategory.self)
                        let result = realmObjects.filter("ANY lumineerList.companyRegistrationNumber = '\(companyregistrationnumber)'")
                        if result.count > 0 {
                        let objCategory = result[0] as LumiCategory
                            for lumineer in objCategory.lumineerList.filter("companyRegistrationNumber = '\(companyregistrationnumber)'") {
                                    try! realm.write {
                                        let  objLumineer = lumineer as LumineerList
                                        objLumineer.status = Int(status)!
                                    }
                                // do something with your vegan meal
                            }

                        }
                       // completionHandler(result)
                    }, failure: { (Error) in
                        print(Error.localizedDescription)
                    })
                }, failure: { (Error) in
                    print(Error.localizedDescription)
                })*/
                let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APISetLumineerCreateEnterpriseRelationship)"

                AFWrapper.requestPOSTURL(urlString, params:["cellNumber":id as AnyObject,"regnNumber":companyregistrationnumber as AnyObject,"status":status as AnyObject], headers: nil, success: { (json) in
                    print(json)
                    let tempDict = json.dictionary
                    guard let code = tempDict!["responseCode"]?.intValue, code != 0 else {
                        return
                    }
                    let realm = try! Realm()
                    let realmObjects = realm.objects(LumiCategory.self)
                    let result = realmObjects.filter("ANY lumineerList.companyRegistrationNumber = '\(companyregistrationnumber)'")
                    if result.count > 0 {
                        let objCategory = result[0] as LumiCategory
                        for lumineer in objCategory.lumineerList.filter("companyRegistrationNumber = '\(companyregistrationnumber)'") {
                            try! realm.write {
                                let  objLumineer = lumineer as LumineerList
                                objLumineer.status = Int(status)!
                                completionHandler(objLumineer)
                            }
                            // do something with your vegan meal
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
    
    func setLumineerCompanyRatings(param:[String:AnyObject],completionHandler: @escaping (_ objData: [String:JSON]) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APISetLumineerRating)"
            do {
                AFWrapper.requestPOSTURL(urlString, params: param as [String : AnyObject], headers: nil, success: { (json) in
                    print(json)
                    let tempDict = json.dictionary
                    guard let code = tempDict!["responseCode"]?.intValue, code != 0 else {
                        return
                    }
                    completionHandler(tempDict!)
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
    
    func getLumineerCompanyFollowingCounts(completionHandler: @escaping (_ objData: [String:JSON]) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIGetLumineerFollowingCounts)"+"?regnNumber=\(self.companyRegistrationNumber!)"

            do {
                AFWrapper.requestGETURL(urlString, success: { (json) in
                    let tempDict = json.dictionary
                    guard let code = tempDict!["responseCode"]?.intValue, code != 0 else {
                        return
                    }
                    completionHandler(tempDict!)
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
    
    func getLumineerCompanyUnReadMessageCounts(param:[String:String],completionHandler: @escaping (_ objData: [String:JSON]) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let cellNumber = param["cellNumber"]!
            let userName = param["lumineerName"]!
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIGetLumineerUnReadMessageCounts)" + "?cellNumber=\(cellNumber)" + "&lumineerName=\(userName)"
            do {
                AFWrapper.requestGETURL(urlString, success: { (json) in
                    let tempDict = json.dictionary
                    guard let code = tempDict!["responseCode"]?.intValue, code != 0 else {
                        return
                    }
                    completionHandler(tempDict!)
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
    
    func getLumineerSocialMediaDetails(completionHandler: @escaping (_ oobjData: [JSON]) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIGetLumineerSocialMediaDetails)"+"?enterpriseId=\(self.id)"

            do {
                AFWrapper.requestGETURL(urlString, success: { (json) in
                    let aryData = json.arrayValue
                    guard aryData.count > 0 else {
                        return
                    }
                    completionHandler(aryData)
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
    func getLumineerAllRatings(completionHandler: @escaping (_ objData: [String:JSON]) -> Void) {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            let urlString: String = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIGetLumineerAllRatings)"+"?enterpriseId=\(self.id)"
            do {
                //todo
                AFWrapper.requestGETURL(urlString, success: { (json) in
                    let tempDict = json.dictionary
                    guard let code = tempDict!["responseCode"]?.intValue, code != 0 else {
                        return
                    }
                   completionHandler(tempDict!)
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
            AFWrapper.requestGETURL(urlString, success: { (json) in
                let tempArray = json.arrayValue
                for index in 0...tempArray.count-1 {
                    let aObject = tempArray[index]
                    let realm = try! Realm()
                    let id : Int = aObject["id"].intValue
                    let data  = realm.objects(LumiCategory.self).filter("id == %d", id)
                    let newObj = LumiCategory(id : id , name : aObject["name"].string,status : aObject["status"].string,categoryDescription : aObject["categoryDescription"].string,originalImage:aObject["originalImage"].string,visitedImage:aObject["visitedImage"].string)
                    let aryLumineerList = realm.objects(LumineerList.self).filter("parentid == %d", id)
                    if aryLumineerList.count > 0 {
                        for index in 0...aryLumineerList.count-1 {
                            let objMessages = aryLumineerList[index] as LumineerList
                            newObj.lumineerList.append(objMessages)
                        }
                    }
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
                viewCtrl.showCustomAlert(strTitle: "", strDetails: Error.localizedDescription, completion: { (str) in
                    completionHandler([])
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

func getLocalFormatedCurrentData() -> String
{
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    let myString = formatter.string(from: date)
    let yourDate: Date? = formatter.date(from: myString)
    formatter.dateFormat = "EE MMM dd y HH:mm:ss 'GMT'Z (zz)"
    let timeZone = TimeZone(identifier: "Africa/Johannesburg")
    formatter.timeZone = timeZone
    let updatedString = formatter.string(from: yourDate!)
    return updatedString
}


