//
//  VideoPlayerViewController.m
//  PBJVisionDemo
//
//  Created by LabanL on 17/08/2017.
//  Copyright © 2017 Wisesoft. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import <PBJVideoPlayer/PBJVideoPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface VideoPlayerViewController () <PBJVideoPlayerControllerDelegate>

@property (nonatomic, retain) PBJVideoPlayerController* videoPlayerController;
@property (nonatomic, retain) UIImageView* playButton;
@property (nonatomic, retain) UIButton* closeButton;
@property (nonatomic, retain) UIButton* saveButton;

@end

@implementation VideoPlayerViewController

- (void)loadView{
    UIView* contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.navigationController.navigationBar.bounds.origin.y, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-self.navigationController.navigationBar.bounds.origin.y)];
    contentView.backgroundColor = [UIColor darkGrayColor];
    self.view = contentView;
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _videoPlayerController = [[PBJVideoPlayerController alloc] init];
    _videoPlayerController.delegate = self;
    _videoPlayerController.view.frame = self.view.bounds;
    
    [self addChildViewController:_videoPlayerController];
    [self.view addSubview:_videoPlayerController.view];
    [_videoPlayerController didMoveToParentViewController:self];
    
    _videoPlayerController.videoPath = _videoPath; //@"http://172.16.9.18:8080/file/video.mp4";
    
    _playButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ic_video"]];
    _playButton.center = self.view.center;
    [self.view addSubview:_playButton];
    [self.view bringSubviewToFront:_playButton];
    
    _closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
    [_closeButton setImageEdgeInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [_closeButton setImage:[UIImage imageNamed:@"ic_close"] forState:UIControlStateNormal];
    [_closeButton addTarget:self action:@selector(closeVc) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_closeButton];
    [self.view bringSubviewToFront:_closeButton];
    
    _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-48, 0, 48, 48)];
    [_saveButton setImageEdgeInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    [_saveButton setImage:[UIImage imageNamed:@"ic_save"] forState:UIControlStateNormal];
    [_saveButton addTarget:self action:@selector(saveVideoAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_saveButton];
    [self.view bringSubviewToFront:_saveButton];
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

- (void) closeVc{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) saveVideoAction{
    ALAssetsLibrary* _assetLibrary = [[ALAssetsLibrary alloc] init];
    [_assetLibrary writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:_videoPath]
                                      completionBlock:^(NSURL *assetURL, NSError *error1) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"视频保存成功"
                                                        message: @"视频已经保存到相册"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"确认", nil];
        [alert show];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - PBJVideoPlayerControllerDelegate
- (void)videoPlayerReady:(PBJVideoPlayerController *)videoPlayer{
    //NSLog(@"Max duration of the video: %f", videoPlayer.maxDuration);
    [videoPlayer playFromBeginning];
}

- (void)videoPlayerPlaybackStateDidChange:(PBJVideoPlayerController *)videoPlayer{
    NSLog(@"videoPlayerPlaybackStateDidChange:%ld, %ld", videoPlayer.bufferingState, videoPlayer.playbackState);
}

- (void)videoPlayerPlaybackWillStartFromBeginning:(PBJVideoPlayerController *)videoPlayer{
    _playButton.alpha = 1.0f;
    _playButton.hidden = NO;
    
    [UIView animateWithDuration:0.1f animations:^{
        _playButton.alpha = 0.0f;
    } completion:^(BOOL finished) {
        _playButton.hidden = YES;
    }];
}

- (void)videoPlayerPlaybackDidEnd:(PBJVideoPlayerController *)videoPlayer{
    _playButton.hidden = NO;
    
    [UIView animateWithDuration:0.1f animations:^{
        _playButton.alpha = 1.0f;
    } completion:^(BOOL finished) {
    }];
}

- (void)videoPlayerBufferringStateDidChange:(PBJVideoPlayerController *)videoPlayer{
    /*switch (videoPlayer.bufferingState) {
     case PBJVideoPlayerBufferingStateUnknown:
     NSLog(@"Buffering state unknown!");
     break;
     
     case PBJVideoPlayerBufferingStateReady:
     NSLog(@"Buffering state Ready! Video will start/ready playing now.");
     break;
     
     case PBJVideoPlayerBufferingStateDelayed:
     NSLog(@"Buffering state Delayed! Video will pause/stop playing now.");
     break;
     default:
     break;
     }*/
}

- (void)videoPlayer:(PBJVideoPlayerController *)videoPlayer didUpdatePlayBackProgress:(CGFloat)progress {
}

- (CMTime)videoPlayerTimeIntervalForPlaybackProgress:(PBJVideoPlayerController *)videoPlayer {
    return CMTimeMake(5, 25);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
