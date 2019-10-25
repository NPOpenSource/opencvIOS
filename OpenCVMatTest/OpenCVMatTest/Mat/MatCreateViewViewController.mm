//
//  MatCreateViewViewController.m
//  OpenCVMatTest
//
//  Created by glodon on 2019/10/23.
//  Copyright © 2019 persion. All rights reserved.
//
#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc.hpp>
#import <opencv2/highgui.hpp>
#import <opencv2/core/core_c.h>
using namespace cv;
using namespace std;

#endif
#import "MatCreateViewViewController.h"

@interface MatCreateViewViewController ()

@end

@implementation MatCreateViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createRedImage];
    [self createRedImageOne];
    [self createMatlab];
    [self atFunction];
    [self IteratorFunction];
    [self pointFunction];
    [self rowOpateration];
    [self diag];
    [self matComputer];
}


-(void)mat_test{
#if 0
    Mat M(600, 800, CV_8UC1);
    for( int i = 0; i < M.rows; ++i) {
    uchar * p = M.ptr<uchar>(i);
    for( int j = 0; j < M.cols; ++j ) {
    double d1 = (double) ((i+j)%255);
              M.at<uchar>(i,j) = d1;
    double d2 = M.at<double>(i,j);//此行有错
    }
    }
#endif
    Mat M(600, 800, CV_8UC1);
    //在变量声明时指定矩阵元素类型
    Mat_<uchar> M1 = (Mat_<uchar>&)M;
    for( int i = 0; i < M1.rows; ++i) {
    //不需指定元素类型，语句简洁
    uchar * p = M1.ptr(i);
    for( int j = 0; j < M1.cols; ++j ) {
    double d1 = (double) ((i+j)%255);
    //直接使用 Matlab 风格的矩阵元素读写，简洁 M1(i,j) = d1;
    double d2 = M1(i,j);
    }
        
    }


}

-(void)matComputer{
    Mat A = Mat::eye(4,4,CV_32SC1);
    Mat B = A * 3 + 1;
    Mat C = B.diag(0) + B.col(1);
    cout << "A = " << A << endl << endl;
    cout << "B = " << B << endl << endl;
    cout << "C = " << C << endl << endl;
    cout << "C .* diag(B) = " << C.dot(B.diag(0)) << endl;

}

///对角线测试
-(void)diag{
     Mat grayim(5, 5, CV_8UC1);
    for( int i = 0; i < grayim.rows; ++i) {
    //获取第 i 行首像素指针
        uchar * p = grayim.ptr<uchar>(i);
    //对第 i 行的每个像素(byte)操作
        for( int j = 0; j < grayim.cols; ++j )
            p[j] = i*grayim.rows+j;
        }
    
    cout << "grayim = " << endl << " " << grayim << endl;
    Mat diag = grayim.diag();
    cout << "diag = " << endl << " " << diag << endl;
    Mat diag1 = grayim.diag(-1);
    cout << "diag1 = " << endl << " " << diag1 << endl;
     Mat diag2 = grayim.diag(1);
    cout << "diag2 = " << endl << " " << diag2 << endl;
}

