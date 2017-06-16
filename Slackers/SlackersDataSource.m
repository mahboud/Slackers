//
//  SlackersDataSource.m
//  Slackers
//
//  Created by mahboud on 6/15/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import "SlackersDataSource.h"

#import "SlackersCell.h"
//#import "SlackersLayout.h"
#import "SlackersDataModel.h"
#import "SlackersGeometry.h"

@implementation SlackersDataSource {
//  SlackersLayout *_layout;
  NSInteger _numberOfSections;
  NSInteger _numberOfItems;
  SlackersDataModel *_dataModel;
}

- (void)setup {
  self.collectionView.showsVerticalScrollIndicator = YES;
  _dataModel = [[SlackersDataModel alloc] init];
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(SlackersCell.class)
                                                  bundle:nil]
        forCellWithReuseIdentifier:NSStringFromClass(SlackersCell.class)];
  [_dataModel fetchNewDataWithCompletionHandler:^(void) {
    _numberOfSections = _dataModel.numberOfSections;
    _numberOfItems = _dataModel.numberOfItems;
    [self.collectionView reloadData];
  }];
}

- (void) showCollectionView {
  [self.collectionView setNeedsFocusUpdate];
  
  [UIView animateWithDuration: 1.0
                   animations:^{
                     _collectionView.alpha = 1.0;
                   }];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  
  return _numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  
  return _numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
  NSString *cellId;
  
  cellId = NSStringFromClass(SlackersCell.class);
  SlackersCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
  
  cell.label.text = [NSString stringWithFormat:@"%@(%ld,%ld)", [_dataModel getNameForPath:indexPath], (long)indexPath.section, (long)indexPath.item];
  UIImage *image = [_dataModel getImageForPath:indexPath completionHandler:^(UIImage *image) {
    dispatch_async(dispatch_get_main_queue(), ^ {
      SlackersCell *cell = (SlackersCell *) [self.collectionView cellForItemAtIndexPath:indexPath];
      if (cell) {
        [UIView transitionWithView:cell.imageView
                          duration:0.5f
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^(void) {
                          cell.image = image;
                        }
                        completion:^(BOOL finished) {
                          [cell doneDownloaded];
                          if (finished) {
                          }
                        }];
      }
    });
  }];
  if (image) {
    cell.image = image;
    [cell doneDownloaded];
  }
  //  else {
  //    cell.image = [UIImage imageNamed:@"slack-round"];
  //  }
  return cell;
  
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat width = cell_width;
  CGFloat height = cell_height;
  
  return CGSizeMake(width, height);
}

@end
