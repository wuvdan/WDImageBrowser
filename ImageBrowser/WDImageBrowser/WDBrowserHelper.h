//
//  WDBrowserHelper.h
//  ImageBrowser
//
//  Created by wudan on 2019/4/18.
//  Copyright © 2019 wudan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define WD_SCREEN_BOUNDS  (UIScreen.mainScreen.bounds)
#define WD_SCREEN_SIZE    (UIScreen.mainScreen.bounds.size)
#define WD_SCREEN_WIDTH   (UIScreen.mainScreen.bounds.size.width)
#define WD_SCREEN_HEIGHT  (UIScreen.mainScreen.bounds.size.height)

@interface WDAlterView : UIView
+ (void)showAlterInView:(UIView *)view
              mainTitle:(NSString *)mainTitle
               subTitle:(NSString *)subTitle
       actionTitleArray:(NSArray<NSString *> *)actionTitleArray
      cancelActionTitle:(NSString *)cancelTitle
            actionBlock:(void(^)(NSInteger index))block;
@end

@interface WDImageBrowserHUD : UIView
+ (void)showTitle:(NSString *)title inView:(UIView *)view;
- (void)showHUDInView:(UIView *)view;
- (void)hidenHUD;
@end

