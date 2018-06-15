//
//  TGChatViewController.swift
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

import UIKit
import NoChat
import IQKeyboardManagerSwift
import QuickLook
import MBProgressHUD

class TGChatViewController: NOCChatViewController, UINavigationControllerDelegate, MessageManagerDelegate, TGChatInputTextPanelDelegate, TGTextMessageCellDelegate, TGAttachmentMessageCellDelegate,QLPreviewControllerDataSource {
    
    fileprivate var documentInteractionController = UIDocumentInteractionController()
    let quickLookController = QLPreviewController()

    var titleView = TGTitleView()
    var avatarButton = TGAvatarButton()
    
    var messageManager = MessageManager.manager
    var layoutQueue = DispatchQueue(label: "com.little2s.nochat-example.tg.layout", qos: DispatchQoS(qosClass: .default, relativePriority: 0))

    let chat: Chat
    var previewUrl : URL!
    // MARK: Overrides
    
    override class func cellLayoutClass(forItemType type: String) -> Swift.AnyClass? {
        if type == "Text" {
            return TGTextMessageCellLayout.self
        } else if type == "Image" {
            return TGAttachmentMessageCellLayout.self
        } else if type == "Location" {
            return TGAttachmentMessageCellLayout.self
        }
        else if type == "Video" {
            return TGAttachmentMessageCellLayout.self
        }else if type == "Date" {
            return TGDateMessageCellLayout.self
        }else if type == "System" {
            return TGSystemMessageCellLayout.self
        }else if type == "Document" {
            return TGAttachmentMessageCellLayout.self
        } else {
            return nil
        }
    }
    
    override class func inputPanelClass() -> Swift.AnyClass? {
        return TGChatInputTextPanel.self
    }
    
    override func registerChatItemCells() {
        collectionView?.register(TGTextMessageCell.self, forCellWithReuseIdentifier: TGTextMessageCell.reuseIdentifier())
        collectionView?.register(TGDateMessageCell.self, forCellWithReuseIdentifier: TGDateMessageCell.reuseIdentifier())
        collectionView?.register(TGSystemMessageCell.self, forCellWithReuseIdentifier: TGSystemMessageCell.reuseIdentifier())
        collectionView?.register(TGAttachmentMessageCell.self, forCellWithReuseIdentifier: TGAttachmentMessageCell.reuseIdentifier())
    }
    
    init(chat: Chat) {
        self.chat = chat
        super.init(nibName: nil, bundle: nil)
        messageManager.addDelegate(self)
        registerContentSizeCategoryDidChangeNotification()
        setupNavigationItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        messageManager.removeDelegate(self)
        unregisterContentSizeCategoryDidChangeNotification()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //backgroundView?.image = UIImage(named: "TGWallpaper")!
        backgroundView?.backgroundColor = UIColor.white
        navigationController?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(loadMessages), name: Notification.Name("attachmentPopupRemoved"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadAttachmentPreview), name: Notification.Name("openPreviewData"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(openDocumentInterationController), name: Notification.Name("openDocumentInterationController"), object: nil)

        
        let saveMenuItem = UIMenuItem(title: "Copy", action: #selector(self.copyTapped(_:)))
        let deleteMenuItem = UIMenuItem(title: "Forward", action: #selector(self.forwardTapped(_:)))
        UIMenuController.shared.menuItems = [saveMenuItem, deleteMenuItem]

    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        print("performAction")
    }
   
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }
    
//    override var canBecomeFirstResponder: Bool {
//        return true
//    }
    

    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        print("canPerformAction")
            // The selector(s) should match your UIMenuItem selector if (action == @selector(customAction:)) { return YES; } return NO; }
        do {
            if action == #selector(self.copyTapped(_:)) {
                return true
            }
            if action == #selector(self.forwardTapped(_:)) {
                return true
            }
            return false
        }
    }
    @objc func copyTapped(_ sender: Any?) {
        if let aSender = sender {
            print("custom action! \(aSender)")
        }
    }
    @objc func forwardTapped(_ sender: Any?) {
        if let aSender = sender {
            print("custom action! \(aSender)")
        }
    }


    // The selector(s) should match your UIMenuItem selector if (action == @selector(customAction:)) { return YES; } return NO; }
    // MARK: - Custom Action(s) - (void)customAction:(id)sender { NSLog(@"custom action! %@", sender); }
    //  %< ------------------------ The converted code is limited to 1 KB ------------------------ %<
    
    override func viewWillAppear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enableAutoToolbar = false
        DispatchQueue.main.async {
            MBProgressHUD.hide(for: (self.navigationController?.view)!, animated: true)}
        GlobalShareData.sharedGlobal.objCurretnVC = self
        loadMessages()
    }
    override func viewWillDisappear(_ animated: Bool) {
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
    }
    
    @objc func loadAttachmentPreview(notification: NSNotification) {
        if let strUrl = notification.userInfo?["url"] as? String {
            let fileName = strUrl.lastPathComponent
            let url = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(fileName)
            quickLookController.dataSource = self
            previewUrl = url
            if QLPreviewController.canPreview(url as QLPreviewItem) {
                let index = GlobalShareData.sharedGlobal.aryAttachUrls.index(of:  url)
                quickLookController.currentPreviewItemIndex = index!;
                navigationController?.pushViewController(quickLookController, animated: true)
                quickLookController.navigationController?.navigationItem.addBackButtonOnLeft()
            }
        }
    }
    
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return GlobalShareData.sharedGlobal.aryAttachUrls.count
    }
    
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return GlobalShareData.sharedGlobal.aryAttachUrls[index] as QLPreviewItem
    }

