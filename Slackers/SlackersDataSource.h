//
//  SlackersDataSource.h
//  Slackers
//
//  Created by mahboud on 6/15/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SlackerDataSourceDelegate
@required
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;
@end

@interface SlackersDataSource : NSObject <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic) UICollectionView *collectionView;

- (void)setup;
- (void)showCollectionView;

@property (nonatomic, weak) id <SlackerDataSourceDelegate> delegate;

@end
