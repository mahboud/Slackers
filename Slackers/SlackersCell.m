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
  IBOutlet UIView *_circleView;
}

- (void)awakeFromNib {
  [super awakeFromNib];
  // Initialization code
  self.clipsToBounds = NO;
  _circleView.clipsToBounds = YES;
  _activityIndicator.layer.cornerRadius = 5;
  _imageView.image = [UIImage imageNamed:@"slack-round"];
}

-(void)prepareForReuse {
  _imageView.image = [UIImage imageNamed:@"slack-round"];
  [_activityIndicator startAnimating];
}

-(void)layoutSubviews {
  [super layoutSubviews];
  UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
  self.layer.shadowPath = path.CGPath;
  _circleView.layer.cornerRadius = _circleView.frame.size.width / 2;
}

-(void)doneDownloaded {
  [_activityIndicator stopAnimating];
}

@end
