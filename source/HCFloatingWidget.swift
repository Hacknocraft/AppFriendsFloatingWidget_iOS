//
//  HCFloatingWidget.swift
//  AppFriendsFloatingWidget
//
//  Created by HAO WANG on 12/13/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsUI

@objc public protocol HCFloatingWidgetDelegate {
    
    @objc optional func widgetButtonTapped(widget: HCFloatingWidget)
    @objc optional func widgetMessagePreviewTapped(dialogID: String, messageID: String, widget: HCFloatingWidget)
}

@objc public class HCFloatingWidget: UIViewController {
    
    open let widgetButton: UIButton = UIButton(type: .custom)
    open let screenshotButton: UIButton = UIButton(type: .custom)
    open let messagePreviewBubble = HCPreviewBubble(frame: .zero)
    
    open weak var delegate: HCFloatingWidgetDelegate?
    
    // MARK: - Configurable images
    
    open var widgetButtonImage: UIImage?
    open var screenshotButtonImage: UIImage?
    
    // MARK: - Configurable Colors
    
    open static var widgetButtonBackgroundColor = UIColor(red: 75/255.0, green: 168/255.0, blue: 225/255.0, alpha: 1.0)
    open static var screenshotButtonBackgroundColor = UIColor(red: 228/255.0, green: 182/255.0, blue: 71/255.0, alpha: 1.0)
    open static var previewBubbleBackgroundColor = UIColor(red: 75/255.0, green: 168/255.0, blue: 225/255.0, alpha: 1.0)
    open static var previewBubbleTextColor = UIColor.white
    open static var previewBubbleAvatarBackgroundColor = UIColor(red: 166/255.0, green: 180/255.0, blue: 191/255.0, alpha: 1.0)
    
    // MARK: - Other Configurables
    
    var allowPanning = true
    var showScreenshotButton = false
    var showMessagePreview = true
    var viewHeight = HCFloatingWidget.initialHeightFull
    
    static let initialWidth: CGFloat = 50
    static let initialHeightFull: CGFloat = 80
    static let initialHeightHalf: CGFloat = 50
    static let previewBubbleWidth: CGFloat = 180.0
    
    // MARK: - Other variables
    
    var _currentFrame: CGRect = .zero
    var _messagePreviewShowing = false
    
    // MARK: - Initialization
    
    public init(widgetImage buttonImage: UIImage? = nil,
                screenshotButtonImage ssButtonImage: UIImage? = nil,
                allowPanning allowed: Bool? = nil,
                showScreenshotButton showScreenshot: Bool? = nil,
                showMessagePreview showPreview: Bool? = nil)
    {
        
        super.init(nibName: nil, bundle: nil)
        
        if let shouldShowScreenshotButton = showScreenshot {
            self.showScreenshotButton = shouldShowScreenshotButton
        }
        if let panningAllowed = allowed {
            self.allowPanning = panningAllowed
        }
        if let shouldShowPreview = showPreview {
            self.showMessagePreview = shouldShowPreview
        }
        
        if self.showScreenshotButton {
            self.viewHeight = HCFloatingWidget.initialHeightFull
        }
        else {
            self.viewHeight = HCFloatingWidget.initialHeightHalf
        }
        
        self.view.frame = CGRect(x: 0, y: 0, width: HCFloatingWidget.initialWidth, height: self.viewHeight)
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
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Presentation
    
    open func present(overVC hostingVC: UIViewController, position: CGPoint) {
        
        hostingVC.addChildViewController(self)
        hostingVC.view.addSubview(self.view)
        self.view.center = position
        self.didMove(toParentViewController: hostingVC)
        
        _currentFrame = self.view.frame
        
        let delayTime = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delayTime)
        {[weak self] in
            self?.showPreviewBubble()
        }
    }
    
    // MARK: - Screenshot
    
    func initializeScreenshotButton() {
        
        screenshotButton.frame = CGRect(x: 7, y: 48, width: 36, height: 36)
        screenshotButton.backgroundColor = HCFloatingWidget.screenshotButtonBackgroundColor
        screenshotButton.layer.cornerRadius = screenshotButton.frame.size.width/2
        if let screenshotImage = screenshotButtonImage {
            screenshotButton.setImage(screenshotImage, for: .normal)
        }else {
            screenshotButton.setTitle("ss", for: .normal)
        }
        
        screenshotButton.setTitleColor(UIColor.white, for: .normal)
        screenshotButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.view.addSubview(screenshotButton)
        screenshotButton.autoresizingMask = [.flexibleLeftMargin]
    }
    
    func screenshotButtonTapped(_ sender: UIButton) {
        
        // present the screenshot tool from the parent view controller
    }
    
    // MARK: - Widget Button
    
    func initializeWidgetButton() {
        
        widgetButton.frame = CGRect(x: 5, y: 5, width: 40, height: 40)
        widgetButton.backgroundColor = HCFloatingWidget.widgetButtonBackgroundColor
        widgetButton.layer.cornerRadius = widgetButton.frame.size.width/2
        if let widgetImage = widgetButtonImage {
            widgetButton.setImage(widgetImage, for: .normal)
        }else {
            widgetButton.setTitle("Chat", for: .normal)
        }
        
        widgetButton.setTitleColor(UIColor.white, for: .normal)
        widgetButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        widgetButton.addTarget(self, action: #selector(widgetButtonTapped(_:)), for: .touchUpInside)
        self.view.addSubview(widgetButton)
        widgetButton.autoresizingMask = [.flexibleLeftMargin]
    }
    
    func widgetButtonTapped(_ sender: UIButton) {
        
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
    
    
}
