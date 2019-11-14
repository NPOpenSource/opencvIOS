//
//  HoughLinesViewController.m
//  OpenCVSecondChapter-hough_lines
//
//  Created by glodon on 2019/11/14.
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
#import "HoughLinesViewController.h"

@interface HoughLinesViewController ()

@end

@implementation HoughLinesViewController

Mat src, edges;
Mat src_gray;
Mat standard_hough, probabilistic_hough;
int min_threshold = 50;
int max_trackbar = 150;
int s_trackbar = max_trackbar;
int p_trackbar = max_trackbar;
- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage * src1Image = [UIImage imageNamed:@"building.jpg"];
     src  = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];
    cvtColor( src, src_gray, COLOR_RGB2GRAY );
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src_gray];
    Canny( src_gray, edges, 50, 200, 3 );

    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:edges];
    
    [self createSliderFrame:CGRectMake(150, 100, 100, 50) maxValue:max_trackbar minValue:0 block:^(float value) {
        s_trackbar = value;
       [self Standard_Hough];
    }];
    [self Standard_Hough];
    
    [self createSliderFrame:CGRectMake(150, 150, 100, 50) maxValue:max_trackbar minValue:0 block:^(float value) {
           p_trackbar = value;
          [self Probabilistic_Hough];
       }];
    [self Probabilistic_Hough];

}

-(void)Standard_Hough{
     vector<Vec2f> s_lines;
    cvtColor( edges, standard_hough, COLOR_GRAY2BGR );
          /// 1. Use Standard Hough Transform
        HoughLines( edges, s_lines, 1, CV_PI/180, min_threshold + s_trackbar, 0, 0 );
    for( size_t i = 0; i < s_lines.size(); i++ )
    {
     float r = s_lines[i][0], t = s_lines[i][1];
     double cos_t = cos(t), sin_t = sin(t);
     double x0 = r*cos_t, y0 = r*sin_t;
     double alpha = 1000;

     cv::Point pt1( cvRound(x0 + alpha*(-sin_t)), cvRound(y0 + alpha*cos_t) );
      cv::Point pt2( cvRound(x0 - alpha*(-sin_t)), cvRound(y0 - alpha*cos_t) );
      line( standard_hough, pt1, pt2, Scalar(255,0,0), 3, LINE_AA);
    }
    
     UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(150, 250, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:standard_hough];
}

-(void)Probabilistic_Hough{
    vector<Vec4i> p_lines;
     cvtColor( edges, probabilistic_hough, COLOR_GRAY2BGR );

     /// 2. Use Probabilistic Hough Transform
     HoughLinesP( edges, p_lines, 1, CV_PI/180, min_threshold + p_trackbar, 30, 10 );

     /// Show the result
     for( size_t i = 0; i < p_lines.size(); i++ )
        {
          Vec4i l = p_lines[i];
          line( probabilistic_hough, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), Scalar(255,0,0), 3, LINE_AA);
        }
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(150, 400, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:probabilistic_hough];
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
