//
//  SlackersDataModel.h
//  Slackers
//
//  Created by mahboud on 6/16/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlackersDataModel : NSObject

@property (nonatomic) NSInteger numberOfSections;
@property (nonatomic) NSInteger numberOfItems;

- (void)fetchNewDataWithCompletionHandler:(void (^)(void))completionHandler;

- (NSString *)getIDForPath:(NSIndexPath *)path;

- (NSString *)getNameForID:(NSString *)slackID;
- (NSString *)getEmailForID:(NSString *)slackID;
- (NSString *)getPhoneForID:(NSString *)slackID;
- (UIImage *)getImageForID:(NSString *)slackID completionHandler:(void (^)(UIImage *))completionHandler;
- (NSDictionary *)getAllDetailsForID:(NSString *)slackID;
- (UIColor *)getColorForID:(NSString *)slackID;
@end
