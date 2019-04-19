//
//  SudoViewController.m
//  ImageBrowser
//
//  Created by wudan on 2019/4/19.
//  Copyright © 2019 wudan. All rights reserved.
//

#import "SudoViewController.h"
#import <Masonry.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "WDImageBrowser.h"
@interface SudoViewController () <WDImageBrowserDelegate>
@property (nonatomic, copy) NSArray<NSString *> *imageUrls;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViews;
@end

@implementation SudoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"For Loop Load Image";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.imageUrls = @[@"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=3212714488,2445925646&fm=26&gp=0.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555490703879&di=810fd2230fe6737e31ea771bb87a8f09&imgtype=0&src=http%3A%2F%2Fatt2.citysbs.com%2Fhangzhou%2F2016%2F12%2F11%2F21%2Fmiddle_780x754-211635_v2_12261481462195135_38f391870a6273fb9786ccdf76b7dece.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555490703878&di=eb570c964181efe82ef7be95db6a5e4d&imgtype=0&src=http%3A%2F%2Fimg0.pconline.com.cn%2Fpconline%2F1503%2F12%2F6209157_09_thumb.jpg",
                       @"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=2580910037,3876105696&fm=26&gp=0.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1556087439&di=9e4fdd967b8926000303d07c7da17155&imgtype=jpg&er=1&src=http%3A%2F%2Fforum.xitek.com%2F200810%2F2230%2F223042%2F223042_1224879110.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555492755145&di=8edf7e706edf4c7b5757833bffdb7f3c&imgtype=0&src=http%3A%2F%2Fwx4.sinaimg.cn%2Forj360%2F0063FsdJly1g1y4pj49doj30u04nbkjm.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555492755145&di=cdbc966589125af5c4de8173708a9112&imgtype=0&src=http%3A%2F%2Fwx3.sinaimg.cn%2Forj360%2F006cpBwyly1fwhcxzv22pj30rs31xqv5.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555501220373&di=a87788bb48dbb178b944076dec0af073&imgtype=0&src=http%3A%2F%2Fimg.qqzhi.com%2Fuploads%2F2019-02-28%2F093511711.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555501220373&di=28cb8af3a84c72e45b219af33dfa15ca&imgtype=0&src=http%3A%2F%2Fimg.qqzhi.com%2Fuploads%2F2019-02-27%2F165616170.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555501220372&di=16248c9ce10f6b808137f9d7b37017e6&imgtype=0&src=http%3A%2F%2Ftupian.qqjay.com%2Ftou2%2F2018%2F0812%2Fb03b779829e9c4628d36cf02037b6eb1.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555501220372&di=c82606c9c6579b6bfe8f79fed161c209&imgtype=0&src=http%3A%2F%2Fimg.qqzhi.com%2Fuploads%2F2019-02-27%2F165604685.jpg",
                        @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1556170554&di=e1573808eb527d3146b5e63a8e2f175c&imgtype=jpg&er=1&src=http%3A%2F%2Fattach.bbs.miui.com%2Fforum%2F201804%2F14%2F115228gf92z731fl2slzvv.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555576259580&di=5fe04c8c2b1e02429a62b6fe36604d37&imgtype=0&src=http%3A%2F%2Fphotocdn.sohu.com%2F20150721%2Fmp23627612_1437451852870_2.gif",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555576260024&di=d95fdf8a927f2f0cf39dcaf25a4a0a03&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201711%2F05%2F20171105001828_e8tPd.thumb.224_0.gif",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1556171140&di=ea4d95e8756c6d5aeaaa5acf66969aec&imgtype=jpg&er=1&src=http%3A%2F%2F5b0988e595225.cdn.sohucs.com%2Fimages%2F20170921%2F7eca427441714963ad04b2633cb04436.gif",
                       @"https://upload-images.jianshu.io/upload_images/3334769-0b94020c5e06325c.gif",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555584022099&di=f2ded6b9c2b4693d547ef5ca8dcc95d8&imgtype=0&src=http%3A%2F%2Fimg.dijiu.com%2F2015%2F0914%2F20150914112834235.gif",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555584212846&di=3d56d2218917ff6acf5025e7f2e24be6&imgtype=0&src=http%3A%2F%2Fimg.mp.itc.cn%2Fupload%2F20161012%2F2b44b77ef7a246929c9de92178947fe0.gif",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555584212844&di=1230dc6fd85fa8245b6b666e20cb7b11&imgtype=0&src=http%3A%2F%2Fimg.alicdn.com%2Fimgextra%2Fi2%2F3369625464%2FTB2PJS8mPuhSKJjSspjXXci8VXa_%2521%25213369625464-1-daren.gif",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555584658453&di=316a2d7d3d0069f5b3acf3c6a4dce444&imgtype=0&src=http%3A%2F%2Fa.hiphotos.baidu.com%2Fzhidao%2Fpic%2Fitem%2F6a63f6246b600c330ffe56ee1e4c510fd9f9a115.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555584820531&di=8d5eb684c5db198937171d24d5454795&imgtype=0&src=http%3A%2F%2Fphotocdn.sohu.com%2F20160107%2Fmp52879019_1452129409544_8.gif",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555585293420&di=3d3d69b0c3f9d0158c2bbd8be0dc5b9a&imgtype=0&src=http%3A%2F%2Fs3.sinaimg.cn%2Fmw690%2F002c2mEVzy7nKnBsVCqc2%26690",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555585293419&di=530f34b8418f4054aca4df011bfcfe06&imgtype=0&src=http%3A%2F%2Fimg.mp.itc.cn%2Fupload%2F20160930%2Ffa901cc3c3cb4a44b54237bb1d3b0ce0_th.gif",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555585516293&di=2a6435253421d15979077a68940cfc59&imgtype=0&src=http%3A%2F%2Fb-ssl.duitang.com%2Fuploads%2Fitem%2F201706%2F11%2F20170611201023_nehzP.thumb.700_0.gif",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1555585578153&di=87f0962911d82be491a3d63b5fc634a5&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01ed1057a8177c0000012e7e144951.gif"];
    
    self.imageViews = [NSMutableArray array];
    
    [self.imageUrls enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView sd_setImageWithURL:[NSURL URLWithString:obj]];
        imageView.tag = idx;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)]];
        [self.imageViews addObject:imageView];
    }];
    
    [self wd_masLayoutSubViewsWithViewArray:self.imageViews columnOfRow:3 topBottomOfItemSpeace:10 leftRightItemSpeace:10 topOfSuperViewSpeace:64 + 10 leftRightSuperViewSpeace:5 addToSubperView:self.view viewHeight:100];
}
                                   
