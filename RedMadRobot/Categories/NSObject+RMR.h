//
//  NSObject+RMR.h
//  RedMadRobot
//
//  Created by Пучка Илья on 27.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (RMR)

- (id)rmr_objectForKey:(id)aKey;
- (id)rmr_objectForKeyPath:(NSString *)keyPath;

@end
