//
//  CaptureViewController.m
//  PBJVisionDemo
//
//  Created by LabanL on 17/08/2017.
//  Copyright © 2017 Wisesoft. All rights reserved.
//

#import "CaptureViewController.h"
#import "PBJVision.h"
#import "DBHelper.h"
#import "VideoRecordButton.h"
#import <PBJVideoPlayer/PBJVideoPlayer.h>

#define ActionButtonCenterY CGRectGetHeight(self.view.frame)-120
#define ActionButtonCenterX CGRectGetWidth(self.view.frame)/2

@interface CaptureViewController () <PBJVisionDelegate, VideoRecordButtonDelegate, PBJVideoPlayerControllerDelegate>

@property (nonatomic, retain) UIView* previewView;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer* previewLayer;

@property (nonatomic, retain) NSDictionary* currentVideo;
@property (nonatomic, assign) BOOL recording;

@property (nonatomic, retain) UIButton* closeButton;
@property (nonatomic, retain) UIButton* cameraTurnButton;
@property (nonatomic, retain) VideoRecordButton* videoRecordButton;


@property (nonatomic, retain) PBJVideoPlayerController* videoPlayerController;
@property (nonatomic, retain) UIButton* backButton;
@property (nonatomic, retain) UIButton* sendButton;
@property (nonatomic, retain) NSString* videoPath;
@property (nonatomic, retain) UIImage* thumbImage;
@property (nonatomic, assign) CGFloat duration;

@end

@implementation CaptureViewController

- (PBJVideoPlayerController*)videoPlayerController{
    if(!_videoPlayerController){
        _videoPlayerController = [[PBJVideoPlayerController alloc] init];
        _videoPlayerController.delegate = self;
        _videoPlayerController.view.frame = self.view.bounds;
    }
    return _videoPlayerController;
}

- (void)showVideoPlayer{
    [self addChildViewController:self.videoPlayerController];
    [self.view addSubview:self.videoPlayerController.view];
    [self.videoPlayerController didMoveToParentViewController:self];
    
    self.videoPlayerController.videoPath = self.videoPath;
    
    //恢复按钮位置
    [self.backButton setCenter:CGPointMake(ActionButtonCenterX, ActionButtonCenterY)];
    [self.sendButton setCenter:CGPointMake(ActionButtonCenterX, ActionButtonCenterY)];
    
    [self.view addSubview:self.backButton];
    [self.view bringSubviewToFront:self.backButton];
    [self.view addSubview:self.sendButton];
    [self.view bringSubviewToFront:self.sendButton];
    
    [[PBJVision sharedInstance] stopPreview];
    
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint backCenter = self.backButton.center;
        backCenter.x -= 84;
        [self.backButton setCenter:backCenter];
        
        CGPoint sendCenter = self.sendButton.center;
        sendCenter.x += 84;
        [self.sendButton setCenter:sendCenter];
    }];
}

