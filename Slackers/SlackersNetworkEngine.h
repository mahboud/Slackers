//
//  SlackersNetworkEngine.h
//  Slackers
//
//  Created by mahboud on 6/16/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SlackersNetworkEngine : NSObject <NSURLSessionDelegate>

- (void)testAuthWithSuccessHandler:(void (^)(NSDictionary *result))successHandler
                      errorHandler:(void (^)(NSError *error, NSString *errorString))errorHandler;

- (void)getUserListWithSuccessHandler:(void (^)(NSDictionary *result))successHandler
                         errorHandler:(void (^)(NSError *error, NSString *errorString))errorHandler;

@end
