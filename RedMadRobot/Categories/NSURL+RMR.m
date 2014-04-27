//
//  NSURL+RMR.m
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import "NSURL+RMR.h"

static NSString * const kRMRCharactersToEscape = @":/?&=;+!@#$()',*";
static NSString * const kRMRCharactersToNotEscape = @"[].";

@implementation NSURL (RMR)

+ (NSURL *)rmr_URLWithString:(NSString *)string
{
    if ([string isKindOfClass:[NSString class]]) {
        return [NSURL URLWithString:string];
    }
    return nil;
}

- (NSURL *)rmr_initWithScheme:(NSString *)scheme host:(NSString *)host path:(NSString *)path query:(NSDictionary *)query
{
    NSString *fullPath = [path stringByAppendingFormat:@"?%@", RMRPercentEscapedQueryParameters(query)];
    return [[NSURL alloc] initWithScheme:scheme host:host path:fullPath];
}

static NSString *RMRPercentEscapedQueryParameters(NSDictionary *parameters)
{
    NSMutableArray *parametersPairs = [@[] mutableCopy];
    [parameters enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *string = RMRURLEncodeValueForKey([obj description], [key description]);
        if (string) {
            [parametersPairs addObject:string];
        }
    }];
    return [parametersPairs componentsJoinedByString:@"&"];
}

static NSString *RMRURLEncodeValueForKey(NSString *value, NSString *key)
{
    if ([key isKindOfClass:[NSString class]] && [value isKindOfClass:[NSString class]]) {
        NSString *string = [NSString stringWithFormat:@"%@=%@", RMRURLEncodedString(key), RMRURLEncodedString(value)];
        return string;
    }
    return nil;
}

static NSString *RMRURLEncodedString(NSString *string)
{
    CFStringEncoding encoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
    CFStringRef stringRef = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                    (__bridge CFStringRef)string,
                                                                    (__bridge CFStringRef)kRMRCharactersToNotEscape,
                                                                    (__bridge CFStringRef)kRMRCharactersToEscape,
                                                                     encoding);
    return (__bridge_transfer  NSString *)stringRef;
}

@end
