# OpenCV 之ios 霍夫圆变换
## 目标
在这个教程中你将学习如何:

*   使用OpenCV函数 [HoughCircles](http://opencv.willowgarage.com/documentation/cpp/imgproc_feature_detection.html?#cv-houghcircles) 在图像中检测圆.
## 原理
### 霍夫圆变换
*   霍夫圆变换的基本原理和上个教程中提到的霍夫线变换类似, 只是点对应的二维极径极角空间被三维的圆心点x, y还有半径r空间取代.

*   对直线来说, 一条直线能由参数极径极角 (r,θ)表示. 而对圆来说, 我们需要三个参数来表示一个圆, 如上文所说现在原图像的边缘图像的任意点对应的经过这个点的所有可能圆是在三维空间有下面这三个参数来表示了，其对应一条三维空间的曲线. 那么与二维的霍夫线变换同样的道理, 对于多个边缘点越多这些点对应的三维空间曲线交于一点那么他们经过的共同圆上的点就越多，类似的我们也就可以用同样的阈值的方法来判断一个圆是否被检测到, 这就是标准霍夫圆变换的原理, 但也正是在三维空间的计算量大大增加的原因, 标准霍夫圆变化很难被应用到实际中:
![](https://upload-images.jianshu.io/upload_images/1682758-4fe4704ad6f70bab.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这里的(x<sub>center</sub>,y<sub>center</sub>)表示圆心的位置 (下图中的绿点) 而r 表示半径, 这样我们就能唯一的定义一个圆了, 见下图:
![](https://upload-images.jianshu.io/upload_images/1682758-d6847c3d972ce30e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

+ 出于上面提到的对运算效率的考虑, OpenCV实现的是一个比标准霍夫圆变换更为灵活的检测方法: 霍夫梯度法, 也叫2-1霍夫变换(21HT), 它的原理依据是圆心一定是在圆上的每个点的模向量上, 这些圆上点模向量的交点就是圆心, 霍夫梯度法的第一步就是找到这些圆心, 这样三维的累加平面就又转化为二维累加平面. 第二部根据所有候选中心的边缘非0像素对其的支持程度来确定半径. 21HT方法最早在Illingworth的论文The Adaptive Hough Transform中提出并详细描述, 也可参照Yuen在1990年发表的A Comparative Study of Hough Transform Methods for Circle Finding, Bradski的《学习OpenCV》一书则对OpenCV中具体对算法的具体实现有详细描述并讨论了霍夫梯度法的局限性.

## 例程
这个例程是用来干嘛的?
+ 加载一幅图像并对其模糊化以降噪
+ 对模糊化后的图像执行霍夫圆变换 .
+ 在窗体中显示检测到的圆.

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
#import "HoughCirclesViewController.h"

@interface HoughCirclesViewController ()

@end

@implementation HoughCirclesViewController

const int cannyThresholdInitialValue = 100;
const int accumulatorThresholdInitialValue = 50;
const int maxAccumulatorThreshold = 200;
const int maxCannyThreshold = 255;
int cannyThreshold = cannyThresholdInitialValue;
int accumulatorThreshold = accumulatorThresholdInitialValue;

 Mat src, src_gray;
- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage * src1Image = [UIImage imageNamed:@"stuff.jpg"];
     src  = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];
   cvtColor( src, src_gray, COLOR_BGR2GRAY );
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src_gray];
    GaussianBlur( src_gray, src_gray, cv::Size(9, 9), 2, 2 );

    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src_gray];
    
    [self createSliderFrame:CGRectMake(150, 100, 100, 50) maxValue:maxCannyThreshold minValue:0 block:^(float value) {
            cannyThreshold = std::max(cannyThreshold, 1);
            [self HoughDetection];
    }];
    
    [self createSliderFrame:CGRectMake(150, 150, 100, 50) maxValue:maxAccumulatorThreshold minValue:0 block:^(float value) {
          accumulatorThreshold = std::max(accumulatorThreshold, 1);
        [self HoughDetection];
       }];
  [self HoughDetection];
}

 -(void)HoughDetection
{
    std::vector<Vec3f> circles;
           // runs the actual detection
    HoughCircles( src_gray, circles, HOUGH_GRADIENT, 1, src_gray.rows/8, cannyThreshold, accumulatorThreshold, 0, 0 );

           // clone the colour, input image for displaying purposes
    Mat display = src.clone();
    for( size_t i = 0; i < circles.size(); i++ )
    {
        cv::Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
        int radius = cvRound(circles[i][2]);
               // circle center
        circle( display, center, 3, Scalar(0,255,0), -1, 8, 0 );
               // circle outline
        circle( display, center, radius, Scalar(0,0,255), 3, 8, 0 );
    }
    
    UIImageView *imageView;
      imageView = [self createImageViewInRect:CGRectMake(150, 250, 150, 150)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:display];

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

## 解释
+ 执行霍夫圆变换:
```
 -(void)HoughDetection
{
    std::vector<Vec3f> circles;
           // runs the actual detection
    HoughCircles( src_gray, circles, HOUGH_GRADIENT, 1, src_gray.rows/8, cannyThreshold, accumulatorThreshold, 0, 0 );

           // clone the colour, input image for displaying purposes
    Mat display = src.clone();
    for( size_t i = 0; i < circles.size(); i++ )
    {
        cv::Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
        int radius = cvRound(circles[i][2]);
               // circle center
        circle( display, center, 3, Scalar(0,255,0), -1, 8, 0 );
               // circle outline
        circle( display, center, radius, Scalar(0,0,255), 3, 8, 0 );
    }
    
    UIImageView *imageView;
      imageView = [self createImageViewInRect:CGRectMake(150, 250, 150, 150)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:display];

}
```
函数带有以下自变量:

*   *src_gray*: 输入图像 (灰度图)
*   *circles*: 存储下面三个参数:x<sub>c</sub>,:y<sub>c</sub>,r

     集合的容器来表示每个检测到的圆.
*   *CV_HOUGH_GRADIENT*: 指定检测方法. 现在OpenCV中只有霍夫梯度法
*   *dp = 1*: 累加器图像的反比分辨率
*   *min_dist = src_gray.rows/8*: 检测到圆心之间的最小距离
*   *param_1 = 200*: Canny边缘函数的高阈值
*   *param_2 = 100*: 圆心检测阈值.
*   *min_radius = 0*: 能检测到的最小圆半径, 默认为0.
*   *max_radius = 0*: 能检测到的最大圆半径, 默认为0


## 结果
![](https://upload-images.jianshu.io/upload_images/1682758-12f65bf3fbdfb848.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


使用图片
![smarties.png](https://upload-images.jianshu.io/upload_images/1682758-d0eeda58dcafe9e7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1682758-a9d33987c3b07d74.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## cpp 代码地址
[cpp](https://github.com/opencv/opencv/blob/master/samples/cpp/tutorial_code/ImgTrans/HoughCircle_Demo.cpp)
----

[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-houghCircles)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/imgtrans/hough_circle/hough_circle.html#hough-circle)

