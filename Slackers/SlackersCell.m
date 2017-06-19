//
//  SlackersCellsCollectionViewCell.m
//  Slackers
//
//  Created by mahboud on 6/15/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import "SlackersCell.h"

@implementation SlackersCell {
  IBOutlet UIActivityIndicatorView *_activityIndicator;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
  self.clipsToBounds = NO;
  _circleView.clipsToBounds = YES;
//  _activityIndicator.layer.backgroundColor = UIColor.darkGrayColor.CGColor;
  _activityIndicator.layer.borderColor = UIColor.whiteColor.CGColor;
  _activityIndicator.layer.borderWidth = 0.5;

  _activityIndicator.layer.cornerRadius = 5;
  _imageView.image = [UIImage imageNamed:@"slack2"];
}

-(void)prepareForReuse {
  _imageView.image = [UIImage imageNamed:@"slack2"];
  [_activityIndicator startAnimating];
}

-(void)layoutSubviews {
  [super layoutSubviews];
  UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
  self.layer.shadowPath = path.CGPath;
  _circleView.layer.cornerRadius = _circleView.frame.size.width / 2;
}

- (void)setImage:(UIImage *)image {
  _imageView.image = image;
  _circleView.layer.cornerRadius = _circleView.frame.size.width / 2;
  [self setNeedsLayout];
}

-(void)doneDownloaded {
  [_activityIndicator stopAnimating];
}

@end
