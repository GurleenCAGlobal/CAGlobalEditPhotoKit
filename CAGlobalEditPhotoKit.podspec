Pod::Spec.new do |s|
  s.name = 'CAGlobalEditPhotoKit'
  s.version = '0.0.1'

  s.ios.deployment_target = '15.0'
  s.platform = :ios, '15.0'

  s.license = 'MIT'
  s.summary = 'Asynchronous image downloader with cache support with an UIImageView category.'
  s.homepage = 'https://github.com/GurleenCAGlobal/CAGlobalEditPhotoKit'
  s.author = { 'GurleenCAGlobal' => 'gurleen.singh@caglobal.com' }
  s.source = { :git => 'https://github.com/GurleenCAGlobal/CAGlobalEditPhotoKit.git', :tag => s.version.to_s }
  s.swift_version = ['5.0']
  s.description = 'This library provides a category for UIImageView with support for remote '      \
                  'images coming from the web. It provides an UIImageView category adding web '    \
                  'image and cache management to the Cocoa Touch framework, an asynchronous '      \
                  'image downloader, an asynchronous memory + disk image caching with automatic '  \
                  'cache expiration handling, a guarantee that the same URL won\'t be downloaded ' \
                  'several times, a guarantee that bogus URLs won\'t be retried again and again, ' \
                  'and performances!'

  s.requires_arc = true
  s.pod_target_xcconfig = {
    'SUPPORTS_MACCATALYST' => 'YES',
    'DERIVE_MACCATALYST_PRODUCT_BUNDLE_IDENTIFIER' => 'NO'
  }
  s.source_files = 'CAGlobalPhotoSDK/**/*.{h,m,swift}'
end
