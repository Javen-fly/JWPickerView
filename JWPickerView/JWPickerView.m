//
//  JWPickerView.m
//  JWPickerViewDemo
//
//  Created by 吴建文 on 2018/2/8.
//  Copyright © 2018年 Javen. All rights reserved.
//

#import "JWPickerView.h"
#import "JWPickerItemView.h"

#define kItemDefaultWidth 60.f

@interface JWPickerView()<JWPickerItemViewDelegate>

{
    BOOL _isLayout;
    NSMutableDictionary *_selectedDictionary;
}

@property (nonatomic, strong) NSMutableArray *itemArr;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *itemXArr;
@property (nonatomic, strong) NSMutableArray *itemYArr;
@property (nonatomic, strong) NSMutableArray *itemWidthArr;
@property (nonatomic, strong) NSMutableArray *itemHeightArr;
@property (nonatomic, strong) NSMutableArray *itemRowHeightArr;
@property (nonatomic, strong) NSMutableArray *itemShowRowArr;

@property (nonatomic, strong) NSMutableArray *itemFreeArr;


@end

@implementation JWPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initBase];
        [self initUI];
        
    }
    return self;
}

- (void)initBase
{
    _itemArr = [NSMutableArray array];
    
    _rowHeight          = 44.f;
    _itemWidth          = kItemDefaultWidth;
    _minItemSpeace      = 10.f;
    _numberOfShow       = 5.f;
    _textColor          = [UIColor lightGrayColor];
    _selectedTextColor  = [UIColor blackColor];
    _textFont           = [UIFont systemFontOfSize:13.f];
    _selectedTextFont   = [UIFont systemFontOfSize:30.f];
    _textAlignment      = NSTextAlignmentCenter;
    _inset              = UIEdgeInsetsMake(10, 10, 10, 10);
    self.backgroundColor= [UIColor whiteColor];
    
    
    _itemXArr           = [NSMutableArray array];
    _itemYArr           = [NSMutableArray array];
    _itemWidthArr       = [NSMutableArray array];
    _itemHeightArr      = [NSMutableArray array];
    _itemRowHeightArr   = [NSMutableArray array];
    _itemShowRowArr     = [NSMutableArray array];
    _itemFreeArr        = [NSMutableArray array];
    
    _selectedDictionary = [NSMutableDictionary dictionary];
}

- (void)initUI
{
    _scrollView = [[UIScrollView alloc]init];
    [self addSubview:_scrollView];
}

