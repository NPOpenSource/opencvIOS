#
#  Be sure to run `pod spec lint OpenGLUtils.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "OpenCVBase"
  spec.version      = "0.0.1"
  spec.summary      = "OpenCVBase."
  spec.description  = "OpenCVBase基础类的简单封装"

  spec.homepage     = "https//www.baidu.com"
  spec.license      = "MIT"
  spec.author    = "温杰"

  spec.source       = { :git => "", :tag => "#{spec.version}" }

  spec.source_files  = "Classes", "Classes/**/*.{h,m}"
  spec.public_header_files = 'Classes/**/*.h'

  spec.platform         = :ios, '8.0'
  spec.requires_arc = true
  spec.libraries = 'c++'

  spec.dependency "OpenCVUtils", "~> 0.0.1"
  spec.dependency "OpenCV", "3.4.6"

end
