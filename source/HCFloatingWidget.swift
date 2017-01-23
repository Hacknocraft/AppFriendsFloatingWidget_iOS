//
//  HCFloatingWidget.swift
//  AppFriendsFloatingWidget
//
//  Created by HAO WANG on 12/13/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsUI
import AppFriendsCore
import CoreStore

@objc public protocol HCFloatingWidgetDelegate {
    
    @objc optional func widgetButtonTapped(widget: HCFloatingWidget)
    @objc optional func widgetMessagePreviewTapped(dialogID: String, dialogType: String, messageID: String, widget: HCFloatingWidget)
    @objc optional func didChooseShareImageToDialog(dialogID: String, dialogType: String)
}

@objc public class HCFloatingWidget: UIViewController, ListObjectObserver {
    
    open let widgetButton: UIButton = UIButton(type: .custom)
    open let screenshotButton: UIButton = UIButton(type: .custom)
    open let messagePreviewBubble = HCPreviewBubble(frame: .zero)
    open let badge = UIView(frame: .zero)
    open var monitor: ListMonitor<HCMessage>?
    open var currentMessageID: String?
    
    open weak var delegate: HCFloatingWidgetDelegate?
    
    // MARK: - Configurable images
    
    open var widgetButtonImage: UIImage?
    open var screenshotButtonImage: UIImage?
    
    // MARK: - Configurable Colors
    
    open static var widgetButtonBackgroundColor = UIColor(red: 75/255.0, green: 168/255.0, blue: 225/255.0, alpha: 1.0)
    open static var widgetButtonIconColor = UIColor.white
    open static var screenshotButtonBackgroundColor = UIColor(red: 228/255.0, green: 182/255.0, blue: 71/255.0, alpha: 1.0)
    open static var previewBubbleBackgroundColor = UIColor(red: 75/255.0, green: 168/255.0, blue: 225/255.0, alpha: 1.0)
    open static var previewBubbleTextColor = UIColor.white
    open static var previewBubbleAvatarBackgroundColor = UIColor(red: 166/255.0, green: 180/255.0, blue: 191/255.0, alpha: 1.0)
    open static var badgeColor = UIColor(red: 242/255.0, green: 67/255.0, blue: 61/255.0, alpha: 1.0)
    
    // MARK: - Other Configurables
    
    var allowPanning = true
    var showScreenshotButton = false
    var showMessagePreview = true
    var showBadge = true
    var viewHeight = HCFloatingWidget.initialHeightFull
    var lastPreviewShownTime = Date()
    var previewShowingInterval: TimeInterval = 10  // seconds between each preview showing
    
    static let initialWidth: CGFloat = 50
    static let initialHeightFull: CGFloat = 80
    static let initialHeightHalf: CGFloat = 50
    static let previewBubbleWidth: CGFloat = 180.0
    
    // MARK: - Other variables
    
    var _currentFrame: CGRect = .zero
    var _messagePreviewShowing = false
    
    // MARK: - Initialization
    
    @objc public convenience init(widgetImage buttonImage: UIImage? = nil,
                                  screenshotButtonImage ssButtonImage: UIImage? = nil)
    {
        self.init(widgetImage: buttonImage,
                  screenshotButtonImage: ssButtonImage,
                  allowPanning: true,
                  showScreenshotButton: true,
                  showMessagePreview: true,
                  showUnreadBadge: true)
        
        
    }
    
    public init(widgetImage buttonImage: UIImage? = nil,
                screenshotButtonImage ssButtonImage: UIImage? = nil,
                allowPanning allowed: Bool? = nil,
                showScreenshotButton showScreenshot: Bool? = nil,
                showMessagePreview showPreview: Bool? = nil,
                showUnreadBadge showBadge: Bool? = nil)
    {
        
        super.init(nibName: nil, bundle: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTabBarBadge), name: NSNotification.Name(rawValue: AppFriendsUI.kTotalUnreadMessageCountChangedNotification), object: nil)
        
        if let shouldShowScreenshotButton = showScreenshot {
            self.showScreenshotButton = shouldShowScreenshotButton
        }
        if let panningAllowed = allowed {
            self.allowPanning = panningAllowed
        }
        if let shouldShowPreview = showPreview {
            self.showMessagePreview = shouldShowPreview
        }
        if let shouldShowBadge = showBadge {
            self.showBadge = shouldShowBadge
        }
        
        if self.showScreenshotButton {
            self.viewHeight = HCFloatingWidget.initialHeightFull
        }
        else {
            self.viewHeight = HCFloatingWidget.initialHeightHalf
        }
        
        self.view.frame = CGRect(x: 0, y: 0, width: HCFloatingWidget.initialWidth, height: self.viewHeight)
        self.view.autoresizingMask = []
        self.view.backgroundColor = UIColor.clear
        self.modalPresentationStyle = .currentContext
        self.widgetButtonImage = buttonImage
        self.screenshotButtonImage = ssButtonImage
        
