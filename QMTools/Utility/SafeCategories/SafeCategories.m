//
//  SafeCategories.h.m
//  SouFun
//
//  Created by qinman on 2017/5/22.
//
//

#import "SafeCategories.h"
#import <objc/runtime.h>
#define AvoidCrashSeparator         @"================================================================"
#define AvoidCrashSeparatorWithFlag @"========================AvoidCrash Log=========================="
#define key_errorName        @"errorName"
#define key_errorReason      @"errorReason"
#define key_errorPlace       @"errorPlace"
#define key_defaultToDo      @"defaultToDo"
#define key_callStackSymbols @"callStackSymbols"
#define key_exception        @"exception"
#define AvoidCrashNotification @"AvoidCrashNotification"

@implementation NSObject (MethodSwizziling)
+ (void)swizzleInstanceSelector:(SEL)originalSelector withSwizzledSelector:(SEL)swizzledSelector
{
    Class class = [self class];
    
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    // 若已经存在，则添加会失败
    
    BOOL didAddMethod = class_addMethod(class,originalSelector,
                                        
                                        method_getImplementation(swizzledMethod),
                                        
                                        method_getTypeEncoding(swizzledMethod));
    
    // 若原来的方法并不存在，则添加即可
    
    if (didAddMethod) {
        //swizzledSelector == hhaha_viewwillapprer
        class_replaceMethod(class,swizzledSelector,
                            
                            method_getImplementation(originalMethod),
                            
                            method_getTypeEncoding(originalMethod));
        
    } else {
        
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}
@end


@implementation NSArray (SafeCategory)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [objc_getClass("__NSArrayI") swizzleInstanceSelector:@selector(objectAtIndex:) withSwizzledSelector:@selector(safeI_ObjectAtIndex:)];
        [objc_getClass("__NSArray0") swizzleInstanceSelector:@selector(objectAtIndex:) withSwizzledSelector:@selector(safe0_ObjectAtIndex:)];
        [objc_getClass("__NSPlaceholderArray") swizzleInstanceSelector:@selector(initWithObjects:count:) withSwizzledSelector:@selector(safe_initWithObjects:count:)];
        
    });
}
- (instancetype)safe_initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt{
    
    id instance = nil;
    
    //以下是对错误数据的处理，把为nil的数据去掉,然后初始化数组
    NSInteger newObjsIndex = 0;
    id  _Nonnull __unsafe_unretained newObjects[cnt];
    
    for (int i = 0; i < cnt; i++) {
        if (objects[i]) {
            newObjects[newObjsIndex] = objects[i];
            newObjsIndex ++;
        }else{
            NSAssert(objects[i], @"*** object is nil ***");
        }
    }
    
    instance = [self safe_initWithObjects:newObjects count:newObjsIndex];
    
    return instance;
}
- (id)safeI_ObjectAtIndex:(NSUInteger)index {
    if (self.count == 0) {
        NSAssert(NO, @"*** Array is empty ***");
        return nil;
    }
    if (index >= self.count) {
        NSAssert(NO, @"*** index out of bound ***");
        return nil;
    }
    return [self safeI_ObjectAtIndex:index];
}
- (id)safe0_ObjectAtIndex:(NSUInteger)index {
    if (self.count == 0) {
        NSAssert(NO, @"*** Array is empty ***");
        return nil;
    }
    if (index >= self.count) {
        NSAssert(NO, @"*** index out of bound ***");
        return nil;
    }
    return [self safe0_ObjectAtIndex:index];
}

@end


@implementation NSMutableArray (SafeCategory)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [objc_getClass("__NSArrayM") swizzleInstanceSelector:@selector(addObject:) withSwizzledSelector:@selector(safe_AddObject:)];
        [objc_getClass("__NSArrayM") swizzleInstanceSelector:@selector(removeObjectAtIndex:) withSwizzledSelector:@selector(safe_RemoveObjectAtIndex:)];
        [objc_getClass("__NSArrayM") swizzleInstanceSelector:@selector(insertObject:atIndex:) withSwizzledSelector:@selector(safe_InsertObject:atIndex:)];
        [objc_getClass("__NSArrayM") swizzleInstanceSelector:@selector(objectAtIndex:) withSwizzledSelector:@selector(safeM_ObjectAtIndex:)];
    });
}

