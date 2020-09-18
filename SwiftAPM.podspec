#
# Be sure to run `pod lib lint SwiftAPM.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftAPM'
  s.version          = '0.1.0'
  s.summary          = 'iOS-APM'

  s.description      = <<-DESC
iOS APM 轮子 Swift 实现
                       DESC

  s.homepage         = 'https://github.com/Boy-Rong/SwiftAPM'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rongshao' => 'rongheng@mucang.com' }
  s.source           = { :git => 'https://github.com/Boy-Rong/SwiftAPM.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'
  s.module_name   = 'SwiftAPM'
  
  s.default_subspec = 'Global', 'Crash'
  
  s.subspec "Global" do |ss|
    ss.source_files  = 'SwiftAPM/Classes/Global/*.{swift,h}'
    ss.framework  = 'Foundation'
    ss.dependency 'ThreadBacktrace'
  end
  
  s.subspec "Crash" do |ss|
    ss.source_files  = 'SwiftAPM/Classes/Crash/**/*.{swift,h,c}'
    ss.framework  = 'Foundation'
  end
  
  # s.resource_bundles = {
  #   'SwiftAPM' => ['SwiftAPM/Assets/*.png']
  # }
  
end
