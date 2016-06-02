//
//  ViewController.m
//  UICollectionDemo
//
//  Created by Guohx on 16/5/30.
//  Copyright © 2016年 guohx. All rights reserved.
//

#import "ViewController.h"
#import "CustomCollectionViewCell.h"
#import "CollectionViewHeadV.h"
#import "User.h"
#import "BottomView.h"

#define KEY @"objectId" ///<查询、过滤关键字

@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout> {
    UICollectionView * collectionV;
    
    BottomView * bottomV;
}

@end

@implementation ViewController

- (void)initData {
    self.selectArr = [[NSMutableSet alloc] init];
    self.disSelectArr = [[NSMutableSet alloc] init];
    
    self.dataArr = [NSMutableArray array];
    
    for (int i =0; i < 10; i ++) {
        User * user = [[User alloc] init];
        user.objectId = [NSString stringWithFormat:@"%d",i];
        user.objectName = [NSString stringWithFormat:@" %d",i];
        [_dataArr addObject:user];
    }
    
    for (int i =0; i < 7; i ++) {
        if (i == 0 || i == 2 || i == 6) {
            User * user = [[User alloc] init];
            user.objectId = [NSString stringWithFormat:@"%d",i];
            user.objectName = [NSString stringWithFormat:@" %d",i];
            [_disSelectArr addObject:user];
        }
        
    }
}

- (void)navInit {

    self.title = @"UICollectionDemo";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    UIBarButtonItem * rightItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem * leftItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(deleteClick:)];
    leftItem.tintColor = [UIColor redColor];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self navInit];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initData];
    
    //layout
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    //item 尺寸
    [layout setItemSize:CGSizeMake(95, 95)];
    //头部 尺寸
    [layout setHeaderReferenceSize:CGSizeMake(320, 40)];
    //滚动方向
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    
    //行距 纵距
    layout.minimumLineSpacing = 10;
    layout.minimumInteritemSpacing = 5;
    
    //UICollectionView 初始化
    collectionV = [[UICollectionView alloc] initWithFrame:[UIScreen mainScreen].bounds collectionViewLayout:layout];
    collectionV.backgroundColor = [UIColor whiteColor];
    
    //协议
    collectionV.delegate = self;
    collectionV.dataSource = self;
    [self.view addSubview:collectionV];
    
    // 注册 cell 以及头部 【复用就有了】 ##必须这么写##
    UINib * nib = [UINib nibWithNibName:@"CustomCollectionViewCell" bundle:nil];
    [collectionV registerNib:nib forCellWithReuseIdentifier:@"11111"];
    
    //collection头视图的注册
    UINib * nibHeadV = [UINib nibWithNibName:@"CollectionViewHeadV" bundle:nil];
    [collectionV registerNib:nibHeadV forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CollectionViewHeadV"];
    
}

#pragma mark- 导航栏按钮点击

- (void)rightClick:(UIBarButtonItem *)sender {
    if ([sender.title isEqualToString:@"编辑"]) {
        sender.title = @"取消";
        self.navigationItem.leftBarButtonItem.title = @"删除";
        [self setCollectionMutiSelect:YES];
        [self bottomViewShow:YES];
        
        [self refreshData];
        
        [collectionV reloadData];
        
        
    } else {
        sender.title = @"编辑";
         self.navigationItem.leftBarButtonItem.title = @"";
        [self setCollectionMutiSelect:NO];
        [self bottomViewShow:NO];
        
        [self refreshData];
        
        [collectionV reloadData];
        
    }
}

- (void)deleteClick:(UIBarButtonItem *)sender {
    
    NSArray * arr = [[_selectArr valueForKeyPath:KEY] allObjects];
    
    //排序
    NSArray * sortDesc = @[[NSSortDescriptor sortDescriptorWithKey:nil ascending:YES]];
    NSArray * sortArr  = [arr sortedArrayUsingDescriptors:sortDesc];
    NSString * str = [sortArr componentsJoinedByString:@"，"];
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[NSString stringWithFormat:@"删除 :%@",str] delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)setCollectionMutiSelect:(BOOL)muti {
    collectionV.allowsMultipleSelection = muti;
}

