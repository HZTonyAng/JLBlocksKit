//
//  ViewController.m
//  JLBlocksKit
//
//  Created by 杨通 on 2019/6/19.
//  Copyright © 2019 TonyAng. All rights reserved.
//
//https://github.com/zwaldowski/BlocksKit

#import "ViewController.h"
//Foundation框架
#import <BlocksKit.h>
//UIKit框架
#import <BlocksKit+UIKit.h>
#import <BlocksKit/A2DynamicDelegate.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addButton];
    [self addTextField];
    [self addWebView];
    [self addView];
    
    [self addArray];
    [self addAssociatedObject];
    [self addAlertView];
    [self addTableview];
    [self addKVO];
    [self addNSTimer];
}

#pragma mark - UIKit相关的Block

- (void)addButton {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor cyanColor];
    btn.frame = CGRectMake(0, 60, self.view.frame.size.width, 40);
    [self.view addSubview:btn];
    
    [btn bk_addEventHandler:^(id sender) {
        // do something
        NSLog(@"Button");
    } forControlEvents:UIControlEventTouchUpInside];
}

- (void)addTextField {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 110, self.view.frame.size.width, 40)];
    textField.backgroundColor = [UIColor lightGrayColor];
    textField.placeholder = @"TextField";
    textField.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:textField];
    
    [textField setBk_shouldReturnBlock:^BOOL(UITextField *field) {
        // do something
        [self.view endEditing:YES];
        NSLog(@"Return");
        return YES;
    }];
}

- (void)addWebView {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 160, self.view.frame.size.width, 100)];
    webView.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    NSURL *url = [NSURL URLWithString:@"http://www.taobao.com"];
    NSURLRequest *request =[NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    [webView bk_setDidFinishWithErrorBlock:^(UIWebView *webView, NSError *error) {
        // do something
        NSLog(@"webView加载完成");
    }];
}

- (void)addView {
    [self.view bk_whenTapped:^{
        NSLog(@"self.view单击了");
    }];
}

#pragma mark - Foundation相关的Block

- (void)addArray {
    NSArray *arr = @[@"1",@"2",@"61",@"71",@"234",@"3456",@"45678",@"59900"];

    ///串行遍历容器中所有元素
    [arr bk_each:^(id obj) {
        NSLog(@"串行遍历obj = %@",obj);
    }];
    
    ///并发遍历容器中所有元素（不要求容器中元素顺次遍历的时候可以使用此种遍历方式来提高遍历速度）
    [arr bk_apply:^(id obj) {
        NSLog(@"无序遍历obj = %@",obj);
    }];
    
    ///返回第一个符合block条件（让block返回YES）的对象
    NSString *str = [arr bk_match:^BOOL(id  _Nonnull obj) {
        return ((NSString *)obj).length == 1;
    }];
    NSLog(@"str长度为1 = %@",str);

    ///返回所有符合block条件（让block返回YES）的对象
    NSArray *arr1 = [arr bk_select:^BOOL(id  _Nonnull obj) {
        return ((NSString *)obj).length == 2;
    }];
    NSLog(@"arr1长度为2的数组 = %@",arr1);

    ///返回所有！！！不符合block条件（让block返回YES）的对象
    NSArray *arr2 = [arr bk_reject:^BOOL(id  _Nonnull obj) {
        return ((NSString *)obj).length == 3;
    }];
    NSLog(@"arr2返回所有 = %@",arr2);
    
    ///查看容器是否有符合block条件的对象
    ///判断是否容器中至少有一个元素符合block条件
    BOOL isHave = [arr bk_any:^BOOL(id obj) {
        return [((NSString *)obj) isEqualToString:@"59900"];
    }];
    NSLog(@"isHave = %d",isHave);

    ///判断是否容器中所有元素都不符合block条件
    BOOL isAccord = [arr bk_none:^BOOL(id obj) {
        return [((NSString *)obj) isEqualToString:@"59900"];
    }];
    NSLog(@"isAccord = %d",isAccord);
    
    ///判断是否容器中所有元素都符合block条件
    BOOL allAccord = [arr bk_none:^BOOL(id obj) {
        return [obj integerValue] > 0;
    }];
    NSLog(@"allAccord = %d",allAccord);
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:arr];
    
    ///删除容器中不符合block条件的对象，即只保留符合block条件的对象
    [mutableArray bk_performSelect:^BOOL(id obj) {
        return [obj integerValue] < 10;
    }];
    NSLog(@"mutableArray = %@",mutableArray);
    
    //删除容器中符合block条件的对象
    [mutableArray bk_performReject:^BOOL(id obj) {
        return ((NSString *)obj).length == 3;
    }];
    NSLog(@"mutableArray = %@",mutableArray);
}

