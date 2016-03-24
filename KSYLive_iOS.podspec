Pod::Spec.new do |spec|
  spec.name         = 'KSYLive_iOS'
  spec.version      = '1.2.7'
  spec.license      = {
:type => 'Proprietary',
:text => <<-LICENSE
      Copyright 2015 kingsoft Ltd. All rights reserved.
      LICENSE
  }
  spec.homepage     = 'http://v.ksyun.com/doc.html'
  spec.authors      = { 'Peng Bin' => 'pengbin@kingsoft.com' }
  spec.summary      = 'KSYLiveSDK help you play and stream live video from ios mobile devices.'
  spec.description  = <<-DESC
    * KSYLiveSDK KSYStreamer capture video, compress and publish stream to rtmp server
    * KSYLiveSDK KSYMediaPlayer manages the playback of movie or live streaming
  DESC
  spec.platform     = :ios, '7.0'
  spec.requires_arc = true
  spec.frameworks   = 'VideoToolbox'
  spec.ios.library = 'z', 'iconv', 'stdc++.6'
  spec.source = { :git => 'https://github.com/ksvc/KSYLive_iOS.git', :tag => 'v1.2.7'}
  spec.preserve_paths      = 'framework/live264/libksylive.framework'
  spec.public_header_files = 'framework/live264/libksylive.framework/Headers'
  spec.vendored_frameworks = 'framework/live264/libksylive.framework'
end