#pragma mark- 多选 全选 
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    return [self isCanSelect:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self isCanSelect:indexPath];
}

//点击 事件
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
//    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    NSLog(@"UICollection 点击了 %ld %ld",(long)indexPath.section,(long)indexPath.row);
    
    [self addSelect:indexPath];
   
}

#pragma mark 操作逻辑

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"UICollection 取消了 %ld %ld",(long)indexPath.section,(long)indexPath.row);
    
    [self deSelect:indexPath];
}

/**
 *  多选操作时 查询不能选中的索引数组 在cellForItemAtIndexPath 处理
 *
 *  @return 不能选中的索引数组
 */
- (void)updataDisableSelCell:(CustomCollectionViewCell *)cell
                   indexPath:(NSIndexPath *)indexPath {
    if (![_disSelectArr count] || !collectionV.allowsMultipleSelection) {
        
        [cell setCellSelect:NO];
        return;
    }
    //不可选的
    NSArray * disSelIdArr = [_disSelectArr valueForKey:KEY];
    NSArray * dataIdArr = [_dataArr valueForKey:KEY];
    NSMutableArray * disSelIndexArr = [NSMutableArray array];
    
    for (NSString * idStr in disSelIdArr) {
        if ([dataIdArr containsObject:idStr]) {
            NSInteger index = [dataIdArr indexOfObject:idStr];
            [disSelIndexArr addObject:@(index)];
        }
    }
    
    if ([disSelIndexArr containsObject:@(indexPath.row)]) {
        [cell setCellDisSelect:YES];
    } else {
        [cell setCellSelect:NO];
    }
}

/**
 *  多选操作时 选中的 在cellForItemAtIndexPath 处理
 *
 *  @return 选中的索引数组
 */
- (void)updataSelCell:(CustomCollectionViewCell *)cell
                   indexPath:(NSIndexPath *)indexPath {
    if (![_selectArr count] || !collectionV.allowsMultipleSelection) {
        
        [cell setCellSelect:NO];

        return;
    }
    //选中的
    NSArray * selIdArr = [_selectArr valueForKey:KEY];
    NSArray * dataIdArr = [_dataArr valueForKey:KEY];
    NSMutableArray * selIndexArr = [NSMutableArray array];
    
    for (NSString * idStr in selIdArr) {
        if ([dataIdArr containsObject:idStr]) {
            NSInteger index = [dataIdArr indexOfObject:idStr];
            [selIndexArr addObject:@(index)];
        }
    }
    
    if ([selIndexArr containsObject:@(indexPath.row)]) {
        [cell setCellSelect:YES];
    } else {
        [cell setCellSelect:NO];
    }
}


- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self updataDisableSelCell:(CustomCollectionViewCell *)cell indexPath:indexPath];
    [self updataSelCell:(CustomCollectionViewCell *)cell indexPath:indexPath];
}

#pragma mark 底部操作
- (void)bottomViewShow:(BOOL)show {
    
    if (show) {
        
        if (![self.view viewWithTag:8888]) {
            bottomV = [[[NSBundle mainBundle] loadNibNamed:@"BottomView" owner:self options:nil] lastObject];
            bottomV.tag = 8888;
            bottomV.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 64 - 40, [UIScreen mainScreen].bounds.size.width, 40);
            
            __block typeof(self) weakSelf = self;
            [bottomV allSelClick:^(BOOL isSelect) {
                if (!isSelect) {
                    //全选
                    [weakSelf allSelect];
                } else {
                    //全不选
                    [weakSelf allDeselect];
                }
            } deleteSelBlock:^{
                //删除操作
                [weakSelf deleteSelect];
            }];
            
            [self.view addSubview:bottomV];
        }
    } else {
        if ([self.view viewWithTag:8888]) {
            [[self.view viewWithTag:8888] removeFromSuperview];
        }
    }
    
}

