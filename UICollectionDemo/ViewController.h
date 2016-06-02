//
//  ViewController.h
//  UICollectionDemo
//
//  Created by Guohx on 16/5/30.
//  Copyright © 2016年 guohx. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  collectionView 使用
 1、协议 <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
 2、构建
 1）创建布局对象 单元格尺寸 头视图高度 floawlayout方向
 2）collectionView初始化 addSubView
 3）collectionViewCell 注册
 4) colletionView头视图注册
 
 3、实现协议内容
 */
@interface ViewController : UIViewController


@property (nonatomic, strong) NSMutableSet * selectArr; ///<可选的
@property (nonatomic, strong) NSMutableSet * disSelectArr; ///<不可选的

@property (nonatomic, strong) NSMutableArray * dataArr; ///<数据数组


@end

