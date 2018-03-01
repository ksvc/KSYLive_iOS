//
//  VideoListShowController.m
//  KSYPlayerDemo
//
//  Created by devcdl on 2017/9/11.
//  Copyright © 2017年 kingsoft. All rights reserved.
//

#import "VideoListShowController.h"
#import "VideoListViewModel.h"
#import "FlowLayout.h"
#import "VideoCollectionViewCell.h"
#import "PlayerViewModel.h"
#import "VideoCollectionHeaderView.h"
#import "SuspendPlayView.h"
#import "VideoModel.h"
#import "UIView+Toast.h"

#import "VodListPlayController.h"
#import "LivePlayController.h"
#import "VodPlayController.h"
//个人设置界面
#import "SettingViewController.h"
//扫描二维码
#import "KSYQRCodeVC.h"

@interface VideoListShowController ()
<UICollectionViewDataSource, UICollectionViewDelegate, FlowLayoutDelegate>
@property (nonatomic, strong) VideoListViewModel        *videoListViewModel;
@property (nonatomic, strong) UICollectionView          *videoCollectionView;
@property (nonatomic, strong) VideoCollectionHeaderView *headerView;

@property (nonatomic, strong) VodPlayController         *vodPlayVC;
@property (nonatomic, strong) VodListPlayController     *vodPlayListVC;

@property (nonatomic, strong) LivePlayController        *livePlayVC;

@property (nonatomic, strong) SuspendPlayView           *suspendView;
@property (nonatomic, strong) UIView                    *clearView;
@property (nonatomic, assign) BOOL willAppearFromPlayerView;
@property (nonatomic, assign) BOOL isMoving;
@property (weak, nonatomic) IBOutlet UIButton *qrcodeButton;
@end

@implementation VideoListShowController

- (instancetype)initWithShowType:(VideoListShowType)showType {
    if (self = [super init]) {
        _showType = showType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.showType == VideoListShowTypeLive) {
        self.title = @"直播";
    } else if (self.showType == VideoListShowTypeVod) {
        self.title = @"点播";
    }
    [self setupUI];
    [self fetchDatasource];
    
    
    UIBarButtonItem* leftItem = [UIBarButtonItem barButtonItemWithImageName:@"扫一扫" frame:KSYScreen_Frame(0, 0, 40, 40) target:self action:@selector(scanQRCodeAction:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIBarButtonItem* rightItem = [UIBarButtonItem barButtonItemWithImageName:@"设置" frame:KSYScreen_Frame(0, 0, 40, 40) target:self action:@selector(jumpSetting)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    //添加一个通知，当打开 直播的时候 需要刷新
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeButtonAction) name:closeSuspensionBox object:nil];
}
-(void)jumpSetting{

   SettingViewController *settingVC = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    settingVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:settingVC animated:YES];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (_willAppearFromPlayerView) {
        [self.view addSubview:self.suspendView];
       self.suspendView.frame = CGRectMake(0, 0, 160, 250);
        self.suspendView.center = self.view.center;
        
        if (self.showType == VideoListShowTypeVod) {
            [self.vodPlayVC.view removeFromSuperview];
            [self.suspendView addSubview:self.vodPlayVC.view];
            [self.suspendView sendSubviewToBack:self.vodPlayVC.view];
            [self.vodPlayVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.suspendView);
            }];
            [self addChildViewController:self.vodPlayVC];
            [self.vodPlayVC suspendHandler];
        } else if (self.showType == VideoListShowTypeLive) {
            [self.suspendView addSubview:self.livePlayVC.player.view];
            [self.suspendView sendSubviewToBack:self.livePlayVC.player.view];
            [self.livePlayVC.player.view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(self.suspendView);
            }];
            [self addChildViewController:self.livePlayVC];
            [self.livePlayVC suspendHandler];
        }
        self.willAppearFromPlayerView = NO;
        self.hasSuspendView = YES;
    }
    
   
}
- (IBAction)scanQRCodeAction:(id)sender {
    if (self.hasSuspendView) {
        return;
    }
    //扫描二维码
    KSYQRCodeVC* qrCodeVC = [[KSYQRCodeVC alloc]init];
    UINavigationController* nav = [[UINavigationController alloc]initWithRootViewController:qrCodeVC];
    [self presentViewController:nav animated:YES completion:nil];
}

// 检测stringQR是否是合法的点播地址，根据视频地址的命名规则自行修改
- (BOOL)legalUrl:(NSString *)rul {
    __block BOOL legal = NO;
    NSArray<NSString*> *legals = @[@".flv", @".m3u8", @".mov", @".mp4", @".avi", @".rmvb", @".mkv"];
    [legals enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([rul containsString:obj]) {
            legal = YES;
            *stop = YES;
        }
    }];
    return legal;
}

