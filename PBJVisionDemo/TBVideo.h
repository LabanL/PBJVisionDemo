//
//  TBVideo.h
//  PBJVisionDemo
//
//  Created by LabanL on 17/08/2017.
//  Copyright © 2017 Wisesoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WCDB/WCDB.h>
#import "TBBase.h"

@interface TBVideo : TBBase <WCTTableCoding>

@property(nonatomic, assign) int tid;
@property(nonatomic, retain) NSString* videoName;
@property(nonatomic, assign) double videoDuration;
@property(nonatomic, retain) NSString* videoPath;
@property(nonatomic, retain) NSData* thumbImage;
@property(nonatomic, retain) NSData* videoData;

WCDB_PROPERTY(tid)
WCDB_PROPERTY(videoName)
WCDB_PROPERTY(videoDuration)
WCDB_PROPERTY(videoPath)
WCDB_PROPERTY(thumbImage)
WCDB_PROPERTY(videoData)

@end
