# OpenCV 之ios 计算物体的凸包
## 目标
在这个教程中你将学习到如何:

*   使用OpenCV函数 [convexHull](http://opencv.willowgarage.com/documentation/cpp/imgproc_structural_analysis_and_shape_descriptors.html#cv-convexhull)

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
#import "ShapeDescriptorsViewController.h"

@interface ShapeDescriptorsViewController ()

@end

@implementation ShapeDescriptorsViewController
/// 全局变量
Mat src; Mat src_gray;
int thresh = 100;
int max_thresh = 255;
RNG rng(12345);


- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIImage * srcImage = [UIImage imageNamed:@"handle1.jpg"];
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
  Mat src_copy = src.clone();
   Mat threshold_output;
    vector<vector<cv::Point> > contours;
   vector<Vec4i> hierarchy;

   /// 对图像进行二值化
   threshold( src_gray, threshold_output, thresh, 255, THRESH_BINARY );
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
    
     /// 对每个轮廓计算其凸包
    vector<vector<cv::Point> >hull( contours.size() );
     for( int i = 0; i < contours.size(); i++ )
        {  convexHull( Mat(contours[i]), hull[i], false ); }

     /// 绘出轮廓及其凸包
     Mat drawing = Mat::zeros( threshold_output.size(), CV_8UC3 );
     for( int i = 0; i< contours.size(); i++ )
        {
          Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
            drawContours( drawing, contours, i, color, 1, 8, vector<Vec4i>(), 0, cv::Point() );
            drawContours( drawing, hull, i, color, 1, 8, vector<Vec4i>(), 0,cv::Point() );
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
![image.png](https://upload-images.jianshu.io/upload_images/1682758-5c26ca2f1c993da7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

----

[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-shapedescriptors)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/shapedescriptors/hull/hull.html)

