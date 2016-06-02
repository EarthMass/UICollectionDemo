//
//  BottomView.h
//  UICollectionDemo
//
//  Created by Guohx on 16/5/31.
//  Copyright © 2016年 guohx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AllSelBlock)(BOOL isSelect);
typedef void(^DeleteSelBlock)(void);

@interface BottomView : UIView

@property (weak, nonatomic) IBOutlet UIButton *allSelBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;


- (void)allSelClick:(AllSelBlock)allSelBlock deleteSelBlock:(DeleteSelBlock)deleteSelBlock;

@end
