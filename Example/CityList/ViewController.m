//
//  ViewController.m
//  CityList
//
//  Created by bhb on 15/7/29.
//  Copyright (c) 2015年 Micky. All rights reserved.
//

#import "ViewController.h"
#import "CityListViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CityListViewController *city = [[CityListViewController alloc] init];
    [self.navigationController pushViewController:city animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