//    private func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController {
//        return self
//    }
//    private func documentInteractionControllerDidEndPreview(controller: UIDocumentInteractionController) {
//        docController = nil
//    }
//
//    private func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController!) -> UIViewController! {
//        return self
//    }
//
//    func documentInteractionControllerViewForPreview(_ controller: UIDocumentInteractionController) -> UIView? {
//        return self.view
//    }
//
//    func documentInteractionControllerRectForPreview(_ controller: UIDocumentInteractionController) -> CGRect {
//        return self.view.frame
//    }

    
    @objc func openDocumentInterationController(notification: NSNotification) {
        if let url = notification.userInfo?["url"] as? URL {
            documentInteractionController.delegate = self
            documentInteractionController.url = url
            documentInteractionController.presentPreview(animated: true)
        }
    }

    // MARK: TGChatInputTextPanelDelegate
    
    func inputTextPanel(_ inputTextPanel: TGChatInputTextPanel, requestSendText text: String) {
        let msg = Message()
        msg.text = text
        msg.msgType = "Text"
        sendMessage(msg)
    }
    
    // MARK: TGAttachmentMessageCellDelegate
    
    func didTapLink(cell: TGAttachmentMessageCell, linkInfo: [AnyHashable : Any]) {
        
    }


    
    // MARK: TGTextMessageCellDelegate
    
    func didTapLink(cell: TGTextMessageCell, linkInfo: [AnyHashable: Any]) {
        inputPanel?.endInputting(true)
        
        guard let command = linkInfo["command"] as? String else { return }
        let msg = Message()
        msg.text = command
        sendMessage(msg)
    }
    

