//
//  OCVBaseViewController.m
//  OpenCVBase
//
//  Created by glodon on 2019/10/23.
//

#import "OCVBaseViewController.h"

@interface OCVBaseViewController ()

@end

@implementation OCVBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

-(UIImageView *)createImageViewInRect:(CGRect)frame{
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:frame];
    return imageView;
}

@end
