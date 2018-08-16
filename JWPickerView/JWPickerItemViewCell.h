//
//  JWPickerItemViewCell.h
//  JWPickerViewDemo
//
//  Created by 吴建文 on 2018/2/8.
//  Copyright © 2018年 Javen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JWPickerItemViewCell : UITableViewCell

@property (nonatomic, copy) NSString *text;

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *selectedTextColor;
@property (nonatomic, strong) UIFont *textFont;
@property (nonatomic, strong) UIFont *selectedTextFont;
@property (nonatomic, assign) NSTextAlignment textAlignment;


@end
