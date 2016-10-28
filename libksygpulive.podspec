Pod::Spec.new do |s|
  s.name         = 'libksygpulive'
  s.version      = '1.8.5'
  s.license      = {
:type => 'Proprietary',
:text => <<-LICENSE
      Copyright 2015 kingsoft Ltd. All rights reserved.
      LICENSE
  }
  s.homepage     = 'http://v.ksyun.com/doc.html'
  s.authors      = { 'ksyun' => 'zengfanping@kingsoft.com' }
  s.summary      = 'libksylive help you play and stream live video from ios mobile devices.'
  s.description  = <<-DESC
    * KSYMediaPlayer lite/vod manages the playback of movie or live streaming
    * libksygpulive  lite/265 capture video, compress and publish stream to rtmp server
  DESC
  s.platform     = :ios, '7.0'
  s.ios.library = 'z', 'iconv', 'stdc++.6', 'bz2'
  s.ios.frameworks   = [ 'AVFoundation', 'VideoToolbox']
  s.ios.deployment_target = '7.0'
  s.source = { 
    :git => 'https://github.com/ksvc/KSYLive_iOS.git',
    :tag => 'v'+s.version.to_s
  }
  s.requires_arc = true
  s.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC -all_load' }

  # Exclude optional Search and Testing modules
  s.default_subspec = 'libksygpulive'

  s.subspec 'KSYMediaPlayer' do |sub|
    libName = sub.name.split("/").last
    sub.source_files =  'prebuilt/include/KSYPlayer/*.h'
    sub.vendored_libraries = [
      'prebuilt/libs/libksybase.a',
      'prebuilt/libs/libksymediacore_dec_lite.a',
      'prebuilt/libs/libksyplayer.a', 
    ]
  end
  s.subspec 'KSYMediaPlayer_vod' do |sub|
    libName = sub.name.split("/").last
    sub.source_files =  'prebuilt/include/KSYPlayer/*.h'
    sub.vendored_libraries = [
      'prebuilt/libs/libksybase.a',
      'prebuilt/libs/libksymediacore_dec_vod.a',
      'prebuilt/libs/libksyplayer.a', 
    ]
  end
  s.subspec 'libksygpulive' do |sub|
    libName = sub.name.split("/").last
    sub.source_files =  ['prebuilt/include/**/*.h',
                         'source/*.{h,m}']
    sub.vendored_libraries = [
      'prebuilt/libs/libksybase.a',
      'prebuilt/libs/libksyyuv.a',
      'prebuilt/libs/libksymediacodec.a',
      'prebuilt/libs/libksymediacore_enc_lite.a',
      'prebuilt/libs/libksyplayer.a', 
      'prebuilt/libs/libksystreamer.a'
    ]
    sub.dependency 'GPUImage'
  end
  s.subspec 'libksygpulive_265' do |sub|
    libName = sub.name.split("/").last
    sub.source_files =  ['prebuilt/include/**/*.h',
                         'source/*.{h,m}']
    sub.vendored_libraries = [
      'prebuilt/libs/libksybase.a',
      'prebuilt/libs/libksyyuv.a',
      'prebuilt/libs/libksymediacodec.a',
      'prebuilt/libs/libksymediacore_enc_265.a',
      'prebuilt/libs/libksyplayer.a', 
      'prebuilt/libs/libksystreamer.a'
    ]
    sub.dependency 'GPUImage'
  end
  s.subspec 'KSYGPUResource' do |sub|
    sub.resource = 'resource/KSYGPUResource.bundle'
  end
end
