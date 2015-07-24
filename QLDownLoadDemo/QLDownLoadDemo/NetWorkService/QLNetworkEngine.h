//
//  QLNetworkEngine.h
//  PengBei
//
//  Created by xuqianlong on 15/3/10.
//  Copyright (c) 2015年 夕阳栗子. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QLNetworkEngineHeader.h"

#define __weakSelf__        __weak __typeof(self)weakSelf = self;

@interface QLNetworkEngine : NSObject

FOUNDATION_EXPORT id JSON2Model(id findJson,NSString *modelName);

FOUNDATION_EXPORT NSString * URLJoinedByPath(NSString *apiPath);

//1.0适用于简单的Post请求，成功则回调SuccBlock；
- (void)PostPath:(NSString *)aPath
          parems:(NSDictionary *)param
       SuccBlock:(QLNetworkEngineSuccessBlock)aSuccBlock
     FailedBlock:(QLNetworkEngineFailedJsonBlock)aFailedBlock;

/** 1.1传入Model，自动解析；
 *  param: aPath        url Path
 *  param: param        url param
 *  param: modelName    model name
 *  param: aSuccBlock   reslut JSON --> model instance
 *  param: aFailedBlock failed block revoke error
 */

- (void)PostPath:(NSString *)aPath
          parems:(NSDictionary *)param
 ResultModelName:(NSString *)modelName
       SuccBlock:(QLNetworkEngineModelBlock)aSuccBlock
     FailedBlock:(QLNetworkEngineFailedJsonBlock)aFailedBlock;


/** 1.2支持keyPath；
 *  parem: modelKeyPath 对应的keyPath：aaa/ddd/cc
 *  param: aSuccBlock   model instance,if the modelName isn't nil,when revoke aSuccBlock,resultJson   is HTTPP result JSON,else the resultJson is throw modelKeyPath finded JOSN;
 *  param: aFailedBlock failed block revoke error
 */
- (void)PostPath:(NSString *)aPath
          parems:(NSDictionary *)param
 ResultModelName:(NSString *)modelName
ResultModelKeyPath:(NSString *)modelKeyPath
       SuccBlock:(QLNetworkEngineModelBlock)aSuccBlock
     FailedBlock:(QLNetworkEngineFailedJsonBlock)aFailedBlock;

/** url地址；
 *  parem: modelKeyPath 对应的keyPath：aaa/ddd/cc
 *  param: aSuccBlock   model instance,if the modelName isn't nil,when revoke aSuccBlock,resultJson   is HTTPP result JSON,else the resultJson is throw modelKeyPath finded JOSN;
 *  param: aFailedBlock failed block revoke error
 */

- (void) PostURL:(NSString *)url
          parems:(NSDictionary *)param
 ResultModelName:(NSString *)modelName
ResultModelKeyPath:(NSString *)modelKeyPath
       SuccBlock:(QLNetworkEngineModelBlock)aSuccBlock
     FailedBlock:(QLNetworkEngineFailedJsonBlock)aFailedBlock;

/** 头像上传等
 *  brief:  不使用默认的服务器地址
 *  param: url        Post请求的地址
 *  param: data       文件data
 */
- (void)UploadURLString:(NSString *)url
                   File:(NSString *)filePath
                 parems:(NSDictionary *)param
        ResultModelName:(NSString *)modelName
     ResultModelKeyPath:(NSString *)modelKeyPath
              SuccBlock:(QLNetworkEngineModelBlock)aSuccBlock
            FailedBlock:(QLNetworkEngineFailedJsonBlock)aFailedBlock;

/** 多文件上传
 *  brief: 不使用默认的服务器地址
 *  param: url        Post请求的地址
 *  param: data       文件data
 */
- (void)UploadURLString:(NSString *)url
              FilePaths:(NSArray *)filePaths
                 parems:(NSDictionary *)param
        ResultModelName:(NSString *)modelName
     ResultModelKeyPath:(NSString *)modelKeyPath
              SuccBlock:(QLNetworkEngineModelBlock)aSuccBlock
            FailedBlock:(QLNetworkEngineFailedJsonBlock)aFailedBlock;
@end
