//
//  RMRUser.h
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RMRInstaUser : NSObject

+ (instancetype)userWithExternalReperesantation:(id)exteranlRepresentation;

@property (nonatomic, copy, readonly) NSString *userId;
@property (nonatomic, copy, readonly) NSString *userName;
@property (nonatomic, copy, readonly) NSString *fullName;

@end
