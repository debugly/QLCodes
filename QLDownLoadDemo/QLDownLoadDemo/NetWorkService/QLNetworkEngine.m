//
//  QLNetworkEngine.m
//  PengBei
//
//  Created by xuqianlong on 15/3/10.
//  Copyright (c) 2015年 夕阳栗子. All rights reserved.
//

#import "QLNetworkEngine.h"
#import "YQBaseModel.h"
#import "AFNetworking.h"

//https://github.com/AFNetworking/AFNetworking
//http://nshipster.com/afnetworking-2/

#define kNetworkLocation       @"http://192.168.0.117:8888/index.php"
#define kNetworkRequestTimeOutInSeconds 25

@implementation QLNetworkEngine

static AFHTTPSessionManager *afSection;

- (instancetype)init
{
    self = [super init];
    if (self) {
        @synchronized(self){
            if(!afSection){
                NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
                cfg.timeoutIntervalForRequest = kNetworkRequestTimeOutInSeconds;
                afSection = [[AFHTTPSessionManager alloc]initWithBaseURL:nil sessionConfiguration:cfg];
            }
        }
        //        子类是单利的，到这就死这了；
//        static dispatch_once_t onceToken;
//        static QLNetworkEngine *instance;
//        dispatch_once(&onceToken, ^{
//            instance = [[[self class]alloc]init];
//            
//        });
    }
    return self;
}

#pragma mark - - util

static id findJSONwithKeyPath(NSString *keyPath,NSDictionary *JSON)
{
    if (!keyPath || keyPath.length == 0) {
        return JSON;
    }
    NSArray *pathArr = [keyPath componentsSeparatedByString:@"/"];
    
    return findJSONwithKeyPathArr(pathArr, JSON);
}

static id findJSONwithKeyPathArr(NSArray *pathArr,NSDictionary *JSON)
{
    if (!JSON) {
        return nil;
    }
    if (!pathArr || pathArr.count == 0) {
        return JSON;
    }
    NSMutableArray *pathArr2 = [NSMutableArray arrayWithArray:pathArr];
    
    while ([pathArr2 firstObject] && [[pathArr2 firstObject] description].length == 0) {
        [pathArr2 removeObjectAtIndex:0];
    }
    if ([pathArr2 firstObject]) {
        JSON = [JSON objectForKey:[pathArr2 firstObject]];
        [pathArr2 removeObjectAtIndex:0];
        return findJSONwithKeyPathArr(pathArr2, JSON);
    }else{
        return JSON;
    }
}

id JSON2Model(id findJson,NSString *modelName)
{
    Class clazz = NSClassFromString(modelName);
    id model = nil;
    if ([findJson isKindOfClass:[NSDictionary class]]) {
        model = [clazz instanceFormDic:findJson];
    }else if([findJson isKindOfClass:[NSArray class]]){
        model = [clazz instanceArrFormArray:findJson];
    }
    return model;
}

NSString * URLJoinedByPath(NSString *apiPath)
{
    NSString *location = kNetworkLocation;
    NSString *scheme = @"";
    if (![location hasPrefix:@"http://"]) {
        scheme = @"http://";
    }
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"%@%@",scheme,location];
    
    if(apiPath)
        [urlString appendFormat:@"%@",apiPath];
    
    return [urlString copy];
    
}

- (BOOL)checkNetConnectStatus:(QLNetworkEngineFailedJsonBlock)aFailedBlock
{
    if([afSection.reachabilityManager isCanReachable]){
        return YES;
    }else{
        if(aFailedBlock){
            NSError *error = [NSError errorWithDomain:@"com.pengbei.me" code:kNetworkNetErrorCode userInfo:@{NSLocalizedDescriptionKey:kNetworkNetErrorTrip}];
            aFailedBlock(error,nil);
        }
        return NO;
    }
}

- (void)handleSuccessJSON:(id)json
                    error:(NSError *)error
          ResultModelName:(NSString *)modelName
       ResultModelKeyPath:(NSString *)modelKeyPath
                SuccBlock:(QLNetworkEngineModelBlock)aSuccBlock
              FailedBlock:(QLNetworkEngineFailedJsonBlock)aFailedBlock
{
    if (error || !json) {
        if(aFailedBlock){
            aFailedBlock(error,nil);
        }
    }else{
        if(aSuccBlock){
            //                找到keypath对应的JSON；
            id findJson = findJSONwithKeyPath(modelKeyPath, json);
            if(!findJson){
                // keyPath找不到内容；
                aSuccBlock(nil,nil);
            }
            if (modelName && modelName.length > 0) {
                id model = JSON2Model(findJson,modelName);
                aSuccBlock(model,json);
            }else{
                aSuccBlock(nil,findJson);
            }
        }
    }
}

