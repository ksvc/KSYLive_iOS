platform :ios, '7.0'
inhibit_all_warnings!
use_frameworks!

target 'KSYLiveDemo' do
  pod 'Bugly'
  # YYImage 仅demo中用于导入gif和apng的格式的图片用到了
  # 不需要支持这些格式的话,不需要添加YYImage的依赖
  pod 'YYImage'
  # ZipArchive 仅demo中用于解压资源文件,不是必须依赖
  pod 'ZipArchive', '~> 1.4'
  
  pod 'GPUImage'
  # KSYGPUResource 为基础版本的图片资源, 包含了美颜滤镜必须依赖的图片
  pod 'libksygpulive/KSYGPUResource',      :path => '../'
  # KSYGPUResourceFull 为完整版本的图片资源, 包含了所有特效滤镜的图片
  #pod 'libksygpulive/KSYGPUResourceFull',      :path => '../'
  ## 请根据需要选择要添加的资源包, 完整版的资源引入的增量为3.1M

  pod 'libksygpulive/libksygpulive',       :path => '../'
  # pod 'libksygpulive/libksygpulive_265', :path => '../'

  # libksygpulive_ks3 和 libksygpulive 的库完全相同
  # 只是ks3的库存放在国内的云盘上, 比从github clone速度快一些
  # pod 'libksygpulive_ks3/KSYGPUResource'
  # pod 'libksygpulive_ks3/libksygpulive'
end

target 'KSYLiveDemo_Swift' do
    pod 'Bugly'
    pod 'GPUImage'
    pod 'libksygpulive/KSYGPUResource', :path => '../'
    pod 'libksygpulive/libksygpulive', :path => '../'
    #pod 'libksygpulive/libksygpulive_265', :path => '../'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    puts "!!!! #{target.name}"
  end
end