        // widget button
        self.initializeWidgetButton()
        
        // panning
        if self.allowPanning {
            self.initializePanning()
        }
        
        // screenshot
        if self.showScreenshotButton {
            self.initializeScreenshotButton()
        }
        
        // preview
        if self.showMessagePreview {
            self.initializePreviewBubble()
        }
        
        // badge
        if self.showBadge {
            self.initializeBadge()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: AppFriendsUI.kTotalUnreadMessageCountChangedNotification), object: nil)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
        
        
        if self.monitor == nil, let monitor = CoreStoreManager.store()?.monitorList(
            //cacheName: cacheName,
            From(HCMessage.self),
            Where("messageType != %@", HCSDKConstants.kMessageTypeSystem),
            OrderBy(.descending("receiveTime")),
            Tweak {(fetchRequest) -> Void in
                fetchRequest.fetchBatchSize = 1
                fetchRequest.fetchLimit = 1
        })
        {
            monitor.addObserver(self)
            self.monitor = monitor
        }
        
        self.updateTabBarBadge(nil)
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Badge
    
    open func initializeBadge() {
        
        badge.frame = CGRect(x: 4, y: 4, width: 10, height: 10)
        badge.backgroundColor = HCFloatingWidget.badgeColor
        badge.layer.cornerRadius = badge.frame.size.width/2
        badge.clipsToBounds = true
        self.view.addSubview(badge)
        badge.autoresizingMask = [.flexibleRightMargin]
    }
    
    func updateTabBarBadge(_ notification: Notification?)
    {
        DispatchQueue.main.async(execute: {
            
            if let count = notification?.object as? NSNumber, count.intValue > 0 {
                self.badge.isHidden = false
            }
            else if DialogsManager.sharedInstance.totalUnreadMessages > 0 {
                self.badge.isHidden = false
            }
            else {
                self.badge.isHidden = true
            }
        })
    }
    
    // MARK: - Presentation
    
    open func present(overVC hostingVC: UIViewController, position: CGPoint) {
        
        let appFriendsCore = HCSDKCore.sharedInstance
        assert(appFriendsCore.isLogin(), "Please login before presenting the widget.")
        
        hostingVC.addChildViewController(self)
        hostingVC.view.addSubview(self.view)
        self.view.center = position
        self.didMove(toParentViewController: hostingVC)
        
        _currentFrame = self.view.frame
        
    }
    
    // MARK: - Screenshot
    
    func initializeScreenshotButton() {
        
        screenshotButton.frame = CGRect(x: 7, y: 48, width: 36, height: 36)
        screenshotButton.backgroundColor = HCFloatingWidget.screenshotButtonBackgroundColor
        screenshotButton.layer.cornerRadius = screenshotButton.frame.size.width/2
        if let screenshotImage = screenshotButtonImage {
            screenshotButton.setImage(screenshotImage, for: .normal)
        }else {
            let screenshotImage = UIImage.GMDIconWithName(.gmdCrop, textColor: HCFloatingWidget.widgetButtonIconColor, size: CGSize(width: 25, height: 25))
            screenshotButton.setImage(screenshotImage, for: .normal)
        }
        
        screenshotButton.setTitleColor(UIColor.white, for: .normal)
        screenshotButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        screenshotButton.addTarget(self, action: #selector(screenshotButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(screenshotButton)
        screenshotButton.autoresizingMask = [.flexibleLeftMargin]
    }
    
    open func screenshotButtonTapped(_ sender: UIButton) {
        
        // present the screenshot tool from the parent view controller
        
        if let keyWindow = UIApplication.shared.keyWindow {
            
            if let screenshot = self.imageFromView(view: keyWindow) {
                
                let screenshotView = HCScreenshotController(image: screenshot, cropMode: .square)
                screenshotView.widget = self
                let nav = UINavigationController(rootViewController: screenshotView)
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Widget Button
    
    func initializeWidgetButton() {
        
        widgetButton.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        widgetButton.backgroundColor = HCFloatingWidget.widgetButtonBackgroundColor
        widgetButton.layer.cornerRadius = widgetButton.frame.size.width/2
        if let image = widgetButtonImage {
            widgetButton.setImage(image, for: .normal)
        } else {
            let widgetImage = UIImage.GMDIconWithName(.gmdQuestionAnswer, textColor: HCFloatingWidget.widgetButtonIconColor, size: CGSize(width: 25, height: 25))
            widgetButton.setImage(widgetImage, for: .normal)
        }
        widgetButton.setTitleColor(HCFloatingWidget.widgetButtonIconColor, for: .normal)
        widgetButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        widgetButton.addTarget(self, action: #selector(widgetButtonTapped), for: .touchUpInside)
        self.view.addSubview(widgetButton)
        widgetButton.autoresizingMask = [.flexibleLeftMargin]
        
    }
    
    func widgetButtonTapped() {
        
        if let d = self.delegate {
            d.widgetButtonTapped?(widget: self)
        }
    }
    
    // MARK: - Preview Bubble
    
    func initializePreviewBubble() {
        
        messagePreviewBubble.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        messagePreviewBubble.autoresizingMask = [.flexibleWidth]
        self.view.addSubview(messagePreviewBubble)
        messagePreviewBubble.alpha = 0
        messagePreviewBubble.layer.cornerRadius = 10.0
        messagePreviewBubble.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(previewBubbleTapped))
        messagePreviewBubble.addGestureRecognizer(tap)
    }
    
    func previewBubbleTapped() {
        
        CoreStoreManager.store()?.beginAsynchronous({ (transaction) in
            
            if let d = self.delegate, let messageID = self.currentMessageID{
                let currentMessage = HCMessage.findOrCreateMessage(serverID: messageID, transaction: transaction)
                
                if let dialogID = currentMessage.dialogID {
                    
                    let dialog = HCChatDialog.findDialog(dialogID, transaction: transaction)
                    let dialogType = dialog?.type
                    
                    if dialog == nil && currentMessage.messageType == HCSDKConstants.kMessageTypeChannel
                    {
                        // channel not found locally, so we should refresh channels
                        ChannelsManager.sharedInstance.fetchChannels({ (error) in
                            
                            if error == nil {
                                
                                DispatchQueue.main.async(execute: {
                                    d.widgetMessagePreviewTapped?(dialogID: dialogID, dialogType:HCSDKConstants.kMessageTypeChannel, messageID: messageID, widget: self)
                                })
                            }
                        })
                    }
                    else if (dialog == nil) {
                        DialogsManager.sharedInstance.fetchDialogs()
                    }
                    else {
                        
                        if let type = dialogType {
                            
                            DispatchQueue.main.async(execute: {
                                d.widgetMessagePreviewTapped?(dialogID: dialogID, dialogType:type, messageID: messageID, widget: self)
                            })
                        }
                    }
                }
            }
            
        })
    }
    
    // MARK: - Panning
    
    func initializePanning() {
        
        let panningGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanning(_:)))
        self.view.addGestureRecognizer(panningGesture)
    }
    
    func handlePanning(_ pan: UIPanGestureRecognizer) {
    
        let translation = pan.translation(in: self.view.superview)
        var center = self.view.center
        center.x += translation.x
        center.y += translation.y
        self.view.center = center
        pan.setTranslation(.zero, in: self.view.superview)
        
        _currentFrame = self.view.frame
    }
    
    // MARK: - Monitoring Messages
    
    open func listMonitorWillChange(_ monitor: ListMonitor<HCMessage>) {
    }
    
    open func listMonitorDidChange(_ monitor: ListMonitor<HCMessage>) {
    }
    
    open func listMonitor(_ monitor: ListMonitor<HCMessage>, didInsertObject object: HCMessage, toIndexPath indexPath: IndexPath) {
        
        
        if let id = object.senderID, !AppFriendsUserManager.sharedInstance.isBlocked(userID: id), let sentTime = object.sentTime, sentTime.timeIntervalSince(lastPreviewShownTime) > previewShowingInterval, let dialogID = object.dialogID
        {
            DialogsManager.sharedInstance.queryDialogMuted(dialogID: dialogID, completion: { (muted, error) in
                
                if !muted && error == nil{
                    
                    DispatchQueue.main.async(execute: {
                        self.showPreviewBubble(message: object)
                        self.lastPreviewShownTime = Date()
                    })
                }
            })
        }
    }
    
    open func listMonitor(_ monitor: ListMonitor<HCMessage>, didDeleteObject object: HCMessage, fromIndexPath indexPath: IndexPath) {
    }
    
    open func listMonitor(_ monitor: ListMonitor<HCMessage>, didUpdateObject object: HCMessage, atIndexPath indexPath: IndexPath) {
    }
    
    
    open func listMonitor(_ monitor: ListMonitor<HCMessage>, didMoveObject object: HCMessage, fromIndexPath: IndexPath, toIndexPath: IndexPath) {
    }
    
    // MARK: ListSectionObserver
    
    open func listMonitor(_ monitor: ListMonitor<HCMessage>, didInsertSection sectionInfo: NSFetchedResultsSectionInfo, toSectionIndex sectionIndex: Int) {
        
    }
    
    open func listMonitor(_ monitor: ListMonitor<HCMessage>, didDeleteSection sectionInfo: NSFetchedResultsSectionInfo, fromSectionIndex sectionIndex: Int) {
        
    }
}
