Pod::Spec.new do |spec|
  spec.name = "mediapicker-ios"
  spec.version = "1.0.1"
  spec.swift_version = "5.1"
  spec.summary = "Media picker plug-in written in Swift (Image, Video, Audio, Image editing)"
  spec.homepage = "https://github.com/TomKaminski/mediapicker-ios"
  spec.license = "MIT"
  spec.author = { "Tomasz Kaminski" => "tkaminski93@gmail.com" }
  spec.source = { :git => "https://github.com/TomKaminski/mediapicker-ios.git", :tag => spec.version }
  spec.source_files = "MediaPicker/**/*.swift"
  spec.requires_arc = true
  spec.ios.deployment_target = "10.0"
  spec.ios.frameworks = "UIKit", "Foundation"
end