- (void)fetchDatasource {
    NSString *urlString = [NSString stringWithFormat:@"https://appdemo.download.ks-cdn.com:8682/api/GetLiveUrl/2017-01-01?Option=%zd", _showType];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSession *session = [NSURLSession sharedSession];
    __weak typeof(self) weakSelf = self;
    [self.view makeToastActivity:CSToastPositionCenter];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        typeof(weakSelf) strongSelf = weakSelf;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                strongSelf.videoListViewModel = [[VideoListViewModel alloc] initWithJsonResponseData:data];
                [strongSelf.headerView configeVideoModel:self.videoListViewModel.listViewDataSource.firstObject];
                [self performSelectorOnMainThread:@selector(refreshUI) withObject:nil waitUntilDone:NO];
                
                self.isMoving = YES;
            } else {
                NSLog(@"Fetch video data error----- : %@",error);
            }
        });
        
    }];
    [task resume];
}

-(void)refreshUI{
    [self.view hideToastActivity];
    [self.videoCollectionView reloadData];
}

- (void)setupUI {
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.videoCollectionView];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.view);
        make.height.mas_equalTo(197);
    }];
    [self.videoCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).offset(5);
        make.leading.trailing.bottom.equalTo(self.view);
    }];
}

- (UICollectionView *)videoCollectionView
{
    if (!_videoCollectionView)
    {
        _videoCollectionView = ({
            FlowLayout *flowLayout = [[FlowLayout alloc]init];
            flowLayout.delegate = self;
            UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
            collectionView.dataSource = self;
            collectionView.delegate = self;
            collectionView.alwaysBounceVertical = YES;
            [collectionView registerNib:[UINib nibWithNibName:@"VideoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kVideoCollectionViewCellId];
            collectionView;
        });
    }
    return _videoCollectionView;
}

- (VideoCollectionHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[NSBundle mainBundle] loadNibNamed:@"VideoCollectionHeaderView" owner:self options:nil].firstObject;
        __weak typeof(self) weakSelf = self;
        _headerView.tapBlock = ^{
            typeof(weakSelf) strongSelf = weakSelf;
            [strongSelf didSelectedVideoHandler:strongSelf.videoListViewModel.listViewDataSource.firstObject selectedIndex:0];
        };
    }
    return _headerView;
}

- (SuspendPlayView *)suspendView  {
    if (!_suspendView) {
        _suspendView = [[NSBundle mainBundle] loadNibNamed:@"SuspendPlayView" owner:self options:nil].firstObject;
        [_suspendView.closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSuspendHandler)];
        [_suspendView addGestureRecognizer:tap];
        _suspendView.backgroundColor = [UIColor brownColor];
    }
    return _suspendView;
}

- (void)tapSuspendHandler {
    self.willAppearFromPlayerView = YES;
    self.hasSuspendView = NO;
    if (self.showType == VideoListShowTypeVod) {
        [self.vodPlayVC.view removeFromSuperview];
        [self.vodPlayVC removeFromParentViewController];
        [self.suspendView removeFromSuperview];
        [self.vodPlayListVC pushFromSuspendHandler];
        [self.vodPlayVC recoveryHandler];
        [self.navigationController pushViewController:self.vodPlayListVC animated:YES];
    } else if (self.showType == VideoListShowTypeLive) {
        [self.livePlayVC.player.view removeFromSuperview];
        [self.livePlayVC removeFromParentViewController];
        [self.suspendView removeFromSuperview];
        [self.livePlayVC recoveryHandler];
        [self.livePlayVC pushFromSuspendHandler];
        [self.navigationController pushViewController:self.livePlayVC animated:YES];
    }
}

- (UIView *)clearView {
    if (!_clearView) {
        _clearView = [[UIView alloc] init];
        _clearView.backgroundColor = [UIColor clearColor];
    }
    return _clearView;
}

- (void)closeButtonAction {
    if (self.showType == VideoListShowTypeVod) {
        [self.vodPlayVC.view removeFromSuperview];
        [self.vodPlayVC removeFromParentViewController];
        [self.suspendView removeFromSuperview];
        [self.vodPlayVC stopSuspend];
        self.vodPlayListVC = nil;
        self.vodPlayVC = nil;
    } else if (self.showType == VideoListShowTypeLive) {
        [self.livePlayVC.player.view removeFromSuperview];
        [self.livePlayVC removeFromParentViewController];
        [self.suspendView removeFromSuperview];
        [self.livePlayVC stopSuspend];
        self.livePlayVC = nil;
    }
    self.hasSuspendView = NO;
}

