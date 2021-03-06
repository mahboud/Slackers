//
//  SlackersDataModel.h
//  Slackers
//
//  Created by mahboud on 6/16/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SlackersDataModelDelegate
@required
- (void)reloadData;
@end

@interface SlackersDataModel : NSObject

@property (nonatomic) NSInteger numberOfSections;
@property (nonatomic) NSInteger numberOfItems;
@property (nonatomic, weak) id <SlackersDataModelDelegate> delegate;

- (void)fetchNewData;
- (NSString *)getIDForPath:(NSIndexPath *)path;
- (NSString *)getNameForID:(NSString *)slackID;
- (NSString *)getEmailForID:(NSString *)slackID;
- (NSString *)getPhoneForID:(NSString *)slackID;
- (UIImage *)getImageForID:(NSString *)slackID completionHandler:(void (^)(UIImage *))completionHandler;
- (NSDictionary *)getAllDetailsForID:(NSString *)slackID;
- (UIColor *)getColorForID:(NSString *)slackID;
- (BOOL)isDeletedForID:(NSString *)slackID;
- (BOOL)isAdminForID:(NSString *)slackID;
- (BOOL)isBotForID:(NSString *)slackID;
- (BOOL)isOwnerForID:(NSString *)slackID;
- (BOOL)isPrimaryOwnerForID:(NSString *)slackID;
- (BOOL)isRestrictedForID:(NSString *)slackID;
- (BOOL)isUltraRestricted:(NSString *)slackID;
- (NSString *)teamIDForID:(NSString *)slackID;
- (NSString *)tzLabelForID:(NSString *)slackID;
  
@end
