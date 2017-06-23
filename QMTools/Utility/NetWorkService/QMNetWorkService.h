//
//  QMNetWorkService.h
//  CatchCrash
//
//  Created by qinman on 2017/6/14.
//  Copyright © 2017年 qinman. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

typedef void(^QMRequestCallBack)(id result, NSError *error);

@interface QMNetWorkService : AFHTTPSessionManager

+ (instancetype)sharedService;

/**
 GET 请求
 
 @param URLString URLString
 @param paramaters parameters
 @param modelName modelName
 @param finished 回调
 */
- (void)qm_GET:(NSString *)URLString
    parameters:(NSMutableDictionary *)paramaters
     modelName:(NSString *)modelName
      finished:(QMRequestCallBack)finished;


/**
 POST 请求

 @param URLString URLString
 @param paramaters parameters
 @param modelName modelName
 @param finished 回调
 */
- (void)qm_POST:(NSString *)URLString
     parameters:(NSMutableDictionary *)paramaters
      modelName:(NSString *)modelName
       finished:(QMRequestCallBack)finished;


@end
