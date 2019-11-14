# OpenCV 之ios 霍夫线变换
## 目标
在这个部分您将学习到:

*   使用OpenCV的以下函数 [HoughLines](http://opencv.willowgarage.com/documentation/cpp/imgproc_feature_detection.html?#cv-houghlines) 和 [HoughLinesP](http://opencv.willowgarage.com/documentation/cpp/imgproc_feature_detection.html?#cv-houghlinesp) 来检测图像中的直线.
## 原理
### 霍夫线变换
+ 霍夫线变换是一种用来寻找直线的方法.
+ 是用霍夫线变换之前, 首先要对图像进行边缘检测的处理，也即霍夫线变换的直接输入只能是边缘二值图像.

##### 它是如何实现的?
1. 众所周知, 一条直线在图像二维空间可由两个变量表示. 例如:
a.  在 **笛卡尔坐标系:** 可由参数: (m,b)斜率和截距表示.
b.  在 **极坐标系:** 可由参数: (r,θ) 极径和极角表示

![](https://upload-images.jianshu.io/upload_images/1682758-d7b2d4c1eb0e79cf.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

对于霍夫变换, 我们将用 极坐标系 来表示直线. 因此, 直线的表达式可为:
![](https://upload-images.jianshu.io/upload_images/1682758-b03098a83e018278.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

化简得: 
![](https://upload-images.jianshu.io/upload_images/1682758-6c61e7ff8d7aea4a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


2. 一般来说对于点 (x<sub>0</sub>,y<sub>0</sub>), 我们可以将通过这个点的一族直线统一定义为:

![](https://upload-images.jianshu.io/upload_images/1682758-36402b0aca1825a2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这就意味着每一对(r<sub>θ</sub>) 代表一条通过点(x<sub>0</sub>,y<sub>0</sub>), 的直线.


3. 如果对于一个给定点 (x<sub>0</sub>,y<sub>0</sub>) 我们在极坐标对极径极角平面绘出所有通过它的直线, 将得到一条正弦曲线. 例如, 对于给定点x<sub>0</sub>=8andy<sub>0</sub>=6
 我们可以绘出下图  (在平面 θ-r):
![](https://upload-images.jianshu.io/upload_images/1682758-d9324836e6d4150a.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

只绘出满足下列条件的点r > 0 and 0< θ < 2π

4.我们可以对图像中所有的点进行上述操作. 如果两个不同点进行上述操作后得到的曲线在平面  θ-r相交, 这就意味着它们通过同一条直线. 例如, 接上面的例子我们继续对点: x<sub>1</sub>=9,y<sub>1</sub>=4 和点x<sub>2</sub>=12,y<sub>2</sub>=3 绘图, 得到下图:

![](https://upload-images.jianshu.io/upload_images/1682758-416243bc19bfcc7e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

.这三条曲线在 θ-r 平面相交于点 (0.925, 9.6), 坐标表示的是参数对(θ,r)
) 或者是说点(x<sub>0</sub>,y<sub>0</sub>),点(x<sub>1</sub>,y<sub>1</sub>)和点 点(x<sub>2</sub>,y<sub>2</sub>) 组成的平面内的的直线.

5.   那么以上的材料要说明什么呢? 这意味着一般来说, 一条直线能够通过在平面 θ-r 寻找交于一点的曲线数量来 *检测*. 越多曲线交于一点也就意味着这个交点表示的直线由更多的点组成. 一般来说我们可以通过设置直线上点的 *阈值* 来定义多少条曲线交于一点我们才认为 *检测* 到了一条直线.

6.  这就是霍夫线变换要做的. 它追踪图像中每个点对应曲线间的交点. 如果交于一点的曲线的数量超过了 *阈值*, 那么可以认为这个交点所代表的参数对(θ,r<sub> θ </sub>) 在原图像中为一条直线.

##### 标准霍夫线变换和统计概率霍夫线变换

OpenCV实现了以下两种霍夫线变换:
> 标准霍夫线变换
>   原理在上面的部分已经说明了. 它能给我们提供一组参数对 (θ,r<sub> θ </sub>) 的集合来表示检测到的直线
>    在OpenCV 中通过函数 [HoughLines](http://opencv.willowgarage.com/documentation/cpp/imgproc_feature_detection.html?#cv-houghlines) 来实现

> 统计概率霍夫线变换
> 这是执行起来效率更高的霍夫线变换. 它输出检测到的直线的端点 (x<sub>0</sub>,y<sub>0</sub>,x<sub>1</sub>,y<sub>1</sub>)
> 在OpenCV 中它通过函数 [HoughLinesP](http://opencv.willowgarage.com/documentation/cpp/imgproc_feature_detection.html?#cv-houghlinesp) 来实现

## 源码
该程序 的主要目的是对图片进行 标准霍夫线变换 或是 统计概率霍夫线变换.
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
#import "HoughLinesViewController.h"

@interface HoughLinesViewController ()

@end

@implementation HoughLinesViewController

Mat src, edges;
Mat src_gray;
Mat standard_hough, probabilistic_hough;
int min_threshold = 50;
int max_trackbar = 150;
int s_trackbar = max_trackbar;
int p_trackbar = max_trackbar;
- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage * src1Image = [UIImage imageNamed:@"building.jpg"];
     src  = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];
    cvtColor( src, src_gray, COLOR_RGB2GRAY );
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src_gray];
    Canny( src_gray, edges, 50, 200, 3 );

    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:edges];
    
    [self createSliderFrame:CGRectMake(150, 100, 100, 50) maxValue:max_trackbar minValue:0 block:^(float value) {
        s_trackbar = value;
       [self Standard_Hough];
    }];
    [self Standard_Hough];
    
    [self createSliderFrame:CGRectMake(150, 150, 100, 50) maxValue:max_trackbar minValue:0 block:^(float value) {
           p_trackbar = value;
          [self Probabilistic_Hough];
       }];
    [self Probabilistic_Hough];

}

-(void)Standard_Hough{
     vector<Vec2f> s_lines;
    cvtColor( edges, standard_hough, COLOR_GRAY2BGR );
          /// 1. Use Standard Hough Transform
        HoughLines( edges, s_lines, 1, CV_PI/180, min_threshold + s_trackbar, 0, 0 );
    for( size_t i = 0; i < s_lines.size(); i++ )
    {
     float r = s_lines[i][0], t = s_lines[i][1];
     double cos_t = cos(t), sin_t = sin(t);
     double x0 = r*cos_t, y0 = r*sin_t;
     double alpha = 1000;

     cv::Point pt1( cvRound(x0 + alpha*(-sin_t)), cvRound(y0 + alpha*cos_t) );
      cv::Point pt2( cvRound(x0 - alpha*(-sin_t)), cvRound(y0 - alpha*cos_t) );
      line( standard_hough, pt1, pt2, Scalar(255,0,0), 3, LINE_AA);
    }
    
     UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(150, 250, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:standard_hough];
}

-(void)Probabilistic_Hough{
    vector<Vec4i> p_lines;
     cvtColor( edges, probabilistic_hough, COLOR_GRAY2BGR );

     /// 2. Use Probabilistic Hough Transform
     HoughLinesP( edges, p_lines, 1, CV_PI/180, min_threshold + p_trackbar, 30, 10 );

     /// Show the result
     for( size_t i = 0; i < p_lines.size(); i++ )
        {
          Vec4i l = p_lines[I];
          line( probabilistic_hough, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), Scalar(255,0,0), 3, LINE_AA);
        }
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(150, 400, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:probabilistic_hough];
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

## 代码说明
 + 标准霍夫线变换
 `首先, 你要执行变换`:
```
     vector<Vec2f> s_lines;
    cvtColor( edges, standard_hough, COLOR_GRAY2BGR );
          /// 1. Use Standard Hough Transform
        HoughLines( edges, s_lines, 1, CV_PI/180, min_threshold + s_trackbar, 0, 0 );
```
带有以下自变量:

*   *dst*: 边缘检测的输出图像. 它应该是个灰度图
*   *lines*: 储存着检测到的直线的参数对 (r,θ) 的容器
 * *rho* : 参数极径r 以像素值为单位的分辨率. 我们使用 **1** 像素.
*   *theta*: θ以弧度为单位的分辨率. 我们使用 **1度** (即CV_PI/180)
*   *threshold*: 要”*检测*” 一条直线所需最少的的曲线交点
*   *srn* and *stn*: 参数默认为0\. 查缺OpenCV参考文献来获取更多信息.

`通过画出检测到的直线来显示结果`
```
 for( size_t i = 0; i < s_lines.size(); i++ )
    {
     float r = s_lines[i][0], t = s_lines[i][1];
     double cos_t = cos(t), sin_t = sin(t);
     double x0 = r*cos_t, y0 = r*sin_t;
     double alpha = 1000;

     cv::Point pt1( cvRound(x0 + alpha*(-sin_t)), cvRound(y0 + alpha*cos_t) );
      cv::Point pt2( cvRound(x0 - alpha*(-sin_t)), cvRound(y0 - alpha*cos_t) );
      line( standard_hough, pt1, pt2, Scalar(255,0,0), 3, LINE_AA);
    }
```
+ 统计概率霍夫线变换
`首先, 你要执行变换:`
```
 vector<Vec4i> p_lines;
     cvtColor( edges, probabilistic_hough, COLOR_GRAY2BGR );

     /// 2. Use Probabilistic Hough Transform
     HoughLinesP( edges, p_lines, 1, CV_PI/180, min_threshold + p_trackbar, 30, 10 );


```
带有以下自变量:

*   *dst*: 边缘检测的输出图像. 它应该是个灰度图 (但事实上是个二值化图) * *lines*: 储存着检测到的直线的参数对(x<sub>start</sub>,y<sub>start</sub>,x<sub>end</sub>,x<sub>end</sub>)的容器
*   *rho* : 参数极径 r 以像素值为单位的分辨率. 我们使用 **1** 像素.
*   *theta*: 参数极角 θ以弧度为单位的分辨率. 我们使用 **1度** (即CV_PI/180)
*   *threshold*: 要”*检测*” 一条直线所需最少的的曲线交点 
* *minLinLength*: 能组成一条直线的最少点的数量. 点数量不足的直线将被抛弃.
*   *maxLineGap*: 能被认为在一条直线上的亮点的最大距离.
`通过画出检测到的直线来显示结果.`
```
 for( size_t i = 0; i < p_lines.size(); i++ )
        {
          Vec4i l = p_lines[I];
          line( probabilistic_hough, cv::Point(l[0], l[1]), cv::Point(l[2], l[3]), Scalar(255,0,0), 3, LINE_AA);
        }
```
## 结果

![](https://upload-images.jianshu.io/upload_images/1682758-09de886111623a34.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## cpp源码地址
[cpp](https://github.com/opencv/opencv/blob/master/samples/cpp/tutorial_code/ImgTrans/HoughLines_Demo.cpp)

-----
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-hough_lines)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/imgtrans/hough_lines/hough_lines.html#hough-lines)