//
//  OpenShare+Networking.h
//  LoginRegisterModule
//
//  Created by InitialC on 16/11/21.
//  Copyright © 2016年 InitialC. All rights reserved.
//

#import "OpenShare.h"

@interface OpenShare (Networking)

+ (void)get:(NSString *)urlPath completionHandler:(void (^)(id data, NSError *error))completionHandler;
+ (void)get:(NSString *)urlPath params:(NSDictionary *)params completionHandler:(void (^)(id, NSError *))completionHandler;

@end
