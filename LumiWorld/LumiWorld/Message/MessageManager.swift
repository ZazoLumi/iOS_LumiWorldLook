//
//  MessageManager.swift
//  NoChat-Swift-Example
//
//  Copyright (c) 2016-present, little2s.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import Realm
import RealmSwift

protocol MessageManagerDelegate: class {
    func didReceiveMessages(messages: [Message], chatId: String)
}

class MessageManager: NSObject{//, NOCClientDelegate {
    
    private var delegates: NSHashTable<AnyObject>
   // private var client: NOCClient
    
    var messages: Dictionary<String, [Message]>
    
    override init() {
        delegates = NSHashTable<AnyObject>.weakObjects()
       // client = NOCClient(userId: User.currentUser.userId)
        messages = [:]
        super.init()
       // client.delegate = self
    }
    
    static let manager = MessageManager()
    
    func play() {
        //client.open()
    }
    
    func getLatestLumiMessages() {
    }

    
    func fetchMessages(withChatId chatId: String, handler: @escaping ([Message]) -> Void) {
        messages.removeAll()
        var arr = [Message]()
        if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.messageThread.rawValue {
            let objLumiMessage = LumiMessage()
            let originalString = Date().getFormattedTimestamp(key: UserDefaultsKeys.messageTimeStamp)
            let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            var aryUnreadMessage : [String] = []
            objLumiMessage.getLumiMessage(param: ["cellNumber":GlobalShareData.sharedGlobal.userCellNumber,"startIndex":"0","endIndex":"10000","lastViewDate":escapedString!], nParentId: GlobalShareData.sharedGlobal.objCurrentLumineer.parentid) { (objLumineer) in
                if objLumineer.lumiMessages.count > 0 {
                var aryLumiMessage = objLumineer.lumiMessages.filter("messageSubjectId = %ld",GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageSubjectId)
                aryLumiMessage = aryLumiMessage.sorted(byKeyPath: "createdTime", ascending: true)
                var date : Date!
                for (index, obj) in aryLumiMessage.enumerated() {
                    print("Item \(index): \(obj)")
                    //                if obj.value(forKeyPath:"contentType") as! String == "Text" {
                    //
                    //                }
                    if obj.isReadByLumi == false {
                        aryUnreadMessage.append(obj.guid!)
                    }
                    let msg = Message()
                    msg.msgType = obj.contentType!
                    msg.text = obj.newsFeedBody
                    msg.attachmentURL = obj.fileName
                    
                    msg.deliveryStatus = .Delivered
                    msg.date = Date().getDateFromString(string: obj.newsfeedPostedTime!, formatter: "yyyy-MM-dd HH:mm")
                    msg.messageId = obj.id
                    if obj.isSentByLumi == true {
                        msg.isOutgoing = true
                    }
                    else {
                        msg.isOutgoing = false
                    }
                    if msg.msgType == "Location" {
                        msg.latitude = obj.latitude
                        msg.longitude = obj.longitude
                    }
                    if msg.msgType == "Video" {
                        msg.thumbURL = obj.imageURL
                    }
                    
                    if index == 0 {
                        date = Date().getDateFromString(string: obj.newsfeedPostedTime!, formatter: "yyyy-MM-dd")
                        let msg2 = Message()
                        msg2.msgType = "System"
                        msg2.text = "Welcome to \(GlobalShareData.sharedGlobal.objCurrentUserDetails.displayName!) Please input your message."
                        
                        let msg1 = Message()
                        msg1.msgType = "Date"
                        msg1.date = date
                        arr.append(msg1)
                        arr.append(msg2)
                    }
                    else if date != Date().getDateFromString(string: obj.newsfeedPostedTime!, formatter: "yyyy-MM-dd"), index != 0
                    {
                        let msg1 = Message()
                        msg1.msgType = "Date"
                        msg1.date = msg.date
                        arr.append(msg1)
                        date = Date().getDateFromString(string: obj.newsfeedPostedTime!, formatter: "yyyy-MM-dd")
                    }
                    arr.append(msg)
                    
                    
                }
                
                self.saveMessages(arr, chatId: chatId)
                for strGuid in aryUnreadMessage {
                    objLumiMessage.setLumineerMessageReadByLumi(strGUID: strGuid) { (json) in
                        
                    }
                }
                handler(arr)
            }
                else {
                    handler([])
                }
                
            }

        }
        else if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.lumiMessages.rawValue {
        }

        else if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.supportThread.rawValue{
            let objLumiSupport = LumiSupport()
            var originalString = Date().getFormattedTimestamp(key: UserDefaultsKeys.supportTimeStamp)
            if originalString.count > 0 {originalString += ":00" }
            let escapedString = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            var aryUnreadMessage : [String] = []
            objLumiSupport.getLumiSupportMessages(cellNumber: GlobalShareData.sharedGlobal.userCellNumber, lastViewDate: escapedString!, completionHandler: { (arySuport) in
                let realm = try! Realm()
                var arySupportMessage = realm.objects(LumiSupport.self).filter("supportSubjectId = %ld",GlobalShareData.sharedGlobal.objCurrentSupport.supportSubjectId)

                    arySupportMessage = arySupportMessage.sorted(byKeyPath: "supportId", ascending: true)
                    var date : Date!
                    for (index, obj) in arySupportMessage.enumerated() {
                        print("Item \(index): \(obj)")
                        //                if obj.value(forKeyPath:"contentType") as! String == "Text" {
                        //
                        //                }
                        if obj.isReadByLumi == false {
                            aryUnreadMessage.append(obj.supportId.string)
                        }
                        let msg = Message()
                        msg.msgType = obj.contentType!
                        msg.text = obj.supportMessageBody
                        msg.attachmentURL = obj.supportFilePath
                        
                        msg.deliveryStatus = .Delivered
                        msg.date = Date().getDateFromString(string: obj.sentDate!, formatter: "yyyy-MM-dd HH:mm")
                        msg.messageId = obj.supportId
                        if obj.sentBy == "Lumi World" {
                            msg.isOutgoing = false
                        }
                        else {
                            msg.isOutgoing = true
                        }
                        if msg.msgType == "Location" {
//                            msg.latitude = obj.latitude
//                            msg.longitude = obj.longitude
                        }
                        if msg.msgType == "Video" {
                            msg.thumbURL = obj.imageURL
                        }
                        
                        if index == 0 {
                            date = Date().getDateFromString(string: obj.sentDate!, formatter: "yyyy-MM-dd")
                            let msg2 = Message()
                            msg2.msgType = "System"
                            msg2.text = "Welcome to \(GlobalShareData.sharedGlobal.objCurrentUserDetails.displayName!) Please input your message."
                            
                            let msg1 = Message()
                            msg1.msgType = "Date"
                            msg1.date = date
                            arr.append(msg1)
                            arr.append(msg2)
                        }
                        else if date != Date().getDateFromString(string: obj.sentDate!, formatter: "yyyy-MM-dd"), index != 0
                        {
                            let msg1 = Message()
                            msg1.msgType = "Date"
                            msg1.date = msg.date
                            arr.append(msg1)
                            date = Date().getDateFromString(string: obj.sentDate!, formatter: "yyyy-MM-dd")
                        }
                        arr.append(msg)
                        
                        
                    }
                    
                    self.saveMessages(arr, chatId: chatId)
                    for strID in aryUnreadMessage {
                        objLumiSupport.setSupportMessageReadByLumi(strSupportID: strID) { (json) in

                        }
                    }
                    handler(arr)
                    
            })

        }


        
    }
    
