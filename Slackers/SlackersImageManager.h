//
//  SlackersImageManager.h
//  Slackers
//
//  Created by mahboud on 6/17/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlackersImageManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)sharedInstance;

- (UIImage *)getImageForID:(NSString *)slackID
                       url:(NSURL *)downloadURL
         completionHandler:(void (^)(UIImage *image))completionHandler;

// If profile has changed, then image may have too, so clear saved image.
- (void)clearCacheForID:(NSString *)slackID;

@end