- (void)safe_AddObject:(id)obj {
    if (!obj) {
        NSAssert(obj, @"***object cannot be nil ***");
    } else {
        [self safe_AddObject:obj];
    }
}

- (void)safe_InsertObject:(id)anObject atIndex:(NSUInteger)index {
    if (!anObject) {
        NSAssert(anObject, @"***object cannot be nil ***");
    } else if (index > self.count) {
        NSAssert(NO, @"*** index out of bound ***");
    } else {
        [self safe_InsertObject:anObject atIndex:index];
    }
}

- (id)safeM_ObjectAtIndex:(NSUInteger)index {
    if (self.count == 0) {
        NSAssert(NO, @"*** Array is empty ***");
        return nil;
    }
    if (index >= self.count) {
        NSAssert(NO, @"*** index out of bound ***");
        return nil;
    }
    return [self safeM_ObjectAtIndex:index];
}

- (void)safe_RemoveObjectAtIndex:(NSUInteger)index {
    
    if (index >= self.count||self.count <= 0) {
        NSAssert(NO, @"*** index out of bound ***");
        return;
    }
    [self safe_RemoveObjectAtIndex:index];
}

@end

@implementation NSDictionary (SafeCategory)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [objc_getClass("__NSPlaceholderDictionary") swizzleInstanceSelector:@selector(initWithObjects:forKeys:count:) withSwizzledSelector:@selector(safe_initWithObjects:forKeys:count:)];
        [objc_getClass("__NSSingleEntryDictionaryI") swizzleInstanceSelector:@selector(objectForKey:) withSwizzledSelector:@selector(safe_objectForKey:)];
    });
}
- (instancetype)safe_initWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt{
    
    id instance = nil;
    
    //以下是对错误数据的处理，把为nil的数据去掉,然后初始化字典
    NSInteger newObjsIndex = 0;
    id  _Nonnull __unsafe_unretained newObjects[cnt];
    id  _Nonnull __unsafe_unretained newkeys[cnt];
    
    for (int i = 0; i < cnt; i++) {
        if (objects[i]&&keys[i]) {
            newObjects[newObjsIndex] = objects[i];
            newkeys[newObjsIndex] = keys[i];
            newObjsIndex ++;
        }else if(!keys[i]){
            NSAssert(keys[i],@"removed nil key-value because key is nil");
        }else{
            NSAssert(objects[i], @"removed nil key-value because value is nil");
        }
    }
    
    instance = [self safe_initWithObjects:newObjects forKeys:newkeys count:newObjsIndex];
    
    return instance;
}

- (id)safe_objectForKey:(id<NSCopying>)aKey
{
    id object = [self safe_objectForKey:aKey];
    if([object isKindOfClass:[NSNull class]]){
        return nil;
    }else{
        return object;
    }
}

@end

@implementation NSMutableDictionary (SafeCategory)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        [objc_getClass("__NSDictionaryM") swizzleInstanceSelector:@selector(setObject:forKey:) withSwizzledSelector:@selector(safe_setObject:forKey:)];
        [objc_getClass("__NSDictionaryM") swizzleInstanceSelector:@selector(objectForKey:) withSwizzledSelector:@selector(safe_MutableobjectForKey:)];
    });
}
- (void)safe_setObject:(id)anObject forKey:(id<NSCopying>)aKey{
    if (!anObject) {
        NSString *str = [NSString stringWithFormat:@"*** setObjectForKey: object cannot be nil forKey:%@",aKey];
        NSAssert(anObject,str);
        return;
    }else if(!aKey){
        NSAssert(aKey,@"*** setObjectForKey: key cannot be nil");
        return;
    }
    
    [self safe_setObject:anObject forKey:aKey];
}
- (id)safe_MutableobjectForKey:(id<NSCopying>)aKey
{
    id object = [self safe_MutableobjectForKey:aKey];
    if([object isKindOfClass:[NSNull class]]){
        return nil;
    }else{
        return object;
    }
}

@end
