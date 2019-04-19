//
//  WDImageCollectionViewCell.m
//  ImageBrowser
//
//  Created by wudan on 2019/4/17.
//  Copyright © 2019 wudan. All rights reserved.
//

#import "WDImageCollectionViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <FLAnimatedImage.h>
#import <Photos/Photos.h>
#import "WDBrowserHelper.h"

@interface WDImageCollectionViewCell () <UIGestureRecognizerDelegate, UIScrollViewDelegate>
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) FLAnimatedImageView *imageView;
@end

@implementation WDImageCollectionViewCell{
    CGPoint firstTouchPoint;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
        [self addPanGusture];
    }
    return self;
}

- (void)setupSubViews {
    self.scrollView                                = [[UIScrollView alloc] init];
    self.scrollView.delegate                       = self;
    self.scrollView.minimumZoomScale               = 1.0;
    self.scrollView.maximumZoomScale               = 2.0;
    self.scrollView.bounces                        = YES;
    self.scrollView.showsVerticalScrollIndicator   = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bouncesZoom                    = YES;
    self.scrollView.decelerationRate               = UIScrollViewDecelerationRateFast;
    if (@available(iOS 11.0, *)) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    [self.contentView addSubview:self.scrollView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = [[UIScreen mainScreen] bounds];
}

#pragma mark - UIGestureRecognizer Delegate Method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    firstTouchPoint = [touch locationInView:self.window];
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint touchPoint = [gestureRecognizer locationInView:self.window];
    CGFloat dirTop = firstTouchPoint.y - touchPoint.y;
    if (dirTop > -10 && dirTop < 10) {
        return NO;
    }
    CGFloat dirLift = firstTouchPoint.x - touchPoint.x;
    if (dirLift > -10 && dirLift < 10 && self.imageView.frame.size.height > [[UIScreen mainScreen] bounds].size.height) {
        return NO;
    }
    return YES;
}

#pragma mark - UIGestureRecognizer Target Event
/** 滑动手势 */
- (void)didRecognizedPanGuesture:(UIPanGestureRecognizer *)pan {
    
    CGPoint point = [pan translationInView:self.window];
    CGFloat scale = 1.0 - ABS(point.y) / [[UIScreen mainScreen] bounds].size.height;
    switch (pan.state) {
        case UIGestureRecognizerStateBegan: {}
            break;
        case UIGestureRecognizerStateChanged:
        {
            scale = MAX(scale, 0);
            CGFloat s = MAX(scale, 0.5);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(point.x / s, point.y / s);
            CGAffineTransform translationScale = CGAffineTransformMakeScale(s, s);
            self.imageView.transform = CGAffineTransformConcat(translation, translationScale);
            // 传出translationScale，修改背景颜色透明度
            if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewCell:panActionWithPercent:)]) {
                [self.delegate collectionViewCell:self panActionWithPercent:scale];
            }
        }
            break;
        case  UIGestureRecognizerStateCancelled | UIGestureRecognizerStateFailed:
        {
            self.imageView.transform = CGAffineTransformIdentity;
            // 回复初始样式，传出translationScale，修改背景颜色透明度
            if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewCell:panActionWithPercent:)]) {
                [self.delegate collectionViewCell:self panActionWithPercent:1];
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            [UIView animateWithDuration:0.5 animations:^{
                CGAffineTransform transform1 = CGAffineTransformMakeTranslation(0,0);
                self.imageView.transform = CGAffineTransformScale(transform1, 1, 1);
            }];
            
            // 回复初始样式，传出translationScale，修改背景颜色透明度
            if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewCell:panActionWithPercent:)]) {
                [self.delegate collectionViewCell:self panActionWithPercent:scale];
            }
            if (scale < 0.7) {
                // 拖动结束，让页面消失
                if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewCell:dimssViewWithImageUrl:)]) {
                    [self.delegate collectionViewCell:self dimssViewWithImageUrl:self.imageUrl];
                }
            } else {
                // 回复初始样式，传出translationScale，修改背景颜色透明度
                if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewCell:panActionWithPercent:)]) {
                    [self.delegate collectionViewCell:self panActionWithPercent:1];
                }
            }
        }
            break;
        default:
            break;
    }
}

/** 消失或缩小 */
- (void)didRecognizedSingalTap:(id)sender {
    if (self.scrollView.zoomScale > 1) {
        [self.scrollView setZoomScale:1 animated:YES];
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(collectionViewCell:singleTapActionWithImageUrl:)]) {
        [self.delegate collectionViewCell:self singleTapActionWithImageUrl:self.imageUrl];
    }
}

/** 双击放大或缩小 */
- (void)didRecognizedDoubleTap:(UIGestureRecognizer *)sender {
    float newScale = self.scrollView.zoomScale;
    BOOL isEqual = [[NSString stringWithFormat:@"%f", newScale] isEqualToString:[NSString stringWithFormat:@"%f", self.scrollView.minimumZoomScale]];
    if (isEqual) {
        newScale = self.scrollView.maximumZoomScale;
    } else {
        newScale = self.scrollView.minimumZoomScale;
    }
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[sender locationInView:sender.view]];
    [self.scrollView zoomToRect:zoomRect animated:YES];
}

