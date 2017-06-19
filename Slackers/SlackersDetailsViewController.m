//
//  SlackersDetailsViewController.m
//  Slackers
//
//  Created by mahboud on 6/18/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import "SlackersDetailsViewController.h"

@interface SlackersDetailsViewController ()
@end

@implementation SlackersDetailsViewController {
  IBOutlet UIView *_avatarPlaceHolderView;
  IBOutlet UIImageView *_avatarImageView;
  IBOutlet UIView *_infoView;
  IBOutlet UITextView *_textView;
  UIVisualEffectView *_blurView;
  UIView *_platter;
  
  NSArray *_platterConstraints;
  NSArray *_avatarConstraints;
  BOOL _isPortrait;
  BOOL _initialPositioning;
}
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view from its nib.
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(tapHandler)];
  [self.view addGestureRecognizer:tapGesture];
  
  UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
  _blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
  [self.view insertSubview:_blurView belowSubview:_avatarPlaceHolderView];
  _avatarPlaceHolderView.translatesAutoresizingMaskIntoConstraints = NO;
  _initialPositioning = YES;
  _platter = [[UIView alloc] init];
  _platter.translatesAutoresizingMaskIntoConstraints = NO;
  _platter.layer.cornerRadius = 10.0;
  _platter.backgroundColor = [_userColor colorWithAlphaComponent:0.75];
  [self.view insertSubview:_platter belowSubview:_avatarPlaceHolderView];
  _infoView.translatesAutoresizingMaskIntoConstraints = NO;
  _infoView.layer.cornerRadius = 10.0;
  _textView.text = _formattedDetailString;
}

-(void)viewDidAppear:(BOOL)animated {
  NSMutableArray *avatarConstraints = @[
                                        [_avatarPlaceHolderView.widthAnchor constraintEqualToConstant:240],
                                        [_avatarPlaceHolderView.heightAnchor constraintEqualToConstant:240]
                                        ].mutableCopy;
  if (_isPortrait) {
    [avatarConstraints addObjectsFromArray:@[
                                             [_avatarPlaceHolderView.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                                                                              constant:40.0],
                                             [_avatarPlaceHolderView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor
                                                                                                  constant:0]
                                             ]];
  }
  else {
    [avatarConstraints addObjectsFromArray:@[
                                             [_avatarPlaceHolderView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                                                                  constant:40.0],
                                             [_avatarPlaceHolderView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor
                                                                                                  constant:0]
                                             ]];
  }
  _avatarConstraints = avatarConstraints.copy;
  for (NSLayoutConstraint *constraint in _avatarConstraints) {
    constraint.active = YES;
  }
  _initialPositioning = NO;
  
  [UIView animateWithDuration:0.25 animations:^{
    [self.view layoutIfNeeded];
  } completion:^(BOOL finished) {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    animation.duration = 0.25;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.toValue = @(10.0);
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [_avatarPlaceHolderView.layer addAnimation:animation forKey:@"setCornerRadius:"];
    [UIView commitAnimations];
    
    CGRect frame = _avatarStartFrame;
    frame.size = CGSizeZero;
    _platter.frame = frame;
    _platter.center = _avatarPlaceHolderView.center;
    frame = CGRectZero;
    _infoView.frame = frame;
    _infoView.center = [_platter convertPoint:_avatarPlaceHolderView.center fromView:self.view];
    _textView.frame = frame;
    _textView.center = _infoView.center;
    [_platter addSubview:_infoView];
    if (_isPortrait) {
      _platterConstraints = @[
                              [_platter.topAnchor constraintEqualToAnchor:self.view.topAnchor
                                                                 constant:20.0],
                              [_platter.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor
                                                                     constant:0],
                              [_platter.widthAnchor constraintEqualToAnchor:self.view.widthAnchor
                                                                   constant:-20],
                              [_platter.heightAnchor constraintEqualToAnchor:self.view.heightAnchor
                                                                    constant:-100],
                              [_infoView.topAnchor constraintEqualToAnchor:_platter.topAnchor
                                                                  constant:268],
                              [_infoView.bottomAnchor constraintEqualToAnchor:_platter.bottomAnchor
                                                                     constant:-8.0],
                              [_infoView.centerXAnchor constraintEqualToAnchor:_platter.centerXAnchor
                                                                      constant:0],
                              [_infoView.widthAnchor constraintEqualToAnchor:_platter.widthAnchor
                                                                    constant:-20],
                              ];
    }
    else {
      _platterConstraints = @[
                              [_platter.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor
                                                                     constant:20.0],
                              [_platter.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor
                                                                     constant:0],
                              [_platter.widthAnchor constraintEqualToAnchor:self.view.widthAnchor
                                                                   constant:-100],
                              [_platter.heightAnchor constraintEqualToAnchor:self.view.heightAnchor
                                                                    constant:-20],
                              [_infoView.leadingAnchor constraintEqualToAnchor:_platter.leadingAnchor
                                                                      constant:268],
                              [_infoView.trailingAnchor constraintEqualToAnchor:_platter.trailingAnchor
                                                                       constant:-8.0],
                              [_infoView.centerYAnchor constraintEqualToAnchor:_platter.centerYAnchor
                                                                      constant:0],
                              [_infoView.heightAnchor constraintEqualToAnchor:_platter.heightAnchor
                                                                     constant:-20],
                              ];
    }
    for (NSLayoutConstraint *constraint in _platterConstraints) {
      constraint.active = YES;
    }
    [UIView animateWithDuration:0.25 animations:^{
      [self.view layoutIfNeeded];
    } ];
    
  }];
}

-(void)viewDidLayoutSubviews {
  _isPortrait = self.view.frame.size.height > self.view.frame.size.width;
  
  _blurView.frame = self.view.frame;
  if (_initialPositioning) {
    _avatarPlaceHolderView.frame = _avatarStartFrame;
    _avatarPlaceHolderView.layer.cornerRadius = _avatarStartFrame.size.width / 2.0;
  }
  _avatarPlaceHolderView.clipsToBounds = YES;
  _avatarImageView.image = _avatarImage;
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)tapHandler {
  [self dismiss];
}

- (void) dismiss {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
  animation.duration = 0.5;
  animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
  animation.fromValue = @(10);
  animation.toValue = @(_avatarStartFrame.size.width / 2.0);
  [_avatarPlaceHolderView.layer addAnimation:animation forKey:@"setCornerRadius:"];
  [UIView commitAnimations];

  for (NSLayoutConstraint *constraint in _platterConstraints) {
    constraint.active = NO;
  }
  [_infoView.centerYAnchor constraintEqualToAnchor:_platter.centerYAnchor
                                          constant:0].active = YES;
  [_infoView.centerXAnchor constraintEqualToAnchor:_platter.centerXAnchor
                                          constant:0].active = YES;
  
  [UIView animateWithDuration:0.25 animations:^{
    [self.view layoutIfNeeded];
    _infoView.alpha = 0;
    _platter.frame = _avatarPlaceHolderView.frame;
  } completion:^(BOOL finished) {
    [_platter removeFromSuperview];
    _initialPositioning = YES;
    for (NSLayoutConstraint *constraint in _avatarConstraints) {
      constraint.active = NO;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
      [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
      [self dismissViewControllerAnimated:NO completion:nil];
    }];
  }];
  
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
  [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
  [self dismiss];
}

@end
