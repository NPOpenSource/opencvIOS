//
//  DrawViewController.m
//  OpenCVFirstChapter-baseDraw
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
#import "DrawViewController.h"

@interface DrawViewController ()

@end

@implementation DrawViewController
 static int w = 300;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    [self createDuGun];
}

void MyEllipse(cv::Mat img, double angle )
{
  int thickness = 2;
  int lineType = 8;
  ellipse( img,
          cv::Point(w/2.0, w/2.0 ),
           cv::Size( w/4.0, w/16.0 ),
           angle,
           0,
           360,
           Scalar( 255, 0, 0 ),
           thickness,
           lineType );
}

void MyFilledCircle( Mat img, cv::Point center )
{
 int thickness = -1;
 int lineType = 8;

 circle( img,
         center,
         w/32.0,
         Scalar( 0, 0, 255 ),
         thickness,
         lineType );
}

void MyPolygon( Mat img )
{
  int lineType = 8;

  /** 创建一些点 */
  cv::Point rook_points[1][20];
    rook_points[0][0] = cv::Point( w/4.0, 7*w/8.0 );
  rook_points[0][1] = cv::Point( 3*w/4.0, 7*w/8.0 );
  rook_points[0][2] = cv::Point( 3*w/4.0, 13*w/16.0 );
  rook_points[0][3] = cv::Point( 11*w/16.0, 13*w/16.0 );
  rook_points[0][4] = cv::Point( 19*w/32.0, 3*w/8.0 );
  rook_points[0][5] = cv::Point( 3*w/4.0, 3*w/8.0 );
  rook_points[0][6] = cv::Point( 3*w/4.0, w/8.0 );
  rook_points[0][7] = cv::Point( 26*w/40.0, w/8.0 );
  rook_points[0][8] = cv::Point( 26*w/40.0, w/4.0 );
  rook_points[0][9] = cv::Point( 22*w/40.0, w/4.0 );
  rook_points[0][10] = cv::Point( 22*w/40.0, w/8.0 );
  rook_points[0][11] = cv::Point( 18*w/40.0, w/8.0 );
  rook_points[0][12] = cv::Point( 18*w/40.0, w/4.0 );
  rook_points[0][13] = cv::Point( 14*w/40.0, w/4.0 );
  rook_points[0][14] = cv::Point( 14*w/40.0, w/8.0 );
  rook_points[0][15] = cv::Point( w/4.0, w/8.0 );
  rook_points[0][16] = cv::Point( w/4.0, 3*w/8.0 );
  rook_points[0][17] = cv::Point( 13*w/32.0, 3*w/8.0 );
  rook_points[0][18] = cv::Point( 5*w/16.0, 13*w/16.0 );
  rook_points[0][19] = cv::Point( w/4.0, 13*w/16.0) ;

  const cv::Point* ppt[1] = { rook_points[0] };
  int npt[] = { 20 };

  fillPoly( img,
            ppt,
            npt,
            1,
            Scalar( 255, 255, 255 ),
            lineType );
 }

void MyLine( Mat img, cv::Point start, cv::Point end )
{
  int thickness = 2;
  int lineType = 8;
  line( img,
        start,
        end,
        Scalar( 0, 0, 0 ),
        thickness,
        lineType );
}

-(void)createDuGun{
      Mat rook_image = Mat::zeros( w, w, CV_8UC3 );
        MyPolygon( rook_image );
    rectangle( rook_image,
              cv:: Point( 0, 7*w/8.0 ),
              cv::Point( w, w),
    Scalar( 0, 255, 255 ),
    -1,
    8 );
    MyLine( rook_image, cv::Point( 0, 15*w/16 ), cv::Point( w, 15*w/16 ) );
    MyLine( rook_image, cv::Point( w/4, 7*w/8 ), cv::Point( w/4, w ) );
    MyLine( rook_image, cv::Point( w/2, 7*w/8 ), cv::Point( w/2, w ) );
    MyLine( rook_image, cv::Point( 3*w/4, 7*w/8 ), cv::Point( 3*w/4, w ) );
    UIImageView *imageView;
       imageView = [self createImageViewInRect:CGRectMake(0, 200, 150, 150)];
       [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:rook_image];
}

-(void)createUI{
  
    Mat atom_image = Mat::zeros( w, w, CV_8UC3 );
    
    MyEllipse( atom_image, 90 );
    MyEllipse( atom_image, 0 );
    MyEllipse( atom_image, 45 );
    MyEllipse( atom_image, -45 );

    MyFilledCircle( atom_image, cv::Point( w/2.0, w/2.0) );

    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:atom_image];
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
