//
//  DocumentBrowserViewController.swift
//  MyDocumentBased
//
//  Created by amarron on 2017/08/26.
//  Copyright © 2017年 amarron. All rights reserved.
//

import UIKit

@available(iOS 11.0, *)
class DocumentBrowserViewController: UIDocumentBrowserViewController, UIDocumentBrowserViewControllerDelegate {
    
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
        var _: Error?
        let fileManager = FileManager.default
        let destinationFilename = documentURL.lastPathComponent
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

