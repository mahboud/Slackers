//
//  SlackersImageManager.m
//  Slackers
//
//  Created by mahboud on 6/17/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import "SlackersImageManager.h"

#import "GetDocumentsDirectory.h"
#import "SlackersNetworkEngine.h"
#import <UIKIt/UIKit.h>
#include <time.h>

static NSString *const kSavedFileDictionaryFileExtension = @"plist";
static NSString *const kDefaultFileDictionaryfileID = @"ImageTempFileDictionary";

@implementation SlackersImageManager {
  NSURLSession *_session;
  NSCache *_cache;
  NSMutableDictionary <NSString *, NSString *>*_imageTempFileLocationsDictionary;
  NSMutableDictionary <NSString *, NSNumber *>*_pendingDownloads;
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
    _imageTempFileLocationsDictionary =
      [NSDictionary dictionaryWithContentsOfFile:[self imageTempFileDictionaryPath]].mutableCopy;
    if (_imageTempFileLocationsDictionary == nil) {
      _imageTempFileLocationsDictionary = [NSMutableDictionary dictionaryWithCapacity:50];
    }
    _pendingDownloads = [NSMutableDictionary dictionaryWithCapacity:50];
  }
  return self;
}

- (NSString *)imageTempFileDictionaryPath {
  NSString *path = GetDocumentsDirectory();
  return [[path stringByAppendingPathComponent:kDefaultFileDictionaryfileID]
          stringByAppendingPathExtension:kSavedFileDictionaryFileExtension];
}

- (void)queueSaveFileDictionary {
  dispatch_async(dispatch_get_main_queue(), ^ {
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(saveImageTempFileDictionary:)
                                               object:_imageTempFileLocationsDictionary];
    [self performSelector:@selector(saveImageTempFileDictionary:)
               withObject:_imageTempFileLocationsDictionary
               afterDelay:15.0];
  });
}

- (void)saveImageTempFileDictionary:(NSMutableDictionary *)dictionary {
  [dictionary writeToFile:[self imageTempFileDictionaryPath] atomically:NO];
}

- (void)clearCacheForID:(NSString *)slackID {
//  [_cache removeObjectForKey:slackID];
//  // TODO: remove file from /tmp directory
//  [_imageTempFileLocationsDictionary removeObjectForKey:slackID];
}

- (UIImage *)getImageForID:(NSString *)slackID
                       url:(NSURL *)downloadURL
         completionHandler:(void (^)(UIImage *))completionHandler {
  NSString *fileID = [NSString stringWithFormat:@"%@-%@", slackID, downloadURL.lastPathComponent];
  UIImage *image = [_cache objectForKey:fileID];
  if (image) {
    NSLog(@"From cache: %@", fileID);
    return image;
  }
  // Image is no longer in the cache
  // First check the /tmp directory. We leave images there for as long as the OS lets us.
  // Then download if not there.
  NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:_imageTempFileLocationsDictionary[fileID]];
  if (path) {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
      UIImage *image = [self processImageFromFile:path];
      if (image) {
        NSLog(@"From file: %@", fileID);
        
        [_cache setObject:image forKey:fileID];
        completionHandler(image);
      }
      else {
        [self getImageFromNetworkForID:fileID url:downloadURL completionHandler:completionHandler];
      }
    });
  }
  else {
    [self getImageFromNetworkForID:fileID url:downloadURL completionHandler:completionHandler];
  }
  return nil;
}

- (void)getImageFromNetworkForID:(NSString *)fileID
                             url:(NSURL *)downloadURL
               completionHandler:(void (^)(UIImage *))completionHandler {
  NSNumber *lastTime = _pendingDownloads[fileID];
  time_t seconds;
  time(&seconds);
  if (lastTime && (lastTime.longValue + 5 > seconds)) {
    return;
  }
  NSLog(@"Download: %@", fileID);
  _pendingDownloads[fileID] = @(seconds);
  [[[SlackersNetworkEngine alloc] init] downloadImage:downloadURL
                                    completionHandler:^(NSURL *location) {
                                      UIImage *image = [self processImageFromFile:location.path];
                                      if (image) {
                                        NSString *newLocationPath =
                                        [NSTemporaryDirectory()
                                           stringByAppendingPathComponent:fileID];
                                        NSFileManager *fileManager = [NSFileManager defaultManager];
                                        if ([fileManager fileExistsAtPath:newLocationPath]) {
                                          [fileManager removeItemAtPath:newLocationPath error:nil];
                                        }
                                        [fileManager moveItemAtPath:location.path toPath:newLocationPath error:nil];
                                        
                                        NSLog(@"From network: %@", fileID);
                                        _imageTempFileLocationsDictionary[fileID] = fileID;
                                        [self queueSaveFileDictionary];
                                        [_cache setObject:image forKey:fileID];
                                      }
                                      completionHandler(image);
                                    }];
}

- (UIImage *)processImageFromFile:(NSString *)path {
  NSData *imageData = [NSData dataWithContentsOfFile:path];
  return [UIImage imageWithData:imageData];
}

@end
