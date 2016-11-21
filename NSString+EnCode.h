//
//  NSString+EnCode.h
//  LoginRegisterModule
//
//  Created by InitialC on 16/11/21.
//  Copyright © 2016年 InitialC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (EnCode)

/// 将字符串进行Url编码
- (NSString *)encodeURL;

/// 将字符串进行Hash
- (NSString *)hmacSha1WithKey:(NSString *)key;


@end
