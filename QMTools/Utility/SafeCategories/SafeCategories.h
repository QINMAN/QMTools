//
//  SafeCategories.h
//  SouFun
//
//  Created by qinman on 2017/5/22.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (MethodSwizziling)
+ (void)swizzleInstanceSelector:(SEL)originalSelector withSwizzledSelector:(SEL)swizzledSelector;
@end


@interface NSArray (SafeCategory)

@end


@interface NSMutableArray (SafeCategory)

@end


@interface NSDictionary (SafeCategory)

@end

@interface NSMutableDictionary (SafeCategory)

@end
