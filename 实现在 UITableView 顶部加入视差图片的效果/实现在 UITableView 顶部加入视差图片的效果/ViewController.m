//
//  ViewController.m
//  实现在 UITableView 顶部加入视差图片的效果
//
//  Created by 远洋 on 16/2/21.
//  Copyright © 2016年 yuayang. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong)UITableView * tableView;
@property (nonatomic,strong)UIImageView * imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0]];
    [self.tableView setContentInset:UIEdgeInsetsMake(300, 0, 0, 0)];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    //因为设置了anchorPoint，图片就会下降图片高度的一半也就是150，所以我们把 frame 的 y 设置为-150。
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -150, self.view.bounds.size.width, 300)];
    self.imageView.layer.anchorPoint = CGPointMake(0.5f, 0);
    self.imageView.image = [UIImage imageNamed:@"2.jpg"];
    
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.tableView];
}

/**
 *  计算图片位移和缩放
 */
- (void)makeParallaxEffect {
    //获取偏移量
    CGPoint point = self.tableView.contentOffset;
    //判断偏移量是否是下拉 是的话就等比例放大
    if (point.y < -300) {
        //计算比例fabs是取绝对值的意思
        float scaleFactor = fabs(point.y) / 300.f;
        //设置图片的transform
        self.imageView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    } else {
        self.imageView.transform = CGAffineTransformMakeScale(1, 1);
    }
    
    if (point.y <= 0) {
        if (point.y >= -300) {
            self.imageView.transform = CGAffineTransformTranslate(self.imageView.transform, 0, (fabs(point.y) - 300) / 2.f);
        }
        self.imageView.alpha = fabs(point.y / 300.f);
        self.navigationController.navigationBar.alpha = 1 - powf(fabs(point.y / 300.f), 3);
    } else {
        self.imageView.transform = CGAffineTransformTranslate(self.imageView.transform, 0, 0);
        self.imageView.alpha = 0;
        self.navigationController.navigationBar.alpha = 1;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self makeParallaxEffect];
}


- (void)viewWillAppear:(BOOL)animated {
    [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    [UIView beginAnimations:nil context:nil];
    [self makeParallaxEffect];
    [UIView commitAnimations];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIView beginAnimations:nil context:nil];
    self.navigationController.navigationBar.alpha = 1;
    [UIView commitAnimations];
    
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if (object == self.tableView) {
        [self makeParallaxEffect];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 30;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * ID = @"cell";
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"我是第:%ld个cell",indexPath.row];
    
    return cell;
}
@end
