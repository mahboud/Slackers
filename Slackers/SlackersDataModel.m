//
//  SlackersDataModel.m
//  Slackers
//
//  Created by mahboud on 6/16/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import "SlackersDataModel.h"

#import "GetDocumentsDirectory.h"
#import "SlackersImageManager.h"
#import "SlackersNetworkEngine.h"
#import <UIKit/UIKit.h>

static NSString *const kDefaultSavedListFileName = @"SlackersList";
static NSString *const kSavedListFileExtension = @"data";

static NSString *const kUserListKeysID = @"id";
static NSString *const kUserListKeysUser = @"user";
static NSString *const kUserListKeysTeam = @"team";
static NSString *const kUserListKeysMembers = @"members";
static NSString *const kUserListKeysProfile = @"profile";
static NSString *const kUserListKeysRealName = @"real_name";
static NSString *const kUserListKeysJustName = @"name";
static NSString *const kUserListKeysUpdated = @"updated";
static NSString *const kUserListKeysImg192 = @"image_192";
static NSString *const kUserListKeysImg512 = @"image_512";
static NSString *const kUserListKeysColor = @"color";
static NSString *const kUserListKeysEmail = @"email";
static NSString *const kUserListKeysPhone = @"phone";
static NSString *const kUserListKeysIsDeleted = @"deleted";

static NSString *const kUserListKeysIsAdmin = @"is_admin";
static NSString *const kUserListKeysIsBot = @"is_bot";
static NSString *const kUserListKeysIsOwner = @"is_owner";
static NSString *const kUserListKeysIsPrimaryOwner = @"is_primary_owner";
static NSString *const kUserListKeysIsRestricted = @"is_restricted";
static NSString *const kUserListKeysIsUltraRestricted = @"is_ultra_restricted";
static NSString *const kUserListKeysTeamID = @"team_id";
static NSString *const kUserListKeysTZLabel = @"tz_label";

@implementation SlackersDataModel {
  NSDictionary <NSString *, NSDictionary *>*_listOfUsers;
  NSArray <NSString *>*_idsSortedByName;
}

-(NSInteger)numberOfItems {
  return _listOfUsers.count;
}

-(NSInteger)numberOfSections {
  return 1;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    NSData *data = [NSData dataWithContentsOfFile:[self savedListFilePath]];
    _listOfUsers = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    _idsSortedByName = [self sortUserList:_listOfUsers];
  }
  return self;
}

- (NSString *)savedListFilePath {
  NSString *path = GetDocumentsDirectory();
  NSLog(@"path: %@", path);
  return [[path stringByAppendingPathComponent:kDefaultSavedListFileName]
          stringByAppendingPathExtension:kSavedListFileExtension];
}

- (void)saveUserList:(NSDictionary *)userList {
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:userList];
  BOOL success = [data writeToFile:[self savedListFilePath] atomically:YES];
  if (success == NO) {
    NSLog(@"Save failed. Filename: %@", [self savedListFilePath]);
  }
}

- (void)fetchNewDataWithCompletionHandler:(void (^)(void))completionHandler {
  SlackersNetworkEngine *networkEngine = [[SlackersNetworkEngine alloc] init];
  [networkEngine testAuthWithSuccessHandler:^(id result) {
    NSLog(@"Verified: You are %@@%@", result[kUserListKeysUser], result[kUserListKeysTeam]);
    [networkEngine getUserListWithSuccessHandler:^(NSDictionary *result) {
      NSDictionary *tempListOfUsers = [self reconcileNewList:result[kUserListKeysMembers]];
      NSArray *tempSortedIDArray = [self sortUserList:tempListOfUsers];
      dispatch_async(dispatch_get_main_queue(), ^ {
        _listOfUsers = tempListOfUsers.copy;
        _idsSortedByName = tempSortedIDArray;
        completionHandler();
      });
      [self saveUserList:tempListOfUsers];
    } errorHandler:^(NSError *error, NSString *errorString) {
      NSLog(@"Error!  Error is %@ (%ld)", errorString, (long)error.code);
    }];
  } errorHandler:^(NSError *error, NSString *errorString) {
    NSLog(@"Error!  Error is %@ (%ld)", errorString, (long)error.code);
  }];
}

- (NSString *)getUserName:(NSDictionary *)user {
  // Some users don't have realnames. This is the workaround.
  NSString *name = user[kUserListKeysProfile][kUserListKeysRealName];
  if (name == nil || name.length == 0) {
    name = user[kUserListKeysJustName];
  }
  return name;
}

