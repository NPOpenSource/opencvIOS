# 1.目的
# 2.原理
# 3.代码
# 4.说明
# 5.结果
-----
# 1.目的
在这节教程中您将学到
*   *线性混合* (linear blending) 是什么以及有什么用处.
*   如何使用 [addWeighted](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?highlight=addweighted#addWeighted) 进行两幅图像求和

# 2.原理
在前面的教程中，我们已经了解一点 像素操作 的知识。 线性混合操作 也是一种典型的二元（两个输入）的 像素操作 ：
![](https://upload-images.jianshu.io/upload_images/1682758-d17286cbca42ef58.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

通过在范围(0->1) 内改变α ，这个操可以用来对两幅图像或两段视频产生时间上的 *画面叠化* （cross-dissolve）效果.

# 3.代码
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
#import "BlendingViewController.h"

@interface BlendingViewController ()

@end

@implementation BlendingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    double alpha = 0.5; double beta;

     Mat src1, src2, dst;
    UIImage * src1Image = [UIImage imageNamed:@"LinuxLogo.jpg"];
    UIImage * src2Image = [UIImage imageNamed:@"WindowsLogo.jpg"];
     src1 = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src1];
    
    src2 = [self cvMatFromUIImage:src2Image];
       imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
       [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:src2];
    
    beta = ( 1.0 - alpha );
    addWeighted( src1, alpha, src2, beta, 0.0, dst);
    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:dst];
}

#pragma mark  - private
///rgbX
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
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
  if (cvMat.elemSize() == 1) {
      colorSpace = CGColorSpaceCreateDeviceGray();
      data= [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
  } else if(cvMat.elemSize() == 3){
      cvtColor(cvMat, src, COLOR_BGR2RGB);
       data= [NSData dataWithBytes:src.data length:src.elemSize()*src.total()];
      colorSpace = CGColorSpaceCreateDeviceRGB();
  }else{
      colorSpace = CGColorSpaceCreateDeviceRGB();
      cvtColor(cvMat, src, COLOR_BGRA2RGBA);
      data= [NSData dataWithBytes:src.data length:src.elemSize()*src.total()];
      info =kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
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
# 4.说明
> 既然我们要执行
> ![](https://upload-images.jianshu.io/upload_images/1682758-d17286cbca42ef58.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
> 我们需要两幅输入图像f0(x)和f1(x)。相应地，我们使用常用的方法加载图像

`Warning 因为我们对 src1 和 src2 求 和 ，它们必须要有相同的尺寸（宽度和高度）和类型。`

> 现在我们生成图像 g(x) .为此目的，使用函数 [addWeighted](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?highlight=addweighted#addWeighted) 可以很方便地实现:
> ```
> beta = ( 1.0 - alpha );
> addWeighted( src1, alpha, src2, beta, 0.0, dst);
> ```

> 这是因为 [addWeighted](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?highlight=addweighted#addWeighted) 进行如下计算
> ![](https://upload-images.jianshu.io/upload_images/1682758-3e1154edec473591.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> 这里γΥ对应于上面代码中被设为0.0 的参数。

# 5 结果
![](https://upload-images.jianshu.io/upload_images/1682758-a6ba0ddcc4beb373.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

------
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVFirstChapter-blending)
[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/core/adding_images/adding_images.html)

