//
//  HMShopCell.h
//  06-瀑布流
//
//  Created by apple on 14-7-28.
//  Copyright (c) 2014年 heima. All rights reserved.
//

#import "ZPHTableViewCell.h"
@class ZPHTableView, HMShop;

@interface HMShopCell : ZPHTableViewCell
+ (instancetype)cellWithWaterflowView:(ZPHTableView *)htableView;

@property (nonatomic, strong) HMShop *shop;
@end
