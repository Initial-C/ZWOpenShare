//
//  OpenShare+Master.m
//  LoginRegisterModule
//
//  Created by InitialC on 16/11/21.
//  Copyright © 2016年 InitialC. All rights reserved.
//

#import "OpenShare+Master.h"
#import "OpenShare+QQ.h"
#import "OpenShare+Weixin.h"
#import "OpenShare+Weibo.m"
#import "OpenShare+Networking.h"
#import "NSString+EnCode.h"

@implementation OpenShare (Master)

+ (void)loginWithPlatformType:(OSThirdPlatformType)type withBlock:(void (^)(NSDictionary *, NSError *))block {
    if (type == OSThirdPlatformTypeQQ) {
        [OpenShare QQAuth:@"get_user_info,get_simple_userinfo,get_info" Success:^(NSDictionary *message) {
//            NSLog(@"QQ登录成功%@", message);
            [OpenShare qqOAuthWithMessage:message completionHandle:block];
            
        } Fail:^(NSDictionary *message, NSError *error) {
            if (block) {
                block(message, error);
//                NSLog(@"QQ登录失败%@---%@", message, error);
            }
        }];
    } else if (type == OSThirdPlatformTypeWeixin) {
        [OpenShare WeixinAuth:@"snsapi_userinfo" Success:^(NSDictionary *message) {
//            NSLog(@"微信登录成功%@", message);
            [OpenShare weixinOAuthWithMessage:message completionHandle:block];
        } Fail:^(NSDictionary *message, NSError *error) {
            if (block) {
                block(message, error);
//                NSLog(@"微信登录失败%@---%@", message, error);
            }
        }];
        
    } else if (type == OSThirdPlatformTypeWeibo) {
        NSString *redirectURI = [[NSUserDefaults standardUserDefaults] objectForKey:kOSPlatformWeiboRedirectURIKey];
        [OpenShare WeiboAuth:@"all" redirectURI:redirectURI Success:^(NSDictionary *message) {
//            NSLog(@"微博登录成功%@", message);
            [OpenShare weiboOAuthWithMessage:message completionHandle:block];
        } Fail:^(NSDictionary *message, NSError *error) {
            if (block) {
                block(message, error);
//                NSLog(@"微博登录失败%@---%@", message, error);
            }
        }];
        
    }
}

+ (void)qqOAuthWithMessage:(NSDictionary *)message completionHandle:(void (^)(NSDictionary *, NSError *))completionHandler
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *url = @"http://openapi.tencentyun.com/v3/user/get_info";
    NSMutableDictionary *params = @{@"appid": [ud objectForKey:kOSPlatformQQIdKey],
                                    @"openkey": message[@"access_token"],
                                    @"openid": message[@"openid"],
                                    @"pf": @"qzone",
                                    @"format": @"json"}.mutableCopy;
    NSMutableString *paramsString = [NSString stringWithFormat:@"GET&%@&", [@"/v3/user/get_info" encodeURL]].mutableCopy;
    NSArray *keys = @[@"appid", @"format", @"openid", @"openkey", @"pf"];
    NSMutableString *keyValueString = @"".mutableCopy;
    for (NSString *key in keys) {
        [keyValueString appendFormat:@"%@=%@&", key, params[key]];
    }
    [keyValueString appendString:@"userip="];
    keyValueString = [keyValueString encodeURL].mutableCopy;
    [keyValueString appendString:@"10.0.0.1"];
    NSString *signStr = [NSString stringWithFormat:@"%@%@", paramsString, keyValueString];
    NSString *sss = [signStr hmacSha1WithKey:[NSString stringWithFormat:@"%@&", [ud objectForKey:kOSPlatformQQSecretKey]]];
    NSString *sig = [sss encodeURL];
    params[@"sig"] = sig;
    params[@"userip"] = @"10.0.0.1";
    
    NSMutableString *urlString = @"?".mutableCopy;
    for (NSString *key in params.allKeys) {
        [urlString appendFormat:@"%@=%@&", key, params[key]];
    }
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@", url, urlString];
    requestUrl = [requestUrl substringToIndex:requestUrl.length - 1];
    
    [OpenShare get:requestUrl completionHandler:^(NSDictionary *data, NSError *error) {
        NSMutableDictionary *dict = data.mutableCopy;
        [dict addEntriesFromDictionary:message];
        if (completionHandler) {
            completionHandler(dict, error);
        }
    }];
}

+ (void)weixinOAuthWithMessage:(NSDictionary *)message completionHandle:(void (^)(NSDictionary *, NSError *))completionHandler
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *appId = [ud objectForKey:kOSPlatformWeixinIdKey];
    NSString *secret = [ud objectForKey:kOSPlatformWeixinSecretKey];
    NSString *url = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code", appId, secret, message[@"code"]];
    [OpenShare get:url completionHandler:^(NSDictionary *data, NSError *error) {
        NSString *accessToken = data[@"access_token"];
        NSString *openid = data[@"openid"];
        
        NSString *userInfoUrl = [NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@&lang=zh_CN", accessToken, openid];
        [OpenShare get:userInfoUrl completionHandler:^(NSDictionary *userInfo, NSError *error) {
            NSMutableDictionary *dict = userInfo.mutableCopy;
            [dict addEntriesFromDictionary:message];
            if (completionHandler) {
                completionHandler(dict, error);
            }
        }];
    }];
}

+ (void)weiboOAuthWithMessage:(NSDictionary *)message completionHandle:(void (^)(NSDictionary *, NSError *))completionHandler
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *url = @"https://api.weibo.com/2/users/show.json";
    NSDictionary *params = @{@"source": [ud objectForKey:kOSPlatformWeiboIdKey],
                             @"access_token": message[@"accessToken"],
                             @"uid": message[@"userID"]};
    [OpenShare get:url params:params completionHandler:^(NSDictionary *data, NSError *error) {
        NSMutableDictionary *dict = data.mutableCopy;
        [dict addEntriesFromDictionary:message];
        if (completionHandler) {
            completionHandler(dict, error);
        }
    }];
}

@end
