//
//  KSYProberVC.m
//  KSYPlayerDemo
//
//  Created by 施雪梅 on 16/7/10.
//  Copyright © 2016年 kingsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "KSYProberVC.h"

@interface KSYProberVC ()
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) KSYMediaInfoProber *prober;
@end

@implementation KSYProberVC{
        UILabel *stat;
    
        UIButton *btnProbe;
        UIButton *btnThumbnail;
        UIButton *btnQuit;
}

- (instancetype)initWithURL:(NSURL *)url {
    if((self = [super init])) {
        self.url = url;
    }
    return self;
}


- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    [super viewDidLoad];
    [self initUI];
}

- (void) initUI {
    //add play button
    btnProbe= [self addButtonWithTitle:@"probe" action:@selector(onProbeMediaInfo:)];
    
    //add Thumbnail button
    btnThumbnail = [self addButtonWithTitle:@"Thumbnail" action:@selector(onThumbnail:)];
    
    //add quit button
    btnQuit = [self addButtonWithTitle:@"quit" action:@selector(onQuit:)];
    
    stat = [[UILabel alloc] init];
    stat.backgroundColor = [UIColor clearColor];
    stat.textColor = [UIColor redColor];
    stat.numberOfLines = -1;
    stat.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:stat];
    [self layoutUI];
    
    NSString *aUrlString = [_url isFileURL] ? [_url path] : [_url absoluteString];
    stat.text = [NSString stringWithFormat:@"url is : %@", aUrlString];
    _prober = [[KSYMediaInfoProber alloc] initWithContentURL: _url];
    _prober.timeout = 10;
}

- (UIButton *)addButtonWithTitle:(NSString *)title action:(SEL)action{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:title forState: UIControlStateNormal];
    button.backgroundColor = [UIColor lightGrayColor];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    button.layer.masksToBounds  = YES;
    button.layer.cornerRadius   = 5;
    button.layer.borderColor    = [UIColor blackColor].CGColor;
    button.layer.borderWidth    = 1;
    [self.view addSubview:button];
    return button;
}

- (void) layoutUI {
    CGFloat wdt = self.view.bounds.size.width;
    CGFloat hgt = self.view.bounds.size.height;
    
    CGFloat gap = 20;
    CGFloat btnWdt = ( (wdt-gap) / 3) - gap;
    CGFloat btnHgt = 30;
    
    CGFloat xPos = gap;
    CGFloat yPos = hgt - btnHgt - gap;

    btnProbe.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    xPos += gap + btnWdt;
    btnThumbnail.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    xPos += gap + btnWdt;
    btnQuit.frame = CGRectMake(xPos, yPos, btnWdt, btnHgt);
    
    stat.frame = CGRectMake(20, 0, wdt, hgt);
}

- (IBAction)onProbeMediaInfo:(id)sender {

    if(nil == _prober)
        return ;
    
    NSMutableString *result = [[NSMutableString alloc] init];
    int i = 0;
    
    KSYMediaInfo *mediaInfo = _prober.ksyMediaInfo;
    if(mediaInfo)
    {
        [result appendFormat:@"\nmux type:%@", [self convertMuxType:mediaInfo.type]];
        [result appendFormat:@"\nbitrate:%lld", mediaInfo.bitrate];
        
        i = 0;
        [result appendFormat:@"\n\nvideo num is : %lu", [mediaInfo.videos count]];
        for (KSYVideoInfo  *videoInfo in mediaInfo.videos) {
            [result appendFormat:@"\n\nvideo[%d] codec:%@", i, [self convertAVCodec:videoInfo.vcodec]];
            [result appendFormat:@"\nvideo[%d] frame width:%d", i, videoInfo.frame_width];
            [result appendFormat:@"\nvideo[%d] frame height:%d", i, videoInfo.frame_height];
            i++;
        }
        
        i = 0;
        [result appendFormat:@"\n\naudio num is : %lu", [mediaInfo.audios count]];
        for(KSYAudioInfo  *audioInfo in mediaInfo.audios)
        {
            [result appendFormat:@"\n\naudio[%d] codec:%@", i, [self convertAVCodec:audioInfo.acodec]];
            [result appendFormat:@"\naudio[%d] language:%@", i, audioInfo.language];
            [result appendFormat:@"\naudio[%d] bitrate:%lld", i, audioInfo.bitrate];
            [result appendFormat:@"\naudio[%d] channels:%d", i, audioInfo.channels];
            [result appendFormat:@"\naudio[%d] frame_size:%d", i, audioInfo.framesize];
            [result appendFormat:@"\naudio[%d] sample_format:%@", i, [self convertSampleFMT:audioInfo.sample_format]];
            [result appendFormat:@"\naudio[%d] samplerate:%d", i, audioInfo.samplerate];
            i++;
        }
    }
    else
        [result appendFormat:@"\nprobe mediainfo failed!"];
    
    stat.text = [NSString stringWithFormat:@"%@", result];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if (error == nil) {
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"O(∩_∩)O~~"
                                                        message:@"缩略图已保存至手机相册"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [toast show];
        
    }else{
        
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"￣へ￣"
                                                        message:@"缩略图截取失败！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [toast show];
    }

}

