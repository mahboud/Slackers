//
//  SlackersDataSource.h
//  Slackers
//
//  Created by mahboud on 6/15/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlackersDataSource : NSObject <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) UICollectionView *collectionView;

- (void)setup;
- (void)showCollectionView;


@end
