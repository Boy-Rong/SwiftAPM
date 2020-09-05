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
  
  s.module_name   = 'BRAPM'
  s.ios.deployment_target = '8.0'

  s.source_files = 'iOS-APM/Classes/**/*.swift'
  
  # s.resource_bundles = {
  #   'iOS-APM' => ['iOS-APM/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  
   s.dependency 'ThreadBacktrace'
   s.dependency 'GodEye'
   
end
