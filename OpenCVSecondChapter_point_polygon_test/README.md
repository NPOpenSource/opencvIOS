# OpenCV 之ios 多边形测试

## 目的
本教程指导用户:

*   使用OpenCV函数 [pointPolygonTest](http://opencv.willowgarage.com/documentation/cpp/imgproc_structural_analysis_and_shape_descriptors.html#cv-pointpolygontest)

## 代码
```

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
#import "PointPolygonTestViewController.h"

@interface PointPolygonTestViewController ()

@end

@implementation PointPolygonTestViewController



- (void)viewDidLoad {
    [super viewDidLoad];
   /// 创建一个图形
     const int r = 100;
    Mat src = Mat::zeros( cv::Size( 4*r, 4*r ), CV_8UC1 );

     /// 绘制一系列点创建一个轮廓:
     vector<Point2f> vert(6);

     vert[0] = cv::Point( 1.5*r, 1.34*r );
     vert[1] = cv::Point( 1*r, 2*r );
     vert[2] = cv::Point( 1.5*r, 2.866*r );
     vert[3] = cv::Point( 2.5*r, 2.866*r );
     vert[4] = cv::Point( 3*r, 2*r );
     vert[5] = cv::Point( 2.5*r, 1.34*r );
    for( int j = 0; j < 6; j++ )
        { line( src, vert[j],  vert[(j+1)%6], Scalar( 255 ), 3, 8 ); }
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];
     /// 得到轮廓
    vector<vector<cv::Point> > contours; vector<Vec4i> hierarchy;
     Mat src_copy = src.clone();
     findContours( src_copy, contours, hierarchy, RETR_TREE, CHAIN_APPROX_SIMPLE);
    
    Mat raw_dist( src.size(), CV_32FC1 );

    for( int j = 0; j < src.rows; j++ )
       { for( int i = 0; i < src.cols; i++ )
            { raw_dist.at<float>(j,i) = pointPolygonTest( contours[0], Point2f(i,j), true ); }
       }

    double minVal; double maxVal;
    minMaxLoc( raw_dist, &minVal, &maxVal, 0, 0, Mat() );
    minVal = abs(minVal); maxVal = abs(maxVal);

    /// 图形化的显示距离
    Mat drawing = Mat::zeros( src.size(), CV_8UC3 );

    for( int j = 0; j < src.rows; j++ )
       { for( int i = 0; i < src.cols; i++ )
            {
              if( raw_dist.at<float>(j,i) < 0 )
                { drawing.at<Vec3b>(j,i)[0] = 255 - (int) abs(raw_dist.at<float>(j,i))*255/minVal; }
              else if( raw_dist.at<float>(j,i) > 0 )
                { drawing.at<Vec3b>(j,i)[2] = 255 - (int) raw_dist.at<float>(j,i)*255/maxVal; }
              else
                { drawing.at<Vec3b>(j,i)[0] = 255; drawing.at<Vec3b>(j,i)[1] = 255; drawing.at<Vec3b>(j,i)[2] = 255; }
            }
       }
    
    
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
       [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:drawing];

    
   
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

```
## 结果
![](https://upload-images.jianshu.io/upload_images/1682758-3119670931f0691b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

----


[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter_point_polygon_test)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/shapedescriptors/point_polygon_test/point_polygon_test.html)

