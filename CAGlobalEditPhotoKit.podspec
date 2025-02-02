Pod::Spec.new do |s|
  s.name             = 'CAGlobalEditPhotoKit'
  s.version          = '0.1.5'
  s.summary          = 'A brief description of your library'
  s.description      = 'A more detailed description of your library'
  s.homepage         = 'https://github.com/GurleenCAGlobal/CAGlobalEditPhotoKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'GurleenCAGlobal' => 'gurleen.singh@caglobal.com' }
  s.source           = { :git => 'https://github.com/GurleenCAGlobal/CAGlobalEditPhotoKit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.source_files     = 'CAGlobalPhotoSDK/**/*.{h,m,swift}'
  s.resource_bundles = {
    'CAGlobalPhotoSDK' => [
        'CAGlobalPhotoSDK/**/*.xib'
    ]
  }
  s.frameworks       = 'UIKit', 'Foundation'
  s.swift_version = ['5.0']
end