    func sendMessage(_ message: Message, toChat chat: Chat) {
        let chatId = chat.chatId
        saveMessages([message], chatId: chatId)
        if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.messageThread.rawValue {
        let firstName =  GlobalShareData.sharedGlobal.objCurrentUserDetails.firstName  //Static "Christian"
        let lastName =  GlobalShareData.sharedGlobal.objCurrentUserDetails.lastName  //Static "Nhlabano"
        
        let name = firstName! + " \(lastName as! String)"
        let sentBy: String = GlobalShareData.sharedGlobal.userCellNumber + "-\(name)"
        
        let objMessage = LumiMessage()
            objMessage.sendLumiTextMessage(param: ["newsFeedBody":message.text as AnyObject,"enterpriseName":GlobalShareData.sharedGlobal.objCurrentLumineer.name! as AnyObject,"enterpriseRegnNmbr":GlobalShareData.sharedGlobal.objCurrentLumineer.companyRegistrationNumber! as AnyObject,"messageCategory":GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageCategory as AnyObject,"messageType":"1" as AnyObject,"sentBy":sentBy as AnyObject,"imageURL":"" as AnyObject,"longitude":"" as AnyObject,"latitude":"" as AnyObject,"messageSubject":GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageSubject as AnyObject,"messageSubjectId":GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageSubjectId as AnyObject], completionHandler: { () in
            })
    }
            else if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.supportThread.rawValue {
                let objSupport = LumiSupport()
            let urlString = Constants.APIDetails.APIScheme + "\(Constants.APIDetails.APIReplyToLumiWorldByLumin)"
                objSupport.sendSupportTextMessage(urlString: urlString, param: ["supportMessageBody":message.text as AnyObject,"supportSubjectId":GlobalShareData.sharedGlobal.objCurrentSupport.supportSubjectId as AnyObject,"sentBy":GlobalShareData.sharedGlobal.userCellNumber! as AnyObject,"supportMessageSubject":GlobalShareData.sharedGlobal.objCurrentSupport.supportMessageSubject! as AnyObject]) {
                    
                }
        }
    }
    
    func addDelegate(_ delegate: MessageManagerDelegate) {
        delegates.add(delegate)
    }
    
    func removeDelegate(_ delegate: MessageManagerDelegate) {
        delegates.remove(delegate)
    }
    
    func clientDidReceiveMessage(_ message: [AnyHashable : Any]) {
        guard let senderId = message["from"] as? String,
            let type = message["type"] as? String,
            let text = message["text"] as? String,
            let chatType = message["ctype"] as? String else {
                return;
        }
        
        if type != "Text" || chatType != "bot" {
            return;
        }
        
        let msg = Message()
        msg.senderId = senderId
        msg.msgType = type
        msg.text = text
        msg.isOutgoing = false
        
        let chatId = chatType + "_" + senderId
        
        saveMessages([msg], chatId: chatId)
        
        for delegate in delegates.allObjects {
            if let d = delegate as? MessageManagerDelegate {
                d.didReceiveMessages(messages: [msg], chatId: chatId)
            }
        }
    }
    
    private func saveMessages(_ messages: [Message], chatId: String) {
        var msgs = self.messages[chatId] ?? []
        msgs += messages
        self.messages[chatId] = msgs
    }
    
}
