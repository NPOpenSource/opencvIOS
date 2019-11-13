# OpenCV 之ios Laplace 算子
## 目标
本文档尝试解答如下问题:

*   如何使用OpenCV函数 [Laplacian](http://opencv.willowgarage.com/documentation/cpp/image_filtering.html#cv-laplacian) 实现 *Laplacian 算子* 的离散模拟。

## 原理

1. 前一节我们学习了 Sobel 算子 ，其基础来自于一个事实，即在边缘部分，像素值出现”跳跃“或者较大的变化。如果在此边缘部分求取一阶导数，你会看到极值的出现。正如下图所示：

![](https://upload-images.jianshu.io/upload_images/1682758-167fb688dcb7d5b3.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

2. 如果在边缘部分求二阶导数会出现什么情况?

![](https://upload-images.jianshu.io/upload_images/1682758-e7ec905e206c2628.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

你会发现在一阶导数的极值位置，二阶导数为0。所以我们也可以用这个特点来作为检测图像边缘的方法。 `但是， 二阶导数的0值不仅仅出现在边缘(它们也可能出现在无意义的位置),但是我们可以过滤掉这些点。`

### Laplacian 算子

1. 从以上分析中，我们推论二阶导数可以用来 检测边缘 。 因为图像是 “2维”, 我们需要在两个方向求导。使用Laplacian算子将会使求导过程变得简单。
2. Laplacian 算子 的定义:
![](https://upload-images.jianshu.io/upload_images/1682758-7cf1ee02a4c4e710.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

3.  OpenCV函数 [Laplacian](http://opencv.willowgarage.com/documentation/cpp/image_filtering.html#cv-laplacian) 实现了Laplacian算子。 实际上，由于 Laplacian使用了图像梯度，它内部调用了 *Sobel* 算子。

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
#import "LaplaceViewController.h"

@interface LaplaceViewController ()

@end

@implementation LaplaceViewController
Mat src, src_gray, dst;
int kernel_size = 3;
int scale = 1;
int delta = 0;
int ddepth = CV_16S;

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage * src1Image = [UIImage imageNamed:@"lena.jpg"];
    Mat     src = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];

     GaussianBlur( src, src, cv::Size(3,3), 0, 0, BORDER_DEFAULT );
        imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
       [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:src];
     cvtColor( src, src_gray, CV_RGB2GRAY );
    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
         [self.view addSubview:imageView];
         imageView.image  = [self UIImageFromCVMat:src_gray];
    
      /// 创建 grad_x 和 grad_y 矩阵
    Mat abs_dst;

    
    /// 求 X方向梯度
    //Scharr( src_gray, grad_x, ddepth, 1, 0, scale, delta, BORDER_DEFAULT );
    Laplacian( src_gray, dst, ddepth, kernel_size, scale, delta, BORDER_DEFAULT );
    convertScaleAbs( dst, abs_dst );
    imageView = [self createImageViewInRect:CGRectMake(150, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:abs_dst];
    

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
.对灰度图使用Laplacian算子:
```
Laplacian( src_gray, dst, ddepth, kernel_size, scale, delta, BORDER_DEFAULT );
```
函数接受了以下参数:

+ src_gray: 输入图像。
+ dst: 输出图像
+ ddepth: 输出图像的深度。 因为输入图像的深度是 CV_8U ，这里我们必须定义 ddepth = CV_16S 以避免外溢。
+ kernel_size: 内部调用的 Sobel算子的内核大小，此例中设置为3。
+ scale, delta 和 BORDER_DEFAULT: 使用默认值。

将输出图像的深度转化为 CV_8U :
```
convertScaleAbs( dst, abs_dst );
```

## 结果
![](https://upload-images.jianshu.io/upload_images/1682758-a1595018bfad57e9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

-----
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-Laplace)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/imgtrans/laplace_operator/laplace_operator.html#laplace-operator)