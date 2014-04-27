//
//  RMRUser.m
//  RedMadRobot
//
//  Created by Пучка Илья on 25.04.14.
//  Copyright (c) 2014 Пучка Илья. All rights reserved.
//

#import "RMRInstaUser.h"

@interface RMRInstaUser()

@property (nonatomic, copy, readwrite) NSString *userId;
@property (nonatomic, copy, readwrite) NSString *userName;
@property (nonatomic, copy, readwrite) NSString *fullName;

@end

@implementation RMRInstaUser

+ (instancetype)userWithExternalReperesantation:(id)exteranlRepresentation
{
    if ([exteranlRepresentation isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)exteranlRepresentation;
        RMRInstaUser *user = [RMRInstaUser new];
        [self fill:&user withDictionary:dict];
        return user;
    }
    return nil;
}

+ (void)fill:(RMRInstaUser *__autoreleasing*)user withDictionary:(NSDictionary *)dict
{
    if (!user) return;
    RMRInstaUser *_user = *user;
    _user.userId = dict[@"id"];
    _user.userName = dict[@"username"];
    _user.fullName = dict[@"full_name"];
}

@end
