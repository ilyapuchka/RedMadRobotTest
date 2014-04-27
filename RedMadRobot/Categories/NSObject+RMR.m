//
//  NSObject+RMR.m
//  RedMadRobot
//
//  Created by Пучка Илья on 27.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import "NSObject+RMR.h"

@implementation NSObject (RMR)

- (id)rmr_objectForKey:(id)aKey
{
    if ([self isKindOfClass:[NSDictionary class]]) {
        return [(NSDictionary *)self objectForKey:aKey];
    }
    return nil;
}

- (id)rmr_objectForKeyPath:(NSString *)keyPath
{
    __block id result = self;
    NSArray *keyPaths = [keyPath componentsSeparatedByString:@"."];
    [keyPaths enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
        result = [result rmr_objectForKey:key];
    }];
    return result;
}

@end
