//
//  NSURL+RMR.h
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (RMR)

- (NSURL *)rmr_initWithScheme:(NSString *)scheme
                         host:(NSString *)host
                         path:(NSString *)path
                        query:(NSDictionary *)query;

+ (NSURL *)rmr_URLWithString:(NSString *)string;

@end
