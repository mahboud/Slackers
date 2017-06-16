//
//  SlackersDataModel.m
//  Slackers
//
//  Created by mahboud on 6/16/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import "SlackersDataModel.h"

#import <UIKit/UIKit.h>

@implementation SlackersDataModel


#define number_of_sections 2
#define number_of_items	10

-(NSInteger)numberOfItems {
  return number_of_items;
}

-(NSInteger)numberOfSections {
  return number_of_sections;
}

- (instancetype)init {
  self = [super init];
  if (self) {
  }
  return self;
}

- (void)fetchNewDataWithCompletionHandler:(void (^)(void))completionHandler {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    completionHandler();
  });
}

- (NSString *)getNameForPath:(NSIndexPath *)path {
  return @"Henryette";
}

- (UIImage *)getImageForPath:(NSIndexPath *)path
           completionHandler:(void (^)(UIImage *))completionHandler {
  UIImage *image;
  switch (path.item % 2) {
    case 0:
      image = [UIImage imageNamed:@"slack1"];
      break;
    case 1:
      image = [UIImage imageNamed:@"slack-round"];
      break;
  }
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        completionHandler(image);
  });
  return nil;
}
@end