- (void)updateBottomView {
    if (bottomV && collectionV.allowsMultipleSelection) {
        BOOL isAll = [self isAllSelect];
        bottomV.allSelBtn.selected =  isAll;
    }
}

//- (void)updateCellView:(UICollectionViewCell *)cell {
//    cell
//}

/**
 *  判断是否全选了【可选的】
 *
 *  @return YES/NO
 */
- (BOOL)isAllSelect {
    
    return [_selectArr isEqualToSet:[self canSelArr]];
}

- (NSSet *)canSelArr {
    
    NSArray * deselectIdArr = [_disSelectArr valueForKeyPath:KEY];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"NOT(%K in %@)",KEY,deselectIdArr];
    NSArray * tmpArr = [_dataArr filteredArrayUsingPredicate:predicate];
    
    NSSet * tmpSet = [[NSSet alloc] initWithArray:tmpArr];
    
    return tmpSet;
}

- (BOOL)isCanSelect:(NSIndexPath *)indexPath {
    
    if (![_disSelectArr count]) {
        return YES;
    }
    
    if (collectionV.allowsMultipleSelection) {
        User * contact = _dataArr[indexPath.row];
        NSArray * disSelectIdArr = [_disSelectArr valueForKey:KEY];
        if ([disSelectIdArr containsObject:contact.objectId]) {
            return NO;
        } else {
            return YES;
        }
    }
    return YES;
}

- (void)addSelect:(NSIndexPath *)indexPath {
    if ([self isCanSelect:indexPath]) {
        [_selectArr addObject:_dataArr[indexPath.row]];
        
        [self updateBottomView];
    }
    
}

- (void)deSelect:(NSIndexPath *)indexPath {
    if ([self isCanSelect:indexPath]) {
        [_selectArr removeObject:_dataArr[indexPath.row]];
        
        [self updateBottomView];
    
    }
}

#pragma mark 全选 全不选操作 删除
//全选
- (void)allSelect {
    [_selectArr removeAllObjects];
    
    NSArray * indexArr = [self getIndexArr:_dataArr targetSet:[self canSelArr]];
    __block typeof(self) weakSelf = self;
    [indexArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath * indexPath = obj;
        if ([weakSelf collectionView:weakSelf->collectionV shouldSelectItemAtIndexPath:indexPath]) {
            [weakSelf->collectionV selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            
        }
    }];
    [_selectArr setSet:[self canSelArr]];

}
//全不选
- (void)allDeselect {
    
    NSArray * indexArr = [self getIndexArr:_dataArr targetSet:_selectArr];
    __block typeof(self) weakSelf = self;
    [indexArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSIndexPath * indexPath = obj;
        if ([weakSelf collectionView:weakSelf->collectionV shouldDeselectItemAtIndexPath:indexPath]) {
            [weakSelf->collectionV deselectItemAtIndexPath:indexPath animated:YES];
        }
    }];
    [_selectArr removeAllObjects];
}
//删除
- (void)deleteSelect {
    NSArray * selIdArr = [_selectArr valueForKey:KEY];
    NSArray * dataIdArr = [_dataArr valueForKey:KEY];
    
    //比对 获取 选中项的 索引 , 用于删除选中的cell
    __block NSMutableArray * selIndexPathArr = [NSMutableArray array];
    __block NSMutableIndexSet * selIndexArr = [NSMutableIndexSet indexSet];
    [selIdArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString * str = [NSString stringWithFormat:@"%@",obj];
        
        if ([dataIdArr indexOfObject:str] < MAXFLOAT) {
            
            [selIndexPathArr addObject:[NSIndexPath indexPathForRow:[dataIdArr indexOfObject:str] inSection:0]];
            [selIndexArr addIndex:[dataIdArr indexOfObject:str]];
        }
        
    }];
    
    //删除cell 移除dataArr数据
