//
//  QMNetWorkService.m
//  CatchCrash
//
//  Created by qinman on 2017/6/14.
//  Copyright © 2017年 qinman. All rights reserved.
//

#import "QMNetWorkService.h"
#import <objc/runtime.h>
#import "MJExtension.h"

@protocol QMNetworkServiceProxy <NSObject>

@optional

/**
 AFN 内部的数据访问方法

 @param method GET/POST
 @param URLString URL
 @param parameters parameters
 @param uploadProgress 上传进度
 @param downloadProgress 下载进度
 @param success 成功回调
 @param failure 失败回调
 @return NSURLSessionDataTask，需要 resume
 */
- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                         success:(void (^)(NSURLSessionDataTask *, id))success
                                         failure:(void (^)(NSURLSessionDataTask *, NSError *))failure;

@end

@interface QMNetWorkService () <QMNetworkServiceProxy>

@end

@implementation QMNetWorkService

+ (instancetype)sharedService {
    static QMNetWorkService *service;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        service = [[[self class] alloc] initWithBaseURL:nil];
//        [service headerField];
    });
    return service;
}

//设置请求头
- (void)headerField {

    //调用以下方法设置请求头
//    [self.requestSerializer setValue:<#(nullable NSString *)#> forHTTPHeaderField:<#(nonnull NSString *)#>];
}

//内部方法，在此方法内进行网络请求
- (void)qm_dataTaskWithHTTPMethod:(NSString *)method
                        URLString:(NSString *)URLString
                       paramaters:(NSMutableDictionary *)paramaters
                        modelName:(NSString *)modelName
                         finished:(QMRequestCallBack)finished {
    
    NSURLSessionDataTask *dataTask = [self dataTaskWithHTTPMethod:method URLString:URLString parameters:paramaters uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask *task, NSString *responseObject) {
        
        id result = [self qm_parseJsonStr:responseObject toModel:modelName];
        finished(result, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        if (error) {
            //记录错误信息
        }
        
        finished(nil, error);
    }];
    
    [dataTask resume];
}

//外部调用的 get 请求
- (void)qm_GET:(NSString *)URLString
    parameters:(NSMutableDictionary *)paramaters
     modelName:(NSString *)modelName
      finished:(QMRequestCallBack)finished {
    
    [self qm_dataTaskWithHTTPMethod:@"GET" URLString:URLString paramaters:paramaters modelName:modelName finished:finished];

}

//外部调用的 post 请求
- (void)qm_POST:(NSString *)URLString
     parameters:(NSMutableDictionary *)paramaters
      modelName:(NSString *)modelName
       finished:(QMRequestCallBack)finished {
    
    [self qm_dataTaskWithHTTPMethod:@"POST" URLString:URLString paramaters:paramaters modelName:modelName finished:finished];

}

- (id)qm_parseJsonStr:(NSString *)jsonStr toModel:(NSString *)modelName {
    
    id result = [objc_getClass([modelName UTF8String]) mj_objectWithKeyValues:jsonStr];
    
    return result;
}

@end
