//
//  WDImageBrowser.m
//  ImageBrowser
//
//  Created by wudan on 2019/4/17.
//  Copyright © 2019 wudan. All rights reserved.
//

#import "WDImageBrowser.h"
#import "WDImageCollectionViewCell.h"
#import "WDBrowserHelper.h"

typedef NS_ENUM(NSInteger, WDImageBrowserStyle) {
    WDImageBrowserStyleWebImage,
    WDImageBrowserStyleLocalImage
};

@interface WDImageBrowser () <UICollectionViewDelegate,
                             UICollectionViewDataSource,
                             WDImageCollectionViewCellDelegate>

@property (nonatomic, weak) id<WDImageBrowserDelegate>  delegate;
@property (nonatomic, copy) NSArray<NSString *> *imageUrls;
@property (nonatomic, copy) NSArray<UIImage *>  *loaclImages;
@property (nonatomic, strong) UIView            *originView;
@property (nonatomic, assign) NSInteger         tappedIndex;
@property (nonatomic, assign) WDImageBrowserStyle loadStyle;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UILabel *pageNumLabel;
@property (nonatomic, assign) NSInteger loadImageCount;
@end

@implementation WDImageBrowser

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.collectionView];
        [self addSubview:self.pageNumLabel];
    }
    return self;
}

- (void)setupWithDelegate:(id<WDImageBrowserDelegate>)delegate
              tappedIndex:(NSInteger)index
                   images:(NSArray<UIImage *> *)array
               originView:(UIView *)view {
    self.delegate = delegate;
    self.tappedIndex = index;
    self.loaclImages = array;
    self.originView = view;
    self.loadStyle = WDImageBrowserStyleLocalImage;
    self.loadImageCount = array.count;
}

- (void)setupWithDelegate:(id<WDImageBrowserDelegate>)delegate
              tappedIndex:(NSInteger)index
                imageUrls:(NSArray<NSString *> *)urls
               originView:(UIView *)view {
    self.delegate = delegate;
    self.tappedIndex = index;
    self.imageUrls = urls;
    self.originView = view;
    self.loadStyle = WDImageBrowserStyleWebImage;
    self.loadImageCount = urls.count;
}

- (void)dealloc {
    NSLog(@"====[%@]被销毁====", [self class]);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self showBrowserAniamtion];
}

- (void)showBrowserAniamtion {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.tappedIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    [self.collectionView layoutIfNeeded];
    
    WDImageCollectionViewCell *cell = (WDImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.tappedIndex inSection:0]];
    CGRect fromFrame                = [self.originView convertRect:self.originView.bounds toView:cell.contentView];
    cell.imageView.frame            = fromFrame;
    [UIView animateWithDuration:0.5 animations:^{
        self.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:1];
        cell.imageView.frame = cell.contentView.bounds;
    }];
}

- (void)showWebImageBrowser {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    self.backgroundColor   = [[UIColor alloc] initWithWhite:0 alpha:0];
    self.frame             = WD_SCREEN_BOUNDS;
    self.pageNumLabel.text = [NSString stringWithFormat:@"%ld / %ld", self.tappedIndex + 1, self.imageUrls.count];
}

- (void)showLocalImageBrowser {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    self.backgroundColor   = [[UIColor alloc] initWithWhite:0 alpha:0];
    self.frame             = WD_SCREEN_BOUNDS;
    self.pageNumLabel.text = [NSString stringWithFormat:@"%ld / %ld", self.tappedIndex + 1, self.loadImageCount];
}

- (void)showBrowser {
    if (self.imageUrls.count > 0) {
        [self showWebImageBrowser];
    } else {
        [self showLocalImageBrowser];
    }
}

#pragma mark - Private Method
- (void)hidenBrowserWithCell:(WDImageCollectionViewCell *)cell {
    CGRect toRect = [self.originView convertRect:self.originView.bounds toView:self.window];
    [UIView animateWithDuration:0.5 animations:^{
        cell.imageView.clipsToBounds = YES;
        cell.imageView.frame         = toRect;
        self.backgroundColor         = [[UIColor alloc] initWithWhite:0 alpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UICollectionView DataSource Method
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.loadImageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    WDImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"WDImageCollectionViewCell" forIndexPath:indexPath];
    if (self.loadStyle == WDImageBrowserStyleWebImage) {
        cell.imageUrl = self.imageUrls[indexPath.item];
    } else {
        cell.image = self.loaclImages[indexPath.item];
    }
    cell.delegate = self;
    return cell;
}

#pragma mark - UIScrollView Delegate Method
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index        = (NSInteger)(scrollView.contentOffset.x / WD_SCREEN_WIDTH);
    self.pageNumLabel.text = [NSString stringWithFormat:@"%ld / %ld", index + 1, self.loadImageCount];
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageBrowser:scrollAtIndex:)]) {
        self.originView = [self.delegate imageBrowser:self scrollAtIndex:index];
    }
}

#pragma mark - WDImageCollectionViewCell Delegate Method
- (void)collectionViewCell:(WDImageCollectionViewCell *)cell singleTapActionWithImageUrl:(NSString *)imageUrl {
    [self hidenBrowserWithCell:cell];
}

- (void)collectionViewCell:(WDImageCollectionViewCell *)cell dimssViewWithImageUrl:(nonnull NSString *)imageUrl {
    [self hidenBrowserWithCell:cell];
}

- (void)collectionViewCell:(WDImageCollectionViewCell *)cell panActionWithPercent:(CGFloat)percent {
    self.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:percent];
    self.pageNumLabel.alpha = percent;
}

#pragma mark - Getter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout             = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize                                = WD_SCREEN_SIZE;
        layout.minimumLineSpacing                      = 0;
        layout.scrollDirection                         = UICollectionViewScrollDirectionHorizontal;
        _collectionView                                = [[UICollectionView alloc] initWithFrame:WD_SCREEN_BOUNDS collectionViewLayout:layout];
        _collectionView.delegate                       = self;
        _collectionView.dataSource                     = self;
        _collectionView.pagingEnabled                  = YES;
        _collectionView.bounces                        = NO;
        _collectionView.backgroundColor                = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_collectionView registerClass:[WDImageCollectionViewCell class] forCellWithReuseIdentifier:@"WDImageCollectionViewCell"];
    }
    return _collectionView;
}

- (UILabel *)pageNumLabel {
    if (!_pageNumLabel) {
        _pageNumLabel               = [[UILabel alloc] init];
        _pageNumLabel.textColor     = [UIColor whiteColor];
        _pageNumLabel.textAlignment = NSTextAlignmentRight;
        _pageNumLabel.font          = [UIFont systemFontOfSize:13];
        _pageNumLabel.frame         = CGRectMake(WD_SCREEN_WIDTH - 50 - 10, WD_SCREEN_HEIGHT - 100, 50, 30);
    }
    return _pageNumLabel;
}

@end
