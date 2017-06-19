//
//  SlackersDetailsViewController.h
//  Slackers
//
//  Created by mahboud on 6/18/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlackersDetailsViewController : UIViewController
@property (strong, nonatomic) UIImage *avatarImage;
@property (assign, nonatomic) CGRect avatarStartFrame;
@property (strong, nonatomic) NSString *formattedDetailString;
@property (strong, nonatomic) UIColor *userColor;
@end
