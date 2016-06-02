//
//  CustomCollectionViewCell.h
//  UICollectionDemo
//
//  Created by Guohx on 16/5/30.
//  Copyright © 2016年 guohx. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCollectionViewCell : UICollectionViewCell

- (void)setInfo:(NSIndexPath *)indexpath num:(NSString *)num;

- (void)setCellSelect:(BOOL)select;
- (void)setCellDisSelect:(BOOL)disselect;

@end
