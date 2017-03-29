//
//  HCFloatingWidgetExtensions.swift
//  AppFriendsFloatingWidgetSample
//
//  Created by HAO WANG on 12/16/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsUI
import AppFriendsCore
import AlamofireImage

public extension HCFloatingWidget {
    
    // MARK: - Preview Bubble
    
    public func showPreviewBubble(message: AFMessage? = nil) {
        
        if let currentUserID = HCSDKCore.sharedInstance.currentUserID(), currentUserID == message?.senderID
        {
            
            // no need to show preview if it's from the current user
            return
        }
        
        if let read = message?.read, read == true {
            
            // no need to show preview if it's already read
            return
        }
        
        self.messagePreviewBubble.messagePreviewText.text = self.currentMessage?.text
        if let url = message?.senderAvatar, let imageURL = URL(string: url) {
            self.messagePreviewBubble.avatarView.af_setImage(withURL: imageURL)
        }
        
        if !_messagePreviewShowing {
            
            UIView.animate(withDuration: 0.1, animations: {
                
                self.messagePreviewBubble.alpha = 1
                self.widgetButton.alpha = 0
                
            }, completion: { (finished) in
                
                UIView.animate(withDuration: 0.2, animations: { 
                    
                    var currentFrame = self._currentFrame
                    let xPosition = currentFrame.size.width >= HCFloatingWidget.previewBubbleWidth ?
                    currentFrame.origin.x :
                    currentFrame.origin.x - HCFloatingWidget.previewBubbleWidth + HCFloatingWidget.initialWidth
                    
                    currentFrame.origin.x = xPosition
                    currentFrame.size.width = HCFloatingWidget.previewBubbleWidth
                    
                    self.view.frame = currentFrame
                    
                }, completion: { (finish) in
                    
                    self._messagePreviewShowing = true
                    let delayTime = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime)
                    {[weak self] in
                        self?.hidePreviewButton()
                    }
                })
            })
        }
    }
    
    public func hidePreviewButton() {
        
        if _messagePreviewShowing {
            
            UIView.animate(withDuration: 0.2, animations: {
                
                var currentFrame = self._currentFrame
                
                let xPosition = currentFrame.size.width < HCFloatingWidget.previewBubbleWidth ?
                currentFrame.origin.x :
                currentFrame.origin.x + HCFloatingWidget.previewBubbleWidth - HCFloatingWidget.initialWidth
                
                currentFrame.origin.x = xPosition;
                currentFrame.size.width = HCFloatingWidget.initialWidth;
                
                self.view.frame = currentFrame;
                
            }, completion: { (finished) in
                
                UIView.animate(withDuration: 0.1, animations: {
                    
                    self.messagePreviewBubble.alpha = 0
                    self.widgetButton.alpha = 1
                    
                }, completion: { (finished) in
                    
                    self.messagePreviewBubble.messagePreviewText.text = ""
                    self.messagePreviewBubble.avatarView.image = nil
                    self._messagePreviewShowing = false
                })
            })
        }
    }
    
    func imageFromView(view: UIView) -> UIImage? {

        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if let width = image?.size.width, width > 600, let img = image {
            
            return resizeWithWidth(img, 600)
        }
        
        return image
    }
    
    func resizeWithWidth(_ image: UIImage, _ width: CGFloat) -> UIImage {
        
        let height = (width * image.size.height) / image.size.width
        let aspectSize = CGSize (width: width, height: height)
        
        UIGraphicsBeginImageContext(aspectSize)
        image.draw(in: CGRect(origin: CGPoint.zero, size: aspectSize))
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img!
    }
    
}
