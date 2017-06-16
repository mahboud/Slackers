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
//  _layout = [[SlackersLayout alloc] init];
//  self.collectionView.collectionViewLayout = _layout;
  self.collectionView.showsHorizontalScrollIndicator = NO;
  self.collectionView.showsVerticalScrollIndicator = NO;
  //	layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//  _layout.itemSize = CGSizeMake(cell_width, cell_height);
  _dataModel = [[SlackersDataModel alloc] init];
  _numberOfSections = _dataModel.numberOfSections;
  _numberOfItems = _dataModel.numberOfItems;
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  
  [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(SlackersCell.class)
                                                  bundle:nil]
        forCellWithReuseIdentifier:NSStringFromClass(SlackersCell.class)];
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
                          cell.imageView.image = image;
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
    cell.imageView.image = image;
    [cell doneDownloaded];
  }
  //  else {
  //    cell.imageView.image = [UIImage imageNamed:@"slack-round"];
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
