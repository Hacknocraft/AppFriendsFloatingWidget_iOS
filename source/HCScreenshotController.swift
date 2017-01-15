//
//  HCScreenshotController.swift
//  AppFriendsFloatingWidgetSample
//
//  Created by HAO WANG on 12/19/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import RSKImageCropper
import AppFriendsUI

@objc open class HCScreenshotController: RSKImageCropViewController, RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource, HCDialogsPickerViewControllerDelegate, UINavigationControllerDelegate {

    let closeButton = UIButton(type: .custom)
    let zoomButton = UIButton(type: .custom)
    let shareButton = UIButton(type: .custom)
    let sendButton = UIButton(type: .custom)
    let actionPanel = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 60))
    
    var croppedImage: UIImage?
    
    enum ScreenShotIntent {
        case share, send
    }
    
    var intent: ScreenShotIntent = .send
    
    override open func viewDidLoad() {
        
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        
        self.cancelButton.isHidden = true
        self.chooseButton.isHidden = true
        
        actionPanel.translatesAutoresizingMaskIntoConstraints = false
        actionPanel.backgroundColor = UIColor.clear
        self.view.addSubview(actionPanel)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        zoomButton.translatesAutoresizingMaskIntoConstraints = false
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        closeButton.setImage(UIImage.GMDIconWithName(.gmdClear, textColor: HCFloatingWidget.widgetButtonIconColor, size: CGSize(width: 30, height: 30)), for: .normal)
        zoomButton.setImage(UIImage.GMDIconWithName(.gmdFullscreen, textColor: HCFloatingWidget.widgetButtonIconColor, size: CGSize(width: 30, height: 30)), for: .normal)
        shareButton.setImage(UIImage.GMDIconWithName(.gmdShare, textColor: HCFloatingWidget.widgetButtonIconColor, size: CGSize(width: 30, height: 30)), for: .normal)
        sendButton.setImage(UIImage.GMDIconWithName(.gmdSend, textColor: HCFloatingWidget.widgetButtonIconColor, size: CGSize(width: 30, height: 30)), for: .normal)
        
        self.actionPanel.addSubview(closeButton)
        self.actionPanel.addSubview(zoomButton)
        self.actionPanel.addSubview(shareButton)
        self.actionPanel.addSubview(sendButton)
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        zoomButton.addTarget(self, action: #selector(zoomButtonTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
    }
    
    override open func updateViewConstraints() {
        
        super.updateViewConstraints()
        
        if let labelTopConstraint = self.value(forKey: "moveAndScaleLabelTopConstraint") as? NSLayoutConstraint
        {
            self.view.removeConstraint(labelTopConstraint)
        }
        
        let labelBottomConstratin = NSLayoutConstraint(item: self.moveAndScaleLabel, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: -50)
        self.view.addConstraint(labelBottomConstratin)
        
        let views = ["actionPanel": actionPanel,
                     "closeButton": closeButton,
                     "zoomButton": zoomButton,
                     "shareButton": shareButton,
                     "sendButton": sendButton]
        
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[actionPanel(60)]", options: [], metrics: nil, views: views))
        self.view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[actionPanel]|", options: [], metrics: nil, views: views))
        
        self.actionPanel.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[closeButton(30)]", options: [], metrics: nil, views: views))
        self.actionPanel.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[zoomButton(30)]", options: [], metrics: nil, views: views))
        self.actionPanel.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[shareButton(30)]", options: [], metrics: nil, views: views))
        self.actionPanel.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-30-[sendButton(30)]", options: [], metrics: nil, views: views))
        self.actionPanel.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[closeButton][zoomButton(==closeButton)][shareButton(==closeButton)][sendButton(==closeButton)]|", options: [], metrics: nil, views: views))

    }
    
    // MARK: - Actions
    
    func closeButtonTapped() {
        self.cancelCrop()
    }
    
    func zoomButtonTapped() {
        
        if let imageScrollView = self.value(forKey: "imageScrollView") as? UIScrollView {
            
            let zoomScale = cropRect.size.height / self.originalImage.size.height;
            imageScrollView.setZoomScale(zoomScale, animated: true)
        }
    }
    
    func shareButtonTapped() {
        
        self.intent = .share
        self.cropImage()
    }
    
    func sendButtonTapped() {
        
        self.intent = .send
        self.cropImage()
    }
    
    // MARK: - RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource
    
    public func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    public func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
        
        return UIBezierPath(rect: cropRect)
    }
    
    public func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        
        return cropRect
    }
    
    public func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        
        self.croppedImage = croppedImage
        
        if self.intent == .share {
            
            let image = croppedImage
            
            let activityItem: [AnyObject] = [image as AnyObject]
            
            let avc = UIActivityViewController(activityItems: activityItem as [AnyObject], applicationActivities: nil)
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                avc.popoverPresentationController!.sourceView = self.view
                avc.popoverPresentationController!.sourceRect = self.shareButton.frame
            }
            
            self.present(avc, animated: true, completion: nil)
        }
        else if self.intent == .send {
            
            let dialogsPicker = HCDialogsPickerViewController()
            dialogsPicker.title = "Pick a Conversation"
            dialogsPicker.delegate = self
            dialogsPicker.includeChannels = true
            self.navigationController?.pushViewController(dialogsPicker, animated: true)
        }
    }

    // MARK: - HCDialogsPickerViewControllerDelegate
    
    public func didChooseDialog(_ dialogID: String) {
        
        if let image = self.croppedImage {
            
            let chatView = HCDialogChatViewController(dialog: dialogID)
            self.navigationController?.pushViewController(chatView, animated: true)
            self.navigationController?.delegate = self
            
            let dismissImage = UIImage.GMDIconWithName(.gmdClear, textColor: HCColorPalette.navigationBarIconColor, size: CGSize(width: 30, height: 30))
            let doneButton = UIBarButtonItem(image: dismissImage, style: .plain, target: self, action: #selector(dismissChatView))
            chatView.navigationItem.leftBarButtonItem = doneButton
        }
    }
    
    func dismissChatView() {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - UINavigationControllerDelegate
    
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        
        if viewController is HCDialogChatViewController, let image = self.croppedImage {
            
            let chatVC = viewController as! HCDialogChatViewController
            chatVC.sendImage(image)
            self.croppedImage = nil
        }
    }
}
