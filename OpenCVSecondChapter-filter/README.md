# OpenCV 之ios 实现自己的线性滤波器
## 目的
本篇教程中，我们将学到：

*   用OpenCV函数 [filter2D](http://opencv.willowgarage.com/documentation/cpp/image_filtering.html#cv-filter2d) 创建自己的线性滤波器。

## 原理
### 卷积
`高度概括地说，卷积是在每一个图像块与某个算子（核）之间进行的运算。`
### 核是什么？
`核说白了就是一个固定大小的数值数组。该数组带有一个 锚点 ，一般位于数组中央。`

### 如何用核实现卷积？
假如你想得到图像的某个特定位置的卷积值，可用下列方法计算：

 1. 将核的锚点放在该特定位置的像素上，同时，核内的其他值与该像素邻域的各像素重合；
2. 将核内各值与相应像素值相乘，并将乘积相加；
3. 将所得结果放到与锚点对应的像素上；
4. 对图像所有像素重复上述过程。

用公式表示上述过程如下：
![](https://upload-images.jianshu.io/upload_images/1682758-ee7b515ae64981d9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
幸运的是，我们不必自己去实现这些运算，OpenCV为我们提供了函数 [filter2D](http://opencv.willowgarage.com/documentation/cpp/image_filtering.html#cv-filter2d) 。

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
#import "FilterViewController.h"

@interface FilterViewController ()

@end

@implementation FilterViewController
Mat src, dst;

 Mat kernel;
    cv::Point anchor;
 double delta;
 int ddepth;
 int kernel_size;

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage * src1Image = [UIImage imageNamed:@"lena.jpg"];
    Mat     src = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];

    anchor = cv::Point( -1, -1 );
    delta = 0;
    ddepth = -1;
    __block int ind = 0;
    [self createButtonFrame:CGRectMake(150, 100, 100, 50) title:@"fiter" Block:^NSString * _Nonnull(int hitCount) {
           kernel_size = 3 + 2*( ind%5 );
            kernel = Mat::ones( kernel_size, kernel_size, CV_32F )/ (float)(kernel_size*kernel_size);
          filter2D(src, dst, ddepth , kernel, anchor, delta, BORDER_DEFAULT );
          ind++;
           UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
                 [self.view addSubview:imageView];
                 imageView.image  = [self UIImageFromCVMat:dst];
             return nil;
         }];
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
[cpp 源码地址](https://github.com/opencv/opencv/blob/master/samples/cpp/tutorial_code/ImgTrans/filter2D_demo.cpp)
## 说明 
上述代码其实很简单,就是每次点击一次按钮实现实现一次滤波操作
这里只介绍下关键代码
```
kernel_size = 3 + 2*( ind%5 );
kernel = Mat::ones( kernel_size, kernel_size, CV_32F )/ (float)(kernel_size*kernel_size);
```
第一行代码将 *核的大小* 设置为 ![[3,11]](https://upload-images.jianshu.io/upload_images/1682758-b039959ef615db2d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

 范围内的奇数。第二行代码把1填充进矩阵，并执行归一化——除以矩阵元素数——以构造出所用的核。

将核设置好之后，使用函数 [filter2D](http://opencv.willowgarage.com/documentation/cpp/image_filtering.html#cv-filter2d) 就可以生成滤波器：
```
filter2D(src, dst, ddepth , kernel, anchor, delta, BORDER_DEFAULT );
```
其中各参数含义如下：

1.  *src*: 源图像
2.  *dst*: 目标图像
3.  *ddepth*: *dst* 的深度。若为负值（如-1)，则表示其深度与源图像相等。
4.  *kernel*: 用来遍历图像的核
5.  *anchor*: 核的锚点的相对位置，其中心点默认为 *(-1, -1)* 。
6.  *delta*: 在卷积过程中，该值会加到每个像素上。默认情况下，这个值为0
7.  *BORDER_DEFAULT*: 这里我们保持其默认值，更多细节将在其他教程中详解

## 结果
![](https://upload-images.jianshu.io/upload_images/1682758-afcfa49274a9d747.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

-----
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-filter)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/imgtrans/filter_2d/filter_2d.html)