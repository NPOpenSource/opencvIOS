# OpenCV 之ios 轮廓矩
## 目标
在这节教程中您将学到:

*   使用OpenCV函数 [moments](http://opencv.willowgarage.com/documentation/cpp/imgproc_structural_analysis_and_shape_descriptors.html#cv-moments) 计算图像所有的矩(最高到3阶)
*   使用OpenCV函数 [contourArea](http://opencv.willowgarage.com/documentation/cpp/imgproc_structural_analysis_and_shape_descriptors.html#cv-contourarea) 来计算轮廓面积
*   使用OpenCV函数 [arcLength](http://opencv.willowgarage.com/documentation/cpp/imgproc_structural_analysis_and_shape_descriptors.html#cv-arclength) 来计算轮廓或曲线长度

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
#import "MomentsViewController.h"

@interface MomentsViewController ()

@end

@implementation MomentsViewController
/// 全局变量
Mat src; Mat src_gray;
int thresh = 100;
int max_thresh = 255;
RNG rng(12345);


- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIImage * srcImage = [UIImage imageNamed:@"pic.png"];
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
    Mat canny_output;
    vector<vector<cv::Point> > contours;
    vector<Vec4i> hierarchy;
   /// 对图像进行二值化
    threshold( src_gray, canny_output, thresh, 255, THRESH_BINARY );
   /// 找到轮廓
    findContours( canny_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    Mat drawing1 = Mat::zeros( canny_output.size(), CV_8UC3 );
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
  vector<Moments> mu(contours.size() );
     for( int i = 0; i < contours.size(); i++ )
        { mu[i] = moments( contours[i], false ); }

     ///  计算中心矩:
     vector<Point2f> mc( contours.size() );
     for( int i = 0; i < contours.size(); i++ )
        { mc[i] = Point2f( mu[i].m10/mu[i].m00 , mu[i].m01/mu[i].m00 ); }

     /// 绘制轮廓
     Mat drawing = Mat::zeros( canny_output.size(), CV_8UC3 );
     for( int i = 0; i< contours.size(); i++ )
        {
          Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
            drawContours( drawing, contours, i, color, 2, 8, hierarchy, 0,cv::Point() );
          circle( drawing, mc[i], 4, color, -1, 8, 0 );
        }

    imageView = [self createImageViewInRect:CGRectMake(150, 250, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:drawing];
    

    printf("\t Info: Area and Contour Length \n");
    for( int i = 0; i< contours.size(); i++ )
       {
         printf(" * Contour[%d] - Area (M_00) = %.2f - Area OpenCV: %.2f - Length: %.2f \n", i, mu[i].m00, contourArea(contours[i]), arcLength( contours[i], true ) );
         Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
           drawContours( drawing, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
         circle( drawing, mc[i], 4, color, -1, 8, 0 );
       }
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
打印结果如下
```
	 Info: Area and Contour Length 
 * Contour[0] - Area (M_00) = 57420.00 - Area OpenCV: 57420.00 - Length: 1082.00 
 * Contour[1] - Area (M_00) = 4255.50 - Area OpenCV: 4255.50 - Length: 429.12 
 * Contour[2] - Area (M_00) = 29.00 - Area OpenCV: 29.00 - Length: 27.31 
 * Contour[3] - Area (M_00) = 57.50 - Area OpenCV: 57.50 - Length: 28.73 
 * Contour[4] - Area (M_00) = 55.50 - Area OpenCV: 55.50 - Length: 27.90 
 * Contour[5] - Area (M_00) = 4078.00 - Area OpenCV: 4078.00 - Length: 432.48 
 * Contour[6] - Area (M_00) = 0.50 - Area OpenCV: 0.50 - Length: 3.41 
 * Contour[7] - Area (M_00) = 1.00 - Area OpenCV: 1.00 - Length: 6.83 
 * Contour[8] - Area (M_00) = 2.00 - Area OpenCV: 2.00 - Length: 6.00 
 * Contour[9] - Area (M_00) = 49.50 - Area OpenCV: 49.50 - Length: 26.73 
 * Contour[10] - Area (M_00) = 49.00 - Area OpenCV: 49.00 - Length: 26.14 
 * Contour[11] - Area (M_00) = 3878.00 - Area OpenCV: 3878.00 - Length: 364.19 
 * Contour[12] - Area (M_00) = 0.00 - Area OpenCV: 0.00 - Length: 0.00 
 * Contour[13] - Area (M_00) = 58.50 - Area OpenCV: 58.50 - Length: 28.73 
 * Contour[14] - Area (M_00) = 4409.50 - Area OpenCV: 4409.50 - Length: 493.55 
 * Contour[15] - Area (M_00) = 51.00 - Area OpenCV: 51.00 - Length: 82.97 
 * Contour[16] - Area (M_00) = 53.00 - Area OpenCV: 53.00 - Length: 28.14 
 * Contour[17] - Area (M_00) = 45.50 - Area OpenCV: 45.50 - Length: 26.73 
 * Contour[18] - Area (M_00) = 8091.50 - Area OpenCV: 8091.50 - Length: 494.86 
 * Contour[19] - Area (M_00) = 8.50 - Area OpenCV: 8.50 - Length: 14.24 
 * Contour[20] - Area (M_00) = 0.00 - Area OpenCV: 0.00 - Length: 4.00 
 * Contour[21] - Area (M_00) = 0.00 - Area OpenCV: 0.00 - Length: 4.00 
 * Contour[22] - Area (M_00) = 63.50 - Area OpenCV: 63.50 - Length: 32.73 
 * Contour[23] - Area (M_00) = 114.50 - Area OpenCV: 114.50 - Length: 40.38 
 * Contour[24] - Area (M_00) = 116.00 - Area OpenCV: 116.00 - Length: 40.97 
```

![](https://upload-images.jianshu.io/upload_images/1682758-92987b416d975369.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

----


[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-moments)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/shapedescriptors/moments/moments.html#moments)