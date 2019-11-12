//
//  DealImageViewController.m
//  OpenCVSecondChapter-imageDeal
//
//  Created by glodon on 2019/11/12.
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
#import "DealImageViewController.h"

@interface DealImageViewController ()

@end

@implementation DealImageViewController
int DELAY_CAPTION = 1500;
int DELAY_BLUR = 100;
int MAX_KERNEL_LENGTH = 31;
- (void)viewDidLoad {
    [super viewDidLoad];
     UIImage * src1Image = [UIImage imageNamed:@"lena.jpg"];
    Mat src1 = [self cvMatFromUIImage:src1Image];
    Mat src;
    cvtColor(src1, src, COLOR_BGRA2BGR);
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];
    ///均值平滑
    Mat dst;
    {
        for ( int i = 1; i < MAX_KERNEL_LENGTH; i = i + 2 ){
            blur( src, dst, cv::Size( i, i ), cv::Point(-1,-1));
        }
        imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:dst];
    }
    /// 高斯平滑
    {
        for ( int i = 1; i < MAX_KERNEL_LENGTH; i = i + 2 ){
            GaussianBlur( src, dst, cv::Size( i, i ), 0, 0 );
        }
        imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:dst];
    }

    ///中值平滑
    {
        for ( int i = 1; i < MAX_KERNEL_LENGTH; i = i + 2 ) {
            medianBlur ( src, dst, i );
        }
        imageView = [self createImageViewInRect:CGRectMake(150, 250, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:dst];
    }

    ///双边平滑
    {
        for ( int i = 1; i < MAX_KERNEL_LENGTH; i = i + 2 ){
                bilateralFilter ( src, dst, i, i*2, i/2 );
        }
        imageView = [self createImageViewInRect:CGRectMake(150, 400, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:dst];
    }
}

#pragma mark  - private
//brgx
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
  CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
    
  CGFloat cols = image.size.width;
  CGFloat rows = image.size.height;
    Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
  CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                 cols,                       // Width of bitmap
                                                 rows,                       // Height of bitmap
                                                 8,                          // Bits per component
                                                 cvMat.step[0],              // Bytes per row
                                                 colorSpace,                 // Colorspace
                                                 kCGImageAlphaNoneSkipLast |
                                                 kCGBitmapByteOrderDefault); // Bitmap info flags
  CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
  CGContextRelease(contextRef);
    
    Mat dst;
    cvtColor(cvMat, dst, COLOR_RGBA2BGRA);

  return dst;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
//    mat 是brg 而 rgb
    Mat src;
    NSData *data=nil;
    CGBitmapInfo info =kCGImageAlphaNone|kCGBitmapByteOrderDefault;
    CGColorSpaceRef colorSpace;
    if (cvMat.depth()!=CV_8U) {
        Mat result;
        cvMat.convertTo(result, CV_8U,255.0);
        cvMat = result;
    }
  if (cvMat.elemSize() == 1) {
      colorSpace = CGColorSpaceCreateDeviceGray();
      data= [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
  } else if(cvMat.elemSize() == 3){
      cvtColor(cvMat, src, COLOR_BGR2RGB);
       data= [NSData dataWithBytes:src.data length:src.elemSize()*src.total()];
      colorSpace = CGColorSpaceCreateDeviceRGB();
  }else if(cvMat.elemSize() == 4){
      colorSpace = CGColorSpaceCreateDeviceRGB();
      cvtColor(cvMat, src, COLOR_BGRA2RGBA);
      data= [NSData dataWithBytes:src.data length:src.elemSize()*src.total()];
      info =kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
  }else{
      NSLog(@"[error:] 错误的颜色通道");
      return nil;
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
