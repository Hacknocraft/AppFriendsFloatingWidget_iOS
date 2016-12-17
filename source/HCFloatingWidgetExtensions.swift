//
//  HCFloatingWidgetExtensions.swift
//  AppFriendsFloatingWidgetSample
//
//  Created by HAO WANG on 12/16/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit
import AppFriendsUI

public extension HCFloatingWidget {
    
    // MARK: - Preview Bubble
    
    open func showPreviewBubble(message: HCMessage? = nil) {
        
        if !_messagePreviewShowing {
            
            _messagePreviewShowing = true
            
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
                    
                    let delayTime = DispatchTime.now() + Double(Int64(5 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                    DispatchQueue.main.asyncAfter(deadline: delayTime)
                    {[weak self] in
                        self?.hidePreviewButton()
                    }
                })
            })
        }
    }
    
    open func hidePreviewButton() {
        
        if _messagePreviewShowing {
            
            _messagePreviewShowing = false
        
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
                    
                })
            })
        }
    }
    
}
