//
//  DisccreteTransfromViewController.m
//  OpenCVFirstChapter-discrete_fourier_transform
//
//  Created by glodon on 2019/11/7.
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
#import "DisccreteTransfromViewController.h"

@interface DisccreteTransfromViewController ()

@end

@implementation DisccreteTransfromViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    UIImage * src1Image = [UIImage imageNamed:@"lena.jpg"];
    UIImage * src1Image = [UIImage imageNamed:@"imageTextR.png"];

    
     Mat source = [self cvMatFromUIImage:src1Image];
    Mat I;
    cvtColor(source, I, COLOR_BGRA2GRAY);;
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
      [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:I];
    
    Mat padded;                            //expand input image to optimal size
       int m = getOptimalDFTSize( I.rows );
       int n = getOptimalDFTSize( I.cols );
    copyMakeBorder(I, padded, 0, m - I.rows, 0, n - I.cols, BORDER_CONSTANT, Scalar::all(0));
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
         [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:padded];
    
    //! [complex_and_real]
        Mat planes[] = {Mat_<float>(padded), Mat::zeros(padded.size(), CV_32F)};
        Mat complexI;
        merge(planes, 2, complexI);         // Add to the expanded another plane with zeros
    //! [complex_and_real]

    //! [dft]
        dft(complexI, complexI);            // this way the result may fit in the source matrix
    //! [dft]

        // compute the magnitude and switch to logarithmic scale
        // => log(1 + sqrt(Re(DFT(I))^2 + Im(DFT(I))^2))
    //! [magnitude]
        split(complexI, planes);                   // planes[0] = Re(DFT(I), planes[1] = Im(DFT(I))
        magnitude(planes[0], planes[1], planes[0]);// planes[0] = magnitude
        Mat magI = planes[0];
    //! [magnitude]
    
    //! [log]
        magI += Scalar::all(1);                    // switch to logarithmic scale
        log(magI, magI);
    //! [log]
    
    //! [crop_rearrange]
    // crop the spectrum, if it has an odd number of rows or columns
    magI = magI(cv::Rect(0, 0, magI.cols & -2, magI.rows & -2));

    // rearrange the quadrants of Fourier image  so that the origin is at the image center
       int cx = magI.cols/2;
       int cy = magI.rows/2;

    Mat q0(magI, cv::Rect(0, 0, cx, cy));   // Top-Left - Create a ROI per quadrant
    Mat q1(magI, cv::Rect(cx, 0, cx, cy));  // Top-Right
    Mat q2(magI, cv::Rect(0, cy, cx, cy));  // Bottom-Left
    Mat q3(magI, cv::Rect(cx, cy, cx, cy)); // Bottom-Right

       Mat tmp;                           // swap quadrants (Top-Left with Bottom-Right)
       q0.copyTo(tmp);
       q3.copyTo(q0);
       tmp.copyTo(q3);

       q1.copyTo(tmp);                    // swap quadrant (Top-Right with Bottom-Left)
       q2.copyTo(q1);
       tmp.copyTo(q2);
    
    //! [crop_rearrange]
    //! [normalize]
    normalize(magI, magI, 0, 1, NORM_MINMAX); // Transform the matrix with float values into a
                                                // viewable image form (float between values 0 and 1).

    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
            [self.view addSubview:imageView];
          imageView.image  = [self UIImageFromCVMat:magI];
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
