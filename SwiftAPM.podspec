#
# Be sure to run `pod lib lint SwiftAPM.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftAPM'
  s.version          = '0.2.0'
  s.summary          = 'iOS-APM'

  s.description      = <<-DESC
iOS APM 轮子 Swift 实现
                       DESC

  s.homepage         = 'https://github.com/Boy-Rong/SwiftAPM'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { '公子荣' => 'rongheng.rh@gmail.com' }
  s.source           = { :git => 'https://github.com/Boy-Rong/SwiftAPM.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '8.0'
  
  s.swift_versions = ['5.1', '5.2', '5.3']
  
  s.module_name   = 'SwiftAPM'
  
  s.default_subspec = 'General', 'Crash', 'ANR', 'Storage', 'Browser'
  
  s.subspec "General" do |ss|
    ss.source_files  = 'SwiftAPM/Source/General/*.{swift,h}'
    ss.header_dir = 'General'
    ss.framework  = 'Foundation'
  end
  
  s.subspec "Crash" do |ss|
    ss.source_files  = 'SwiftAPM/Source/Crash/**/*.{swift,h,c}'
    ss.header_dir = 'Crash'
    ss.dependency 'SwiftAPM/General'
    ss.dependency 'SwiftAPM/Storage'
    ss.dependency 'ThreadBacktrace'
    ss.framework  = 'Foundation'
  end
  
  s.subspec "ANR" do |ss|
    ss.source_files  = 'SwiftAPM/Source/ANR/**/*.{swift,h,c}'
    ss.dependency 'SwiftAPM/General'
    ss.dependency 'SwiftAPM/Storage'
    ss.dependency 'ThreadBacktrace'
    ss.framework  = 'Foundation'
  end
  
  s.subspec "Storage" do |ss|
    ss.source_files  = 'SwiftAPM/Source/Storage/**/*.{swift,h,c}'
    ss.header_dir = 'Storage'
    ss.dependency 'SwiftAPM/General'
    ss.dependency 'MMKV'
    ss.framework  = 'Foundation'
  end
  
  s.subspec "Browser" do |ss|
    ss.source_files  = 'SwiftAPM/Source/Browser/**/*.{swift,h,c}'
    ss.header_dir = 'Browser'
    ss.framework  = 'UIKit'
  end
  
  s.pod_target_xcconfig = {
    "DEFINES_MODULE" => "YES"
  }
  
  
#  ss.dependency 'SwiftAPM/Global'
  
#  s.framework  = 'Foundation', 'UIKit'
  
  # s.resource_bundles = {
  #   'SwiftAPM' => ['SwiftAPM/Assets/*.png']
  # }
  
end
