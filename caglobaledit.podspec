Pod::Spec.new do |s|
s.name              = 'caglobaledit'
s.version           = '0.0.1'
s.summary           = 'CAGlobalPhotoSDK'
s.homepage          = 'https://github.com/GurleenCAGlobal/CAGlobalEditPhotoKit'
s.ios.deployment_target = '8.0'
s.platform = :ios, '8.0'
s.license           = {
:type => 'MIT',
:file => 'LICENSE'
}
s.author            = {
'GurleenSingh' => 'Gurleen'
}
s.source            = {
:git => 'https://github.com/GurleenCAGlobal/CAGlobalEditPhotoKit.git',
:tag => '#{s.version}' }
s.framework = "UIKit"
s.source_files      = 'CAGlobalPhotoSDK*' , 'Classes/*', 'Resource/*'
s.requires_arc      = true
end
