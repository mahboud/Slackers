//
//  SlackersCellsCollectionViewCell.h
//  Slackers
//
//  Created by mahboud on 6/15/17.
//  Copyright © 2017 BitsOnTheGo.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlackersCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UILabel *label;

- (void)doneDownloaded;

@end
