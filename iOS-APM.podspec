#
# Be sure to run `pod lib lint iOS-APM.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iOS-APM'
  s.version          = '0.1.0'
  s.summary          = 'A short description of iOS-APM.'

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/Boy-Rong/iOS-APM'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'rongshao' => 'rongheng@mucang.com' }
  s.source           = { :git => 'https://github.com/Boy-Rong/iOS-APM.git', :tag => s.version.to_s }
  
  s.ios.deployment_target = '8.0'
  s.swift_version = '5.0'
  s.module_name   = 'BRAPM'
  
  s.default_subspec = 'Global', 'Crash'
  
  s.subspec "Global" do |ss|
    ss.source_files  = 'iOS-APM/Classes/Global/*.{swift,h}'
    ss.framework  = 'Foundation'
    ss.dependency 'ThreadBacktrace'
  end
  
  s.subspec "Crash" do |ss|
    ss.source_files  = 'iOS-APM/Classes/Crash/**/*.{swift,h}'
#    ss.private_header_files = 'iOS-APM/Classes/Crash/**/*.h'
    ss.framework  = 'Foundation'
  end
  
  # s.resource_bundles = {
  #   'iOS-APM' => ['iOS-APM/Assets/*.png']
  # }
  
   s.dependency 'GodEye'
   
end
