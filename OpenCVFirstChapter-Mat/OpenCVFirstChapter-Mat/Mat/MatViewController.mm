//
//  MatViewController.m
//  OpenCVFirstChapter-Mat
//
//  Created by glodon on 2019/10/29.
//  Copyright © 2019 persion. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/core/operations.hpp>

#import <opencv2/core/core_c.h>
using namespace cv;
using namespace std;

#endif

#import "MatViewController.h"

@interface MatViewController ()

@end

@implementation MatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    ///mat 创建不同指针,相同内存
    [self createMat];
    ///不同内存,不同指针
    [self createMatDifferBuffer];
    /// 不同方式创建Mat
    [self createMatMethod];
    //格式打印
    [self foramtPrint];
}

-(void)createMat{
    Mat A, C;                                 // 只创建信息头部分
    A= Mat(300,200, CV_8UC3, Scalar(0,0,255)); // 这里为矩阵开辟内存 bgr
    Mat B(A);                                 // 使用拷贝构造函数
    C = A;
    
    ///修改A的颜色  这里ABC 都是操作的同一个内存单元,改变一个颜色,ABC 颜色同时改变
    for( int i = 0; i < A.rows; ++i){
           for( int j = 0; j < A.cols; ++j ) {
              Vec3b pixel;
              pixel[0] = 255; //Blue
               pixel[1] = 0; //Green
               pixel[2] = 0; //Red
               A.at<Vec3b>(i,j) = pixel;
              }
       }
    
    UIImageView * imageView = [self createImageViewInRect:CGRectMake(0, 100, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:A];
    
   imageView = [self createImageViewInRect:CGRectMake(0, 200, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:B];
    
    imageView = [self createImageViewInRect:CGRectMake(0, 300, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:C];
    
}

-(void)createMatDifferBuffer{
    Mat  A= Mat(300,300, CV_8UC3, Scalar(0,0,255)); // 这里为矩阵开辟内存 bgr
    Mat F = A.clone();
    Mat G;
    A.copyTo(G);
    
    ///修改A的颜色  这里ABC 都是操作的同一个内存单元,改变一个颜色,ABC 颜色同时改变
       for( int i = 0; i < A.rows; ++i){
              for( int j = 0; j < A.cols; ++j ) {
                 Vec3b pixel;
                 pixel[0] = 255; //Blue
                  pixel[1] = 0; //Green
                  pixel[2] = 0; //Red
                  A.at<Vec3b>(i,j) = pixel;
                 }
          }
    
    
    ///修改A的颜色  这里ABC 都是操作的同一个内存单元,改变一个颜色,ABC 颜色同时改变
       for( int i = 0; i < F.rows; ++i){
              for( int j = 0; j < F.cols; ++j ) {
                 Vec3b pixel;
                 pixel[0] = 255; //Blue
                  pixel[1] = 0; //Green
                  pixel[2] = 255; //Red
                  F.at<Vec3b>(i,j) = pixel;
                 }
          }
    
    ///修改A的颜色  这里ABC 都是操作的同一个内存单元,改变一个颜色,ABC 颜色同时改变
    for( int i = 0; i < F.rows; ++i){
           for( int j = 0; j < F.cols; ++j ) {
              Vec3b pixel;
              pixel[0] = 125; //Blue
               pixel[1] = 0; //Green
               pixel[2] = 255; //Red
               F.at<Vec3b>(i,j) = pixel;
              }
       }
    
    UIImageView * imageView = [self createImageViewInRect:CGRectMake(100, 100, 100, 100)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:A];
      
     imageView = [self createImageViewInRect:CGRectMake(100, 200, 100, 100)];
      [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:F];

      imageView = [self createImageViewInRect:CGRectMake(100, 300, 100, 100)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:G];
    
}

-(void)createMatMethod{
    cout << "=============== createMatMethod  begin ==============="<<endl;
    ///构造函数创建
    Mat M(4,4, CV_8UC3, Scalar(0,0,255));
    cout << "M = " << endl << " " << M << endl << endl;
    UIImageView * imageView = [self createImageViewInRect:CGRectMake(200, 100, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:M];
    
    ///create函数 这个创建方法不能为矩阵设初值，它只是在改变尺寸时重新为矩阵数据开辟内存。
    M.create(4,4, CV_8UC(3));
    cout << "M = "<< endl << " "  << M << endl << endl;
    imageView = [self createImageViewInRect:CGRectMake(200, 200, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:M];
    
    Mat E = Mat::eye(4, 4,  CV_8UC(3))*255;
       cout << "E = " << endl << " " << E << endl << endl;
       imageView = [self createImageViewInRect:CGRectMake(200, 300, 100, 100)];
       [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:E];
       Mat O = Mat::ones(4, 4, CV_8UC(3))*255;
       cout << "O = " << endl << " " << O << endl << endl;
    imageView = [self createImageViewInRect:CGRectMake(200, 400, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:O];
    Mat Z = Mat::zeros(3,3, CV_8UC(3))*255;
    cout << "Z = " << endl << " " << Z << endl << endl;
    imageView = [self createImageViewInRect:CGRectMake(200, 500, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:Z];
    cout << "=============== createMatMethod  end ==============="<<endl;
}

-(void)foramtPrint{
      cout << "=============== 格式打印 begin ==============="<<endl;
    Mat R = Mat(3, 3, CV_8UC3);
    randu(R, Scalar::all(0), Scalar::all(255));
    ///默认方式
     cout << "R (default) = " << endl <<        R           << endl << endl;
    ///Python
    cout << "R (python)  = " << endl << format(R,Formatter::FMT_PYTHON) << endl << endl;
//    以逗号分隔的数值 (CSV)
    cout << "R (CSV)  = " << endl << format(R,Formatter::FMT_CSV) << endl << endl;
    // Numpy
    cout << "R (Numpy)  = " << endl << format(R,Formatter::FMT_NUMPY) << endl << endl;
    //c
    cout << "R (c)  = " << endl << format(R,Formatter::FMT_C) << endl << endl;

    cout << "=============== 格式打印 end==============="<<endl;

}

#pragma mark  - private

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
//    mat 是brg 而 rgb
    Mat src;
    NSData *data=nil;
  CGColorSpaceRef colorSpace;
  if (cvMat.elemSize() == 1) {
      colorSpace = CGColorSpaceCreateDeviceGray();
      data= [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
  } else {
      cvtColor(cvMat, src, COLOR_BGR2RGB);
       data= [NSData dataWithBytes:src.data length:src.elemSize()*src.total()];
      colorSpace = CGColorSpaceCreateDeviceRGB();
  }
  CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
  // Creating CGImage from cv::Mat
  CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                     cvMat.rows,                                 //height
                                     8,                                          //bits per component
                                     8 * cvMat.elemSize(),                       //bits per pixel
                                     cvMat.step[0],                            //bytesPerRow
                                     colorSpace,                                 //colorspace
                                     kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                     provider,                                   //CGDataProviderRef
                                     NULL,                                       //decode
                                     false,                                      //should interpolate
                                     kCGRenderingIntentAbsoluteColorimetric                   //intent
                                     );
  // Getting UIImage from CGImage
  UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  CGDataProviderRelease(provider);
  CGColorSpaceRelease(colorSpace);
  return finalImage;
 }


@end
