//
//  ViewController.m
//  EZCarouseImageView
//
//  Created by xuqianlong on 15/7/30.
//  Copyright (c) 2015年 xuqianlong. All rights reserved.
//

#import "ViewController.h"
#import "EZCarouseImageView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    EZCarouseImageView *carouse = [[EZCarouseImageView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 240) animationDuration:3];
    
    [carouse resetEasyURLArr:@[@"http://cdn.duitang.com/uploads/item/201110/09/20111009155438_ddWci.jpg",
                               @"http://pic27.nipic.com/20130220/11588199_085521216128_2.jpg",
                               @"http://a0.att.hudong.com/57/78/05300001208815130387782748704.jpg",
                               @"http://pic29.nipic.com/20130506/3822951_101843891000_2.jpg"]];
    
    [self.view addSubview:carouse];
    
    [carouse didClickedEZCarouseImageView:^(NSUInteger idx) {
        NSLog(@"----%lu",(unsigned long)idx);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
