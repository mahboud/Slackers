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

static NSString *const kUserListKeysUser = @"user";
static NSString *const kUserListKeysTeam = @"team";
static NSString *const kUserListKeysMembers = @"members";
static NSString *const kUserListKeysProfile = @"profile";
static NSString *const kUserListKeysRealName = @"real_name";
static NSString *const kUserListKeysJustName = @"name";
static NSString *const kUserListKeysUpdated = @"updated";
static NSString *const kUserListKeysImg192 = @"image_192";
static NSString *const kUserListKeysImg512 = @"image_512";

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

- (void)saveUserList {
  NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_listOfUsers];
  BOOL success = [data writeToFile:[self savedListFilePath] atomically:YES];
  if (success == NO) {
    NSLog(@"Save failed");
  }
}

- (void)fetchNewDataWithCompletionHandler:(void (^)(void))completionHandler {
  SlackersNetworkEngine *networkEngine = [[SlackersNetworkEngine alloc] init];
  [networkEngine testAuthWithSuccessHandler:^(id result) {
    NSLog(@"Verified: You are %@@%@", result[kUserListKeysUser], result[kUserListKeysTeam]);
    [networkEngine getUserListWithSuccessHandler:^(NSDictionary *result) {
      [self reconcileNewList:result[kUserListKeysMembers]];
      dispatch_async(dispatch_get_main_queue(), ^ {
        NSLog(@"trigger reload");
        completionHandler();
      });
      [self saveUserList];
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

- (void)reconcileNewList:(NSArray <NSDictionary *>*)latestListOfUsers {
  NSMutableDictionary *tempListOfUsers = _listOfUsers.mutableCopy;
  if (tempListOfUsers == nil) {
    tempListOfUsers = [NSMutableDictionary dictionaryWithCapacity:50];
  }

  for (NSDictionary *user in latestListOfUsers) {
    NSString *slackUserID = user[@"id"];
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
  NSArray *tempSortedIDArray = [self sortUserList:tempListOfUsers];
  
  @synchronized (self) {
    _listOfUsers = tempListOfUsers.copy;
    _idsSortedByName = tempSortedIDArray;
  }
}

- (NSString *)getIDForPath:(NSIndexPath *)path {
  return _idsSortedByName[path.item];
}

- (NSString *)getNameForID:(NSString *)slackID {
  return [self getUserName:_listOfUsers[slackID]];
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
@end
