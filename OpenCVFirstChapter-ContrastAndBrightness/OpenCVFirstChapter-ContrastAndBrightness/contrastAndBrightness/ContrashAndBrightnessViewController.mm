//
//  ContrashAndBrightnessViewController.m
//  OpenCVFirstChapter-ContrastAndBrightness
//
//  Created by glodon on 2019/11/1.
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
#import "ContrashAndBrightnessViewController.h"

@interface ContrashAndBrightnessViewController ()
@property (nonatomic ,assign) Mat  src1 ;
@end

@implementation ContrashAndBrightnessViewController
double alpha; /**< 控制对比度 */
int beta;  /**< 控制亮度 */
- (void)viewDidLoad {
  
    [super viewDidLoad];


    UIImage * image = [UIImage imageNamed:@"lena.jpg"];
    Mat src =  [self cvMatFromUIImage:image];
    cvtColor(src, _src1, COLOR_BGRA2BGR);
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:self.src1];
    
    [self createSliderFrame:CGRectMake(0, 450, 100, 40) maxValue:3 minValue:0 block:^(float value) {
         NSLog(@"[alpha]: %f",value);
        alpha = value;
        [self createContrashAndBrightness];
        [self createContrashAndBrightness1];
    }];
    [self createSliderFrame:CGRectMake(0, 550, 100, 40) maxValue:100 minValue:0 block:^(float value) {
           beta = value;
            NSLog(@"[beta]: %f",value);
            [self createContrashAndBrightness];
            [self createContrashAndBrightness1];
       }];
}

-(void)createContrashAndBrightness1{
    Mat new_image = Mat::zeros( self.src1.size(), self.src1.type() );
    self.src1.convertTo(new_image, -1, alpha, beta);
    UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(150, 250, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:new_image];
}


-(void)createContrashAndBrightness{
    Mat new_image = Mat::zeros( self.src1.size(), self.src1.type() );
     for( int y = 0; y < self.src1.rows; y++ )
     {
         for( int x = 0; x < self.src1.cols; x++ )
         {
             for( int c = 0; c < 3; c++ )
             {
                 new_image.at<Vec3b>(y,x)[c] = saturate_cast<uchar>( alpha*( self.src1.at<Vec3b>(y,x)[c] ) + beta );
             }
         }
     }
    UIImageView *imageView;
     imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
     [self.view addSubview:imageView];
     imageView.image  = [self UIImageFromCVMat:new_image];
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
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
        data= [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    } else if(cvMat.elemSize() == 3){
        cvtColor(cvMat, src, COLOR_BGR2RGB);
        data= [NSData dataWithBytes:src.data length:src.elemSize()*src.total()];
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }else{
        colorSpace = CGColorSpaceCreateDeviceRGB();
        cvtColor(cvMat, src, COLOR_BGRA2RGBA);
        data= [NSData dataWithBytes:src.data length:src.elemSize()*src.total()];
        info =kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
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
