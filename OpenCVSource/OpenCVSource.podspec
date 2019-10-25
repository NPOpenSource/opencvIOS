#
#  Be sure to run `pod spec lint openGLResource.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "OpenCVSource"
  spec.version      = "0.0.1"
  spec.summary      = "OpenCVSource."
  spec.description  = "OpenCV资源文件"

  spec.homepage     = "https//www.baidu.com"
  spec.license      = "MIT"
  spec.author    = "xxx"

  spec.source       = { :git => "", :tag => "#{spec.version}" }

  spec.resources = "Resources/*"



end