- (void)reloadData
{
    //1、先判断是否实现必要的代理
    NSAssert(_dateSource, @"未设置代理");
    NSAssert([_dateSource respondsToSelector:@selector(jw_numberOfItemInPickerView:)] &&
            ([_dateSource respondsToSelector:@selector(jw_pickerView:attributedTextForRowAtIndexPath:)] ||
             [_dateSource respondsToSelector:@selector(jw_pickerView:textForRowAtIndexPath:)]), @"未实现代理方法");
    //2、如果存在旧的内容，先清空
    if (_itemArr.count) {
        [_itemArr enumerateObjectsUsingBlock:^(JWPickerItemView *itemView, NSUInteger idx, BOOL * _Nonnull stop) {
            [itemView removeFromSuperview];
            [self.itemFreeArr addObject:itemView];
        }];
        [_itemArr           removeAllObjects];
        [_itemXArr          removeAllObjects];
        [_itemYArr          removeAllObjects];
        [_itemWidthArr      removeAllObjects];
        [_itemHeightArr     removeAllObjects];
        [_itemRowHeightArr  removeAllObjects];
        [_itemShowRowArr    removeAllObjects];
    }
    
    
    _scrollView.frame = CGRectMake(_inset.left, _inset.top, self.bounds.size.width - _inset.left - _inset.right, self.bounds.size.height - _inset.top - _inset.bottom);
    NSInteger numberOfItem  = 0;
    if ([_dateSource respondsToSelector:@selector(jw_numberOfItemInPickerView:)]) {
        //获取总item数
        numberOfItem = [_dateSource jw_numberOfItemInPickerView:self];
        
        //获取item宽度
        CGFloat totalWidth          = 0.f;
        CGFloat totalItemWidth      = 0.f;
        CGFloat totalMinSpeaceWith  = 0.f;
        
        if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:widthForRowInItem:)]) {
            for (int item = 0; item < numberOfItem; item++) {
                CGFloat width = [_delegate jw_pickerView:self widthForRowInItem:item];
                width = width >= 0 ? width : kItemDefaultWidth;
                [_itemWidthArr addObject:@(width)];
                totalItemWidth += width;
            }
        }
        else
        {
            _itemWidth = _itemWidth >= 0 ? _itemWidth :kItemDefaultWidth;
            totalItemWidth = _itemWidth * numberOfItem;
            
            NSInteger item = 0;
            while (item < numberOfItem) {
                [_itemWidthArr addObject:@(_itemWidth)];
                item++;
            }
        }
        
        CGFloat scrollViewWidth = _scrollView.bounds.size.width;
        
        //获取最小间隔距离
        totalMinSpeaceWith  = _minItemSpeace * numberOfItem;
        totalWidth          = totalItemWidth + totalMinSpeaceWith;
        
        //根据总边距设置布局
        //获取item的X
        if (totalWidth > scrollViewWidth - _minItemSpeace * 2) {
            CGFloat currentX = totalWidth > scrollViewWidth? 0.f : (scrollViewWidth - totalWidth)/2;
            for (NSInteger item = 0; item < numberOfItem; item++) {
                if (item) {
                    CGFloat lastWidth = [_itemWidthArr[item - 1] doubleValue];
                    currentX += lastWidth + _minItemSpeace;
                }
                [_itemXArr addObject:@(currentX)];
            }
        }
        else
        {
            CGFloat speace      = (scrollViewWidth - totalItemWidth) / (numberOfItem + 1);
            CGFloat currentX    = speace;
            for (NSInteger item = 0; item < numberOfItem; item ++) {
                if (item) {
                    CGFloat width = [_itemWidthArr[item - 1] doubleValue];
                    currentX += speace + width;
                }
                [_itemXArr addObject:@(currentX)];
            }
        }
        //获取item的Y、height
        for (NSInteger item = 0; item < numberOfItem; item++) {
            CGFloat numberOfShow = _numberOfShow;
            CGFloat rowHeight = _rowHeight;
            if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:numberOfShowInItem:)]) {
                numberOfShow = [_delegate jw_pickerView:self numberOfShowInItem:item];
            }
            if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:heightForItemInItem:)]) {
                rowHeight = [_delegate jw_pickerView:self heightForItemInItem:item];
            }
            
            CGFloat height = rowHeight * numberOfShow;
            CGFloat y = (_scrollView.bounds.size.height - rowHeight * numberOfShow) / 2;
            
            [_itemYArr           addObject:@(y)];
            [_itemHeightArr      addObject:@(height)];
            [_itemShowRowArr     addObject:@(numberOfShow)];
            [_itemRowHeightArr   addObject:@(rowHeight)];
        }
        
        BOOL isAttributedText = NO;
        if ([_dateSource respondsToSelector:@selector(jw_pickerView:attributedTextForRowAtIndexPath:)]) {
            isAttributedText = YES;
        }
        else if ([_dateSource respondsToSelector:@selector(jw_pickerView:textForRowAtIndexPath:)])
        {
            isAttributedText = NO;
        }
        else
        {
            NSAssert(0, @"缺少数据来源");
        }
        
        for (NSInteger item = 0; item < numberOfItem; item++) {
            JWPickerItemView *itemView;
            if (_itemFreeArr.count) {
                itemView = [_itemFreeArr firstObject];
                [_itemFreeArr removeObject:itemView];
            }
            else
            {
                itemView = [[JWPickerItemView alloc]init];
                itemView.delegate = self;
            }
            itemView.tag = item;
            CGFloat x       = [_itemXArr[item] doubleValue];
            CGFloat y       = [_itemYArr[item] doubleValue];
            CGFloat width   = [_itemWidthArr[item] doubleValue];
            CGFloat height  = [_itemHeightArr[item] doubleValue];
            
            itemView.frame  = CGRectMake(x, y, width, height);
            [_scrollView addSubview:itemView];
            [_itemArr addObject:itemView];
            
            NSInteger numberOfRow   = [_dateSource jw_pickerView:self numberOfRowInItem:item];
            NSInteger numberOfShow  = [_itemShowRowArr[item] integerValue];
            CGFloat   rowHeight     = [_itemRowHeightArr[item] doubleValue];
            
            itemView.numberOfShow   = numberOfShow;
            itemView.rowHeight      = rowHeight;
            
            NSTextAlignment textAlignment = _textAlignment;
            if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:textAlignmentInItem:)]) {
                textAlignment = [_delegate jw_pickerView:self textAlignmentInItem:item];
            }
            itemView.textAlignment = textAlignment;
            
            //backgroundColor
            UIColor *bgColor = self.backgroundColor;
            if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:backgroundColorInItem:)]) {
                bgColor = [_delegate jw_pickerView:self backgroundColorInItem:item];
            }
            itemView.backgroundColor = bgColor;
            
            if (!isAttributedText) {
                
                UIColor *textColor          = _textColor;
                UIColor *selectedTextColor  = _selectedTextColor;
                UIFont *textFont            = _textFont;
                UIFont *selectedTextFont    = _selectedTextFont;
                
                if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:textColorForItem:)]) {
                    textColor = [_delegate jw_pickerView:self textColorForItem:item];
                }
                if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:selectedTextColorForItem:)]) {
                    selectedTextColor = [_delegate jw_pickerView:self selectedTextColorForItem:item];
                }
                if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:textFontForItem:)]) {
                    textFont = [_delegate jw_pickerView:self textFontForItem:item];
                }
                if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:selectedTextFontForItem:)]) {
                    selectedTextFont = [_delegate jw_pickerView:self selectedTextFontForItem:item];
                }
                
                itemView.textColor          = textColor;
                itemView.selectedTextColor  = selectedTextColor;
                itemView.textFont           = textFont;
                itemView.selectedTextFont   = selectedTextFont;
                
                NSMutableArray *dataSource  = [NSMutableArray arrayWithCapacity:numberOfRow];
                for (NSInteger row = 0; row < numberOfRow; row++) {
                    NSIndexPath *indexPath  = [NSIndexPath indexPathForRow:row inSection:item];
                    NSString    *text       = [_dateSource jw_pickerView:self textForRowAtIndexPath:indexPath];
                    [dataSource addObject:text];
                }
                itemView.dataSource = dataSource;
                
            }
            else
            {
                NSMutableArray *dataSource  = [NSMutableArray arrayWithCapacity:numberOfRow];
                for (NSInteger row = 0; row < numberOfRow; row++) {
                    NSIndexPath         *indexPath  = [NSIndexPath indexPathForRow:row inSection:item];
                    NSAttributedString  *text       = [_dateSource jw_pickerView:self attributedTextForRowAtIndexPath:indexPath];
                    [dataSource addObject:text];
                }
                itemView.dataSource = dataSource;
            }
            
            
            [itemView reloadData];
            itemView.delegate = self;
        }
        _scrollView.contentSize = CGSizeMake(totalWidth, 0);
        [_itemArr enumerateObjectsUsingBlock:^(JWPickerItemView * _Nonnull itemView, NSUInteger idx, BOOL * _Nonnull stop) {
            if (itemView.dataSource.count) {
//                NSInteger index = itemView.finalRow < itemView.dataSource.count ? itemView.finalRow : 0;
//                [itemView selectIndex:index];
                [self showItemViewSelected:itemView];
            }
        }];
    }
}

