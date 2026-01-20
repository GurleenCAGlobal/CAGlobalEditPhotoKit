Pod::Spec.new do |s|
  s.name             = 'CAGlobalEditPhotoKit'
  s.version          = '2.0.0'
  s.summary          = '**CAGlobal Photo Editor SDK** is a comprehensive iOS photo editing framework that provides a full-featured photo editing experience. The SDK enables applications to offer professional-grade photo editing capabilities including filters, adjustments, frames, stickers, text overlays, brush tools, and transformation features.'
  s.description      = 'fdsfdfsdfdf'
  s.homepage         = 'https://github.com/GurleenCAGlobal/CAGlobalEditPhotoKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'GurleenCAGlobal' => 'gurleen.singh@caglobal.com' }
  s.source           = { :git => 'https://github.com/GurleenCAGlobal/CAGlobalEditPhotoKit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '15.0'
  s.source_files     = 'CAGlobalPhotoSDK/**/*.{h,m,swift}'
  s.resource_bundles = {
  'CAGlobalPhotoSDKResources' => ['CAGlobalPhotoSDK/Resources/**/*.{xib,storyboard,xcassets,png,jpg,ttf,otf}']
  }
  s.frameworks       = 'UIKit', 'Foundation'
  s.swift_version = ['5.0']
end
