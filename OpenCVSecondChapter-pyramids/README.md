# OpenCV 之ios 图像金字塔
## 目标
本文档尝试解答如下问题：

*   如何使用OpenCV函数 [pyrUp](http://opencv.willowgarage.com/documentation/cpp/imgproc_image_filtering.html#cv-pyrup) 和 [pyrDown](http://opencv.willowgarage.com/documentation/cpp/imgproc_image_filtering.html#cv-pyrdown) 对图像进行向上和向下采样。

## 原理
+ 一个图像金字塔是一系列图像的集合 - 所有图像来源于同一张原始图像 - 通过梯次向下采样获得，直到达到某个终止条件才停止采样。
有两种类型的图像金字塔常常出现在文献和应用中:
+ + `高斯金字塔(Gaussian pyramid)`: 用来向下采样
+ + `拉普拉斯金字塔(Laplacian pyramid)`: 用来从金字塔低层图像重建上层未采样图像
在这篇文档中我们将使用 高斯金字塔 。

### 高斯金字塔
+ 想想金字塔为一层一层的图像，层级越高，图像越小。
![](https://upload-images.jianshu.io/upload_images/1682758-c62c631d20f14e52.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
*   每一层都按从下到上的次序编号， 层级(i+1) (表示为G<sub>i+1</sub> 尺寸小于层级i(Gi))
+ 为了获取层级为(i+1) 的金字塔图像，我们采用如下方法:
> 1.将 G<sub>i</sub> 与高斯内核卷积:
> ![](https://upload-images.jianshu.io/upload_images/1682758-2ce4a5af301f7cb9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
> 2.将所有偶数行和列去除。
>
>  *   显而易见，结果图像只有原图的四分之一。通过对输入图像G0  (原始图像) 不停迭代以上步骤就会得到整个金字塔。

+ 以上过程描述了对图像的向下采样，如果将图像变大呢?:
>   首先，将图像在每个方向扩大为原来的两倍，新增的行和列以0填充(0)
>   使用先前同样的内核(乘以4)与放大后的图像卷积，获得 “新增像素” 的近似值。

 *   这两个步骤(向下和向上采样) 分别通过OpenCV函数 [pyrUp](http://opencv.willowgarage.com/documentation/cpp/imgproc_image_filtering.html#cv-pyrup) 和 [pyrDown](http://opencv.willowgarage.com/documentation/cpp/imgproc_image_filtering.html#cv-pyrdown) 实现, 我们将会在下面的示例中演示如何使用这两个函数。

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
#import "PyramidsViewController.h"

@interface PyramidsViewController ()

@end

@implementation PyramidsViewController
Mat src, dst, tmp;
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage * src1Image = [UIImage imageNamed:@"chicky_512.png"];
      Mat     src = [self cvMatFromUIImage:src1Image];
            UIImageView *imageView;
            imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
            [self.view addSubview:imageView];
            imageView.image  = [self UIImageFromCVMat:src];
    tmp = src;
     dst = tmp;
             imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
             [self.view addSubview:imageView];
              imageView.image  = [self UIImageFromCVMat:dst];
    [self createButtonFrame:CGRectMake(150, 100, 100, 50) title:@"放大" Block:^NSString * _Nonnull(int hitCount) {
        pyrUp( tmp, dst, cv::Size( tmp.cols*2, tmp.rows*2 ) );
         imageView.image  = [self UIImageFromCVMat:dst];
         tmp = dst;
        return nil;
    }];
    
    [self createButtonFrame:CGRectMake(150, 150, 100, 50) title:@"缩小" Block:^NSString * _Nonnull(int hitCount) {
        pyrDown( tmp, dst, cv::Size( tmp.cols/2, tmp.rows/2 )) ;
        imageView.image  = [self UIImageFromCVMat:dst];
         tmp = dst;
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

## 解释
### 向上采样 
```
yrUp( tmp, dst, Size( tmp.cols*2, tmp.rows*2 )
```
函数 [pyrUp](http://opencv.willowgarage.com/documentation/cpp/imgproc_image_filtering.html#cv-pyrup) 接受了3个参数:

*   *tmp*: 当前图像， 初始化为原图像 *src* 。
*   *dst*: 目的图像( 显示图像，为输入图像的两倍)
*   *Size( tmp.cols*2, tmp.rows*2 )* : 目的图像大小， 既然我们是向上采样， [pyrUp](http://opencv.willowgarage.com/documentation/cpp/imgproc_image_filtering.html#cv-pyrup) 期待一个两倍于输入图像( *tmp* )的大小。

> 这里需要注意,ios 加载到内存的图片大小是有限制的,不能无限制的向上采样

### 向下采样
```
pyrDown( tmp, dst, Size( tmp.cols/2, tmp.rows/2 )
```
类似于 [pyrUp](http://opencv.willowgarage.com/documentation/cpp/imgproc_image_filtering.html#cv-pyrup), 函数 [pyrDown](http://opencv.willowgarage.com/documentation/cpp/imgproc_image_filtering.html#cv-pyrdown) 也接受了3个参数:

*   *tmp*: 当前图像， 初始化为原图像 *src* 。
*   *dst*: 目的图像( 显示图像，为输入图像的一半)
*   *Size( tmp.cols/2, tmp.rows/2 )* :目的图像大小， 既然我们是向下采样， [pyrDown](http://opencv.willowgarage.com/documentation/cpp/imgproc_image_filtering.html#cv-pyrdown) 期待一个一半于输入图像( *tmp*)的大小。

+ `注意输入图像的大小(在两个方向)必须是2的幂，否则，将会显示错误(很重要)`。

## 结果
![](https://upload-images.jianshu.io/upload_images/1682758-578a7ca2e3847d75.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
注意图像大小是512*512,因此向下采样不会产生错误 

结果图像是我们先点击两次缩小,再点击两次放大最终的结果

----
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-pyramids)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/pyramids/pyramids.html)