//
//    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
//    }
    // MARK: MessageManagerDelegate
    
    func didReceiveMessages(messages: [Message], chatId: String) {
        if isViewLoaded == false { return }
        
        if chatId == chat.chatId {
            addMessages(messages, scrollToBottom: true, animated: true)
            
            SoundManager.manager.playSound(name: "notification.caf", vibrate: false)
        }
    }
    
    // MARK: UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
        isInControllerTransition = true
        
        guard let tc = navigationController.topViewController?.transitionCoordinator else { return }
        tc.notifyWhenInteractionEnds { [weak self] (context) in
            guard let strongSelf = self else { return }
            if context.isCancelled {
                strongSelf.isInControllerTransition = false
            }
        }
    }
    
    // MARK: Private
    
    private func setupNavigationItems() {
        GlobalShareData.sharedGlobal.objCurretnVC = self

        if GlobalShareData.sharedGlobal.currentScreenValue == currentScreen.messageThread.rawValue {
            titleView.title = GlobalShareData.sharedGlobal.objCurrentLumineer.name
            let details: String = GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageCategory! + " | \(GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageSubject!)"
            titleView.detail = details
//            let imgThumb = UIImage.decodeBase64(strEncodeData:GlobalShareData.sharedGlobal.objCurrentLumineer.enterpriseLogo)
//            let scalImg = imgThumb.af_imageScaled(to: CGSize(width: 30, height: 30))
//    titleView.detailLabel.setImage(scalImg, for: .normal)
//            titleView.detailLabel.addTarget(self, action: #selector(didTapLumineerBtn(_:)), for: .touchUpInside)

        }
        else {
            titleView.title = "SUPPORT"
            titleView.detail = GlobalShareData.sharedGlobal.objCurrentSupport.supportMessageSubject
        }
        navigationItem.titleView = titleView
        
        let spacerItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacerItem.width = -12
        
        let rightItem = UIBarButtonItem(customView: avatarButton)
        
        //navigationItem.rightBarButtonItems = [spacerItem, rightItem]
        navigationItem.addSettingButtonOnRight()
        navigationItem.addBackButtonOnLeft()
    }
    
    @objc private func loadMessages() {
        layouts.removeAllObjects()
        GlobalShareData.sharedGlobal.aryAttachUrls = []
        messageManager.fetchMessages(withChatId: chat.chatId) { [weak self] (msgs) in
            if let strongSelf = self {
                strongSelf.addMessages(msgs, scrollToBottom: true, animated: false)
            }
        }
    }
    
    @objc func didTapLumineerBtn(_ sender: UIButton) {
    }

    private func sendMessage(_ message: Message) {
        message.isOutgoing = true
        message.senderId = User.currentUser.userId
        message.deliveryStatus = .Read
        
        addMessages([message], scrollToBottom: true, animated: true)
        
        messageManager.sendMessage(message, toChat: chat)
        
        SoundManager.manager.playSound(name: "sent.caf", vibrate: false)
    }
    
    private func addMessages(_ messages: [Message], scrollToBottom: Bool, animated: Bool) {
        layoutQueue.async { [weak self] in
            guard let strongSelf = self else { return }
            let indexes = IndexSet(integersIn: 0..<messages.count)
            
            var layouts = [NOCChatItemCellLayout]()
            
            for message in messages {
                let layout = strongSelf.createLayout(with: message)!
                layouts.insert(layout, at: 0)
            }
            
            DispatchQueue.main.async {
                strongSelf.insertLayouts(layouts, at: indexes, animated: animated)
                if scrollToBottom {
                    strongSelf.scrollToBottom(animated: animated)
                }
            }
        }
    }
    
    // MARK: Dynamic font support
    
    private func registerContentSizeCategoryDidChangeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleContentSizeCategoryDidChanged(notification:)), name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    private func unregisterContentSizeCategoryDidChangeNotification() {
        NotificationCenter.default.removeObserver(self, name: .UIContentSizeCategoryDidChange, object: nil)
    }
    
    @objc private func handleContentSizeCategoryDidChanged(notification: Notification) {
        if isViewLoaded == false {
            return
        }
        
        if layouts.count == 0 {
            return
        }
        
        // ajust collection display
        
        let collectionViewSize = containerView!.bounds.size
        
        let anchorItem = calculateAnchorItem()
        
        for layout in layouts {
            (layout as! NOCChatItemCellLayout).calculate()
        }
        
        collectionLayout!.invalidateLayout()
        
        let cellLayouts = layouts.map { $0 as! NOCChatItemCellLayout }
        
        var newContentHeight = CGFloat(0)
        let newLayoutAttributes = collectionLayout!.layoutAttributes(for: cellLayouts, containerWidth: collectionViewSize.width, maxHeight: CGFloat.greatestFiniteMagnitude, contentHeight: &newContentHeight)
        
        var newContentOffset = CGPoint.zero
        newContentOffset.y = -collectionView!.contentInset.top
        if anchorItem.index >= 0 && anchorItem.index < newLayoutAttributes.count {
            let attributes = newLayoutAttributes[anchorItem.index]
            newContentOffset.y += attributes.frame.origin.y - floor(anchorItem.offset * attributes.frame.height)
        }
        newContentOffset.y = min(newContentOffset.y, newContentHeight + collectionView!.contentInset.bottom - collectionView!.frame.height)
        newContentOffset.y = max(newContentOffset.y, -collectionView!.contentInset.top)
        
        collectionView!.reloadData()
        
        collectionView!.contentOffset = newContentOffset
        
        // fix navigation items display
        setupNavigationItems()
    }
    
    typealias AnchorItem = (index: Int, originY: CGFloat, offset: CGFloat, height: CGFloat)
    private func calculateAnchorItem() -> AnchorItem {
        let maxOriginY = collectionView!.contentOffset.y + collectionView!.contentInset.top
        let previousCollectionFrame = collectionView!.frame
        
        var itemIndex = Int(-1)
        var itemOriginY = CGFloat(0)
        var itemOffset = CGFloat(0)
        var itemHeight = CGFloat(0)
        
        let cellLayouts = layouts.map { $0 as! NOCChatItemCellLayout }

        let previousLayoutAttributes = collectionLayout!.layoutAttributes(for: cellLayouts, containerWidth: previousCollectionFrame.width, maxHeight: CGFloat.greatestFiniteMagnitude, contentHeight: nil)
        
        for i in 0..<layouts.count {
            let attributes = previousLayoutAttributes[i]
            let itemFrame = attributes.frame
            
            if itemFrame.origin.y < maxOriginY {
                itemHeight = itemFrame.height
                itemIndex = i
                itemOriginY = itemFrame.origin.y
            }
        }
        
        if itemIndex != -1 {
            if itemHeight > 1 {
                itemOffset = (itemOriginY - maxOriginY) / itemHeight
            }
        }
        
        return (itemIndex, itemOriginY, itemOffset, itemHeight)
    }
    
}
extension TGChatViewController: UIDocumentInteractionControllerDelegate {
    
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
}
