source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/Hacknocraft/hacknocraft-cocoapods-spec.git'

# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'AppFriendsFloatingWidgetSample' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AppFriendsFloatingWidget
  #latest AppFriends version
  pod 'AppFriendsUI', :git => 'https://github.com/Hacknocraft/AppFriendsUI.git', :branch => ‘swift4_0’
  pod 'AppFriendsCore', :git => 'https://github.com/Hacknocraft/AppFriendsCore.git', :branch => ‘swift4_0’
  pod 'CoreStore', :git => 'https://github.com/JohnEstropia/CoreStore.git', :branch => 'prototype/Swift_4_0’
  pod 'SlackTextViewController', :git => 'https://github.com/Hacknocraft/SlackTextViewController.git', :branch => 'master'
  pod 'AppFriendsFloatingWidget', :path => './'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end
