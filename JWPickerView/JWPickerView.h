//
//  JWPickerView.h
//  JWPickerViewDemo
//
//  Created by 吴建文 on 2018/2/8.
//  Copyright © 2018年 Javen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class JWPickerView;

@protocol JWPickerViewDataSource <NSObject>

- (NSInteger)jw_numberOfItemInPickerView:(JWPickerView *)pickerView;
- (NSInteger)jw_pickerView:(JWPickerView *)pickerView numberOfRowInItem:(NSInteger)item;

@optional

- (NSString *)jw_pickerView:(JWPickerView *)pickerView textForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSAttributedString *)jw_pickerView:(JWPickerView *)pickerView attributedTextForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@protocol JWPickerViewDelegate <NSObject>
@optional
- (void)jw_pickerView:(JWPickerView *)pickerView didSelectedRow:(NSInteger)row inItem:(NSInteger)item;

- (UIColor *)jw_pickerView:(JWPickerView *)pickerView textColorForItem:(NSInteger)item;
- (UIColor *)jw_pickerView:(JWPickerView *)pickerView selectedTextColorForItem:(NSInteger)item;
- (UIFont  *)jw_pickerView:(JWPickerView *)pickerView textFontForItem:(NSInteger)item;
- (UIFont  *)jw_pickerView:(JWPickerView *)pickerView selectedTextFontForItem:(NSInteger)item;

- (CGFloat)jw_pickerView:(JWPickerView *)pickerView widthForRowInItem:(NSInteger)item;
- (CGFloat)jw_pickerView:(JWPickerView *)pickerView heightForItemInItem:(NSInteger)item;
- (CGFloat)jw_minSpeaceForItmeInPickerView:(JWPickerView *)pickerView;

- (NSInteger)jw_pickerView:(JWPickerView *)pickerView numberOfShowInItem:(NSInteger)item;

- (NSTextAlignment)jw_pickerView:(JWPickerView *)pickerView textAlignmentInItem:(NSInteger)item;

- (UIColor *)jw_pickerView:(JWPickerView *)pickerView backgroundColorInItem:(NSInteger)item;


@end

@interface JWPickerView : UIView

/** 行高 */
@property (nonatomic, assign) CGFloat rowHeight;
/** item宽 */
@property (nonatomic, assign) CGFloat itemWidth;
/** 最小间距 */
@property (nonatomic, assign) CGFloat minItemSpeace;
/** 同时显示几行 */
@property (nonatomic, assign) NSInteger numberOfShow;

/** 文字颜色 */
@property (nonatomic, strong) UIColor *textColor;
/** 选中文字颜色 */
@property (nonatomic, strong) UIColor *selectedTextColor;
/** 文字格式 */
@property (nonatomic, strong) UIFont *textFont;
/** 选中文字颜色 */
@property (nonatomic, strong) UIFont *selectedTextFont;

/** 文字位置 */
@property (nonatomic, assign) NSTextAlignment textAlignment;

/** 代理 */
@property (nonatomic, weak) id<JWPickerViewDataSource> dateSource;
@property (nonatomic, weak) id<JWPickerViewDelegate> delegate;

/** 内边距 */
@property (nonatomic, assign) UIEdgeInsets inset;

/** 被选中各组的row */
@property (nonatomic, assign, readonly) NSMutableDictionary *selectedDic;


- (void)reloadData;
- (void)reloadDataWithItem:(NSInteger)item;

- (void)selectIndexPath:(NSIndexPath *)indexPath;
- (void)selectIndexPaths:(NSArray <NSIndexPath *>*)indexPaths;
@end