- (void)reloadDataWithItem:(NSInteger)item
{
    CGFloat numberOfShow    = _numberOfShow;
    CGFloat rowHeight       = _rowHeight;
    CGFloat width           = _itemWidth;
    if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:numberOfShowInItem:)]) {
        numberOfShow    = [_delegate jw_pickerView:self numberOfShowInItem:item];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:heightForItemInItem:)]) {
        rowHeight       = [_delegate jw_pickerView:self heightForItemInItem:item];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:widthForRowInItem:)]) {
        width           = [_delegate jw_pickerView:self widthForRowInItem:item];
    }
    
    CGFloat height  = rowHeight * numberOfShow;
    CGFloat y       = (_scrollView.bounds.size.height - rowHeight * numberOfShow)/2;
    
    CGFloat originY     = [_itemYArr[item] doubleValue];
    CGFloat originWidth = [_itemWidthArr[item] doubleValue];
    
    if (y != originY) {
        [_itemYArr      replaceObjectAtIndex:item withObject:@(y)];
        [_itemHeightArr replaceObjectAtIndex:item withObject:@(height)];
    }
    
    JWPickerItemView *itemView = _itemArr[item];
   
    
    if (numberOfShow != [_itemShowRowArr[item] integerValue]) {
        [_itemShowRowArr replaceObjectAtIndex:item withObject:@(numberOfShow)];
        itemView.numberOfShow = numberOfShow;
    }
    if (rowHeight != [_itemRowHeightArr[item] doubleValue]) {
        [_itemRowHeightArr replaceObjectAtIndex:item withObject:@(rowHeight)];
        itemView.rowHeight = rowHeight;
    }
    
    //dataSource
    NSInteger numberOfRow       = [_dateSource jw_pickerView:self numberOfRowInItem:item];
    NSMutableArray *dataSource  = [NSMutableArray arrayWithCapacity:numberOfRow];
    BOOL isAttributedText = NO;
    if ([_dateSource respondsToSelector:@selector(jw_pickerView:attributedTextForRowAtIndexPath:)]) {
        isAttributedText = YES;
    }
    else
    {
        UIColor *textColor          = _textColor;
        UIColor *selectedTextColor  = _selectedTextColor;
        UIFont  *textFont           = _textFont;
        UIFont  *selectedTextFont   = _selectedTextFont;
        if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:textColorForItem:)]) {
            textColor           = [_delegate jw_pickerView:self textColorForItem:item];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:selectedTextColorForItem:)]) {
            selectedTextColor   = [_delegate jw_pickerView:self selectedTextColorForItem:item];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:textColorForItem:)]) {
            textFont            = [_delegate jw_pickerView:self textFontForItem:item];
        }
        if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:selectedTextFontForItem:)]) {
            selectedTextFont    = [_delegate jw_pickerView:self selectedTextFontForItem:item];
        }
        itemView.textColor              = textColor;
        itemView.selectedTextColor      = selectedTextColor;
        itemView.textFont               = textFont;
        itemView.selectedTextFont       = selectedTextFont;
    }
    
    //textAlignment
    NSTextAlignment textAlignment = _textAlignment;
    if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:textAlignmentInItem:)]) {
        textAlignment = [_delegate jw_pickerView:self textAlignmentInItem:item];
    }
    itemView.textAlignment = textAlignment;
    
    //backgroundColor
    UIColor *bgColor = self.backgroundColor;
    if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:backgroundColorInItem:)]) {
        bgColor = [_delegate jw_pickerView:self backgroundColorInItem:item];
    }
    itemView.backgroundColor = bgColor;
    
    for (int i = 0; i < numberOfRow; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:item];
        if (isAttributedText) {
            NSAttributedString *text = [_dateSource jw_pickerView:self attributedTextForRowAtIndexPath:indexPath];
            NSAssert(text, @"jw_pickerView:attributedTextForRowAtIndexPath: return nil");
            [dataSource addObject:text];
        }
        else
        {
            NSString *text = [_dateSource jw_pickerView:self textForRowAtIndexPath:indexPath];
            NSAssert(text, @"jw_pickerView:textForRowAtIndexPath: return nil");
            [dataSource addObject:text];
        }
    }
    itemView.dataSource = dataSource;
    
    [UIView animateWithDuration:0.2 animations:^{
        if (width != originWidth) {
            [self.itemWidthArr  replaceObjectAtIndex:item withObject:@(width)];
            
            CGFloat offset = width - originWidth;
            
            for (NSInteger i = item + 1; i < self.itemArr.count; i++) {
                CGFloat x = [self.itemXArr[i] doubleValue];
                x += offset;
                [self.itemXArr replaceObjectAtIndex:i withObject:@(x)];
                
                JWPickerItemView *aitemView = self.itemArr[i];
                CGRect itemFrame = aitemView.frame;
                aitemView.frame = CGRectMake(x, itemFrame.origin.y, itemFrame.size.width, itemFrame.size.height);
            }
        }
        if (width != originWidth || y != originY) {
            CGRect itemFrame = itemView.frame;
            itemView.frame = CGRectMake(itemFrame.origin.x, y, width, height);
            [itemView layoutIfNeeded];
        }
    } completion:^(BOOL finished) {
        [itemView reloadData];
        [self showItemViewSelected:itemView];
    }];
}