- (void)imageTapped:(UITapGestureRecognizer *)sender {
    WDImageBrowser *v = [[WDImageBrowser alloc] init];
    [v setupWithDelegate:self tappedIndex:sender.view.tag imageUrls:self.imageUrls originView:sender.view];
    [v showBrowser];
}

- (UIView *)imageBrowser:(WDImageBrowser *)browser scrollAtIndex:(NSInteger)index {
    return self.imageViews[index];
}
- (void)wd_masLayoutSubViewsWithViewArray:(NSArray<UIView *> *)viewArray
                              columnOfRow:(NSInteger)column
                    topBottomOfItemSpeace:(CGFloat)tbSpeace
                      leftRightItemSpeace:(CGFloat)lrSpeace
                     topOfSuperViewSpeace:(CGFloat)topSpeace
                 leftRightSuperViewSpeace:(CGFloat)lrSuperViewSpeace
                          addToSubperView:(UIView *)superView
                               viewHeight:(CGFloat)viewHeight{
    
    CGFloat viewWidth = superView.bounds.size.width;
    CGFloat itemWidth = (viewWidth - lrSuperViewSpeace * 2 - (column - 1) * lrSpeace) / column * 1.0f;
    CGFloat itemHeight = viewHeight;
    UIView *last = nil;
    
    for (int i = 0; i < viewArray.count; i++) {
        UIView *item = viewArray[i];
        [superView addSubview:item];
        [item mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(itemWidth);
            make.height.mas_equalTo(itemHeight);
            
            CGFloat top = topSpeace + (i / column) * (itemHeight + tbSpeace);
            make.top.mas_offset(top);
            if (!last || (i % column) == 0) {
                make.left.mas_offset(lrSuperViewSpeace);
            }else{
                make.left.mas_equalTo(last.mas_right).mas_offset(lrSpeace);
            }
        }];
        last = item;
    }
}

@end