#pragma mark - - POST

- (void)PostPath:(NSString *)aPath parems:(NSDictionary *)param SuccBlock:(QLNetworkEngineSuccessBlock)aSuccBlock FailedBlock:(QLNetworkEngineFailedJsonBlock)aFailedBlock
{
    [self PostPath:aPath parems:param ResultModelName:nil SuccBlock:^(id models, NSDictionary *result) {
        if (aSuccBlock) {
            aSuccBlock(result);
        }
    } FailedBlock:aFailedBlock];
}

- (void)PostPath:(NSString *)aPath
          parems:(NSDictionary *)param
 ResultModelName:(NSString *)modelName
       SuccBlock:(QLNetworkEngineModelBlock)aSuccBlock
     FailedBlock:(QLNetworkEngineFailedJsonBlock)aFailedBlock
{
    [self PostPath:aPath parems:param ResultModelName:modelName ResultModelKeyPath:nil SuccBlock:aSuccBlock FailedBlock:aFailedBlock];
}

- (void) PostPath:(NSString *)aPath
           parems:(NSDictionary *)param
  ResultModelName:(NSString *)modelName
ResultModelKeyPath:(NSString *)modelKeyPath
        SuccBlock:(QLNetworkEngineModelBlock)aSuccBlock
      FailedBlock:(QLNetworkEngineFailedJsonBlock)aFailedBlock
{
    NSString *url = URLJoinedByPath(aPath);
    
    [self PostURL:url parems:param ResultModelName:modelName ResultModelKeyPath:modelKeyPath SuccBlock:aSuccBlock FailedBlock:aFailedBlock];
}

- (void) PostURL:(NSString *)url
           parems:(NSDictionary *)param
  ResultModelName:(NSString *)modelName
ResultModelKeyPath:(NSString *)modelKeyPath
        SuccBlock:(QLNetworkEngineModelBlock)aSuccBlock
      FailedBlock:(QLNetworkEngineFailedJsonBlock)aFailedBlock
{
    if ([self checkNetConnectStatus:aFailedBlock]) {
        __weakSelf__
        [afSection POST:url parameters:param success:^(NSURLSessionDataTask *task, id json) {
            [weakSelf handleSuccessJSON:json error:nil ResultModelName:modelName ResultModelKeyPath:modelKeyPath SuccBlock:aSuccBlock FailedBlock:aFailedBlock];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            if(aFailedBlock){
                aFailedBlock(error,nil);
            }
        }];
    }
}

- (void)UploadURLString:(NSString *)url
                 File:(NSString *)filePath
               parems:(NSDictionary *)param
      ResultModelName:(NSString *)modelName
   ResultModelKeyPath:(NSString *)modelKeyPath
            SuccBlock:(QLNetworkEngineModelBlock)aSuccBlock
          FailedBlock:(QLNetworkEngineFailedJsonBlock)aFailedBlock
{
    [self UploadURLString:url FilePaths:@[filePath] parems:param ResultModelName:modelName ResultModelKeyPath:modelKeyPath SuccBlock:aSuccBlock FailedBlock:aFailedBlock];
}

- (void)UploadURLString:(NSString *)url
            FilePaths:(NSArray *)filePaths
               parems:(NSDictionary *)param
      ResultModelName:(NSString *)modelName
   ResultModelKeyPath:(NSString *)modelKeyPath
            SuccBlock:(QLNetworkEngineModelBlock)aSuccBlock
FailedBlock:(QLNetworkEngineFailedJsonBlock)aFailedBlock
{
    if([self checkNetConnectStatus:aFailedBlock]){
        NSError *r_error = nil;
        NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:url parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for (int i = 0; i < filePaths.count; i ++) {
                NSString *filePath = filePaths[i];
                NSString *dataKey = [NSString stringWithFormat:@"head%@",(i!=0)?@(i):@""];
                [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:dataKey fileName:[filePath lastPathComponent] mimeType:@"image/jpeg" error:nil];
            }
        } error:&r_error];
        if (!r_error) {
            NSProgress *progress = nil;
            __weakSelf__
            NSURLSessionUploadTask *uploadTask = [afSection uploadTaskWithStreamedRequest:request progress:&progress completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
                [weakSelf handleSuccessJSON:responseObject error:error ResultModelName:nil ResultModelKeyPath:nil SuccBlock:aSuccBlock FailedBlock:aFailedBlock];
            }];
            [uploadTask resume];
        }else if(aFailedBlock){
            aFailedBlock(r_error,nil);
        }
    }
}

@end

