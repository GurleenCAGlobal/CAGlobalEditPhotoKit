Pod::Spec.new do |s|
s.name              = 'CAGlobalPhotoSDKKit'
s.version           = '0.0.1'
s.summary           = 'CAGlobalPhotoSDK'
s.homepage          = 'https://github.com/GurleenCAGlobal/CAGlobalEditPhotoKit'
s.ios.deployment_target = '15.0'
s.platform = :ios, '15.0'
s.swift_versions = ['5.0']
s.license           = {
                        :type => 'MIT',
                        :file => 'LICENSE'
}
s.author = { 'GurleenSingh' => 'gurleen.singh@example.com' }
s.source            = {
                        :git => 'https://github.com/GurleenCAGlobal/CAGlobalEditPhotoKit.git',
                        :tag => s.version.to_s }
s.frameworks = 'UIKit', 'Foundation'
s.source_files = 'CAGlobalPhotoSDK/**/*.{h,m,swift}'
s.requires_arc      = true
end
