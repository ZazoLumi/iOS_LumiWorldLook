//
//  AboutPlusTC.swift
//  LumiWorld
//
//  Created by Ashish Patel on 2018/05/18.
//  Copyright © 2018 Ashish Patel. All rights reserved.
//

import UIKit
import WebKit
import MBProgressHUD

class AboutPlusTC: UIViewController {
    var urlToDisplay : URL!
    var webView: WKWebView!
    var strTitle : String!
    var hud : MBProgressHUD!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.addSettingButtonOnRight()
        self.navigationItem.addBackButtonOnLeft()
        self.navigationItem.title = strTitle
        hud = MBProgressHUD.showAdded(to: (self.navigationController?.view)!, animated: true)
        hud.label.text = NSLocalizedString("Loading...", comment: "HUD loading title")
        
        webView = WKWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        self.view.sendSubviewToBack(webView)
        webView.load(URLRequest(url: urlToDisplay))
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self

    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}

extension AboutPlusTC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // show indicator
        print("Strat to load")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // dismiss indicator
        print("finish to load")
        DispatchQueue.main.async {
            self.hud.hide(animated: true)}

        // if url is not valid {
        //    decisionHandler(.cancel)
        // }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // dismiss indicator
        print("finish to load")
        DispatchQueue.main.async {
            self.hud.hide(animated: true)}

      //  navigationItem.title = webView.title
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        // show error dialog
    }
}

extension AboutPlusTC: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

