
//
//  JWPickerItemView.m
//  JWPickerViewDemo
//
//  Created by 吴建文 on 2018/2/8.
//  Copyright © 2018年 Javen. All rights reserved.
//

#import "JWPickerItemView.h"
#import "JWPickerItemViewCell.h"
@interface JWPickerItemView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

//tableView高度约束
@property (nonatomic, strong) NSLayoutConstraint *tableVieWHeightLayout;

@property (nonatomic, assign) NSInteger numberOfRowtoTop;

@end

@implementation JWPickerItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initBase];
        [self initUI];
    }
    return self;
}

#pragma mark -------- base -------

- (void)initBase
{
    self.rowHeight      = 44.f;
    _numberOfShow       = 5;
    _numberOfRowtoTop   = 2.f;
    _textColor          = [UIColor lightGrayColor];
    _textFont           = [UIFont systemFontOfSize:15.f];
    _selectedTextColor  = [UIColor blackColor];
    _selectedTextFont   = [UIFont systemFontOfSize:30.f];
    _textAlignment      = NSTextAlignmentCenter;
    
    _currentRow = -1;
}

#pragma mark -------- UI -------

- (void)initUI
{
    [self addSubview:self.tableView];
    
    NSLayoutConstraint *leftLayout      = [NSLayoutConstraint constraintWithItem:_tableView
                                                                       attribute:NSLayoutAttributeLeft
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeLeft
                                                                      multiplier:1.0
                                                                        constant:0.f];
    NSLayoutConstraint *centerXLayout   = [NSLayoutConstraint constraintWithItem:_tableView
                                                                       attribute:NSLayoutAttributeCenterX
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeCenterX
                                                                      multiplier:1.0
                                                                        constant:0.f];
    NSLayoutConstraint *centerYLayout   = [NSLayoutConstraint constraintWithItem:_tableView
                                                                       attribute:NSLayoutAttributeCenterY
                                                                       relatedBy:NSLayoutRelationEqual
                                                                          toItem:self
                                                                       attribute:NSLayoutAttributeCenterY
                                                                      multiplier:1.0
                                                                        constant:0.f];
    
    [self addConstraints:@[leftLayout, centerXLayout, centerYLayout,self.tableVieWHeightLayout]];
    
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    [_tableView setBackgroundColor:backgroundColor];
    [_tableView reloadData];
}

- (void)setDataSource:(NSArray *)dataSource
{
    _dataSource = dataSource;
    [self reloadData];
}

- (void)reloadData
{
    [_tableView reloadData];
    [self resetSelected];
//    if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerItemViewDidEndScrollingAnimation:didSelectRow:)]) {
//        [_delegate jw_pickerItemViewDidEndScrollingAnimation:self didSelectRow:_finalRow];
//    }
}


- (void)selectIndex:(NSInteger)index
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    _finalRow = index;
    [_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark -------- UITableViewDataSource -------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JWPickerItemViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JWPickerItemViewCell class])];
    id text = _dataSource[indexPath.row];
    if ([text isKindOfClass:[NSAttributedString class]]) {
        cell.textLabel.attributedText = text;
    }
    else
    {
        cell.textColor          = _textColor;
        cell.selectedTextColor  = _selectedTextColor;
        cell.textFont           = _textFont;
        cell.selectedTextFont   = _selectedTextFont;
        if ([text isKindOfClass:[NSString class]]){
            cell.text     = _dataSource[indexPath.row];
        }
        else
        {
            cell.text     = [NSString stringWithFormat:@"%@",_dataSource[indexPath.row]];
        }
    }
    cell.textAlignment      = _textAlignment;
    cell.backgroundColor    = self.backgroundColor;
    return cell;
}

#pragma mark -------- UITableViewDelegate -------

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == _tableView) {
        [_tableView setContentOffset:CGPointMake(0, _rowHeight * (indexPath.row - _numberOfRowtoTop)) animated:YES];
    }
}

