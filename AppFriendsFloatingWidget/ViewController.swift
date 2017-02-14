//
//  ViewController.swift
//  AppFriendsFloatingWidget
//
//  Created by HAO WANG on 12/13/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsFloatingWidget
import AppFriendsUI
import AppFriendsCore
import EZSwiftExtensions

class ViewController: UIViewController, HCFloatingWidgetDelegate, HCSidePanelViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let key = "c3ZsINZMGHdGmbY3S6pcVgtt"
        let secret = "FhsajDeh6XXBF143m82sKwtt"
        
        let userID = "1782f486effd67d86d9140e52c561617"
        let userName = "jeanne lawrence"
        
        let appFriendsCore = HCSDKCore.sharedInstance
        appFriendsCore.setValue(true, forKey: "useSandbox")
        AppFriendsUI.sharedInstance.initialize(key, secret: secret) { (success, error) in
            
            if success {
                
                if !appFriendsCore.isLogin(){
                    appFriendsCore.loginWithUserInfo([HCSDKConstants.kUserName: userName as AnyObject, HCSDKConstants.kUserID: userID as AnyObject], completion:
                    { (response, error) in
                        
                        if error == nil {
                            
                            self.presentWidget()
                        }
                        else {
                            
                            let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                            self.show(alert, sender: nil)
                        }
                    })
                }
                else {
                    self.presentWidget()
                }
            }
            else {
                
                let alert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                self.show(alert, sender: nil)
            }
        }
    }
    
    
    func presentWidget() {
        
        let floatingWidget =
            HCFloatingWidget(widgetImage: UIImage(named: "ic_chat_widget"),
                             screenshotButtonImage: UIImage(named: "ic_camera"),
                             showScreenshotButton: true)
        floatingWidget.present(overVC: self, position: CGPoint(x: 260, y: 80))
        floatingWidget.delegate = self
    }
    
    // MARK: - HCFloatingWidgetDelegate
    
    func widgetButtonTapped(widget: HCFloatingWidget) {
        
//        let channelID = "456df29e-ff5f-494d-ba9a-f1e4127c9244"
//        let channelChatVC = HCChannelChatContainerController(dialog: channelID, hasStatusBar: true) // the dialogID has to be a channel you created
        
        let chatListVC = HCDialogsListViewController()
        chatListVC.automaticallyAdjustsScrollViewInsets = false
        chatListVC.edgesForExtendedLayout = []
        let nav = UINavigationController(rootViewController: chatListVC)
        let sidePanelVC = AppFriendsUI.sharedInstance.presentVCInSidePanel(fromVC: self, showVC: nav)
        sidePanelVC.delegate = self
    }
    
    func widgetMessagePreviewTapped(dialogID: String, messageID: String, widget: HCFloatingWidget) {
        
    }
    
    // MARK: - HCSidePanelViewControllerDelegate
    
    func sidePanelWillAppear(panel: HCSidePanelViewController) {
        
    }
    
    func sidePanelWillDisappear(panel: HCSidePanelViewController) {
        
    }
}

