Pod::Spec.new do |spec|
  spec.name         = 'KSYGPULiveDy_iOS'
  spec.version      = '1.5.3.0'
  spec.license      = {
:type => 'Proprietary',
:text => <<-LICENSE
      Copyright 2015 kingsoft Ltd. All rights reserved.
      LICENSE
  }
  spec.homepage     = 'http://v.ksyun.com/doc.html'
  spec.authors      = { 'Peng Bin' => 'pengbin@kingsoft.com' }
  spec.summary      = 'KSYGPULiveSDK help you play and stream live video from ios mobile devices.'
  spec.description  = <<-DESC
    * KSYGPULiveSDK KSYStreamer     capture video, compress and publish stream to rtmp server
    * KSYGPULiveSDK KSYMediaPlayer  manages the playback of movie or live streaming
    * KSYGPULiveSDK KSYStreamerBase compress input CMSampleBuffers and publish stream to rtmp server
    * KSYGPULiveSDK KSYGPUCamera    capture video, Inherits from  GPUImageVideoCamera
    * KSYGPULiveSDK KSYGPUStreamer  Conforms to GPUImageInput, compress and publish filted video to rtmp server
  DESC
  spec.platform     = :ios, '8.0'
  spec.requires_arc = true
  spec.frameworks   = 'VideoToolbox'
  spec.dependency 'GPUImage'
  spec.ios.library = 'z', 'iconv', 'stdc++.6'
  spec.source = { :git => 'https://github.com/ksvc/KSYLive_iOS.git', :tag => 'v1.5.2.2'}
  spec.preserve_paths      = 'framework/livegpu/libksygpulivedylib.framework'
  spec.public_header_files = 'framework/livegpu/libksygpulivedylib.framework/Headers'
  spec.vendored_frameworks = 'framework/livegpu/libksygpulivedylib.framework'
end

