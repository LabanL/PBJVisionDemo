//
//  DBHelper.h
//  PBJVisionDemo
//
//  Created by LabanL on 17/08/2017.
//  Copyright © 2017 Wisesoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WCDB/WCDB.h>
#import "TBVideo.h"

#define PJBDataBaseVersionCode 0   //当前的数据库版本
#define PJBDataBaseName @"pjbvision_demo.db"
#define PJBDataBasePassword @"PJBVisionDemo"

@interface DBHelper : NSObject

+ (DBHelper*) sharedHelper;
+ (WCTDatabase*) sharedDB;

@end
