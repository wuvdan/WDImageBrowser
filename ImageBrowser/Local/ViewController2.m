//
//  ViewController2.m
//  ImageBrowser
//
//  Created by wudan on 2019/4/19.
//  Copyright © 2019 wudan. All rights reserved.
//

#import "ViewController2.h"
#import "ImageCollectionViewCell.h"
#import "WDImageBrowser.h"

@interface ViewController2 () <UICollectionViewDelegate, UICollectionViewDataSource, WDImageBrowserDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray<UIImage *> *images;
@end

@implementation ViewController2

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"CollectionView Load Image";
    self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:1];
    
    NSArray *imageNameArray = @[@"2.jpeg",
                                @"1.jpeg",
                                @"02ecdccd9a7f187d5827893a3dada3ce.jpg",
                                @"10ba4c8e82ddffe55d718c95896480f7.jpeg",
                                @"22f043eb37713667a824b28421449ed7.png",
                                @"23f7a9616cf66fce28a864c2e676a067.jpg",
                                @"99fa878d04b189f9484f7caf14e4fe91 2.jpeg",
                                @"99fa878d04b189f9484f7caf14e4fe91.jpeg",
                                @"465f6b58924b887469fd35ffd4c5bfd8.jpg",
                                @"507f63b1ff3fe67cb1e4f792ebd0c320.jpg",
                                @"4470bd1f5c0679ae00d1eea43b6a8789.jpg",
                                @"鬼刀风铃公主4k超清壁纸_彼岸图网.jpg",
                                @"星空 幻想 女孩 夜晚 梦想 8k动漫壁纸7680x4320_彼岸图网.jpg",];
    
    self.images = [NSMutableArray array];
    for (NSString *string in imageNameArray) {
        [self.images addObject:[UIImage imageNamed:string]];
    }
        
    self.flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.flowLayout.minimumLineSpacing = 5;
    self.flowLayout.minimumInteritemSpacing = 5;
    self.flowLayout.itemSize = CGSizeMake((UIScreen.mainScreen.bounds.size.width - 40) / 3, (UIScreen.mainScreen.bounds.size.width - 40) / 3);
    [self.collectionView registerNib:[UINib nibWithNibName:@"ImageCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.images.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    cell.imageView.image = self.images[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    WDImageBrowser *v = [[WDImageBrowser alloc] init];
    [v setupWithDelegate:self tappedIndex:indexPath.item images:self.images originView:[collectionView cellForItemAtIndexPath:indexPath]];
    [v showBrowser];
}

- (UIView *)imageBrowser:(WDImageBrowser *)browser scrollAtIndex:(NSInteger)index {
    return [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

@end
