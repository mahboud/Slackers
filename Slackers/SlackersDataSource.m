//
//  SlackersDataSource.m
//  Slackers
//
//  Created by mahboud on 6/15/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import "SlackersDataSource.h"

#import "SlackersCell.h"
#import "SlackersDataModel.h"
#import "SlackersDetailsViewController.h"
#import "SlackersGeometry.h"

@interface SlackersDataSource () <SlackersDataModelDelegate>
@end

@implementation SlackersDataSource {
  SlackersDataModel *_dataModel;
}

- (void)setup {
  self.collectionView.showsVerticalScrollIndicator = YES;
  _dataModel = [[SlackersDataModel alloc] init];
  _dataModel.delegate = self;
  self.collectionView.dataSource = self;
  self.collectionView.delegate = self;
  [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(SlackersCell.class)
                                                  bundle:nil]
        forCellWithReuseIdentifier:NSStringFromClass(SlackersCell.class)];
  [_dataModel fetchNewData];
}

- (void) showCollectionView {
  [self.collectionView setNeedsFocusUpdate];
  
  [UIView animateWithDuration: 1.0
                   animations:^{
                     _collectionView.alpha = 1.0;
                   }];
}

- (void)reloadData {
  [self.collectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return _dataModel.numberOfSections;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  return _dataModel.numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath; {
  NSString *cellId;
  
  cellId = NSStringFromClass(SlackersCell.class);
  SlackersCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];

  cell.slackID = [_dataModel getIDForPath:indexPath];
  cell.label.text = [NSString stringWithFormat:@"%@", [_dataModel getNameForID:cell.slackID]];
  UIImage *image = [_dataModel getImageForID:cell.slackID completionHandler:^(UIImage *image) {
    dispatch_async(dispatch_get_main_queue(), ^ {
      if (image == nil)
        return;
      SlackersCell *cell = (SlackersCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
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


#if 0
// The following is necessary for iOS 10, since the above does some prefetching.
// I'm not going to spend much time worrying about this since iOS10+ support is
// not a requirement.
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(SlackersCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"%s: getting image for id: %@ indexPath: %@, cell.index %@ %d", __PRETTY_FUNCTION__, cell.slackID, indexPath, cell.indexPath, __IPHONE_OS_VERSION_MAX_ALLOWED);
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
#endif

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

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  SlackersCell *cell = (SlackersCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
  SlackersDetailsViewController *detailsVC = [[SlackersDetailsViewController alloc] init];
  detailsVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
  detailsVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
  detailsVC.avatarImage = cell.imageView.image;
  detailsVC.avatarStartFrame =
  [collectionView.superview convertRect:[cell convertRect:cell.imageView.frame fromView:cell.circleView] fromView:cell];
  NSMutableString *tempString = [NSMutableString stringWithFormat:@"%@\nID:%@", [_dataModel getNameForID:cell.slackID], cell.slackID];
  NSString *emailString = [_dataModel getEmailForID:cell.slackID];
  NSString *phoneString = [_dataModel getPhoneForID:cell.slackID];
  if (emailString.length) {
    [tempString appendString:@"\n"];
    [tempString appendString:emailString];
  }
  if (phoneString.length) {
    [tempString appendString:@"\n"];
    [tempString appendString:phoneString];
  }
  NSArray *isSometingStringsArray = @[
                                      [_dataModel isDeletedForID:cell.slackID] ? @"Deleted, " : @"",
                                      [_dataModel isAdminForID:cell.slackID] ? @"Administrator, " : @"",
                                      [_dataModel isBotForID:cell.slackID] ? @"Bot\n" : @"",
                                      [_dataModel isOwnerForID:cell.slackID] ? @"Owner, " : @"",
                                      [_dataModel isPrimaryOwnerForID:cell.slackID] ? @"Primary Owner\n" : @"",
                                      [_dataModel isRestrictedForID:cell.slackID] ? @"Restricted, " : @"",
                                      [_dataModel isUltraRestricted:cell.slackID] ? @"Ultra Restricted\n" : @"",
                                      ];
  NSString *isSometingStrings = [isSometingStringsArray componentsJoinedByString:@""];
  if (isSometingStrings.length) {
    [tempString appendString:@"\n"];
    [tempString appendString:isSometingStrings];
  }
  NSString *teamIDString = [_dataModel teamIDForID:cell.slackID];
  if (teamIDString) {
    [tempString appendString:@"\nTeam ID: "];
    [tempString appendString:teamIDString];
  }
  NSString *tzLabelString = [_dataModel tzLabelForID:cell.slackID];
  if (tzLabelString) {
    [tempString appendString:@"\n"];
    [tempString appendString:tzLabelString];
  }
  
  detailsVC.formattedDetailString = tempString.copy;
  detailsVC.userColor = [_dataModel getColorForID:cell.slackID];
  [_delegate presentViewController:detailsVC animated:YES completion:nil];
}
@end
