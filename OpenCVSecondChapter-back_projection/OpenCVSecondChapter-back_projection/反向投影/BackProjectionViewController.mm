//
//  BackProjectionViewController.m
//  OpenCVSecondChapter-back_projection
//
//  Created by glodon on 2019/11/15.
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
#import "BackProjectionViewController.h"

@interface BackProjectionViewController ()

@end

@implementation BackProjectionViewController
Mat src; Mat hsv; Mat hue;
int bins = 25;

- (void)viewDidLoad {
    [super viewDidLoad];
    Mat src_base, hsv_base;
    Mat src_test1, hsv_test1;
    Mat src_test2, hsv_test2;
    Mat hsv_half_down;
    
    UIImage * srcImage = [UIImage imageNamed:@"handle1.jpg"];
    src  = [self cvMatFromUIImage:srcImage];
  UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:src];
    cvtColor( src, hsv, CV_BGR2HSV );
    hue.create( hsv.size(), hsv.depth());
     int ch[] = { 0, 0 };
     mixChannels( &hsv, 1, &hue, 1, ch, 1 );

    [self createSliderFrame:CGRectMake(150, 100, 150, 50) maxValue:180 minValue:2 block:^(float value) {
        bins= value;
        [self Hist_and_Backproj];
    }];
    [self Hist_and_Backproj];
}

-(void)Hist_and_Backproj{
    MatND hist;
     int histSize = MAX( bins, 2 );
     float hue_range[] = { 0, 180 };
     const float* ranges = { hue_range };

     /// 计算直方图并归一化
     calcHist( &hue, 1, 0, Mat(), hist, 1, &histSize, &ranges, true, false );
     normalize( hist, hist, 0, 255, NORM_MINMAX, -1, Mat() );

     /// 计算反向投影
     MatND backproj;
     calcBackProject( &hue, 1, 0, hist, backproj, &ranges, 1, true );
    UIImageView *imageView;
              imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
              [self.view addSubview:imageView];
              imageView.image  = [self UIImageFromCVMat:backproj];
     /// 显示反向投影

     /// 显示直方图
     int w = 400; int h = 400;
     int bin_w = cvRound( (double) w / histSize );
     Mat histImg = Mat::zeros( w, h, CV_8UC3 );

     for( int i = 0; i < bins; i ++ )
        { rectangle( histImg, cv::Point( i*bin_w, h ), cv::Point( (i+1)*bin_w, h - cvRound( hist.at<float>(i)*h/255.0 ) ), Scalar( 0, 0, 255 ), -1 );
        }
    calcBackProject( &hue, 1, 0, hist, backproj, &ranges, 1, true );
    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
            [self.view addSubview:imageView];
             imageView.image  = [self UIImageFromCVMat:histImg];
}

#pragma mark  - private
//brg
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
    Mat src;
    cvtColor(cvMat, dst, COLOR_RGBA2BGRA);
    cvtColor(dst, src, COLOR_BGRA2BGR);

  return src;
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
