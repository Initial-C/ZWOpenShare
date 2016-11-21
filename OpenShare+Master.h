//
//  OpenShare+Master.h
//  LoginRegisterModule
//
//  Created by InitialC on 16/11/21.
//  Copyright © 2016年 InitialC. All rights reserved.
//

#import "OpenShare.h"
#import <UIKit/UIKit.h>

@interface OpenShare (Master)

/**
 *  登录到第三方平台
 *
 *  @param type     平台类型
 *  @param block 完成后的代理，成功后会返回用户信息，失败后会返回失败信息
 */
+ (void)loginWithPlatformType:(OSThirdPlatformType)type withBlock:(void (^)(NSDictionary *message, NSError *error))block;

@end