#pragma mark -------- UIScrollViewDelegate -------
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _tableView) {
        [self resetSelected];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (scrollView == _tableView) {
        self.isScrolling = YES;
        self.beginUserActivity  = YES;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (scrollView == _tableView) {
        NSInteger index = (NSInteger)targetContentOffset->y/_rowHeight;
        if (targetContentOffset->y != _rowHeight * index) {
            if (targetContentOffset->y - _rowHeight * index > _rowHeight/2) {
                targetContentOffset->y = _rowHeight * (++index);
            }
            else
            {
                targetContentOffset->y = _rowHeight * index;
            }
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    self.isScrolling = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        self.isScrolling = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.isScrolling = NO;
}

#pragma mark -------- lazy -------

- (UITableView *)tableView
{
    if (!_tableView ) {
        _tableView = [[UITableView alloc]init];
        [_tableView registerClass:[JWPickerItemViewCell class] forCellReuseIdentifier:NSStringFromClass([JWPickerItemViewCell class])];
        _tableView.dataSource       = self;
        _tableView.delegate         = self;
        _tableView.rowHeight        = _rowHeight;
        _tableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator     = NO;
        _tableView.showsHorizontalScrollIndicator   = NO;
        _tableView.translatesAutoresizingMaskIntoConstraints = NO;
        
    }
    return _tableView;
}

- (NSLayoutConstraint *)tableVieWHeightLayout
{
    if (!_tableVieWHeightLayout) {
        CGFloat height = (_rowHeight * _numberOfShow);// > CGRectGetHeight(self.frame) ? CGRectGetHeight(self.frame) : (_rowHeight * 5);
        _tableVieWHeightLayout = [NSLayoutConstraint constraintWithItem:_tableView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:0.0
                                                               constant:height];
    }
    return _tableVieWHeightLayout;
}

- (void)setRowHeight:(CGFloat)rowHeight
{
    if (rowHeight != _rowHeight) {
        _rowHeight = rowHeight;
        self.tableView.contentInset = UIEdgeInsetsMake(rowHeight * _numberOfRowtoTop, 0, rowHeight * _numberOfRowtoTop, 0);
        self.tableVieWHeightLayout.constant = rowHeight * (_numberOfRowtoTop * 2 + 1);
        [_tableView setContentOffset:CGPointMake(0, -_rowHeight * _numberOfRowtoTop) animated:YES];
        [self layoutIfNeeded];
        [self reloadData];
    }
}

- (void)setNumberOfShow:(NSInteger)numberOfShow
{
    _numberOfShow = numberOfShow;
    self.numberOfRowtoTop = numberOfShow/2;
}

- (void)setNumberOfRowtoTop:(NSInteger)numberOfRowtoTop
{
    _numberOfRowtoTop = numberOfRowtoTop;
    self.tableView.contentInset = UIEdgeInsetsMake(_rowHeight * numberOfRowtoTop, 0, _rowHeight * numberOfRowtoTop, 0);
    self.tableVieWHeightLayout.constant = _rowHeight * (numberOfRowtoTop * 2 + 1);
    [self layoutIfNeeded];
}

- (void)setIsScrolling:(BOOL)isScrolling
{
    _isScrolling = isScrolling;
    if (!isScrolling) {
        _finalRow = _currentRow;
        if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerItemViewDidEndScrollingAnimation:didSelectRow:)]) {
            [_delegate jw_pickerItemViewDidEndScrollingAnimation:self didSelectRow:_currentRow];
        }
    }
}

- (void)resetSelected
{
    CGFloat tabelViewHeight = CGRectGetHeight(_tableView.frame);
    CGFloat tableViewContentOffsetY = 0;
    if (_tableView.contentOffset.y < - (_rowHeight * _numberOfRowtoTop)) {
        tableViewContentOffsetY = -_rowHeight * _numberOfRowtoTop;
    }
    else if (_tableView.contentOffset.y > _tableView.contentSize.height - _rowHeight * (_numberOfShow/2 + 1))
    {
        tableViewContentOffsetY = _tableView.contentSize.height - _rowHeight * (_numberOfShow/2 + 1);
    }
    else
    {
        tableViewContentOffsetY = _tableView.contentOffset.y;
    }
    CGPoint scrollViewCenter    = CGPointMake(0, tableViewContentOffsetY + tabelViewHeight/2);
    NSIndexPath *indexPath      = [_tableView indexPathForRowAtPoint:scrollViewCenter];
    [_tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    if (_currentRow == indexPath.row) {
        return;
    }
    _currentRow = indexPath.row;
    if (_delegate && [_delegate respondsToSelector:@selector(jw_pickerItemView:didSelectRow:)]) {
        [_delegate jw_pickerItemView:self didSelectRow:indexPath.row];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_tableView setContentOffset:CGPointMake(0, _rowHeight * (_finalRow - _numberOfRowtoTop))];
    [self resetSelected];
}
@end