- (void)showItemViewSelected:(JWPickerItemView *)itemView
{
    if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:didSelectedRow:inItem:)]) {
        [_delegate jw_pickerView:self didSelectedRow:itemView.finalRow inItem:itemView.tag];
    }
}

- (void)selectIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(indexPath.section < _itemArr.count, @"无效setion");
    JWPickerItemView *itemView = _itemArr[indexPath.section];
    NSAssert(indexPath.row < itemView.dataSource.count, @"无效index");
    [itemView selectIndex:indexPath.row];
}

- (void)selectIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    for (NSIndexPath *indexPath in indexPaths) {
        _selectedDictionary[@(indexPath.section)] = @(indexPath.row);
    }
    
    for (NSIndexPath *indexPath in indexPaths) {
        [self selectIndexPath:indexPath];
    }
}

#pragma mark ------- JWPickerItemViewDelegate -------

- (void)jw_pickerItemView:(JWPickerItemView *)pickerItemView didSelectRow:(NSInteger)row
{
    
}

- (void)jw_pickerItemViewDidEndScrollingAnimation:(JWPickerItemView *)itemView didSelectRow:(NSInteger)row
{
    _selectedDictionary[@(itemView.tag)] = @(row);
    BOOL isScrolling = NO;
    for (JWPickerItemView *itemView in _itemArr) {
        if (itemView.isScrolling) {
            isScrolling = YES;
            break;
        }
    }
    if (!isScrolling) {
        NSInteger index = [_itemArr indexOfObject:itemView];
        if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerView:didSelectedRow:inItem:)]) {
            [_delegate jw_pickerView:self didSelectedRow:row inItem:index];
        }
    }
    
}


- (void)layoutSubviews
{
    [self reloadData];
    [super layoutSubviews];
}

- (NSMutableDictionary *)selectedDic
{
    return _selectedDictionary;
}


@end
