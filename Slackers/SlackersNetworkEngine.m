//
//  SlackersNetworkEngine.m
//  Slackers
//
//  Created by mahboud on 6/16/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import "SlackersNetworkEngine.h"

#import <UIKit/UIKit.h>

static NSString *const scheme = @"https";
static NSString *const username = nil;
static NSString *const password = nil;
static NSString *const server = @"api.slack.com";
static NSString *const userList = @"/api/users.list";
static NSString *const authTest = @"/api/auth.test";
static NSString *const tokenKey = @"token";

// Add valid token here
//static NSString *const token = @"xoxp-4698769766-4698769768-125892898775-d1244403ab86f233f03dce6f9d2adf37";
static NSString *const token = ;

@implementation SlackersNetworkEngine {
  NSURLSession *_session;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    //    static dispatch_once_t onceToken;
    //    dispatch_once(&onceToken, ^{
    //  No need for this to be a singleton since it isn't a backgroundSession
    _session = [NSURLSession sharedSession];

    //    });
  }
  return self;
}

- (void)testAuthWithSuccessHandler:(void (^)(NSDictionary *result))successHandler
                      errorHandler:(void (^)(NSError *error, NSString *errorString))errorHandler {
  NSURLComponents *baseURL = [[NSURLComponents alloc] init];
  baseURL.scheme = scheme;
  baseURL.host = server;
  baseURL.user = username;
  baseURL.password = password;
  baseURL.query = [NSString stringWithFormat:@"%@=%@", tokenKey, token];
  baseURL.path = authTest;
  [self executeNetworkMethodWithURL:[baseURL URL] successHandler:successHandler errorHandler:errorHandler];
}

- (void)getUserListWithSuccessHandler:(void (^)(NSDictionary *result))successHandler
                         errorHandler:(void (^)(NSError *error, NSString *errorString))errorHandler {
  NSURLComponents *baseURL = [[NSURLComponents alloc] init];
  baseURL.scheme = scheme;
  baseURL.host = server;
  baseURL.user = username;
  baseURL.password = password;
  baseURL.query = [NSString stringWithFormat:@"%@=%@", tokenKey, token];
  baseURL.path = userList;
  [self executeNetworkMethodWithURL:[baseURL URL] successHandler:successHandler errorHandler:errorHandler];
}

- (void)executeNetworkMethodWithURL:(NSURL *)downloadURL
                     successHandler:(void (^)(NSDictionary *result))successHandler
                       errorHandler:(void (^)(NSError *error, NSString *errorString))errorHandler {
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
                      if (((NSNumber *)jsonResults[@"ok"]).intValue == 0) {
                        errorHandler(nil, jsonResults[@"error"]);
                      }
                      else {
                        successHandler(jsonResults);
                      }
                    }
                    else {
                      errorHandler(nil, @"JSON Not a Dictionary");
                    }
                  }
                }
              }];
  [downloadTask resume];
}

- (void)downloadImage:(NSURL *)downloadURL
    completionHandler:(void (^)(NSURL *location))completionHandler {
  NSURLSessionDownloadTask *downloadTask =
  [_session downloadTaskWithURL:downloadURL
              completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
    completionHandler(location);
  }];
  [downloadTask resume];
}

@end
