//
//  DBHelper.m
//  PBJVisionDemo
//
//  Created by LabanL on 17/08/2017.
//  Copyright © 2017 Wisesoft. All rights reserved.
//

#import "DBHelper.h"

static NSString* PJBDataBasePath = @"";
static WCTDatabase* db;

@implementation DBHelper

+ (DBHelper*) sharedHelper{
    static DBHelper *sharedHelperInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedHelperInstance = [[self alloc] init];
        [sharedHelperInstance initHelper];
    });
    return sharedHelperInstance;
}

- (void) initHelper{
    PJBDataBasePath = [[NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:PJBDataBaseName];
    
    db = [[WCTDatabase alloc] initWithPath:PJBDataBasePath];
    NSData *password = [PJBDataBasePassword dataUsingEncoding:NSASCIIStringEncoding];
    [db setCipherKey:password];
    
    [db createTableAndIndexesOfName:TBVideo.tableName withClass:TBVideo.class];
}

+ (WCTDatabase*) sharedDB{
    if(db == nil){
        [[DBHelper sharedHelper] initHelper];
    }
    return db;
}

@end
