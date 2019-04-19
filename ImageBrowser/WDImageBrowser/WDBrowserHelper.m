//
//  WDBrowserHelper.m
//  ImageBrowser
//
//  Created by wudan on 2019/4/18.
//  Copyright © 2019 wudan. All rights reserved.
//

#import "WDBrowserHelper.h"

#define alter_actionHeight      45 * WD_SCREEN_WIDTH/375.0
#define alter_cancelSpece       5 * WD_SCREEN_WIDTH/375.0
#define alter_mainTitleHeight   alter_actionHeight + alter_cancelSpece
#define alter_FontSize(s)       [UIFont systemFontOfSize:s * WD_SCREEN_WIDTH/375.0]

#pragma mark WDAlterView
@interface WDAlterView ()
@property (nonatomic) CGRect                        conterViewRect;
@property (nonatomic, strong) UIView                *contanerView;
@property (nonatomic, copy) void(^titleButtonTappedBlock)(NSInteger index);
@end

@implementation WDAlterView

+ (instancetype)alter {
    static dispatch_once_t onceToken;
    static WDAlterView *alter;
    dispatch_once(&onceToken, ^{
        alter = [[WDAlterView alloc] init];
    });
    return alter;
}

+ (void)showAlterInView:(UIView *)view
              mainTitle:(NSString *)mainTitle
               subTitle:(NSString *)subTitle
       actionTitleArray:(NSArray<NSString *> *)actionTitleArray
      cancelActionTitle:(NSString *)cancelTitle
            actionBlock:(void(^)(NSInteger index))block {
    
    [[WDAlterView alter] showAlterInView:view
                               mainTitle:mainTitle
                                subTitle:subTitle
                        actionTitleArray:actionTitleArray
                             actionBlock:block
                       cancelActionTitle:cancelTitle];
}

- (void)showAlterInView:(UIView *)view
              mainTitle:(NSString *)mainTitle
               subTitle:(NSString *)subTitle
       actionTitleArray:(NSArray<NSString *> *)actionTitleArray
            actionBlock:(void(^)(NSInteger index))block
      cancelActionTitle:(NSString *)cancelTitle {
    
    self.titleButtonTappedBlock = block;
    CGFloat width           = alter_actionHeight * (actionTitleArray.count + 1) + alter_cancelSpece + alter_mainTitleHeight;
    self.contanerView.frame = CGRectMake(0, [self safeScreenHeight] - width, WD_SCREEN_WIDTH, width);
    [self addSubview:self.contanerView];
    
    UILabel *titleLabel     = [self setupMainTitle:mainTitle subTitle:subTitle];
    titleLabel.frame        = CGRectMake(0, 0, WD_SCREEN_WIDTH, alter_mainTitleHeight);
    [self.contanerView addSubview:titleLabel];
    
    UIButton *cancelButton  = [self cancelButtonWithTitle:cancelTitle];
    cancelButton.frame      = CGRectMake(0, self.contanerView.frame.size.height - alter_actionHeight, WD_SCREEN_WIDTH, alter_actionHeight);
    [self.contanerView addSubview:cancelButton];
    
    for (NSString *name in actionTitleArray) {
        UIButton *button = [self setupActionWithTitle:name];
        NSInteger index  = [actionTitleArray indexOfObject:name];
        button.tag       = 1000 + index;
        button.frame     = CGRectMake(0, titleLabel.frame.size.height + 0.5 + alter_actionHeight * index, WD_SCREEN_WIDTH, alter_actionHeight - 0.5);
        [self.contanerView addSubview:button];
    }
    self.conterViewRect = self.contanerView.frame;

    [self showAlterInView:view];
}

- (void)showAlterInView:(UIView *)view {
    [UIApplication.sharedApplication.delegate.window addSubview:self];
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.frame           = CGRectMake(0, 0, WD_SCREEN_WIDTH, WD_SCREEN_HEIGHT);
    self.alpha           = 0;
    self.contanerView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.height, 0);
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha              = 1;
        self.contanerView.frame = self.conterViewRect;
    }];
}

