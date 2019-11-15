# OpenCV 之ios 直方图均衡化
## 目标
在这个教程中你将学到:

*   什么是图像的直方图和为什么图像的直方图很有用
*   用OpenCV函数 [equalizeHist](http://opencv.willowgarage.com/documentation/cpp/imgproc_histograms.html?#equalizeHist) 对图像进行直方图均衡化

## 原理
### 图像的直方图是什么?
+ 直方图是图像中像素强度分布的图形表达方式.
+ 它统计了每一个强度值所具有的像素个数.
![](https://upload-images.jianshu.io/upload_images/1682758-15ca2ffb662305f9.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 直方图均衡化是什么?
+ 直方图均衡化是通过拉伸像素强度分布范围来增强图像对比度的一种方法.
+ 说得更清楚一些, 以上面的直方图为例, 你可以看到像素主要集中在中间的一些强度值上. 直方图均衡化要做的就是 拉伸 这个范围. 见下面左图: 绿圈圈出了 少有像素分布其上的 强度值. 对其应用均衡化后, 得到了中间图所示的直方图. 均衡化的图像见下面右图.

![](https://upload-images.jianshu.io/upload_images/1682758-3a160e0e937af5ba.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 直方图均衡化是怎样做到的?
+ *   均衡化指的是把一个分布 (给定的直方图) *映射* 到另一个分布 (一个更宽更统一的强度值分布), 所以强度值分布会在整个范围内展开.

*   要想实现均衡化的效果, 映射函数应该是一个 *累积分布函数 (cdf)* (更多细节, 参考*学习OpenCV*). 对于直方图 H(i) , 它的 *累积分布* H'(i)是:

![](https://upload-images.jianshu.io/upload_images/1682758-bf73fe4f9a22b53f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

要使用其作为映射函数, 我们必须对最大值为255 (或者用图像的最大强度值) 的累积分布 H'(i)进行归一化. 同上例, 累积分布函数为:
![](https://upload-images.jianshu.io/upload_images/1682758-464d67bc75a35c76.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

最后, 我们使用一个简单的映射过程来获得均衡化后像素的强度值:

![](https://upload-images.jianshu.io/upload_images/1682758-e77f1bd4a38b248c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 例程
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
#import "ZFTViewController.h"

@interface ZFTViewController ()

@end

@implementation ZFTViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    Mat src, dst;
    UIImage * src1Image = [UIImage imageNamed:@"chicky_512.png"];
     src  = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];
    /// 转为灰度图
    cvtColor( src, src, CV_BGR2GRAY );
    
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
     [self.view addSubview:imageView];
     imageView.image  = [self UIImageFromCVMat:src];
    /// 应用直方图均衡化
     equalizeHist( src, dst );
      /// 设置源图像和目标图像上的三组点以计算仿射变换
     
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


## 说明

利用函数 [equalizeHist](http://opencv.willowgarage.com/documentation/cpp/imgproc_histograms.html?#equalizeHist) 对上面灰度图做直方图均衡化:
```
equalizeHist( src, dst );
```
可以看到, 这个操作的参数只有源图像和目标 (均衡化后) 图像.
## 结果

![](https://upload-images.jianshu.io/upload_images/1682758-5aa43973913f0a27.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
直方图变化如下
![](https://upload-images.jianshu.io/upload_images/1682758-766a178a3d7d7901.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![](https://upload-images.jianshu.io/upload_images/1682758-d454279564f9d29e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

直方图具体绘制看后面的章节

----
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-histogram_equalization)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/histograms/histogram_equalization/histogram_equalization.html#histogram-equalization)