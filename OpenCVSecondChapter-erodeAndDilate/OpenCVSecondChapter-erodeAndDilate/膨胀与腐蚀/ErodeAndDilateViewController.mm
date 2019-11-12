//
//  ErodeAndDilateViewController.m
//  OpenCVSecondChapter-erodeAndDilate
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
#import "ErodeAndDilateViewController.h"

@implementation ErodeAndDilateViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    UIImage * src1Image = [UIImage imageNamed:@"cat.jpg"];
      Mat src1 = [self cvMatFromUIImage:src1Image];
      UIImageView *imageView;
      imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:src1];
    
   __block int erosion_elem = 0;

   __block int dilation_elem = 0;
    int const max_kernel_size = 21;

    ///膨胀
    [self createSliderFrame:CGRectMake(150, 100, 100, 50) maxValue:max_kernel_size minValue:0 block:^(float value) {
        int erosion_type ;
        if( erosion_elem == 0 ){ erosion_type = MORPH_RECT; }
         else if( erosion_elem == 1 ){ erosion_type = MORPH_CROSS; }
         else  { erosion_type = MORPH_ELLIPSE; }

        int erosion_size = value;
        Mat erosion_dst;
        Mat element = getStructuringElement( erosion_type,
                                              cv::Size( 2*erosion_size + 1, 2*erosion_size+1 ),
                                              cv::Point( erosion_size, erosion_size ) );
          cout<<erosion_size<<endl;
        cout<<element<<endl;
        erode( src1, erosion_dst, element );
        
        UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:erosion_dst];
        
    }];
   
    [self createButtonFrame:CGRectMake(250, 100, 100, 50) title:@"Rect" Block:^NSString * _Nonnull(int hitCount) {
        erosion_elem = hitCount%3;
        if (erosion_elem==0) {
            return @"Rect";
        }else if (erosion_elem==1){
            return @"CROSS";
        }else{
            return @"ELLIPSE";
        }
    }];
    
    
    [self createSliderFrame:CGRectMake(150, 150, 100, 50) maxValue:max_kernel_size minValue:0 block:^(float value) {
        int dilation_type;
        if( dilation_elem == 0 ){ dilation_type = MORPH_RECT; }
         else if( dilation_elem == 1 ){ dilation_type = MORPH_CROSS; }
         else{ dilation_type = MORPH_ELLIPSE; }
          int dilation_size = value;
        Mat dilation_dst;
        Mat element = getStructuringElement( dilation_type,
                                             cv::Size( 2*dilation_size + 1, 2*dilation_size+1 ),
                                             cv::Point( dilation_size, dilation_size ) );
       
        dilate( src1, dilation_dst, element );
        
        UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:dilation_dst];

      }];
    [self createButtonFrame:CGRectMake(250, 150, 100, 50) title:@"Rect" Block:^NSString * _Nonnull(int hitCount) {
        dilation_elem  = hitCount%3;
             if (dilation_elem==0) {
                 return @"Rect";
             }else if (dilation_elem==1){
                 return @"CROSS;";
             }else{
                 return @"ELLIPSE";
             }
        }];
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