/** 长按图片触摸事件 */
- (void)didRecognizedLongGuesture:(UILongPressGestureRecognizer *)sender {
    if (sender.state != UIGestureRecognizerStateBegan) {
        return;
    }

    [WDAlterView showAlterInView:self.contentView
                       mainTitle:@"温馨提示"
                        subTitle:@"是否保存图片到相册？"
                actionTitleArray:@[@"确定"]
               cancelActionTitle:@"取消" actionBlock:^(NSInteger index) {
                    [self saveImageToAblum];
               }];
}

/** 保存图片到相册 */
- (void)saveImageToAblum {
    // 本地图片不保存
    if (self.imageUrl.length == 0) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:self.imageUrl]];
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:data options:nil];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(success && !error){
                    [WDImageBrowserHUD showTitle:@"保存图片成功" inView:self.contentView];
                } else {
                    [WDImageBrowserHUD showTitle:@"保存图片失败" inView:self.contentView];
                }
            });
        }];
    });
}
#pragma mark - Private Method
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    CGSize size = CGSizeMake(self.scrollView.bounds.size.width / scale,
                             self.scrollView.bounds.size.height / scale);
    CGRect rect = CGRectMake(center.x - (size.width / 2.0),
                             center.y - (size.height / 2.0),
                             size.width,
                             size.height);
    return rect;
}

- (void)addPanGusture {
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizedPanGuesture:)];
    self.panGestureRecognizer.delegate = self;
    if (![self.scrollView.gestureRecognizers containsObject:self.panGestureRecognizer]){
        [self.scrollView addGestureRecognizer:self.panGestureRecognizer];
    }
}

- (void)addTapGusture {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizedDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.imageView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singalTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizedSingalTap:)];
    [singalTap requireGestureRecognizerToFail:doubleTap];
    [singalTap setNumberOfTapsRequired:1];
    [self.scrollView addGestureRecognizer:singalTap];
}

- (void)addLongGusture {
    UILongPressGestureRecognizer *longGuesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizedLongGuesture:)];
    [self.contentView addGestureRecognizer:longGuesture];
}

#pragma mark -- UIScrollView Delegate Method
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width){
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2 ;
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height){
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    } else {
        frameToCenter.origin.y = 0;
    }
    self.imageView.frame = frameToCenter;
}

#pragma mark - Setter
- (void)setImage:(UIImage *)image {
    _image = image;
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
        self.imageView.image = nil;
    }
    
    [self.scrollView setZoomScale:1 animated:YES];
    self.imageView                        = [[FLAnimatedImageView alloc] init];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.layer.masksToBounds    = YES;
    self.imageView.backgroundColor        = [UIColor lightGrayColor];
    self.imageView.contentMode            = UIViewContentModeScaleAspectFill;
    [self.scrollView addSubview:self.imageView];
    [self setupImageView:image];
}

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    if (self.imageView) {
        [self.imageView removeFromSuperview];
        self.imageView = nil;
        self.imageView.image = nil;
    }
    
    [self.scrollView setZoomScale:1 animated:YES];
    self.imageView                        = [[FLAnimatedImageView alloc] init];
    self.imageView.userInteractionEnabled = YES;
    self.imageView.layer.masksToBounds    = YES;
    self.imageView.backgroundColor        = [UIColor lightGrayColor];
    self.imageView.contentMode            = UIViewContentModeScaleAspectFill;
    [self.scrollView addSubview:self.imageView];

    WDImageBrowserHUD *hud = [[WDImageBrowserHUD alloc] init];
    [hud showHUDInView:self.contentView];
    
    __weak typeof(self) weakself = self;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        __weak typeof(weakself) strongself = weakself;
        [hud hidenHUD];
        [strongself setupImageView:image];
    }];
}

- (void)setupImageView:(UIImage *)image {
    self.imageView.image = image;
    CGFloat imageW = self.frame.size.width;
    CGFloat rotaion = (image.size.width / (image.size.height > 0 ? image.size.height : imageW)) ;
    if(rotaion <= 0.0f){
        rotaion = 1.0;
    }
    CGFloat imageH = imageW/rotaion;
    CGFloat originY = 0.0;
    if (imageH > self.contentView.frame.size.height) {
        originY = 0;
    } else {
        originY = (self.contentView.frame.size.height - imageH) / 2.0;
    }
    
    CGRect imgViewRect = CGRectMake(0, originY,  WD_SCREEN_WIDTH, imageH);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.imageView.frame = imgViewRect;
    });
    self.scrollView.contentSize = CGSizeMake(imageW, imageH);
    [self addTapGusture];
    [self addLongGusture];
}

@end
