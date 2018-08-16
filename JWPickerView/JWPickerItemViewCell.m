//
//  JWPickerItemViewCell.m
//  JWPickerViewDemo
//
//  Created by 吴建文 on 2018/2/8.
//  Copyright © 2018年 Javen. All rights reserved.
//

#import "JWPickerItemViewCell.h"

@interface JWPickerItemViewCell()

@property (nonatomic, strong) UILabel *contentLab;

@end

@implementation JWPickerItemViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textFont = self.contentLab.font;
        _textColor = self.contentLab.textColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _contentLab = [[UILabel alloc]initWithFrame:CGRectZero];
        _contentLab.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:_contentLab];
        NSLayoutConstraint *leftLayout   = [NSLayoutConstraint constraintWithItem:_contentLab
                                                                           attribute:NSLayoutAttributeLeft
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.contentView
                                                                           attribute:NSLayoutAttributeLeft
                                                                          multiplier:1.0
                                                                            constant:0.f];
        NSLayoutConstraint *rightLayout   = [NSLayoutConstraint constraintWithItem:_contentLab
                                                                           attribute:NSLayoutAttributeRight
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.contentView
                                                                           attribute:NSLayoutAttributeRight
                                                                          multiplier:1.0
                                                                            constant:0.f];
        NSLayoutConstraint *topLayout   = [NSLayoutConstraint constraintWithItem:_contentLab
                                                                           attribute:NSLayoutAttributeTop
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.contentView
                                                                           attribute:NSLayoutAttributeTop
                                                                          multiplier:1.0
                                                                            constant:0.f];
        NSLayoutConstraint *bottomLayout   = [NSLayoutConstraint constraintWithItem:_contentLab
                                                                           attribute:NSLayoutAttributeBottom
                                                                           relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.contentView
                                                                           attribute:NSLayoutAttributeBottom
                                                                          multiplier:1.0
                                                                            constant:0.f];
        [self.contentView addConstraints:@[leftLayout, rightLayout, topLayout, bottomLayout]];
    }
    return self;
}

- (void)setText:(NSString *)text
{
    _text = text;
    _contentLab.text = text;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _textAlignment = textAlignment;
    self.contentLab.textAlignment = textAlignment;
}

- (void)setTextFont:(UIFont *)textFont
{
    _textFont = textFont;
    self.contentLab.font = textFont;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    self.contentLab.textColor = textColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (_selectedTextFont) {
        if (selected) {
            self.contentLab.font = _selectedTextFont;
        }
        else
        {
            self.contentLab.font = _textFont;
        }
    }
    if (_selectedTextColor) {
        if (selected) {
            self.contentLab.textColor = _selectedTextColor;
        }
        else
        {
            self.contentLab.textColor = _textColor;
        }
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

@end
