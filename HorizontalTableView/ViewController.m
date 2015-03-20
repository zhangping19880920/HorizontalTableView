//
//  ViewController.m
//  HorizontalTableView
//
//  Created by zhangping on 15/3/19.
//  Copyright (c) 2015年 dycx. All rights reserved.
//

#import "ViewController.h"
#import "ZPHTableView.h"
#import "ZPHTableViewCell.h"
#import "HMShop.h"
#import "HMShopCell.h"
#import "MJExtension.h"
#import "MJRefresh.h"

static NSUInteger const loopNumber = 50;

@interface ViewController () <ZPHTableViewDataSource, ZPHtableViewDelegate>
@property (weak, nonatomic) ZPHTableView *htableView;
@property (nonatomic, strong)NSMutableArray *shops;
@end

@implementation ViewController
- (NSMutableArray *)shops {
    if (_shops == nil) {
        self.shops = [NSMutableArray array];
        NSArray *shops = [HMShop objectArrayWithFilename:@"2.plist"];
        [self.shops addObjectsFromArray:shops];
    }
    return _shops;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    ZPHTableView *htableView = [[ZPHTableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    self.htableView = htableView;
    self.htableView.delegate = self;
    self.htableView.dataSource = self;
    self.htableView.backgroundColor = [UIColor redColor];
    
    [self.view addSubview:htableView];
    [self.htableView addHeaderWithTarget:self action:@selector(loadNewShops)];
    [self.htableView addFooterWithTarget:self action:@selector(loadMoreShops)];
    [self.htableView showItemAtIndex:self.shops.count * loopNumber / 2];
}

- (void)loadNewShops {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *newShops = [HMShop objectArrayWithFilename:@"1.plist"];
        NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newShops.count)];
        [self.shops insertObjects:newShops atIndexes:set];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.htableView reloadData];
            [self.htableView headerEndRefreshing];
        });
    });
}

- (void)loadMoreShops {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *moreShops = [HMShop objectArrayWithFilename:@"3.plist"];
        [self.shops addObjectsFromArray:moreShops];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.htableView reloadData];
            [self.htableView headerEndRefreshing];
        });
    });
}

/** 总共有多少个条目 */
- (NSUInteger)numberOfCellInHTableView:(ZPHTableView *)htableView{
    return self.shops.count * loopNumber;
}

/** 一页要显示多少个 */
//- (NSUInteger)numberOfCellInOnePageWithHTableView:(ZPHTableView *)htableView {
//    return 1;
//}

- (ZPHTableViewCell *)htableView:(ZPHTableView *)htableView cellAtIndex:(NSUInteger)index {
    HMShopCell *cell = [HMShopCell cellWithWaterflowView:htableView];
    cell.shop = self.shops[index % self.shops.count];
    
    cell.backgroundColor = [UIColor grayColor];
    return cell;
}

@end
