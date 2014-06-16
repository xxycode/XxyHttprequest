//
//  XxyHttpRequest.h
//  BestvSoccer
//
//  Created by Apple on 14-6-16.
//  Copyright (c) 2014年 xxy. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^FinishLoadBlock)(NSData *);
typedef void(^FailedBlock)(NSError *);
typedef void(^ProgressBlock)(float);

@interface XxyHttpRequest : NSObject <NSURLConnectionDataDelegate,NSURLConnectionDelegate>
{
    NSMutableData *resData;
    NSURLConnection *connection;
    NSMutableURLRequest *request;
    NSInteger dataTotalSize;
}

@property (nonatomic, strong)FinishLoadBlock finishBlock;
@property (nonatomic, strong)FailedBlock failedBlock;
@property (nonatomic, strong)ProgressBlock progressBlock;

- (void)startAsyncWithUrl:(NSURL *)url;
- (void)startAsyncWithUrl:(NSURL *)url postData:(NSDictionary *)dic;
- (void)startAsyncWithUrl:(NSURL *)url postData:(NSDictionary *)dic name:(NSString *)name;

@end
