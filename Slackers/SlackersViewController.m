//
//  SlackersViewController.m
//  Slackers
//
//  Created by mahboud on 6/15/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import "SlackersViewController.h"
#import "SlackersDataSource.h"

@interface SlackersViewController () <SlackerDataSourceDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) SlackersDataSource *dataSource;

@end

@implementation SlackersViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  _dataSource = [[SlackersDataSource alloc] init];
  _dataSource.collectionView = _collectionView;
  _dataSource.delegate = self;
  [_dataSource setup];
  
  _collectionView.alpha = 0;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

-(void)viewDidAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [_dataSource showCollectionView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
