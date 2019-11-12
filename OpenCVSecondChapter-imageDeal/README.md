# OpenCV 之ios 图像平滑处理

## 目标
本教程教您怎样使用各种线性滤波器对图像进行平滑处理，相关OpenCV函数如下:
*   [blur](http://opencv.willowgarage.com/documentation/cpp/image_filtering.html#cv-blur)
*   [GaussianBlur](http://opencv.willowgarage.com/documentation/cpp/image_filtering.html#cv-gaussianblur)
*   [medianBlur](http://opencv.willowgarage.com/documentation/cpp/image_filtering.html#cv-medianblur)
*   [bilateralFilter](http://opencv.willowgarage.com/documentation/cpp/image_filtering.html#cv-bilateralfilter)

## 原理

*   `平滑`也称`模糊`, 是一项简单且使用频率很高的图像处理方法。

*   平滑处理的用途有很多， 但是在`本教程`中我们仅仅`关注`它`减少噪声`的功用 (其他用途在以后的教程中会接触到)。

*   平滑处理时需要用到一个`滤波器`。 最常用的滤波器是`线性滤波器`，线性滤波处理的输出像素值 (i.e. g(i,j))是输入像素值 (i.e.  f(i+k,j+l))的加权和 :

    ![](https://upload-images.jianshu.io/upload_images/1682758-5bc70c59839734dc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

    h(k,l)称为 *核*, 它仅仅是一个加权系数。
不妨把`滤波器`想象成一个包含加权系数的窗口，当使用这个滤波器平滑处理图像时，就把这个窗口滑过图像。

*   滤波器的种类有很多， 这里仅仅提及最常用的:
### 归一化块滤波器 (Normalized Box Filter)
最简单的滤波器， 输出像素值是核窗口内像素值的 均值 ( 所有像素加权系数相等)
核如下:
![](https://upload-images.jianshu.io/upload_images/1682758-120f239422f77d46.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> 掩码矩阵（也称作核）
### 高斯滤波器 (Gaussian Filter)
最有用的滤波器 (尽管不是最快的)。 高斯滤波是将输入数组的每一个像素点与 高斯内核 卷积将卷积和当作输出像素值。

还记得1维高斯函数的样子吗?
![](https://upload-images.jianshu.io/upload_images/1682758-989983d5623fd876.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
假设图像是1维的,那么观察上图，不难发现中间像素的加权系数是最大的， 周边像素的加权系数随着它们远离中间像素的距离增大而逐渐减小。

> Note 2维高斯函数可以表达为 :
> ![](https://upload-images.jianshu.io/upload_images/1682758-debd0ca8ce935ba6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
> 其中 μ 为均值 (峰值对应位置)， σ代表标准差 (变量x和 变量 y 各有一个均值，也各有一个标准差)

### 中值滤波器 (Median Filter)
中值滤波将图像的每个像素用邻域 (以当前像素为中心的正方形区域)像素的 中值 代替 。
### 双边滤波 (Bilateral Filter)
+ 目前我们了解的滤波器都是为了 平滑 图像， 问题是有些时候这些滤波器不仅仅削弱了噪声， 连带着把边缘也给磨掉了。 为避免这样的情形 (至少在一定程度上 ), 我们可以使用双边滤波。
+ 类似于高斯滤波器，双边滤波器也给每一个邻域像素分配一个加权系数。 这些加权系数包含两个部分, 第一部分加权方式与高斯滤波一样，第二部分的权重则取决于该邻域像素与当前像素的灰度差值。
+   详细的解释可以查看 [链接](http://homepages.inf.ed.ac.uk/rbf/CVonline/LOCAL_COPIES/MANDUCHI1/Bilateral_Filtering.html)

## 源码
+ 本程序做什么?
装载一张图像
使用4种不同滤波器 (见原理部分) 并显示平滑图像
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
#import "DealImageViewController.h"

@interface DealImageViewController ()

@end

@implementation DealImageViewController
int DELAY_CAPTION = 1500;
int DELAY_BLUR = 100;
int MAX_KERNEL_LENGTH = 31;
- (void)viewDidLoad {
    [super viewDidLoad];
     UIImage * src1Image = [UIImage imageNamed:@"lena.jpg"];
    Mat src1 = [self cvMatFromUIImage:src1Image];
    Mat src;
    cvtColor(src1, src, COLOR_BGRA2BGR);
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];
    ///均值平滑
    Mat dst;
    {
        for ( int i = 1; i < MAX_KERNEL_LENGTH; i = i + 2 ){
            blur( src, dst, cv::Size( i, i ), cv::Point(-1,-1));
        }
        imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:dst];
    }
    /// 高斯平滑
    {
        for ( int i = 1; i < MAX_KERNEL_LENGTH; i = i + 2 ){
            GaussianBlur( src, dst, cv::Size( i, i ), 0, 0 );
        }
        imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:dst];
    }

    ///中值平滑
    {
        for ( int i = 1; i < MAX_KERNEL_LENGTH; i = i + 2 ) {
            medianBlur ( src, dst, I );
        }
        imageView = [self createImageViewInRect:CGRectMake(150, 250, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:dst];
    }

    ///双边平滑
    {
        for ( int i = 1; i < MAX_KERNEL_LENGTH; i = i + 2 ){
                bilateralFilter ( src, dst, i, i*2, i/2 );
        }
        imageView = [self createImageViewInRect:CGRectMake(150, 100, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:dst];
    }
}

#pragma mark  - private
//brgx
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
### 1.归一化块滤波器:
OpenCV函数 [blur](http://opencv.willowgarage.com/documentation/cpp/image_filtering.html#cv-blur) 执行了归一化块平滑操作。
```
for ( int i = 1; i < MAX_KERNEL_LENGTH; i = i + 2 ){
            blur( src, dst, cv::Size( i, i ), cv::Point(-1,-1));
        }
```
我们输入4个实参 (详细的解释请参考 Reference):

+ src: 输入图像
+ dst: 输出图像
+ Size( w,h ): 定义内核大小( w 像素宽度， h 像素高度)
+ Point(-1, -1): 指定锚点位置(被平滑点)，` 如果是负值，取核的中心为锚点`。

### 2.高斯滤波器:
OpenCV函数 [GaussianBlur](http://opencv.willowgarage.com/documentation/cpp/image_filtering.html#cv-gaussianblur) 执行高斯平滑 :
```
  for ( int i = 1; i < MAX_KERNEL_LENGTH; i = i + 2 ){
            GaussianBlur( src, dst, cv::Size( i, i ), 0, 0 );
        }
```

我们输入4个实参 (详细的解释请参考 Reference):
*   *src*: 输入图像
*   *dst*: 输出图像
*   *Size(w, h)*: 定义内核的大小(需要考虑的邻域范围)。  w 和h必须是正奇数，否则将使用 σx和 σy参数来计算内核大小。
*  σx: x 方向标准方差， 如果是0  则 σx使用内核大小计算得到。
*   σy:y 方向标准方差， 如果是0 则 σy使用内核大小计算得到。.

### 3.中值滤波器:
OpenCV函数 [medianBlur](http://opencv.willowgarage.com/documentation/cpp/image_filtering.html#cv-medianblur) 执行中值滤波操作:
```
 for ( int i = 1; i < MAX_KERNEL_LENGTH; i = i + 2 ) {
            medianBlur ( src, dst, I );
        }
```
我们用了3个参数:
src: 输入图像
dst: 输出图像, 必须与 src 相同类型
i: 内核大小 (只需一个值，因为我们使用正方形窗口)，必须为奇数。
### 4.双边滤波器
OpenCV函数 [bilateralFilter](http://opencv.willowgarage.com/documentation/cpp/image_filtering.html#cv-bilateralfilter) 执行双边滤波操作:
```
 for ( int i = 1; i < MAX_KERNEL_LENGTH; i = i + 2 ){
                bilateralFilter ( src, dst, i, i*2, i/2 );
        }
```
1.  我们使用了5个参数:
    *   `src`: 输入图像
    *   `dst`: 输出图像
    *   `d`: 像素的邻域直径
    *  `σColor`: 颜色空间的标准方差
    *  `σSpace`: 坐标空间的标准方差(像素单位)

## 结果
![](https://upload-images.jianshu.io/upload_images/1682758-086c9bdc569c964d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
+ 第一行是原始图
+ 第二行第一张图片是`归一化块滤波器`处理结果
+ 第二行第二张图片是`高斯滤波器`处理结果
+ 第三行第一张图片是`中值滤波器`处理结果
+ 第三行第二张图片是`双边滤波器`处理结果

------
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-imageDeal)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/gausian_median_blur_bilateral_filter/gausian_median_blur_bilateral_filter.html#smoothing)