-(void)rowOpateration{
     Mat grayim(2, 2, CV_8UC1);
    for( int i = 0; i < grayim.rows; ++i) {
     //获取第 i 行首像素指针
         uchar * p = grayim.ptr<uchar>(i);
     //对第 i 行的每个像素(byte)操作
         for( int j = 0; j < grayim.cols; ++j )
                      p[j] = 100;
         }
    
    UIImageView * imageView;
         imageView = [self createImageViewInRect:CGRectMake(100, 100, 100, 100)];
            [self.view addSubview:imageView];
            imageView.image  = [self UIImageFromCVMat:grayim];
         
        
     grayim.row(1) = grayim.row(0)*2;
    imageView = [self createImageViewInRect:CGRectMake(200, 100, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:grayim];
}

-(void)pointFunction{
    Mat grayim(600, 800, CV_8UC1);
    Mat colorim(600, 800, CV_8UC3);
    for( int i = 0; i < grayim.rows; ++i) {
    //获取第 i 行首像素指针
        uchar * p = grayim.ptr<uchar>(i);
    //对第 i 行的每个像素(byte)操作
        for( int j = 0; j < grayim.cols; ++j )
                     p[j] = (i+j)%255;
        }
    //遍历所有像素，并设置像素值
    for( int i = 0; i < colorim.rows; ++i) {
    //获取第 i 行首像素指针
        Vec3b * p = colorim.ptr<Vec3b>(i);
        for( int j = 0; j < colorim.cols; ++j ) {
            p[j][0] = i%255; //Blue
            p[j][1] = j%255; //Green
            p[j][2] = 0; //Red
        }
    }
    
    UIImageView * imageView;
      imageView = [self createImageViewInRect:CGRectMake(100, 100, 100, 100)];
         [self.view addSubview:imageView];
         imageView.image  = [self UIImageFromCVMat:grayim];
      
      imageView = [self createImageViewInRect:CGRectMake(200, 100, 100, 100)];
          [self.view addSubview:imageView];
          imageView.image  = [self UIImageFromCVMat:colorim];
}

-(void)IteratorFunction{
    Mat grayim(600, 800, CV_8UC1);
    Mat colorim(600, 800, CV_8UC3);
    MatIterator_<uchar> grayit, grayend;
    for( grayit = grayim.begin<uchar>(),grayend=grayim.end<uchar>(); grayit != grayend; ++grayit){
        *grayit = rand()%255;
    }
    //遍历所有像素，并设置像素值
    MatIterator_<Vec3b> colorit, colorend;
    for( colorit = colorim.begin<Vec3b>(),colorend=colorim.end<Vec3b>(); colorit != colorend; ++colorit) {
        (*colorit)[0] = rand()%255; //Blue
        (*colorit)[1] = rand()%255; //Green
        (*colorit)[2] = rand()%255; //Red
    }
    
        UIImageView * imageView;
       imageView = [self createImageViewInRect:CGRectMake(100, 300, 100, 100)];
          [self.view addSubview:imageView];
          imageView.image  = [self UIImageFromCVMat:grayim];
       
       imageView = [self createImageViewInRect:CGRectMake(100, 400, 100, 100)];
           [self.view addSubview:imageView];
           imageView.image  = [self UIImageFromCVMat:colorim];
}

-(void)atFunction{
    Mat grayim(600, 800, CV_8UC1);
    Mat colorim(600, 800, CV_8UC3);
    for( int i = 0; i < grayim.rows; ++i){
        for( int j = 0; j < grayim.cols; ++j ){
             grayim.at<uchar>(i,j) = (i+j)%255;
        }
    }
   
    //遍历所有像素，并设置像素值
    for( int i = 0; i < colorim.rows; ++i){
        for( int j = 0; j < colorim.cols; ++j ) {
           Vec3b pixel;
           pixel[0] = i%255; //Blue
            pixel[1] = j%255; //Green
            pixel[2] = 0; //Red
            colorim.at<Vec3b>(i,j) = pixel;
           }
    }
    UIImageView * imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 300, 100, 100)];
       [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:grayim];
    
    imageView = [self createImageViewInRect:CGRectMake(0, 400, 100, 100)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:colorim];
    
}

-(void)createMatlab{
    Mat Z = Mat::zeros(2,3, CV_8UC1);
    cout << "Z = " << endl << " " << Z << endl;
    Mat O = Mat::ones(2, 3, CV_8UC4);
    cout << "O = " << endl << " " << O << endl;
    Mat E = Mat::eye(3, 3, CV_64F);
    cout << "E = " << endl << " " << E << endl;
}

-(void)createRedImageOne{
    Mat M(2,2, CV_8UC3,Scalar(0,0,255));//创建红色
      cout << "M = " << endl << " " << M << endl;
    M.create(3,2, CV_8UC4);//create 方式创建
     cout << "M = " << endl << " " << M << endl;
}

-(void)createRedImage{
    Mat M(3,2, CV_8UC3, Scalar(0,0,255));
    cout << "M = " << endl << " " << M << endl;
    UIImageView * imageView = [self createImageViewInRect:CGRectMake(0, 0100, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:M];
}

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
