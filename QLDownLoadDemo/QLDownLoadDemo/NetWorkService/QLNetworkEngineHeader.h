//
//  QLNetworkEngineHeader.h
//  PengBei
//
//  Created by xuqianlong on 15/3/27.
//  Copyright (c) 2015年 夕阳栗子. All rights reserved.
//

#ifndef PengBei_QLNetworkEngineHeader_h
#define PengBei_QLNetworkEngineHeader_h

typedef void(^YQHttpServiceResultBlock)(bool isTrue,NSDictionary *resultJson,id models);
typedef void(^QLNetworkEngineBoolBlock)(bool isTrue,NSDictionary *json);

typedef void(^QLNetworkEngineVoidBlock)(void);
typedef void(^QLNetworkEngineIDSuccessBlock)(id result);
typedef void(^QLNetworkEngineSuccessBlock)(NSDictionary *json);
typedef void(^QLNetworkEngineModelBlock)(id models,id resultJson);
typedef void(^QLNetworkEngine2ModelBlock)(id models1,id models2,id resultJson);
typedef void(^QLNetworkEngineFailedBlock) (NSError *error);
//需要使用page；
typedef void(^QLNetworkEngineFailedJsonBlock) (NSError *error,id resultJson);

#define kNetworkDataErrorCode 1400004
#define kNetworkDataErrorTrip @"暂无数据"

#define kNetworkNetErrorCode  1400005
#define kNetworkNetErrorTrip  @"网络未连接，请连接后重试"

#define kAccessTokenErrorCode 1400006
#define kAccessTokenErrorTrip @"您的登录信息发生变化，需要重新登录"

#define kPrepareRequestFailedErrorCode 8300006
#define kPrepareRequestFailedErrorTrip @"哦，NO..."

#define kSystemErrorCode 2900006
#define kSystemErrorTrip @"系统错误，不允许继续使用"

#endif
