//
//  WDImageCollectionViewCell.h
//  ImageBrowser
//
//  Created by wudan on 2019/4/17.
//  Copyright © 2019 wudan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WDImageCollectionViewCell;
@protocol WDImageCollectionViewCellDelegate <NSObject>
- (void)collectionViewCell:(WDImageCollectionViewCell *)cell singleTapActionWithImageUrl:(NSString *)imageUrl;
- (void)collectionViewCell:(WDImageCollectionViewCell *)cell panActionWithPercent:(CGFloat)percent;
- (void)collectionViewCell:(WDImageCollectionViewCell *)cell dimssViewWithImageUrl:(NSString *)imageUrl;
@end

@interface WDImageCollectionViewCell : UICollectionViewCell
@property (nonatomic, weak) id<WDImageCollectionViewCellDelegate> delegate;
@property (nonatomic, copy) NSString *imageUrl;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong, readonly) UIImageView *imageView;
@end

NS_ASSUME_NONNULL_END