#pragma mark - NSObject动态增加属性

/// 添加 AssociatedObject  为一个已经存在的类添加属性
- (void)addAssociatedObject {
    NSObject *test = [[NSObject alloc] init];
    [test bk_associateValue:@"Draveness" withKey:@"name"];
    NSLog(@"AssociatedObject------%@",[test bk_associatedValueForKey:@"name"]);
    
}

#pragma mark - UIAlertView

- (void)addAlertView {
    UIAlertView *alert = [UIAlertView bk_showAlertViewWithTitle:@"提示" message:@"这是一条提示" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确认"] handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == 0) { // 取消
            NSLog(@"buttonITitle = 取消");
            [self addActionSheet];
        }
        NSLog(@"buttonIndex = %ld", buttonIndex);
    }];
    
    [alert show];
}

#pragma mark - UIActionSheet

- (void)addActionSheet {
    UIActionSheet *action = [[UIActionSheet alloc] bk_initWithTitle:@"title"];
    
    [action bk_addButtonWithTitle:@"1" handler:^{
        NSLog(@"1");
    }];
    [action bk_addButtonWithTitle:@"2" handler:^{
        NSLog(@"2");
    }];
    [action bk_setDestructiveButtonWithTitle:@"销毁" handler:^{
        NSLog(@"销毁");
    }];
    [action bk_addButtonWithTitle:@"3" handler:^{
        NSLog(@"3");
    }];
    
    [action bk_setCancelButtonWithTitle:@"取消" handler:^{
        NSLog(@"取消");
    }];
    
    [action showInView:self.view];
}

#pragma mark - Tableview

- (void)addTableview {
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 260, self.view.frame.size.width, 300) style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    A2DynamicDelegate *datasource = tableView.bk_dynamicDelegate;
    [datasource implementMethod:@selector(tableView:numberOfRowsInSection:) withBlock:^ NSInteger (UITableView *tableView,NSInteger section){
        return 3;
    }];
    [datasource implementMethod:@selector(tableView:cellForRowAtIndexPath:) withBlock:^ UITableViewCell * (UITableView *tableView, NSIndexPath *indexPath){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        cell.textLabel.text = @"dfdfd";
        return cell;
    }];
    [datasource implementMethod:@selector(tableView:heightForRowAtIndexPath:) withBlock:^ CGFloat (UITableView *tableview , NSIndexPath * indexPath) {
        return 100;
    }];
    tableView.dataSource = (id)datasource;
    tableView.delegate = (id)datasource;
    
}

#pragma mark - KVO

- (void)addKVO {
    ///1 生成indentify
    // 生成的是用于移除观察的 indentify
    UILabel *label = [UILabel new];
    NSString *token = [label bk_addObserverForKeyPath:@"text" options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        NSLog(@"indentify-----%@",change);
        NSLog(@"indentify-----%@",obj);
    }];
    // 移除上面添加的
    [label bk_removeObserversWithIdentifier:token];
    
    ///2 直接写indentify，使用感觉比较方便，indentify 可以与通知一样写个 常量。
    [label bk_addObserverForKeyPath:@"test" identifier:@"indentfy" options:NSKeyValueObservingOptionNew task:^(id obj, NSDictionary *change) {
        NSLog(@"indentify-----%@",change);
        NSLog(@"indentify-----%@",obj);
    }];
    [label bk_removeObserversWithIdentifier:@"indentify"];
    
}

#pragma mark - NSTimer

- (void)addNSTimer {
    [NSTimer bk_scheduledTimerWithTimeInterval:1 block:^(NSTimer *timer) {
        // do
        NSLog(@"1");
    } repeats:YES];
    
}


@end
