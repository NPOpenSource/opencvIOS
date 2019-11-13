# OpenCV 之ios Canny 边缘检测
## 目标
本文档尝试解答如下问题:

*   使用OpenCV函数 [Canny](http://opencv.willowgarage.com/documentation/cpp/imgproc_feature_detection.html?#Canny) 检测边缘.

## 原理
Canny 边缘检测算法 是 John F. Canny 于 1986年开发出来的一个多级边缘检测算法，也被很多人认为是边缘检测的 最优算法, 最优边缘检测的三个主要评价标准是:
+ 低错误率: 标识出尽可能多的实际边缘，同时尽可能的减少噪声产生的误报。
+ 高定位性: 标识出的边缘要与图像中的实际边缘尽可能接近。
+ 最小响应: 图像中的边缘只能标识一次。

###  步骤

1. 消除噪声。 使用高斯平滑滤波器卷积降噪。 下面显示了一个size = 5 的高斯内核示例:

![](https://upload-images.jianshu.io/upload_images/1682758-4b4955bafcf0198c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2. 计算梯度幅值和方向。 此处，按照Sobel滤波器的步骤:

+  运用一对卷积阵列 (分别作用于 x 和y方向):

![](https://upload-images.jianshu.io/upload_images/1682758-0cd8c29aa8f86a5e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

+ 使用下列公式计算梯度幅值和方向:

![](https://upload-images.jianshu.io/upload_images/1682758-8753ac2b1c4eda86.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

梯度方向近似到四个可能角度之一(一般 0, 45, 90, 135)

3. 非极大值 抑制。 这一步排除非边缘像素， 仅仅保留了一些细线条(候选边缘)。
4. 滞后阈值: 最后一步，Canny 使用了滞后阈值，滞后阈值需要两个阈值(高阈值和低阈值):
+ 如果某一像素位置的幅值超过 高 阈值, 该像素被保留为边缘像素。
+ 如果某一像素位置的幅值小于 低 阈值, 该像素被排除。
+ 如果某一像素位置的幅值在两个阈值之间,该像素仅仅在连接到一个高于 高 阈值的像素时被保留。

`Canny 推荐的 高:低 阈值比在 2:1 到3:1之间。`

## 源码
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
#import "CannyViewController.h"

@interface CannyViewController ()

@end

@implementation CannyViewController
Mat src, src_gray;
Mat dst, detected_edges;

int edgeThresh = 1;
int lowThreshold;
int const max_lowThreshold = 100;
int cratio = 3;
int kernel_size = 3;

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage * src1Image = [UIImage imageNamed:@"building.jpg"];
    src = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];

     dst.create( src.size(), src.type() );
    cvtColor( src, src_gray, CV_BGR2GRAY );
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
       [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:src_gray];
    
    [self createSliderFrame:CGRectMake(150, 100, 100, 50) maxValue:max_lowThreshold minValue:0 block:^(float value) {
        lowThreshold = value;
        [self CannyThreshold];
    }];

}

-(void)CannyThreshold{
    blur( src_gray, detected_edges, cv::Size(3,3) );
    Canny( detected_edges, detected_edges, lowThreshold, lowThreshold*cratio, kernel_size );
    dst = Scalar::all(0);
    src.copyTo( dst, detected_edges);
    
    UIImageView *imageView;
      imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:dst];
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
这里主要是代码
```
-(void)CannyThreshold{
    blur( src_gray, detected_edges, cv::Size(3,3) );
    Canny( detected_edges, detected_edges, lowThreshold, lowThreshold*cratio, kernel_size );
    dst = Scalar::all(0);
    src.copyTo( dst, detected_edges);
    
    UIImageView *imageView;
      imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:dst];
}
```
+ 首先, 使用 3x3的内核平滑图像:
```
blur( src_gray, detected_edges, Size(3,3) );
```

+ 其次,运用 [Canny](http://opencv.willowgarage.com/documentation/cpp/imgproc_feature_detection.html?#Canny) 寻找边缘:
```
Canny( detected_edges, detected_edges, lowThreshold, lowThreshold*ratio, kernel_size );
```

输入参数:

1. detected_edges: 原灰度图像
2. detected_edges: 输出图像 (支持原地计算，可为输入图像)
3. lowThreshold: 用户通过 trackbar设定的值。
4. highThreshold: 设定为低阈值的3倍 (根据Canny算法的推荐)
5. kernel_size: 设定为 3 (Sobel内核大小，内部使用)

## 结果

滑动标尺, 尝试不同的阈值，我们得到如下结果:
![](https://upload-images.jianshu.io/upload_images/1682758-b6f465d8570334a0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
仔细观察边缘像素是如何叠加在黑色背景之上的。

-----
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-Canny)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/imgtrans/canny_detector/canny_detector.html#canny-detector)