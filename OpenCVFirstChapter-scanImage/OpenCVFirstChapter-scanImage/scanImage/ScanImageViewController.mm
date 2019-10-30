//
//  ScanImageViewController.m
//  OpenCVFirstChapter-scanImage
//
//  Created by glodon on 2019/10/29.
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
#import "ScanImageViewController.h"

@interface ScanImageViewController ()

@end

@implementation ScanImageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setTable];
   UIImage * image =  [UIImage imageNamed:@"1.jpeg"];
    Mat sourceMat = [self cvMatFromUIImage:image];
    Mat rgbSourceMat;
    cvtColor(sourceMat, rgbSourceMat, COLOR_RGBA2BGR);
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:rgbSourceMat];
    
    Mat sourceCMat = rgbSourceMat.clone();
    [self _computerBlockTime:^{
        for (int i=0; i<100; i++) {
              [self  ScanImageAndReduceC:sourceCMat];
        }
    }];
    
    imageView = [self createImageViewInRect:CGRectMake(0, 200, 100, 100)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:sourceCMat];
  
      Mat sourceIteratorMat = rgbSourceMat.clone();
    [self _computerBlockTime:^{
          for (int i=0; i<100; i++) {
        [self  ScanImageAndReduceIterator:sourceIteratorMat];
          }
    }];
    
    imageView = [self createImageViewInRect:CGRectMake(0, 300, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:sourceIteratorMat];
    
    Mat sourceAccessMat = rgbSourceMat.clone();
    [self _computerBlockTime:^{
          for (int i=0; i<100; i++) {
              [self  ScanImageAndReduceRandomAccess:sourceAccessMat];
        }
    }];
    
    
    imageView = [self createImageViewInRect:CGRectMake(0, 400, 100, 100)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:sourceIteratorMat];
    
    lookUpTable =Mat(1,256, CV_8U);
      uchar* p = lookUpTable.data;
    for( int i = 0; i < 256; ++i)
                p[i] = table[i];
    Mat j = rgbSourceMat.clone();
    [self _computerBlockTime:^{
           for (int i=0; i<100; i++) {
               [self  ScanImageAndLUPMethod:rgbSourceMat src:j];
         }
     }];
   
     imageView = [self createImageViewInRect:CGRectMake(100, 400, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:j];
       
    // Do any additional setup after loading the view.
}

static Mat lookUpTable;


-(void)_computerBlockTime:(void(^)(void))exeBlock{
    double t = (double)getTickCount();
    exeBlock();
    t = ((double)getTickCount() - t)/getTickFrequency();
    cout << "Times passed in seconds: " << t << endl;
}

#pragma mark  - test
-(cv::Mat)ScanImageAndLUPMethod:(cv::Mat)I src:(cv::Mat)src{
    LUT(I, lookUpTable, src);
    return src;
}

-(cv::Mat)ScanImageAndReduceRandomAccess:(cv::Mat)I{
    CV_Assert(I.depth() != sizeof(uchar));
    const int channels = I.channels();
    switch(channels)
    {
    case 1:
        {
            for( int i = 0; i < I.rows; ++i)
                for( int j = 0; j < I.cols; ++j )
                    I.at<uchar>(i,j) = table[I.at<uchar>(i,j)];
            break;
        }
    case 3:
        {
         Mat_<Vec3b> _I = I;
            
         for( int i = 0; i < I.rows; ++i)
            for( int j = 0; j < I.cols; ++j )
               {
                   _I(i,j)[0] = table[_I(i,j)[0]];
                   _I(i,j)[1] = table[_I(i,j)[1]];
                   _I(i,j)[2] = table[_I(i,j)[2]];
            }
         I = _I;
         break;
        }
    }
    
    return I;
}

-(cv::Mat)ScanImageAndReduceIterator:(cv::Mat)I{
    CV_Assert(I.depth() != sizeof(uchar));
       const int channels = I.channels();
       switch(channels)
       {
       case 1:
           {
               MatIterator_<uchar> it, end;
               for( it = I.begin<uchar>(), end = I.end<uchar>(); it != end; ++it)
                   *it = table[*it];
               break;
           }
       case 3:
           {
               MatIterator_<Vec3b> it, end;
               for( it = I.begin<Vec3b>(), end = I.end<Vec3b>(); it != end; ++it)
               {
                   (*it)[0] = table[(*it)[0]];
                   (*it)[1] = table[(*it)[1]];
                   (*it)[2] = table[(*it)[2]];
               }
           }
       }
       
       return I;
}

-(cv::Mat)ScanImageAndReduceC:(cv::Mat)I {
    CV_Assert(I.depth() != sizeof(uchar));
    int channels = I.channels();
    int nRows = I.rows * channels;
    int nCols = I.cols;
    if (I.isContinuous())
    {
        nCols *= nRows;
        nRows = 1;
    }
    int i,j;
    uchar* p;
    for( i = 0; i < nRows; ++i)
    {
        p = I.ptr<uchar>(i);
        for ( j = 0; j < nCols; ++j)
        {
            p[j] = table[p[j]];
        }
    }
    return I;
}


#pragma mark  - private
static uchar table[256];
static int divideWith;
-(void)_setTable{
    if (divideWith<=0) {
        divideWith = 10;
    }
    for (int i = 0; i < 256; ++i)
         table[i] = divideWith* (i/divideWith);
}

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
