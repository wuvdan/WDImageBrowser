//
//  WDImageBrowser.h
//  ImageBrowser
//
//  Created by wudan on 2019/4/17.
//  Copyright © 2019 wudan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class WDImageBrowser;

@protocol WDImageBrowserDelegate <NSObject>
@required
- (UIView *)imageBrowser:(WDImageBrowser *)browser scrollAtIndex:(NSInteger)index;
@end

@interface WDImageBrowser : UIView

- (void)setupWithDelegate:(nonnull id<WDImageBrowserDelegate>)delegate
              tappedIndex:(NSInteger)index
                   images:(nonnull NSArray<UIImage *> *)array
               originView:(nullable UIView *)view;

- (void)setupWithDelegate:(nonnull id<WDImageBrowserDelegate>)delegate
              tappedIndex:(NSInteger)index
                imageUrls:(nonnull NSArray<NSString *> *)urls
               originView:(nullable UIView *)view;

- (void)showBrowser;
@end

NS_ASSUME_NONNULL_END
