//
//  BottomView.m
//  UICollectionDemo
//
//  Created by Guohx on 16/5/31.
//  Copyright © 2016年 guohx. All rights reserved.
//

#import "BottomView.h"



@interface BottomView()

@property (nonatomic, copy) AllSelBlock allSelBlock;
@property (nonatomic, copy) DeleteSelBlock deleteSelBlock;

@end

@implementation BottomView

- (IBAction)allSel:(id)sender {
    UIButton * btn = (UIButton *)sender;
    btn.selected =  !btn.selected;
    
    if (self.allSelBlock) {
        self.allSelBlock(!btn.selected);
    }
}
- (IBAction)delete:(id)sender {
    if (self.deleteSelBlock) {
        self.deleteSelBlock();
    }
}

- (void)allSelClick:(AllSelBlock)allSelBlock deleteSelBlock:(DeleteSelBlock)deleteSelBlock {
    self.allSelBlock = allSelBlock;
    self.deleteSelBlock = deleteSelBlock;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