- (UIButton*)backButton{
    if(!_backButton){
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(ActionButtonCenterX, ActionButtonCenterY-42, 84, 84)];
        [_backButton setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
        [_backButton setImage:[UIImage imageNamed:@"ic_back"] forState:UIControlStateNormal];
        [_backButton setImageEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
        _backButton.layer.cornerRadius = 42;
        _backButton.clipsToBounds = YES;
        [_backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _backButton;
}

- (void)backButtonAction{
    [[PBJVision sharedInstance] startPreview];
    
    [self.videoPlayerController.view removeFromSuperview];
    [self.videoPlayerController removeFromParentViewController];
    [self.backButton removeFromSuperview];
    [self.sendButton removeFromSuperview];
    
    __weak typeof(self) weakSelf = self;
    //如果用户取消，则删除已录制的视频
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if(weakSelf.videoPath && weakSelf.videoPath.length > 0 && [[NSFileManager defaultManager] fileExistsAtPath:weakSelf.videoPath]){
            NSError* error;
            [[NSFileManager defaultManager] removeItemAtPath:weakSelf.videoPath error:&error];
        }
        
        weakSelf.videoPath = nil;
        weakSelf.duration = 0.0;
        weakSelf.thumbImage = nil;
    });
}

- (UIButton*)sendButton{
    if(!_sendButton){
        _sendButton = [[UIButton alloc] initWithFrame:CGRectMake(ActionButtonCenterX, ActionButtonCenterY-42, 84, 84)];
        [_sendButton setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.8]];
        [_sendButton setImage:[UIImage imageNamed:@"ic_ok"] forState:UIControlStateNormal];
        [_sendButton setImageEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
        _sendButton.layer.cornerRadius = 42;
        _sendButton.clipsToBounds = YES;
        [_sendButton addTarget:self action:@selector(sendButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sendButton;
}

- (void)sendButtonAction{
    TBVideo* video = [[TBVideo alloc] init];
    video.isAutoIncrement = YES;
    video.videoName = [self.videoPath.pathComponents lastObject];
    video.videoDuration = self.duration;
    NSData *data = UIImagePNGRepresentation(self.thumbImage);
    if (!data) {
        data = UIImageJPEGRepresentation(self.thumbImage, 1);
    }
    video.thumbImage = data;
    video.videoPath = self.videoPath;
    video.videoData = [NSData dataWithContentsOfFile:self.videoPath];
    BOOL isRetInsert = [[DBHelper sharedDB] insertObject:video into:TBVideo.tableName];
    
    if(isRetInsert) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationCaptureVideoCompleted object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)loadView{
    self.title = @"录制";
    
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    self.view = contentView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // preview and AV layer
    _previewView = [[UIView alloc] initWithFrame:CGRectZero];
    _previewView.backgroundColor = [UIColor blackColor];
    CGRect previewFrame = CGRectMake(0, 0, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame));
    _previewView.frame = previewFrame;
    _previewLayer = [[PBJVision sharedInstance] previewLayer];
    _previewLayer.frame = previewFrame;
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [_previewView.layer addSublayer:_previewLayer];
    [self.view addSubview:_previewView];
    
    _videoRecordButton = [[VideoRecordButton alloc] initWithCenter:CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame)-120)];
    _videoRecordButton.delegate = self;
    [self.view addSubview:_videoRecordButton];
    
    
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)/2-120, CGRectGetHeight(self.view.frame)-120-24, 48, 48)];
    [_closeButton setImageEdgeInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [_closeButton setImage:[UIImage imageNamed:@"ic_arrow_down"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeVc) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    [self.view bringSubviewToFront:_closeButton];
    
    _cameraTurnButton = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-48, 0, 48, 48)];
    [_cameraTurnButton setImageEdgeInsets:UIEdgeInsetsMake(12, 0, 12, 0)];
    [_cameraTurnButton setImage:[UIImage imageNamed:@"ic_camera_turn"] forState:UIControlStateNormal];
    [_cameraTurnButton addTarget:self action:@selector(cameraTurnAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_cameraTurnButton];
    [self.view bringSubviewToFront:_cameraTurnButton];
    
    [self videoPlayerController];
    [self backButton];
    [self sendButton];
    
    [self setup];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void) recordStarted:(VideoRecordButton*)sender{
    [[PBJVision sharedInstance] startVideoCapture];
}

- (void) recordCompleted:(VideoRecordButton*)sender{
    [[PBJVision sharedInstance] endVideoCapture];
}

- (void) closeVc{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) cameraTurnAction{
    PBJVision *vision = [PBJVision sharedInstance];
    [vision stopPreview];
    if(vision.cameraDevice == PBJCameraDeviceBack){
        vision.cameraDevice = PBJCameraDeviceFront;
    }else{
        vision.cameraDevice = PBJCameraDeviceBack;
    }
    [vision startPreview];
}

- (void) stopRecord{
    [[PBJVision sharedInstance] endVideoCapture];
}

- (void)viewDidLayoutSubviews{
    _previewLayer.frame = _previewView.bounds;
}

- (void)setup{
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    vision.cameraMode = PBJCameraModeVideo;
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatFullscreen;
    vision.captureDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"SmallVideo"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:vision.captureDirectory]){
        NSError* error;
        [[NSFileManager defaultManager] createDirectoryAtPath:vision.captureDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    [vision startPreview];
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error{
    if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
        NSLog(@"recording session cancelled");
        return;
    } else if (error) {
        NSLog(@"encounted an error in video capture (%@)", error);
        return;
    }
    
    _currentVideo = videoDict;
    self.duration = [[_currentVideo objectForKey:PBJVisionVideoCapturedDurationKey] floatValue];
    self.thumbImage = (UIImage*)[_currentVideo objectForKey:PBJVisionVideoThumbnailKey];
    self.videoPath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
    
    [self showVideoPlayer];
}

#pragma mark - PBJVideoPlayerControllerDelegate
- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer{
    [videoPlayer playFromBeginning];
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer{
    [videoPlayer playFromBeginning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