- (NSArray *)sortUserList:(NSDictionary *)listOfUsers {
   return [listOfUsers keysSortedByValueUsingComparator:
           ^NSComparisonResult(NSDictionary *_Nonnull user1, NSDictionary *_Nonnull user2) {
             return [[self getUserName:user1] localizedCompare:[self getUserName:user2]];
           }];
}

- (NSDictionary *)reconcileNewList:(NSArray <NSDictionary *>*)latestListOfUsers {
  NSMutableDictionary *tempListOfUsers = _listOfUsers.mutableCopy;
  if (tempListOfUsers == nil) {
    tempListOfUsers = [NSMutableDictionary dictionaryWithCapacity:50];
  }

  for (NSDictionary *user in latestListOfUsers) {
    NSString *slackUserID = user[kUserListKeysID];
    NSDictionary *existingUser = tempListOfUsers[slackUserID];
    BOOL profileChanged = NO;
    if ((existingUser == nil) || (profileChanged =
        (existingUser && user[kUserListKeysUpdated] > existingUser[kUserListKeysUpdated]))) {
      tempListOfUsers[slackUserID] = user;
      if (profileChanged) {
        [[SlackersImageManager sharedInstance] clearCacheForID:slackUserID];
      }
    }
    // TODO: remove users from saved list that were deleted from new list.  Given that users may
    // just be flagged as deleted, they may never get removed from the list, which would make
    // unnecessary to remove from our list.
    // Do a loop at the end, looking to see that each id in the saved list, is in new list; if
    // not, then delete.
    
  }
  return tempListOfUsers.copy;
}

- (NSString *)getIDForPath:(NSIndexPath *)path {
  return _idsSortedByName[path.item];
}

- (NSString *)getNameForID:(NSString *)slackID {
  return [self getUserName:_listOfUsers[slackID]];
}

- (NSString *)getEmailForID:(NSString *)slackID {
  return _listOfUsers[slackID][kUserListKeysProfile][kUserListKeysEmail];
}

- (NSString *)getPhoneForID:(NSString *)slackID {
  return _listOfUsers[slackID][kUserListKeysProfile][kUserListKeysPhone];
}

- (UIImage *)getImageForID:(NSString *)slackID
           completionHandler:(void (^)(UIImage *))completionHandler {

  NSString *path = _listOfUsers[slackID][kUserListKeysProfile][kUserListKeysImg512];
  if (!path) {
    path = _listOfUsers[slackID][kUserListKeysProfile][kUserListKeysImg192];
  }
  NSURL *url;
  if (path) {
    url = [NSURL URLWithString:path];
  }
  return [[SlackersImageManager sharedInstance] getImageForID:slackID
                                                          url:url
                                            completionHandler:^(UIImage *image) {
                                              completionHandler(image);
                                            }];
}

- (NSDictionary *)getAllDetailsForID:(NSString *)slackID {
  return _listOfUsers[slackID];
}

- (UIColor *)getColorForID:(NSString *)slackID {
  NSString *colorString = _listOfUsers[slackID][kUserListKeysColor];
  unichar redChar = [colorString characterAtIndex:0];
  ushort blueChar = [colorString characterAtIndex:1];
  ushort greenChar =  [colorString characterAtIndex:2];
  UIColor *color = [UIColor colorWithRed:redChar / 255.0 green:greenChar / 255.0 blue:blueChar / 255.0 alpha:1.0];
  return color;
}

- (BOOL)isAdminForID:(NSString *)slackID {
  return ((NSNumber *)_listOfUsers[slackID][kUserListKeysIsAdmin]).boolValue;
}

- (BOOL)isBotForID:(NSString *)slackID {
  return ((NSNumber *)_listOfUsers[slackID][kUserListKeysIsBot]).boolValue;
}

- (BOOL)isOwnerForID:(NSString *)slackID {
  return ((NSNumber *)_listOfUsers[slackID][kUserListKeysIsOwner]).boolValue;
}

- (BOOL)isPrimaryOwnerForID:(NSString *)slackID {
  return ((NSNumber *)_listOfUsers[slackID][kUserListKeysIsPrimaryOwner]).boolValue;
}

- (BOOL)isRestrictedForID:(NSString *)slackID {
  return ((NSNumber *)_listOfUsers[slackID][kUserListKeysIsRestricted]).boolValue;
}

- (BOOL)isUltraRestricted:(NSString *)slackID {
  return ((NSNumber *)_listOfUsers[slackID][kUserListKeysIsUltraRestricted]).boolValue;
}

- (NSString *)teamIDForID:(NSString *)slackID {
  return _listOfUsers[slackID][kUserListKeysTeamID];
}

- (NSString *)tzLabelForID:(NSString *)slackID {
  return _listOfUsers[slackID][kUserListKeysTZLabel];
}

@end
