# OpenCV 之ios  创建包围轮廓的矩形和圆形边界框
## 目标
在这节教程中您将学到:

*   使用OpenCV函数 [boundingRect](http://opencv.willowgarage.com/documentation/cpp/imgproc_structural_analysis_and_shape_descriptors.html#cv-boundingrect) 来计算包围轮廓的矩形框.
*   使用OpenCV函数 [minEnclosingCircle](http://opencv.willowgarage.com/documentation/cpp/imgproc_structural_analysis_and_shape_descriptors.html#cv-minenclosingcircle) 来计算完全包围已有轮廓最小圆.
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
#import "BoundingRectsCirclesViewController.h"

@interface BoundingRectsCirclesViewController ()

@end

@implementation BoundingRectsCirclesViewController
/// 全局变量
Mat src; Mat src_gray;
int thresh = 100;
int max_thresh = 255;
RNG rng(12345);


- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIImage * srcImage = [UIImage imageNamed:@"qiqiu.png"];
    src  = [self cvMatFromUIImage:srcImage];
  UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:src];
    cvtColor( src, src_gray, CV_BGR2GRAY );
    blur( src_gray, src_gray, cv::Size(3,3) );

    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src_gray];
    
    [self createSliderFrame:CGRectMake(150, 400, 150, 50) maxValue:max_thresh currentValue:thresh  minValue:0 block:^(float value) {
           thresh= value;
           [self thresh_callback];
       }];
    [self thresh_callback];
}

-(void)thresh_callback{
    Mat threshold_output;
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
   /// 对图像进行二值化
    threshold( src_gray, threshold_output, thresh, 255, THRESH_BINARY );
   /// 找到轮廓
    findContours( threshold_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    Mat drawing1 = Mat::zeros( threshold_output.size(), CV_8UC3 );
      for( int i = 0; i< contours.size(); i++ )
        {
        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( drawing1, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
    }
    UIImageView *imageView;
          imageView = [self createImageViewInRect:CGRectMake(150, 100, 150, 150)];
          [self.view addSubview:imageView];
          imageView.image  = [self UIImageFromCVMat:drawing1];
    
    
    /// 多边形逼近轮廓 + 获取矩形和圆形边界框
    vector<vector<cv::Point> > contours_poly( contours.size() );
    vector<cv::Rect> boundRect( contours.size() );
     vector<Point2f>center( contours.size() );
     vector<float>radius( contours.size() );
    
    for( int i = 0; i < contours.size(); i++ )
    { approxPolyDP( Mat(contours[i]), contours_poly[i], 3, true );
      boundRect[i] = boundingRect( Mat(contours_poly[i]) );
      minEnclosingCircle( contours_poly[i], center[i], radius[i] );
    }
    
    Mat drawing = Mat::zeros( threshold_output.size(), CV_8UC3 );
    for( int i = 0; i< contours.size(); i++ )
       {
         Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
           drawContours( drawing, contours_poly, i, color, 1, 8, vector<Vec4i>(), 0, cv::Point() );
         rectangle( drawing, boundRect[i].tl(), boundRect[i].br(), color, 2, 8, 0 );
         circle( drawing, center[i], (int)radius[i], color, 2, 8, 0 );
       }
    

    imageView = [self createImageViewInRect:CGRectMake(150, 250, 150, 150)];
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

![](https://upload-images.jianshu.io/upload_images/1682758-bb538d5c63029b95.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

--------


[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-bounding_rects_circles)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/shapedescriptors/bounding_rects_circles/bounding_rects_circles.html)