/** Event button style */
- (UIButton *)setupActionWithTitle:(NSString *)title {
    UIButton *button       = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    button.titleLabel.font = alter_FontSize(15);
    [button addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

/** Cancel button style */
- (UIButton *)cancelButtonWithTitle:(NSString *)title {
    UIButton *button       = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.9 green:0 blue:0 alpha:1] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    button.titleLabel.font = alter_FontSize(15);
    [button addTarget:self action:@selector(hidenAlter) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

/** Title style */
- (UILabel *)setupMainTitle:(NSString *)title subTitle:(NSString *)subTitle {
    NSString *titleString;
    
    if (subTitle.length == 0) {
        titleString = [NSString stringWithFormat:@"%@",title];
    } else {
        titleString = [NSString stringWithFormat:@"%@\n%@",title,subTitle];
    }
    
    UILabel *label                         = [[UILabel alloc] init];
    label.backgroundColor                  = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    label.textColor                        = UIColor.blackColor;
    label.font                             = alter_FontSize(15);
    NSMutableAttributedString *muAttribute = [[NSMutableAttributedString alloc] initWithString:titleString];
    
    [muAttribute addAttribute:NSFontAttributeName value:alter_FontSize(12) range:NSMakeRange(titleString.length - subTitle.length, subTitle.length)];
    [muAttribute addAttribute:NSForegroundColorAttributeName value:UIColor.grayColor range:NSMakeRange(titleString.length - subTitle.length, subTitle.length)];
    
    label.textAlignment                    = NSTextAlignmentCenter;
    label.numberOfLines                    = 2;
    label.attributedText                   = muAttribute;
    return label;
}

#pragma mark - Button click events and delegate

- (void)buttonTouched:(UIButton *)sender {
    [self hidenAlter];
    self.titleButtonTappedBlock(sender.tag - 1000);
}

- (void)hidenAlter {
    [UIView animateWithDuration:0.4 animations:^{
        self.alpha              = 0;
        self.contanerView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height, UIScreen.mainScreen.bounds.size.height, 0);
    } completion:^(BOOL finished) {
        for (UIView *view in self.contanerView.subviews) {
            [view removeFromSuperview];
        }
        [self removeFromSuperview];
    }];
}

/** iOS 11 safeArea bottom space */
- (CGFloat)safeScreenHeight {
    CGFloat safeAreaInsetsBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeAreaInsetsBottom = UIApplication.sharedApplication.delegate.window.safeAreaInsets.bottom;
    } else {
        safeAreaInsetsBottom = 0;
    }
    return WD_SCREEN_HEIGHT - safeAreaInsetsBottom;
}

- (UIView *)contanerView {
    if (!_contanerView) {
        _contanerView                 = [[UIView alloc] init];
        _contanerView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:0.5];
    }
    return _contanerView;
}
@end

#pragma mark WDImageBrowserHUD
@interface WDImageBrowserHUD ()
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation WDImageBrowserHUD

+ (void)showTitle:(NSString *)title inView:(UIView *)view {
    WDImageBrowserHUD *v = [[WDImageBrowserHUD alloc] init];
    
    [view addSubview:v];
    
    v.titleLabel = [[UILabel alloc] init];
    v.titleLabel.text = title;
    v.titleLabel.textAlignment =  NSTextAlignmentCenter;
    v.titleLabel.textColor = [UIColor whiteColor];
    v.titleLabel.font = [UIFont systemFontOfSize:15];
    [view addSubview:v.titleLabel];
    
    v.bounds = CGRectMake(0, 0, 100, 45);
    v.center = view.center;
    v.layer.cornerRadius = 10;
    v.layer.masksToBounds = YES;
    v.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:0.8];
    
    v.titleLabel.bounds = CGRectMake(0, 0, 100, 45);
    v.titleLabel.center = view.center;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            v.alpha = 0;
            v.titleLabel.alpha = 0;
        } completion:^(BOOL finished) {
            [v removeFromSuperview];
            [v.titleLabel removeFromSuperview];
        }];
    });
}

- (void)showHUDInView:(UIView *)view {
    [view addSubview:self];
    self.bounds = CGRectMake(0, 0, 60, 60);
    self.center = view.center;
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:0.3];
    
    self.indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.indicatorView startAnimating];
    self.indicatorView.bounds = CGRectMake(0, 0, 60, 60);
    self.indicatorView.center = self.center;
    [view addSubview:self.indicatorView];
}

- (void)hidenHUD {
    if (!self.indicatorView) {
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
        self.indicatorView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.indicatorView removeFromSuperview];
    }];
}
@end
