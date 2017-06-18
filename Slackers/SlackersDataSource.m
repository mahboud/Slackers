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
  _numberOfSections = _dataModel.numberOfSections;
  _numberOfItems = _dataModel.numberOfItems;
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(SlackersCell.class)
                                                  bundle:nil]
        forCellWithReuseIdentifier:NSStringFromClass(SlackersCell.class)];
  [_dataModel fetchNewDataWithCompletionHandler:^(void) {
    _numberOfSections = _dataModel.numberOfSections;
    _numberOfItems = _dataModel.numberOfItems;
    [self.collectionView reloadData];
    NSLog(@"reloading");
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

  cell.indexPath = indexPath;
  cell.slackID = [_dataModel getIDForPath:indexPath];
  cell.label.text = [NSString stringWithFormat:@"%@", [_dataModel getNameForID:cell.slackID]];
  NSLog(@"%s: getting image for id: %@ index: %@", __PRETTY_FUNCTION__, cell.slackID, indexPath);
  UIImage *image = [_dataModel getImageForID:cell.slackID completionHandler:^(UIImage *image) {
    dispatch_async(dispatch_get_main_queue(), ^ {
      if (image == nil)
        return;
      SlackersCell *cell = (SlackersCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
      NSLog(@"%s: got image for id: %@, image %@, indexPath %@", __PRETTY_FUNCTION__, cell.slackID, image, cell.indexPath);
      if (cell) {
        [self transitionImage:image intoCell:cell];
      }
    });
  }];
  if (image) {
    cell.image = image;
    [cell doneDownloaded];
  }
  return cell;
  
}

// The following is necessary for iOS 10, since the above does some prefetching.
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SlackersCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"%s: getting image for id: %@ indexPath: %@, cell.index %@", __PRETTY_FUNCTION__, cell.slackID, indexPath, cell.indexPath);
 UIImage *image = [_dataModel getImageForID:cell.slackID completionHandler:^(UIImage *image) {
   NSLog(@"%s: got image for id: %@, image %@ index: %@, cellindex: %@", __PRETTY_FUNCTION__, cell.slackID, image, indexPath, cell.indexPath);
   if (indexPath.item != cell.indexPath.item )
     NSLog(@"Oh oh" );
    dispatch_async(dispatch_get_main_queue(), ^ {
      [self transitionImage:image intoCell:cell];
    });
  }];
  if (image) {
    cell.image = image;
    [cell doneDownloaded];
  }
}

- (void)transitionImage:(UIImage *)image intoCell:(SlackersCell *)cell {
  if (image == nil)
    return;
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

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  CGFloat width = cell_width;
  CGFloat height = cell_height;
  
  return CGSizeMake(width, height);
}

@end
