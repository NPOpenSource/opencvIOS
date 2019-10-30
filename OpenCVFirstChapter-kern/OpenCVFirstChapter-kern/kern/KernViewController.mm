//
//  KernViewController.m
//  OpenCVFirstChapter-kern
//
//  Created by glodon on 2019/10/30.
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
#import "KernViewController.h"

@interface KernViewController ()

@end

@implementation KernViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage * image =  [UIImage imageNamed:@"lena.jpg"];
    Mat sourceMat = [self cvMatFromUIImage:image];
    Mat rgbSourceMat;
    cvtColor(sourceMat, rgbSourceMat, COLOR_RGBA2BGR);
    UIImageView *imageView;
      imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:rgbSourceMat];
    
    Mat result = [self SharpenSourceMat:rgbSourceMat];
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
         [self.view addSubview:imageView];
         imageView.image  = [self UIImageFromCVMat:result];
    
    result = [self filter2DSourceMat:rgbSourceMat];
    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
         [self.view addSubview:imageView];
         imageView.image  = [self UIImageFromCVMat:result];
    // Do any additional setup after loading the view.
}


-(cv::Mat)SharpenSourceMat:(cv::Mat) myImage {
    CV_Assert(myImage.depth() == CV_8U);  // 仅接受uchar图像
    Mat Result;
    Result.create(myImage.size(),myImage.type());
    const int nChannels = myImage.channels();

    for(int j = 1 ; j < myImage.rows-1; ++j)
    {
        const uchar* previous = myImage.ptr<uchar>(j - 1);
        const uchar* current  = myImage.ptr<uchar>(j    );
        const uchar* next     = myImage.ptr<uchar>(j + 1);
        uchar* output = Result.ptr<uchar>(j);
        for(int i= nChannels;i < nChannels*(myImage.cols-1); ++i)
        {
            *output++ = saturate_cast<uchar>(5*current[i]
                         -current[i-nChannels] - current[i+nChannels] - previous[i] - next[i]);
        }
    }

    Result.row(0).setTo(Scalar(0));
    Result.row(Result.rows-1).setTo(Scalar(0));
    Result.col(0).setTo(Scalar(0));
    Result.col(Result.cols-1).setTo(Scalar(0));
    return Result;
}

-(cv::Mat)filter2DSourceMat:(cv::Mat) myImage {
    Mat kern = (Mat_<char>(3,3) <<  0, -1,  0,
    -1,  5, -1,
     0, -1,  0);
    Mat Result;
    filter2D(myImage, Result, myImage.depth(), kern );
    return Result;
}

#pragma mark  - private
///rgbX
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
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
  return cvMat;
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
