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


#define number_of_sections 1
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

- (NSString *)getNameForPath:(NSIndexPath *)path {
  return @"Henryette";
}

- (UIImage *)getImageForPath:(NSIndexPath *)path completionHandler:(void (^)(UIImage *))completionHandler {
  UIImage *image;
  switch (path.item % 3) {
    case 0:
      image = [UIImage imageNamed:@"slack1"];
      break;
    case 1:
      image = [UIImage imageNamed:@"slack2"];
      break;
    case 2:
      image = [UIImage imageNamed:@"slackbot.jpeg"];
     break;
  }
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //    completionHandler(image);
  });
  return nil;
}
@end
