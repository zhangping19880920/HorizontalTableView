//
//  ZPHTableView.m
//  HorizontalTableView
//
//  Created by zhangping on 15/3/19.
//  Copyright (c) 2015年 dycx. All rights reserved.
//

#import "ZPHTableView.h"
#import "ZPHTableViewCell.h"

static CGFloat const ZPHTableViewDefaultNumberOfCell = 3;
static CGFloat const ZPHTableViewDefaultMargin = 0;
static NSUInteger const ZPHTableViewDefaultNumberOfMoreCheckout = 40;

@interface ZPHTableView ()
/** 所有cell的frame数据 */
@property (nonatomic, strong)NSMutableArray *cellFrames;
/** 正在展示的cell */
@property (nonatomic, strong)NSMutableDictionary *displayingCells;
/** 正在展示的cell的index */
@property (nonatomic, strong)NSMutableArray *displayingCellIndexs;

/** 缓存池（用Set，存放离开屏幕的cell） */
@property (nonatomic, strong)NSMutableSet *reusableCells;

@end

@implementation ZPHTableView
#pragma 初始化
- (NSMutableArray *)cellFrames {
    if (_cellFrames == nil) {
        self.cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells {
    if (_displayingCells == nil) {
        self.displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

- (NSMutableArray *)displayingCellIndexs {
    if (_displayingCellIndexs == nil) {
        self.displayingCellIndexs = [NSMutableArray array];
    }
    return _displayingCellIndexs;
}

- (NSMutableSet *)reusableCells {
    if (_reusableCells == nil) {
        self.reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self reloadData];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.decelerationRate = UIScrollViewDecelerationRateFast;
    }
    return self;
}

/** 加载数据 */
- (void)reloadData {
    NSLog(@"reloadData");
    //清除之前数据
    [self.displayingCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.displayingCells removeAllObjects];
    [self.cellFrames removeAllObjects];
    [self.reusableCells removeAllObjects];
    
    //目标:算出所有cell的frame
    NSUInteger numberOfCells = [self.dataSource numberOfCellInHTableView:self];
    CGFloat cellHeight = [self cellHeight];
    
    CGFloat cellMarginLeft = [self marginForType:ZPHTableViewMarginTypeLeft];
    CGFloat cellMarginRight = [self marginForType:ZPHTableViewMarginTypeRight];
    CGFloat cellMarginColum = [self marginForType:ZPHTableViewMarginTypeColumn];
    CGFloat cellMarginTop = [self marginForType:ZPHTableViewMarginTypeTop];
    
    for (int i = 0; i < numberOfCells; i++) {
        CGFloat cellWidth = [self widthAtIndex:i];
        CGFloat cellX = cellMarginLeft + (cellWidth + cellMarginColum) * i;
        CGFloat cellY = cellMarginTop;
        CGRect frame = CGRectMake(cellX, cellY, cellWidth, cellHeight);
        [self.cellFrames addObject:[NSValue valueWithCGRect:frame]];
    }
    CGRect maxFrame = [self.cellFrames.lastObject CGRectValue];
    CGFloat contentMaxX = CGRectGetMaxX(maxFrame);
    self.contentSize = CGSizeMake(contentMaxX + cellMarginRight, cellHeight);
}
CGFloat lastOffestX = 0;
/** 当UIScrollView滚动的时候会调用这个方法 */
- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat currentOffestX = self.contentOffset.x;
    CGFloat offest = ABS(currentOffestX - lastOffestX);
    
    int count = offest / [self widthAtIndex:0];
    if (count > 5) {
        NSLog(@"offest count = %d", count);
    }
    
    lastOffestX = currentOffestX;
    
    // 向数据源索要对应位置的cell
    NSUInteger numberOfCells = self.cellFrames.count;
    
    NSUInteger minDisplayingIndex = [self.displayingCellIndexs.firstObject unsignedIntValue];
    NSUInteger maxDisplayingIndex = [self.displayingCellIndexs.lastObject unsignedIntValue];
    
    if (self.displayingCellIndexs.count == 0) { //根据contentOffest.x算现在该显示哪个cell
        // TODO: 1
        minDisplayingIndex = [self indexFromContentOffestX];
        maxDisplayingIndex = minDisplayingIndex + [self numberOfCellInOnePage];
        NSLog(@"displayingCells.count == 0 minDisplayingIndex = %zd", minDisplayingIndex);
    }
    
    int startIndex = minDisplayingIndex - ZPHTableViewDefaultNumberOfMoreCheckout;
    NSUInteger endIndex = maxDisplayingIndex + ZPHTableViewDefaultNumberOfMoreCheckout;
    
    if (startIndex < 0) {
        startIndex = 0;
    }
    
    if (endIndex >= numberOfCells) {
        endIndex = numberOfCells;
    }

    
    for (int i = startIndex; i < endIndex; i++) {
        // 取出i位置的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        
        // 优先从字典中取出i位置的cell
        ZPHTableViewCell *cell = self.displayingCells[@(i)];
        if ([self isInScreen:cellFrame]) {
            if (cell == nil) {
                cell = [self.dataSource htableView:self cellAtIndex:i];
                cell.frame = cellFrame;
                self.displayingCells[@(i)] = cell;
                [self.displayingCellIndexs addObject:[NSNumber numberWithInt:i]];
                [self addSubview:cell];
            }
        } else {
            if (cell) {
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                [self.displayingCellIndexs removeObject:[NSNumber numberWithInt:i]];
                [self.reusableCells addObject:cell];
            }
        }
    }
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    __block ZPHTableViewCell *reusableCell = nil;
    [self.reusableCells enumerateObjectsUsingBlock:^(ZPHTableViewCell *cell, BOOL *stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    
    if (reusableCell) {
        [self.reusableCells removeObject:reusableCell];
    }
    return reusableCell;
}

- (NSUInteger)indexFromContentOffestX {
    NSUInteger index = self.contentOffset.x / [self widthAtIndex:0];
    return index;
}

/** 判断一个frame有无显示在屏幕上 */
- (BOOL)isInScreen:(CGRect)frame {
    return (CGRectGetMaxX(frame) > self.contentOffset.x) &&
    (CGRectGetMinX(frame) < self.contentOffset.x + self.bounds.size.width);
}

/** cell的宽度 */
- (CGFloat)widthAtIndex:(NSUInteger)index {
    if ([self.delegate respondsToSelector:@selector(htableView:widthAtIndex:)]) {
        return [self.delegate htableView:self widthAtIndex:index];
    } else {
        CGFloat marginLeft = [self marginForType:ZPHTableViewMarginTypeLeft];
        CGFloat marginRight = [self marginForType:ZPHTableViewMarginTypeRight];
        return (self.bounds.size.width - marginLeft - marginRight) / [self numberOfCellInOnePage];
    }
}

/** cell的高度 */
- (CGFloat)cellHeight {
    CGFloat marginTop = [self marginForType:ZPHTableViewMarginTypeTop];
    CGFloat marginBottom = [self marginForType:ZPHTableViewMarginTypeBottom];
    return self.bounds.size.height - marginTop - marginBottom;
}

/** 获取间距 */
- (CGFloat)marginForType:(ZPHTableViewMarginType)type {
    if ([self.delegate respondsToSelector:@selector(htableview:marginForType:)]) {
        return [self.delegate htableview:self marginForType:type];
    } else {
        if (ZPHTableViewMarginTypeColumn == type) {
            return 0;
        } else {
            return ZPHTableViewDefaultMargin;
        }
    }
}

/** 一页显示多少个 */
- (NSUInteger)numberOfCellInOnePage {
    if ([self.dataSource respondsToSelector:@selector(numberOfCellInOnePageWithHTableView:)]) {
        return [self.dataSource numberOfCellInOnePageWithHTableView:self];
    } else {
        return ZPHTableViewDefaultNumberOfCell;
    }
}

- (void)showItemAtIndex:(NSUInteger)index {
    if (self.cellFrames.count < index) {
        NSLog(@"cellFrames.count = 0");
        return;
    }
    CGFloat offestX = 0;
    for (int i = 0; i <= index; i++) {
        CGRect frame = [self.cellFrames[i] CGRectValue];
        offestX += frame.size.width;
    }
    CGPoint half = CGPointMake(offestX, 0);
    [self setContentOffset:half animated:NO];
}
@end
