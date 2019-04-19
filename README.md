# WDImageBrowser
一直想写一个自己的图片浏览器，但是自己能力又不是很够，所以一直拖这，最近趁自己时间充裕，自己研究了一下这方面的知识。感觉有以下几个难点：
1. 显示和消失的转场动画
2. 手势拖拽
3.  图片加载

## 加载方式和转场动画
- 通过`Controller`加载：需要使用`ViewController`实现`UIViewControllerAnimatedTransitioning`实现转场效果
- 通过`View`加载：使用`UIView`动画试下转场效果

转场动画必要元素
1. 显示时需要`fromView`的`frame`
2. 消失时需要`toView`的`frame`
#### 显示
通过修改当前需要显示图片的`CollectionViewCell`中`ImageView`的`frame`，同时修改当期`View`的背景颜色透明度
```
WDImageCollectionViewCell *cell = (WDImageCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.tappedIndex inSection:0]];
CGRect fromFrame                = [self.originView convertRect:self.originView.bounds toView:cell.contentView];
cell.imageView.frame            = fromFrame;
[UIView animateWithDuration:0.5 animations:^{
    self.backgroundColor = [[UIColor alloc] initWithWhite:0 alpha:1];
    cell.imageView.frame = cell.contentView.bounds;
}];
```
#### 消失
原理与显示相同
```
CGRect toRect = [self.originView convertRect:self.originView.bounds toView:self.window];
[UIView animateWithDuration:0.5 animations:^{
    cell.imageView.clipsToBounds = YES;
    cell.imageView.frame         = toRect;
    self.backgroundColor         = [[UIColor alloc] initWithWhite:0 alpha:0];
} completion:^(BOOL finished) {
    [self removeFromSuperview];
}];
```
## 拖拽的手势
将手势添加在`CollectionViewCell`中`ScrollView`上，并遵循`UIGestureRecognizerDelegate`协议，不然会`CollectionView`无法进行滚动操作。
1. 声明一个全局属性
```
CGPoint firstTouchPoint;
```
2. 实现代理
```
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
    if (dirLift > -10 && dirLift < 10 && self.scrollView.frame.size.height > [[UIScreen mainScreen] bounds].size.height) {
        return NO;
    }
    return YES;
}
```
3. 拖动手势操作，同意代理传给`View`
- 协议方法
```
@class WDImageCollectionViewCell;
@protocol WDImageCollectionViewCellDelegate <NSObject>
- (void)collectionViewCell:(WDImageCollectionViewCell *)cell singleTapActionWithImageUrl:(NSString *)imageUrl;
- (void)collectionViewCell:(WDImageCollectionViewCell *)cell panActionWithPercent:(CGFloat)percent;
- (void)collectionViewCell:(WDImageCollectionViewCell *)cell dimssViewWithImageUrl:(NSString *)imageUrl;
@end
```
- 拖动手势方法
```
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
```
## 图片加载
使用`SDWebImage`获取图片，通过`FLAnimatedImageView`加载`gif`图
