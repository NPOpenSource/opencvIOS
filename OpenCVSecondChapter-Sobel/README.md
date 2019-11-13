# Sobel 导数

## 目标


本文档尝试解答如下问题:

   * 如何使用OpenCV函数 :sobel 对图像求导。
   * 如何使用OpenCV函数 :scharr 更准确地计算 :math:`3 \times 3` 核的导数。

## 原理

  + 上面两节我们已经学习了卷积操作。一个最重要的卷积运算就是导数的计算(或者近似计算).

+  为什么对图像进行求导是重要的呢? 假设我们需要检测图像中的 *边缘* ，如下图:
![](https://upload-images.jianshu.io/upload_images/1682758-92f9475f853c238d.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


   你可以看到在 *边缘* ,相素值显著的 *改变* 了。表示这一 *改变* 的一个方法是使用 *导数* 。 梯度值的大变预示着图像中内容的显著变化。 

+ 用更加形象的图像来解释,假设我们有一张一维图形。下图中灰度值的"跃升"表示边缘的存在:
![](https://upload-images.jianshu.io/upload_images/1682758-3314815ff4ac2b88.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


+ 使用一阶微分求导我们可以更加清晰的看到边缘"跃升"的存在(这里显示为高峰值)

+  从上例中我们可以推论检测边缘可以通过定位梯度值大于邻域的相素的方法找到(或者推广到大于一个阀值).

### Sobel算子

+  Sobel 算子是一个离散微分算子 (discrete differentiation operator)。 它用来计算图像灰度函数的近似梯度。 
+  Sobel 算子结合了高斯平滑和微分求导。  

### 计算
假设被作用图像为I:

1. 在两个方向求导:

   a. **水平变化**: 将 I`与一个奇数大小的内核G(x) 进行卷积。比如，当内核大小为3时, G(x)的计算结果为:
![](https://upload-images.jianshu.io/upload_images/1682758-bb65b2d761b86186.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

   b. **垂直变化**: 将I 与一个奇数大小的内核 G(y) 进行卷积。比如，当内核大小为3时,  G(y) 的计算结果为:
    ![](https://upload-images.jianshu.io/upload_images/1682758-24b9d644c3ea1cbe.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

#. 在图像的每一点，结合以上两个结果求出近似 *梯度*:

![](https://upload-images.jianshu.io/upload_images/1682758-5465102f97ea3afa.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


   有时也用下面更简单公式代替:

![](https://upload-images.jianshu.io/upload_images/1682758-e86409514be2aeb7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

>    当内核大小为 3 时, 以上Sobel内核可能产生比较明显的误差(毕竟，Sobel算子只是求取了导数的近似值)。 为解决这一问题，OpenCV提供了 scharr 函数，但该函数仅作用于大小为3的内核。该函数的运算与Sobel函数一样快，但结果却更加精确，其内核为:
>    ![](https://upload-images.jianshu.io/upload_images/1682758-603e3f9ff60ca7d7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

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
#import "SobelViewController.h"

@interface SobelViewController ()

@end

@implementation SobelViewController
Mat src, src_gray;
Mat grad;
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
    Mat grad_x, grad_y;
    Mat abs_grad_x, abs_grad_y;
    
    /// 求 X方向梯度
    //Scharr( src_gray, grad_x, ddepth, 1, 0, scale, delta, BORDER_DEFAULT );
    Sobel( src_gray, grad_x, ddepth, 1, 0, 3, scale, delta, BORDER_DEFAULT );
    convertScaleAbs( grad_x, abs_grad_x );
    imageView = [self createImageViewInRect:CGRectMake(150, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:grad_x];
    
    imageView = [self createImageViewInRect:CGRectMake(150, 250, 150, 150)];
       [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:abs_grad_x];
    
    /// 求Y方向梯度
    //Scharr( src_gray, grad_y, ddepth, 0, 1, scale, delta, BORDER_DEFAULT );
    Sobel( src_gray, grad_y, ddepth, 0, 1, 3, scale, delta, BORDER_DEFAULT );
    convertScaleAbs( grad_y, abs_grad_y );

    /// 合并梯度(近似)
    addWeighted( abs_grad_x, 0.5, abs_grad_y, 0.5, 0, grad );
    
    
    imageView = [self createImageViewInRect:CGRectMake(150, 400, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:grad];

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

这里转换灰度图前先对图像进行降噪处理
```
GaussianBlur( src, src, Size(3,3), 0, 0, BORDER_DEFAULT );
```

这里主要是求导函数
```
Mat grad_x, grad_y;
Mat abs_grad_x, abs_grad_y;

/// 求 X方向梯度
Sobel( src_gray, grad_x, ddepth, 1, 0, 3, scale, delta, BORDER_DEFAULT );
/// 求 Y方向梯度
Sobel( src_gray, grad_y, ddepth, 0, 1, 3, scale, delta, BORDER_DEFAULT );

```
该函数接受了以下参数:

+ src_gray: 在本例中为输入图像，元素类型 CV_8U
+ grad_x/grad_y: 输出图像.
+ ddepth: 输出图像的深度，设定为 CV_16S 避免外溢。
+ x_order: x 方向求导的阶数。
+ y_order: y 方向求导的阶数。
+ scale, delta 和 BORDER_DEFAULT: 使用默认值

注意为了在 x 方向求导我们使用x<sub>order</sub>=1,y<sub>order</sub>=0.采用同样方法在 y 方向求导。

将中间结果转换到 CV_8U:
```
convertScaleAbs( grad_x, abs_grad_x );
convertScaleAbs( grad_y, abs_grad_y );
```

将两个方向的梯度相加来求取近似 梯度 (注意这里没有准确的计算，但是对我们来讲已经足够了)。
```
addWeighted( abs_grad_x, 0.5, abs_grad_y, 0.5, 0, grad );

```

## 结果
![](https://upload-images.jianshu.io/upload_images/1682758-6097632c3def6e64.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这里我输出了每个状态的图片样子

---------
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-Sobel)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/imgtrans/sobel_derivatives/sobel_derivatives.html#sobel-derivatives)

