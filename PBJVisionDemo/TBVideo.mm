//
//  TBVideo.m
//  PBJVisionDemo
//
//  Created by LabanL on 17/08/2017.
//  Copyright © 2017 Wisesoft. All rights reserved.
//

#import "TBVideo.h"

@implementation TBVideo

@synthesize tid;
@synthesize videoName;
@synthesize videoDuration;
@synthesize videoPath;
@synthesize thumbImage;
@synthesize videoData;

//The order of the definitions is the order of the fields in the database
WCDB_IMPLEMENTATION(TBVideo)

WCDB_SYNTHESIZE(TBVideo, tid)
WCDB_SYNTHESIZE(TBVideo, videoName)
WCDB_SYNTHESIZE(TBVideo, videoDuration)
WCDB_SYNTHESIZE(TBVideo, videoPath)
WCDB_SYNTHESIZE(TBVideo, thumbImage)
WCDB_SYNTHESIZE(TBVideo, videoData)

WCDB_PRIMARY_AUTO_INCREMENT(TBVideo, tid)

+ (NSString*) tableName{
    return @"tb_video";
}

@end
