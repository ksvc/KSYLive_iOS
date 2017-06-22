#import <UIKit/UIKit.h>
#import <GPUImage/GPUImage.h>

/**
 UIView subclass to use as an endpoint for displaying GPUImage outputs
 */
@interface KSYGPUView : UIView <GPUImageInput> {
    GPUImageRotationMode inputRotation;
}

/** 画面填充模式, 默认值为kGPUImageFillModePreserveAspectRatio
 */
@property(readwrite, nonatomic) GPUImageFillModeType fillMode;

/** This calculates the current display size, in pixels, taking into account Retina scaling factors
 */
@property(readonly, nonatomic) CGSize sizeInPixels;

/** GPUImageInput 启用
 */
@property(nonatomic) BOOL enabled;

/** Handling fill mode
 
 @param redComponent Red component for background color
 @param greenComponent Green component for background color
 @param blueComponent Blue component for background color
 @param alphaComponent Alpha component for background color
 */
- (void)setBackgroundColorRed:(GLfloat)redComponent
                        green:(GLfloat)greenComponent
                         blue:(GLfloat)blueComponent
                        alpha:(GLfloat)alphaComponent;

/** 是否接收单通道输入
 */
- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue;

@end
