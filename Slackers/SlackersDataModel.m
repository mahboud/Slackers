//
//  SlackersDataModel.m
//  Slackers
//
//  Created by mahboud on 6/16/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import "SlackersDataModel.h"

#import "SlackersNetworkEngine.h"
#import <UIKit/UIKit.h>

NSString *GetDocumentsDirectory() {
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  return [paths firstObject];
}

static NSString *const kDefaultSavedListFileName = @"SlackersList";
static NSString *const kSavedListFileExtension = @"data";


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

//    _listOfUsers = [NSDictionary dictionaryWithContentsOfFile:[self savedListFilePath]];
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

//  BOOL success = [_listOfUsers writeToFile:[self savedListFilePath] atomically:YES];
  if (success == NO) {
    NSLog(@"Save failed");
  }
}

- (void)fetchNewDataWithCompletionHandler:(void (^)(void))completionHandler {
  SlackersNetworkEngine *networkEngine = [[SlackersNetworkEngine alloc] init];
  [networkEngine testAuthWithSuccessHandler:^(id result) {
    NSLog(@"Verified:  You are %@@%@", result[@"user"], result[@"team"]);
    [networkEngine getUserListWithSuccessHandler:^(NSDictionary *result) {
      [self reconcileNewList:result[@"members"]];
      dispatch_async(dispatch_get_main_queue(), ^ {
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

- (NSArray *)sortUserList:(NSDictionary *)listOfUsers {
   return [listOfUsers keysSortedByValueUsingComparator:^NSComparisonResult(NSDictionary   * _Nonnull user1, NSDictionary   * _Nonnull user2) {
    
    return [user1[@"profile"][@"real_name"] localizedCompare:user2[@"profile"][@"real_name"]];
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
#warning the >= should be changed to > after tessting
    if ((existingUser == nil) || (existingUser && user[@"updated"] >= existingUser[@"updated"])) {
      tempListOfUsers[slackUserID] = user;
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
  return _listOfUsers[slackID][@"real_name"];
}

- (UIImage *)getImageForID:(NSString *)slackID
           completionHandler:(void (^)(UIImage *))completionHandler {
  UIImage *image;
      image = [UIImage imageNamed:@"slack1"];
      image = [UIImage imageNamed:@"slack-round"];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completionHandler(image);
  });
  return nil;
}
@end