//    [collectionV deleteItemsAtIndexPaths:selIndexPathArr];

    [_dataArr removeObjectsAtIndexes:selIndexArr];
    [self refreshData];
    [collectionV reloadData];
}

//刷新数据 选中项 不可编辑项 【单一次处理完成后】
- (void)refreshData {
    [_selectArr removeAllObjects];
}

//判断cell选中状态
- (BOOL)checkCellIsSel:(NSIndexPath *)indexPath {
    
    NSArray * selIdArr = [_selectArr valueForKey:KEY];
    User * user = _dataArr[indexPath.row];
    
   BOOL isSel = [selIdArr containsObject:user.objectId];
    
   return isSel;
}

/**
 *  获取数组在 源数组 中的 索引
 *
 *  @param data      源数组
 *  @param targetSet 目标数组
 *
 *  @return 索引数组 [NSIndexPath]
 */
- (NSArray *)getIndexArr:(NSArray *)data targetSet:(NSSet *)targetSet {
    
    NSArray * targetIdArr = [targetSet valueForKey:KEY];
    NSArray * dataIdArr = [data valueForKey:KEY];
    NSMutableArray * indexArr = [NSMutableArray array];
    
    for (NSString * idStr in targetIdArr) {
        if ([dataIdArr containsObject:idStr]) {
            NSInteger index = [dataIdArr indexOfObject:idStr];
            [indexArr addObject:[NSIndexPath indexPathForItem:index inSection:0]];
        }
    }
    return indexArr;

}


#pragma mark-

#pragma mark- uicollection datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArr.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString * indentifier = @"11111";
    CustomCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:indentifier forIndexPath:indexPath];
    
    //选中颜色
    cell.selectedBackgroundView = ({
        UIView * selectView = [[UIView alloc] initWithFrame:cell.bounds];
        selectView.backgroundColor = [UIColor brownColor];
        selectView;
    });
    
    User * user = _dataArr[indexPath.row];
    [cell setInfo:indexPath num:user.objectName];
    
    return cell;
}

#pragma mark- uicollection delegate


//组的头视图创建
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CollectionViewHeadV" forIndexPath:indexPath];

    return headView;
}



//边界范围
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

//单元格大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        return CGSizeMake(300 , 100);
    }
    return CGSizeMake(95, 95);
}

//横 纵间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

#pragma mark- ###长按显示菜单### 三个方法一起写才有效
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        return YES;
    }
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    
    // 【只支持这三个】此处只显示copy cut paste 复制 剪切 黏贴
    if ([NSStringFromSelector(action) isEqualToString:@"copy:"] || [NSStringFromSelector(action) isEqualToString:@"cut:"] || [NSStringFromSelector(action) isEqualToString:@"paste:"]) {
        return YES;
    }
    return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if ([NSStringFromSelector(action) isEqualToString:@"copy:"] || [NSStringFromSelector(action) isEqualToString:@"cut:"] || [NSStringFromSelector(action) isEqualToString:@"paste:"] || [NSStringFromSelector(action) isEqualToString:@"selectAll"]) {
        NSLog(@"call method is :-- %@",NSStringFromSelector(action));
    }
    
    if ([NSStringFromSelector(action) isEqualToString:@"copy:"]) { //copy
//        CustomCollectionViewCell *cell = (CustomCollectionViewCell *)[collectionView  cellForItemAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setPersistent:YES]; //本程序有效
        [[UIPasteboard generalPasteboard] setString:@"121221"];    //剪贴板存储
    }
    
    if ([NSStringFromSelector(action) isEqualToString:@"paste:"]) { //paste
        NSString * str = [[UIPasteboard generalPasteboard] string];
        NSLog(@"黏贴 内容：--%@",str) ;    //黏贴内容
    }
    
}
#pragma mark-

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