- (void)didSelectedVideoHandler:(VideoModel *)videoModel selectedIndex:(NSInteger)selectedIndex {
    [self closeButtonAction];
    if (!videoModel) {
        return;
    }
    PlayerViewModel *playerViewModel = [[PlayerViewModel alloc] initWithPlayingVideoModel:videoModel videoListViewModel:_videoListViewModel selectedIndex:selectedIndex];
    
    UIViewController *desVC = nil;
    NSString *selectPlayUrl = videoModel.PlayURL[videoModel.definitation.integerValue];
   
    if (self.showType == VideoListShowTypeLive) {
        
        if (self.livePlayVC) {
            NSString *currPlayUrl = self.livePlayVC.currentVideoModel.PlayURL[_livePlayVC.currentVideoModel.definitation.integerValue];
            self.livePlayVC.playerViewModel = playerViewModel;
            [self.livePlayVC configeVideoModel:videoModel];
            [self.livePlayVC.player.view removeFromSuperview];
            [self.livePlayVC removeFromParentViewController];
            [self.suspendView removeFromSuperview];
            [self.livePlayVC recoveryHandler];
            if ([currPlayUrl isEqualToString:selectPlayUrl]) {
                [self.livePlayVC pushFromSuspendHandler];
            } else {
                [self.livePlayVC reloadPushFromSuspendHandler];
            }
            desVC = self.livePlayVC;
        } else {
            LivePlayController *lpc = [[LivePlayController alloc] initWithVideoModel:videoModel];
            lpc.playerViewModel = playerViewModel;
            desVC = lpc;
            self.livePlayVC = lpc;
            
            __weak typeof(self) weakSelf = self;
            lpc.willDisappearBlocked = ^{
                typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.willAppearFromPlayerView = YES;
            };
        }
    } else if (self.showType == VideoListShowTypeVod) {
        
        if (self.vodPlayListVC) {
            NSString *currPlayUrl = self.vodPlayVC.currentVideoModel.PlayURL[_livePlayVC.currentVideoModel.definitation.integerValue];
            self.vodPlayVC.playerViewModel = playerViewModel;
            [self.vodPlayVC configeVideoModel:videoModel];
            [self.vodPlayVC.view removeFromSuperview];
            [self.vodPlayVC removeFromParentViewController];
            [self.suspendView removeFromSuperview];
            [self.vodPlayVC recoveryHandler];
            if ([currPlayUrl isEqualToString:selectPlayUrl]) {
                [self.vodPlayListVC pushFromSuspendHandler];
            } else {
                [self.vodPlayListVC reloadPushFromSuspendHandler];
            }
            desVC = self.vodPlayListVC;
        } else {
            VodListPlayController *vodVC = [[VodListPlayController alloc] initWithPlayerViewModel:playerViewModel suspendView:_suspendView];
            desVC = vodVC;
            self.vodPlayVC = vodVC.playVC;
            self.vodPlayListVC = vodVC;
            
            __weak typeof(self) weakSelf = self;
            vodVC.willDisappearBlocked = ^{
                typeof(weakSelf) strongSelf = weakSelf;
                strongSelf.willAppearFromPlayerView = YES;
            };
        }
    }
    if (desVC) {
        desVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:desVC animated:YES];
    }
}

#pragma mark - CollectionView Datasource and Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _videoListViewModel.listViewDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kVideoCollectionViewCellId forIndexPath:indexPath];
    if (indexPath.row < self.videoListViewModel.listViewDataSource.count) {
        [cell configeWithVideoModel:self.videoListViewModel.listViewDataSource[indexPath.row]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    VideoModel *videoModel = nil;
    if (indexPath.row < self.videoListViewModel.listViewDataSource.count) {
        videoModel = self.videoListViewModel.listViewDataSource[indexPath.row];
    }
    if (videoModel) {
        [self didSelectedVideoHandler:videoModel selectedIndex:indexPath.row];
    }
}

#pragma mark --
#pragma mark - FlowLayoutDelegate

- (CGFloat)flowLayout:(FlowLayout *)flowLayout heightForRowAtIndexPath:(NSInteger )index itemWidth:(CGFloat)itemWidth {
    return kVideoCollectionViewCellHeight;
}

#pragma mark --
#pragma mark -- touch event

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    CGPoint convertPoint = [self.view convertPoint:point toView:self.suspendView];
    if (convertPoint.x > 0 && convertPoint.y > 0) {
        self.isMoving = YES;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    
    if(!_isMoving){
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint current = [touch locationInView:self.view];
    CGPoint previous = [touch previousLocationInView:self.view];
    
    CGPoint center = self.suspendView.center;
    
    CGPoint offset = CGPointMake(current.x - previous.x, current.y - previous.y);
    
    if (center.x + offset.x >= 0 && center.x + offset.x <= self.view.frame.size.width &&
        center.y + offset.y >= 0 && center.y + offset.y <= self.view.frame.size.height - 64
        ) {
        self.suspendView.center = CGPointMake(center.x + offset.x, center.y + offset.y);
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    self.isMoving = NO;
}



-(BOOL)prefersStatusBarHidden

{
    
    return NO;// 返回YES表示隐藏，返回NO表示显示
    
}

@end
