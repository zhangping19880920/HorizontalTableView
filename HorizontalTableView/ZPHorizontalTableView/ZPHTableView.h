//
//  ZPHTableView.h
//  HorizontalTableView
//
//  Created by zhangping on 15/3/19.
//  Copyright (c) 2015年 dycx. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZPHTableView, ZPHTableViewCell;

typedef enum {
    ZPHTableViewMarginTypeTop,
    ZPHTableViewMarginTypeBottom,
    ZPHTableViewMarginTypeLeft,
    ZPHTableViewMarginTypeRight,
    ZPHTableViewMarginTypeColumn, // 每一列
    ZPHTableViewMarginTypeRow, // 每一行
} ZPHTableViewMarginType;

/** 数据源 */
@protocol ZPHTableViewDataSource <NSObject>
@required
/** 一共有多少个数据 */
- (NSUInteger)numberOfCellInHTableView:(ZPHTableView *)htableView;

/** 一行多少个条目 */
- (NSUInteger)numberOfCellInOnePageWithHTableView:(ZPHTableView *)htableView;

/** 返回index位置对应的cell */
- (ZPHTableViewCell *)htableView:(ZPHTableView *)htableView cellAtIndex:(NSUInteger)index;
@end

/** 代理方法 */
@protocol ZPHtableViewDelegate <UIScrollViewDelegate>
@optional
/** 第index位置cell对应的宽度 */
- (CGFloat)htableView:(ZPHTableView *)htableView widthAtIndex:(NSUInteger)index;

/** 选中第index位置的cell */
- (void)htableView:(ZPHTableView *)htableView didSelectAtIndex:(NSUInteger)index;

/** 返回间距 */
- (CGFloat)htableview:(ZPHTableView *)htableView marginForType:(ZPHTableViewMarginType)type;
@end

/** 水平滚动tableView */
@interface ZPHTableView : UIScrollView

/** 数据源 */
@property (nonatomic, weak) id<ZPHTableViewDataSource> dataSource;

/** 代理 */
@property (nonatomic, weak) id<ZPHtableViewDelegate> delegate;

/** 刷新数据（只要调用这个方法，会重新向数据源和代理发送请求，请求数据）*/
- (void)reloadData;

/** 根据标识去缓存池查找可循环利用的cell */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;

/** cell的高度 */
- (CGFloat)cellHeight;

/** 显示第Index个条目 */
- (void)showItemAtIndex:(NSUInteger)index;
@end
