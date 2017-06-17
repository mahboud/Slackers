//
//  SlackersImageManager.m
//  Slackers
//
//  Created by mahboud on 6/17/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import "SlackersImageManager.h"

#import "SlackersNetworkEngine.h"
#import <UIKIt/UIKit.h>

@implementation SlackersImageManager {
  NSURLSession *_session;
  NSCache *_cache;
  NSMutableDictionary *fileDictionary;
}

+ (instancetype)sharedInstance
{
  static dispatch_once_t once;
  static id sharedInstance;
  dispatch_once(&once, ^{
    sharedInstance = [[self alloc] init];
    
  });
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _cache = [[NSCache alloc] init];
    fileDictionary = [NSMutableDictionary dictionaryWithCapacity:50];
  }
  return self;
}

- (void)clearCacheForID:(NSString *)slackID {
  [_cache removeObjectForKey:slackID];
  // TODO: remove file from /tmp directory
  [fileDictionary removeObjectForKey:slackID];
}

- (UIImage *)getImageForID:(NSString *)slackID
                       url:(NSURL *)downloadURL
         completionHandler:(void (^)(UIImage *))completionHandler {
  UIImage *image = [_cache objectForKey:slackID];
  if (image) {
    NSLog(@"From cache");
    return image;
  }
  // Image is no longer in the cache
  // First check the /tmp directory. We leave images there for as long as the OS lets us.
  // Then download if not there.
  NSString *path = fileDictionary[slackID];
  if (path) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
      UIImage *image = [self processImageFromFile:path];
      if (image) {
        NSLog(@"From file");
        
        [_cache setObject:image forKey:slackID];
        completionHandler(image);
      }
      else {
        [self getImageFromNetworkForID:slackID url:downloadURL completionHandler:completionHandler];
      }
    });
  }
  else {
    [self getImageFromNetworkForID:slackID url:downloadURL completionHandler:completionHandler];
  }
  return nil;
}

- (void)getImageFromNetworkForID:(NSString *)slackID
                             url:(NSURL *)downloadURL
               completionHandler:(void (^)(UIImage *))completionHandler {
  [[[SlackersNetworkEngine alloc] init] downloadImage:downloadURL
                                    completionHandler:^(NSURL *location) {
                                      UIImage *image = [self processImageFromFile:location.path];
                                      if (image) {
                                        NSString *newLocationPath =
                                        [[[location.path stringByDeletingLastPathComponent]
                                          stringByAppendingPathComponent:slackID]
                                         stringByAppendingPathExtension:downloadURL.pathExtension];
                                        NSFileManager *fileManager = [NSFileManager defaultManager];
                                        if ([fileManager fileExistsAtPath:newLocationPath]) {
                                          [fileManager removeItemAtPath:newLocationPath error:nil];
                                        }
                                        [fileManager moveItemAtPath:location.path toPath:newLocationPath error:nil];
                                        
                                        NSLog(@"From network");
                                        fileDictionary[slackID] = newLocationPath;
                                        [_cache setObject:image forKey:slackID];
                                      }
                                      completionHandler(image);
                                    }];
}

- (UIImage *)processImageFromFile:(NSString *)path {
  NSData *imageData = [NSData dataWithContentsOfFile:path];
  return [UIImage imageWithData:imageData];
}

@end
