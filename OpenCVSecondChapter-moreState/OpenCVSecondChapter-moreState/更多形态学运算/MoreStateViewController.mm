//
//  MoreStateViewController.m
//  OpenCVSecondChapter-moreState
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
#import "MoreStateViewController.h"

@interface MoreStateViewController ()

@end

@implementation MoreStateViewController
int morph_operator = 0;
int morph_elem = 0;
int morph_size=0;
Mat src1;
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage * src1Image = [UIImage imageNamed:@"baboon.jpg"];
        src1 = [self cvMatFromUIImage:src1Image];
         UIImageView *imageView;
         imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
         [self.view addSubview:imageView];
         imageView.image  = [self UIImageFromCVMat:src1];
     int const max_kernel_size = 21;
    
     [self createSliderFrame:CGRectMake(150, 100, 100, 50) maxValue:max_kernel_size minValue:0 block:^(float value) {
         morph_size = (int)value;
         [self Morphology_Operations];
     }];
 
    [self createButtonFrame:CGRectMake(250, 100, 100, 50) title:@"Opening" Block:^NSString * _Nonnull(int hitCount) {
         morph_operator = hitCount%5;
        [self Morphology_Operations];
         if (morph_operator==0) {
             return @"Opening";
         }else if (morph_operator==1){
             return @"Closeing";
         }else if (morph_operator==2){
             return @"Gradient";
         }else if (morph_operator==3){
             return @"Top Hat";
         }else{
             return @"Black Hat";
         }
     }];

    [self createButtonFrame:CGRectMake(250, 150, 100, 50) title:@"Rect" Block:^NSString * _Nonnull(int hitCount) {
         morph_elem = hitCount%3;
        [self Morphology_Operations];
         if (morph_elem==0) {
             return @"Rect";
         }else if (morph_elem==1){
             return @"CROSS";
         }else{
             return @"ELLIPSE";
         }
     }];
    
}

-(void)Morphology_Operations{
    Mat dst;
    int operation = morph_operator + 2;
    Mat element = getStructuringElement( morph_elem, cv::Size( 2*morph_size + 1, 2*morph_size+1 ), cv::Point( morph_size, morph_size ) );
    morphologyEx( src1, dst, operation, element );
      UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:dst];
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
