//
//  VideoCell.h
//  PBJVisionDemo
//
//  Created by LabanL on 17/08/2017.
//  Copyright © 2017 Wisesoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TBVideo.h"
static NSString* const VideoCellReuseIdentifier = @"VideoCellReuseIdentifier";

@interface VideoCell : UICollectionViewCell

@property (nonatomic, retain) TBVideo* video;

@end
