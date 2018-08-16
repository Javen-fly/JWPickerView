//
//  JWPickerItemView.h
//  JWPickerViewDemo
//
//  Created by 吴建文 on 2018/2/8.
//  Copyright © 2018年 Javen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JWPickerItemView;
@protocol JWPickerItemViewDelegate<NSObject>
@optional

- (void)jw_pickerItemView:(JWPickerItemView *)pickerItemView didSelectRow:(NSInteger)row;
- (void)jw_pickerItemViewDidEndScrollingAnimation:(JWPickerItemView *)pickerItemView didSelectRow:(NSInteger)row;


@end

@interface JWPickerItemView : UIView

/** 行高 */
@property (nonatomic) CGFloat rowHeight;

/** 同时显示几行 */
@property (nonatomic) NSInteger numberOfShow;

@property (nonatomic, strong) NSArray *dataSource;

/** 文字颜色 */
@property (nonatomic, strong) UIColor *textColor;
/** 选中文字颜色 */
@property (nonatomic, strong) UIColor *selectedTextColor;
/** 文字格式 */
@property (nonatomic, strong) UIFont  *textFont;
/** 选中文字颜色 */
@property (nonatomic, strong) UIFont  *selectedTextFont;

/** 文字位置 */
@property (nonatomic, assign) NSTextAlignment textAlignment;


@property (nonatomic, weak) id<JWPickerItemViewDelegate> delegate;

/** 当前显示第几行，实时更新 */
@property (nonatomic, assign, readonly) NSInteger currentRow;
/** 最后显示第几行，停止滚动 */
@property (nonatomic, assign, readonly) NSInteger finalRow;

@property (nonatomic, assign) BOOL isScrolling;
@property (nonatomic, assign) BOOL beginUserActivity;

- (void)reloadData;

- (void)selectIndex:(NSInteger)index;

@end

