//
//  SlackersNetworkEngine.m
//  Slackers
//
//  Created by mahboud on 6/16/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import "SlackersNetworkEngine.h"


static NSString *const scheme = @"https";
static NSString *const username = nil;
static NSString *const password = nil;
static NSString *const server = @"api.slack.com";
static NSString *const userList = @"/api/users.list";
static NSString *const authTest = @"/api/auth.test";
static NSString *const tokenKey = @"token";

// Add valid token here
static NSString *const token = @"xoxs-4111381947-186936593057-187440450611-8b992ff9f5";

@implementation SlackersNetworkEngine {
  NSURLSession *_session;
  NSURLComponents *_baseURL;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _baseURL = [[NSURLComponents alloc] init];
    _baseURL.scheme = scheme;
    _baseURL.host = server;
    _baseURL.user = username;
    _baseURL.password = password;
    _baseURL.query = [NSString stringWithFormat:@"%@=%@", tokenKey, token];
    //    static dispatch_once_t onceToken;
    //    dispatch_once(&onceToken, ^{
    //  No need for this to be a singleton since it isn't a backgroundSession
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];

    configuration.sessionSendsLaunchEvents = YES;
    _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];

    //    });

  }
  return self;
}

- (void)testAuthWithSuccessHandler:(void (^)(NSDictionary *result))successHandler
                      errorHandler:(void (^)(NSError *error, NSString *errorString))errorHandler {
  _baseURL.path = authTest;
  [self executeNetworkMethodWithSuccessHandler:successHandler errorHandler:errorHandler];
}

- (void)getUserListWithSuccessHandler:(void (^)(NSDictionary *result))successHandler
                         errorHandler:(void (^)(NSError *error, NSString *errorString))errorHandler {
  _baseURL.path = userList;
  [self executeNetworkMethodWithSuccessHandler:successHandler errorHandler:errorHandler];
}

- (void)executeNetworkMethodWithSuccessHandler:(void (^)(NSDictionary *result))successHandler
                                  errorHandler:(void (^)(NSError *error, NSString *errorString))errorHandler {  NSURL *downloadURL = [_baseURL URL];

  NSURLSessionDownloadTask *downloadTask =
  [_session downloadTaskWithURL:downloadURL
              completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                if (error) {
                  errorHandler(error, error.localizedDescription);
                }
                else {
                  NSData *data=[NSData dataWithContentsOfFile:location.path];
                  NSError *error;
                  id objectFromJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                  if (error) {
                    errorHandler(error, error.localizedDescription);
                  }
                  else {
                    if ([objectFromJSON isKindOfClass:NSDictionary.class]) {
                      NSDictionary *jsonResults = objectFromJSON;
                      successHandler(jsonResults);
                    }
                    else {
                      errorHandler(nil, @"JSON Not a Dictionary");
                    }
                  }
                }
              }];
  [downloadTask resume];
}

#if 0
- (void)downloadImage:(NSString *)file  completionHandler:(void (^)(UIImage *image))completionHandler {
  NSURL *downloadURL = [[[baseURL URL] URLByAppendingPathComponent:file] URLByAppendingPathExtension:@"jpeg"];

  NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:downloadURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
    NSData *imageData=[NSData dataWithContentsOfFile:location.path];
    UIImage *image=[UIImage imageWithData:imageData];
    //    UIImage *image = [UIImage imageWithContentsOfFile:location.path];
    completionHandler(image);
  }];
  [downloadTask resume];

}
- (UIImage *) getImageForPath:(NSIndexPath *)path completionHandler:(void (^)(UIImage *))completionHandler {
  NSInteger realSection, realItem;
  realItem = path.item;
  if (realItem >= number_of_items)
    realItem = realItem % number_of_items;
  realSection = path.section;
  if (realSection >= number_of_sections)
    realSection = realSection % number_of_sections;

  NSString *key = [NSString stringWithFormat:@"%04ld-%04ld", (long)realSection, (long)realItem];

  UIImage *image = [cache objectForKey:key];
  if (image == nil) {
    [self downloadImage:key completionHandler:^(UIImage *image) {
      if (image) {
        [cache setObject:image forKey:key];
        completionHandler(image);
      }
    }];
  }
  else {
    return image;
  }
  return nil;
}
#endif
@end
