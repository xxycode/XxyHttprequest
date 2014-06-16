//
//  XxyHttpRequest.m
//  BestvSoccer
//
//  Created by Apple on 14-6-16.
//  Copyright (c) 2014年 xxy. All rights reserved.
//

#import "XxyHttpRequest.h"
#import <UIKit/UIKit.h>
#define kPicName @"myPic"

@implementation XxyHttpRequest 

- (id)init
{
    self = [super init];
    request = [[NSMutableURLRequest alloc] init];
    return self;
}

- (void)startAsyncWithUrl:(NSURL *)url
{
    [request setURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    resData = [[NSMutableData alloc] init];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [request setTimeoutInterval:60];
    [connection start];
}

- (void)startAsyncWithUrl:(NSURL *)url postData:(NSDictionary *)dic
{
    NSArray *keyArr = [dic allKeys];
    NSArray *valueArr = [dic allValues];
    NSMutableString *postStr = [[NSMutableString alloc] init];
    for (int i = 0; i < [dic count]; i ++) {
        NSString *key = [keyArr objectAtIndex:i];
        NSString *value = [valueArr objectAtIndex:i];
        if (i == 0) {
            [postStr appendFormat:@"%@=%@",key,[self urlEncode:value]];
        } else {
            [postStr appendFormat:@"&%@=%@",key,[self urlEncode:value]];
        }
    }
    NSLog(@"%@",postStr);
    NSData *postData = [[postStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]dataUsingEncoding:NSUTF8StringEncoding];
    NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
    [request setURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    resData = [[NSMutableData alloc] init];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [request setTimeoutInterval:60];
    [connection start];
}

- (NSString*)urlEncode:(NSString *)str
{
    NSString *resultStr = str;
    CFStringRef originalString = CFBridgingRetain(str);
    CFStringRef leaveUnescaped = CFSTR(" ");
    CFStringRef forceEscaped = CFSTR("!*'();:@&=+$,/?%#[]");
    CFStringRef escapedStr;
    escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                         originalString,
                                                         leaveUnescaped,
                                                         forceEscaped,
                                                         kCFStringEncodingUTF8);
    
    if( escapedStr )
    {
        NSMutableString *mutableStr = [NSMutableString stringWithString:(NSString *)CFBridgingRelease(escapedStr)];
        [mutableStr replaceOccurrencesOfString:@" "
                                    withString:@"%20"
                                       options:0
                                         range:NSMakeRange(0, [mutableStr length])];
        resultStr = mutableStr;
    }
    return resultStr;
}

- (void)startAsyncWithUrl:(NSURL *)url postData:(NSDictionary *)params name:(NSString *)name;
{
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    if (request == nil) {
        request = [[NSMutableURLRequest alloc] init];
    }
    [request setURL:url];
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    UIImage *image=[params objectForKey:@"pic"];
    NSData* data = UIImagePNGRepresentation(image);
    NSString *imgType = [XxyHttpRequest typeForImageData:data];
    NSMutableString *body=[[NSMutableString alloc]init];
    NSArray *keys= [params allKeys];
    for(int i=0;i<[keys count];i++)
    {
        NSString *key=[keys objectAtIndex:i];
        if(![key isEqualToString:@"pic"])
        {
            [body appendFormat:@"%@\r\n",MPboundary];
            [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
            [body appendFormat:@"%@\r\n",[params objectForKey:key]];
        }
    }
    [body appendFormat:@"%@\r\n",MPboundary];
    NSArray *imgT = [imgType componentsSeparatedByString:@"/"];
    NSString *suffixName = [imgT objectAtIndex:1];
    NSString *fileName = [NSString stringWithFormat:@"%@.%@",kPicName,suffixName];
    NSLog(@"%@",fileName);
    NSString *contentDis = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",name,fileName];
    [body appendString:contentDis];
    [body appendFormat:@"Content-Type: %@\r\n\r\n",imgType];
    NSString *end=[[NSString alloc]initWithFormat:@"\r\n%@",endMPboundary];
    NSMutableData *myRequestData=[NSMutableData data];
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    [myRequestData appendData:data];
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:myRequestData];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:60];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    resData = [[NSMutableData alloc] init];
    [connection start];
}

+ (NSString *)typeForImageData:(NSData *)data {
    
    
    uint8_t c;
    [data getBytes:&c length:1];
    
    switch (c) {
        case 0xFF:
            return @"image/jpeg";
        case 0x89:
            return @"image/png";
        case 0x47:
            return @"image/gif";
        case 0x49:
        case 0x4D:
            return @"image/tiff";
    }
    return nil;
}
#pragma mark NSconnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [resData appendData:data];
    float currPercent = ([resData length] * 1.0)/dataTotalSize;
    _progressBlock(currPercent);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    _finishBlock(resData);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    _failedBlock(error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if(httpResponse && [httpResponse respondsToSelector:@selector(allHeaderFields)]){
        NSDictionary *httpResponseHeaderFields = [httpResponse allHeaderFields];
        
        dataTotalSize = [[httpResponseHeaderFields objectForKey:@"Content-Length"] integerValue];
    }
}

@end
