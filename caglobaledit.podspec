Pod::Spec.new do |s|
s.name             = 'CAGlobalPhotoSDK'
s.version          = '0.0.1'
s.summary          = 'Image Editing SDK for iOS'
s.description      = 'Image Editing SDK for iOS'

s.homepage         = 'https://github.com/GurleenCAGlobal/CAGlobalEditPhotoKit'
s.license          = { :type => 'MIT', :file => 'LICENSE' }
s.author           = { 'username' => 'gurleen.singh@caglobal.com' } //your git mailid
s.source           = { :git => 'https://github.com/username/customPod.git', :tag => s.version.to_s } //your git repository url//
s.ios.deployment_target = '10.0'
s.source_files = 'CAGlobalPhotoSDK/*'
end
