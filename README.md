<p align="center">
<img alt="AppFriends" src="http://res.cloudinary.com/hacknocraft-appfriends/image/upload/v1492110660/AppFriends_logo_cinxuq.png" width=614 />
<br />
<br />
MAKE YOUR APP SOCIAL
<br />
Engage users with our turnkey social layer
<br />
<br />
<a href="https://www.bitrise.io/app/b64fc32389e5c132#/builds"><img alt="Build Status" src="https://www.bitrise.io/app/b64fc32389e5c132.svg?token=LK2n0BLiCini3bDGIGO_pg" /></a>
<a href="https://cocoapods.org/pods/CoreStore"><img alt="Cocoapods compatible" src="https://img.shields.io/cocoapods/v/CoreStore.svg?style=flat&label=Cocoapods" /></a>
</p>

# AppFriends Floating Widget
This floating widget works with AppFriends to provide:
1. message badge and preview bubble popup over any UI
2. screenshot taking and sharing to chat

## Integration
To integrate AppFriends iOS SDK to your Xcode iOS project, add this line in your `Podfile`
``` ruby
pod 'AppFriendsFloatingWidget', '~> 1.0.4'
```
Also, add `use_frameworks!` to the top of file. eg.
``` ruby
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/Hacknocraft/hacknocraft-cocoapods-spec.git'
```

### Present the widget
```swift
/// Present the AppFriends Widget. The AppFriends widget has these features:
/// 1. show message preview button
/// 2. show badge
/// 3. draggable
/// 4. you can use it share screenshots to chat
func presentWidget() {

    let floatingWidget =
        HCFloatingWidget(widgetImage: UIImage(named: "ic_chat_widget"),
                         screenshotButtonImage: UIImage(named: "ic_camera"),
                         showScreenshotButton: true)
    floatingWidget.present(overVC: self, position: CGPoint(x: 295, y: 60))
    floatingWidget.delegate = self
}
```