- (IBAction)onThumbnail:(id)sender {
    
    if(nil == _prober)
        return ;
    
    UIImage *thumbnailImage = [_prober getVideoThumbnailImageAtTime:0 width:640 height:480];
    if(thumbnailImage)
        UIImageWriteToSavedPhotosAlbum(thumbnailImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    else
    {
        UIAlertView *toast = [[UIAlertView alloc] initWithTitle:@"￣へ￣"
                                                        message:@"缩略图截取失败！"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil, nil];
        [toast show];
    }
}

- (IBAction)onQuit:(id)sender {
    [self dismissViewControllerAnimated:FALSE completion:nil];
}

#pragma mark converMediaInfo

- (NSString *)convertMuxType:(MEDIAINFO_MUX_TYPE)muxType
{
    NSString *muxTypeStr = @"unknow mux type";

    if(MEDIAINFO_MUXTYPE_MP2T == muxType)
        muxTypeStr = @"mpeg-ts";
    else if(MEDIAINFO_MUXTYPE_MOV == muxType)
        muxTypeStr = @"mov";
    else if(MEDIAINFO_MUXTYPE_AVI == muxType)
        muxTypeStr = @"avi";
    else if(MEDIAINFO_MUXTYPE_FLV == muxType)
        muxTypeStr = @"flv";
    else if(MEDIAINFO_MUXTYPE_MKV == muxType)
        muxTypeStr = @"mkv";
    else if(MEDIAINFO_MUXTYPE_ASF == muxType)
        muxTypeStr = @"asf";
    else if(MEDIAINFO_MUXTYPE_RM == muxType)
        muxTypeStr = @"rm";
    else if(MEDIAINFO_MUXTYPE_WAV == muxType)
        muxTypeStr = @"wav";
    else if(MEDIAINFO_MUXTYPE_OGG == muxType)
        muxTypeStr = @"ogg";
    else if(MEDIAINFO_MUXTYPE_APE == muxType)
        muxTypeStr = @"ape";
    else if(MEDIAINFO_MUXTYPE_RAWVIDEO == muxType)
        muxTypeStr = @"rawvideo";
    else if(MEDIAINFO_MUXTYPE_HLS == muxType)
        muxTypeStr = @"hls";
    
    return muxTypeStr;
}

- (NSString *)convertAVCodec:(MEDIAINFO_CODEC_ID)codecID
{
    NSString *codecIDStr = @"unknow codec";
    
    if(MEDIAINFO_CODEC_MPEG2VIDEO == codecID)
        codecIDStr = @"mpeg2";
    else if(MEDIAINFO_CODEC_MPEG4 == codecID)
        codecIDStr = @"mpeg4";
    else if(MEDIAINFO_CODEC_MJPEG == codecID)
        codecIDStr = @"mjpeg";
    else if(MEDIAINFO_CODEC_JPEG2000 == codecID)
        codecIDStr = @"jpeg2000";
    else if(MEDIAINFO_CODEC_H264 == codecID)
        codecIDStr = @"h264";
    else if(MEDIAINFO_CODEC_HEVC == codecID)
        codecIDStr = @"hevc";
    else if(MEDIAINFO_CODEC_VC1 == codecID)
        codecIDStr = @"vc1";
    else if(MEDIAINFO_CODEC_AAC == codecID)
        codecIDStr = @"aac";
    else if(MEDIAINFO_CODEC_AC3 == codecID)
        codecIDStr = @"ac3";
    else if(MEDIAINFO_CODEC_MP3 == codecID)
        codecIDStr = @"mp3";
    else if(MEDIAINFO_CODEC_PCM == codecID)
        codecIDStr = @"pcm";
    else if(MEDIAINFO_CODEC_DTS == codecID)
        codecIDStr = @"dts";
    else if(MEDIAINFO_CODEC_NELLYMOSER == codecID)
        codecIDStr = @"nellymoser";
    
    return codecIDStr;
}


- (NSString *)convertSampleFMT:(MEDIAINFO_SAMPLE_FMT)afmt
{
    NSString *sampleFMTStr = @"unknown sample formats";
    
    if(MEDIAINFO_SAMPLE_FMT_U8 == afmt)
        sampleFMTStr = @"unsigned 8 bits";
    else if(MEDIAINFO_SAMPLE_FMT_S16 == afmt)
        sampleFMTStr = @"signed 16 bits";
    else if(MEDIAINFO_SAMPLE_FMT_S32 == afmt)
        sampleFMTStr = @"signed 32 bits";
    else if(MEDIAINFO_SAMPLE_FMT_FLT == afmt)
        sampleFMTStr = @"float";
    else if(MEDIAINFO_SAMPLE_FMT_DBL == afmt)
        sampleFMTStr = @"double";
    else if(MEDIAINFO_SAMPLE_FMT_U8P == afmt)
        sampleFMTStr = @"unsigned 8 bits, planar";
    else if(MEDIAINFO_SAMPLE_FMT_S16P == afmt)
        sampleFMTStr = @"signed 16 bits, planar";
    else if(MEDIAINFO_SAMPLE_FMT_S32P == afmt)
        sampleFMTStr = @"signed 32 bits, planar";
    else if(MEDIAINFO_SAMPLE_FMT_FLTP == afmt)
        sampleFMTStr = @"float, planar";
    else if(MEDIAINFO_SAMPLE_FMT_DBLP == afmt)
        sampleFMTStr = @"double, planar";
    else if(MEDIAINFO_SAMPLE_FMT_NB == afmt)
        sampleFMTStr = @"Number of sample formats";

    return sampleFMTStr;
}

@end
