//
//  HCPreviewBubble.swift
//  AppFriendsFloatingWidgetSample
//
//  Created by HAO WANG on 12/16/16.
//  Copyright © 2016 Hacknocraft. All rights reserved.
//

import UIKit

@objc public class HCPreviewBubble: UIView {
    
    open let avatarView = UIImageView(frame: .zero)
    open let messagePreviewText = UILabel(frame: .zero)

    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = HCFloatingWidget.previewBubbleBackgroundColor
        self.avatarView.backgroundColor = HCFloatingWidget.previewBubbleAvatarBackgroundColor
        self.messagePreviewText.textColor = HCFloatingWidget.previewBubbleTextColor
        self.messagePreviewText.backgroundColor = UIColor.clear
        self.addSubview(avatarView)
        self.addSubview(messagePreviewText)
        
        avatarView.layer.cornerRadius = 10
        messagePreviewText.numberOfLines = 2
        messagePreviewText.font = UIFont.systemFont(ofSize: 13)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        messagePreviewText.translatesAutoresizingMaskIntoConstraints = false
        
        let views: [String: UIView] = ["avatarView": avatarView, "messagePreviewText": messagePreviewText]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-10-[avatarView(20)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-3-[messagePreviewText(34)]", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-10-[avatarView(20@999)]-10-[messagePreviewText]-5-|", options: [], metrics: nil, views: views))
        
        // debug
        messagePreviewText.text = "asdfaf asfasdf asdfasdf"
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
