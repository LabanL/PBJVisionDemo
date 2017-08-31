//
//  VideoCell.m
//  PBJVisionDemo
//
//  Created by LabanL on 17/08/2017.
//  Copyright © 2017 Wisesoft. All rights reserved.
//

#import "VideoCell.h"
#import <Masonry/Masonry.h>

@interface VideoCell()

@property (nonatomic, retain) UIImageView* videoThumbImageView;
@property (nonatomic, retain) UILabel* nameLabel;

@end

@implementation VideoCell

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setup];
    }
    return self;
}

- (void) setup{
    _videoThumbImageView = [UIImageView new];
    [self.contentView addSubview:_videoThumbImageView];
    _videoThumbImageView.layer.cornerRadius = 4;
    _videoThumbImageView.clipsToBounds = YES;
    _videoThumbImageView.backgroundColor = [UIColor blackColor];
    _videoThumbImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_videoThumbImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView.mas_left).offset(6);
        make.top.equalTo(self.contentView.mas_top).offset(6);
        make.right.equalTo(self.contentView.mas_right).offset(-6);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-6);
    }];
    
    UIImageView* iconImageView= [UIImageView new];
    [self.contentView addSubview:iconImageView];
    [iconImageView setImage:[UIImage imageNamed:@"ic_video"]];
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.height.mas_equalTo(48);
        make.width.mas_equalTo(48);
    }];
    
    _nameLabel = [UILabel new];
    [self.contentView addSubview:_nameLabel];
    _nameLabel.font = [UIFont systemFontOfSize:12.0];
    _nameLabel.textColor = [UIColor whiteColor];
    _nameLabel.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.6];
    _nameLabel.layer.cornerRadius = 4;
    _nameLabel.clipsToBounds = YES;
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_videoThumbImageView.mas_left);
        make.right.equalTo(_videoThumbImageView.mas_right);
        make.bottom.equalTo(_videoThumbImageView.mas_bottom);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void) setVideo:(TBVideo *)video{
    if(video.thumbImage){
        [_videoThumbImageView setImage:[UIImage imageWithData:video.thumbImage]];
    }
    
    _nameLabel.text = [NSString stringWithFormat:@" %.f' %@ %@",video.videoDuration, [self dataSizeStr:video.videoData], video.videoName];
}

- (NSString*) dataSizeStr:(NSData*)data{
    NSUInteger length = data.length;
    
    if(length > 1024){
        NSUInteger kbLength = length / 1024;
        if(kbLength > 1024){
            CGFloat mbLength = kbLength / 1024.0;
            return [NSString stringWithFormat:@"%.2f MB", mbLength];
        }else{
            return [NSString stringWithFormat:@"%ld KB", kbLength];
        }
    }else{
        return [NSString stringWithFormat:@"%ld Byte", length];
    }
}

@end
