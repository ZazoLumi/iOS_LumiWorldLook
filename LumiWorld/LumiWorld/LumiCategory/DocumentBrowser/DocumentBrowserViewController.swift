//
//  DocumentBrowserViewController.swift
//  MyDocumentBased
//
//  Created by amarron on 2017/08/26.
//  Copyright © 2017年 amarron. All rights reserved.
//

import UIKit
import MBProgressHUD

@available(iOS 11.0, *)
class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    var isFromChat = false
    static let shared = DocumentBrowserViewController()

    var didFinishCapturingDocument: ((UIImage,String?,String?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        self.navigationItem.addBackButtonOnLeft()
        self.navigationItem.title = "Select Document"
        allowsDocumentCreation = true
        allowsPickingMultipleItems = false
        // Update the style of the UIDocumentBrowserViewController
        // browserUserInterfaceStyle = .dark
        // view.tintColor = .white
        
        // Specify the allowed content types of your application via the Info.plist.
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    // MARK: UIDocumentBrowserViewControllerDelegate
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        let newDocumentURL: URL? = nil
        
        // Set the URL for the new document here. Optionally, you can present a template chooser before calling the importHandler.
        // Make sure the importHandler is always called, even if the user cancels the creation request.
        if newDocumentURL != nil {
            importHandler(newDocumentURL, .move)
        } else {
            importHandler(nil, .none)
        }
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let sourceURL = documentURLs.first else { return }
        
        // Present the Document View Controller for the first document that was picked.
        // If you support picking multiple items, make sure you handle them all.
        presentDocument(at: sourceURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didImportDocumentAt sourceURL: URL, toDestinationURL destinationURL: URL) {
        // Present the Document View Controller for the new newly created document
        presentDocument(at: destinationURL)
    }
    
    func documentBrowser(_ controller: UIDocumentBrowserViewController, failedToImportDocumentAt documentURL: URL, error: Error?) {
        // Make sure to handle the failed import appropriately, e.g., by presenting an error message to the user.
    }
    
    // MARK: Document Presentation
    
    func presentDocument(at documentURL: URL) {
        let destinationFilename = documentURL.lastPathComponent

        let alert = UIAlertController(title: "", message: "Send \(destinationFilename) to \(GlobalShareData.sharedGlobal.objCurrentLumineer.name!) ?", preferredStyle: UIAlertControllerStyle.alert)

        let notNowAction = UIAlertAction(title: "Cancel", style: .default)
        notNowAction.setValue(UIColor.lumiGreen, forKey: "titleTextColor")
        alert.addAction(notNowAction)
        
        let submitAction = UIAlertAction(title:"Send", style:.default ) { (action) in
            
            
            let objMessage = LumiMessage()
            
            if documentURL.isFileURL {
                if documentURL.startAccessingSecurityScopedResource() {
                    if let data = NSData(contentsOfFile: documentURL.path) {
                        print(data.length)
                        var _: Error?
                        _ = FileManager.default
                        _ = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(destinationFilename )

                        let strFilePath = GlobalShareData.sharedGlobal.storeGenericfileinDocumentDirectory(fileContent: data as NSData, fileName: destinationFilename)

                        if self.isFromChat {
                            let firstName =  GlobalShareData.sharedGlobal.objCurrentUserDetails.firstName
                            let lastName =  GlobalShareData.sharedGlobal.objCurrentUserDetails.lastName
                            
                            var nSubjectID : Double? = nil
                            nSubjectID = GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageSubjectId
                            
                            let name = firstName! + " \(lastName as! String)"
                            let sentBy: String = GlobalShareData.sharedGlobal.userCellNumber + "-\(name)"

                            let hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
                            hud.label.text = NSLocalizedString("Uploading...", comment: "HUD loading title")
                            objMessage.sendLumiAttachmentMessage(param: ["newsFeedBody":destinationFilename as AnyObject,"enterpriseName":GlobalShareData.sharedGlobal.objCurrentLumineer.name! as AnyObject,"enterpriseRegnNmbr":GlobalShareData.sharedGlobal.objCurrentLumineer.companyRegistrationNumber! as AnyObject,"messageCategory":GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageCategory as AnyObject,"messageType":"1" as AnyObject,"sentBy":sentBy as AnyObject,"imageURL":"" as AnyObject,"longitude":"" as AnyObject,"latitude":"" as AnyObject,"messageSubject":GlobalShareData.sharedGlobal.objCurrentLumiMessage.messageSubject! as AnyObject,"messageSubjectId":nSubjectID as AnyObject],filePath:strFilePath, completionHandler: {(error) in
                                DispatchQueue.main.async {
                                    hud.hide(animated: true)}
                                documentURL.stopAccessingSecurityScopedResource()
                                if error != nil  {
                                    self.showCustomAlert(strTitle: "", strDetails: (error?.localizedDescription)!, completion: { (str) in
                                    })
                                }
                                DispatchQueue.main.async {
                                    GlobalShareData.sharedGlobal.removeFilefromDocumentDirectory(fileName: strFilePath)
                                    self.navigationController?.popViewController(animated: true)
                                }
                            })

                        }
                        else {
                            self.didFinishCapturingDocument!(UIImage.init(named: "docFile")!,strFilePath,destinationFilename)
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                    
                }

                
                
            }


        }
        submitAction.setValue(UIColor.lumiGreen, forKey: "titleTextColor")
        alert.addAction(submitAction)
        
        self.present(alert, animated: true, completion: nil)

        
        var _: Error?
        let fileManager = FileManager.default
        let destinationURL = GlobalShareData.sharedGlobal.applicationDocumentsDirectory.appendingPathComponent(destinationFilename )
        if fileManager.fileExists(atPath: destinationURL.path ) {
            if destinationURL.isFileURL {
                try? fileManager.removeItem(at: destinationURL)
            }
        }
        if documentURL.startAccessingSecurityScopedResource() {
            do {
                try fileManager.copyItem(atPath: (documentURL.path), toPath: destinationURL.path)
            } catch let error as NSError {
                print("Couldn't copy file to final location! Error:\(error.description)")
            }
            documentURL.stopAccessingSecurityScopedResource()

        }


        
//        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
//        let documentViewController = storyBoard.instantiateViewController(withIdentifier: "DocumentViewController") as! DocumentBrowserViewController
//        documentViewController.document = Document(fileURL: documentURL)
//
//        present(documentViewController, animated: true, completion: nil)
    }
}

