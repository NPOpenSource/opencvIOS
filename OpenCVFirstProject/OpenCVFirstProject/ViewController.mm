//
//  ViewController.m
//  OpenCVFirstProject
//
//  Created by glodon on 2019/10/22.
//  Copyright © 2019 persion. All rights reserved.
//
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/core/core_c.h>
//OpenCV离散傅里叶变换
using namespace cv;
using namespace std;
#endif

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Mat M(3,2, CV_8UC3, Scalar(0,0,255));
    cout << "M = " << endl << " " << M << endl;
}


@end


