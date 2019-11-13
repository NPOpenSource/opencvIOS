# OpenCV 之ios  给图像添加边界

## 目标
本文档尝试解答如下问题:
*   如何使用OpenCV函数 [copyMakeBorder](http://opencv.willowgarage.com/documentation/cpp/imgproc_image_filtering.html?#copyMakeBorder) 设置边界(添加额外的边界)。

## Theory
1.  前一节我们学习了图像的卷积操作。一个很自然的问题是如何处理卷积边缘。当卷积点在图像边界时会发生什么，如何处理这个问题？

2.  大多数用到卷积操作的OpenCV函数都是将给定图像拷贝到另一个轻微变大的图像中，然后自动填充图像边界(通过下面示例代码中的各种方式)。这样卷积操作就可以在边界像素安全执行了(填充边界在操作完成后会自动删除)。

3.  本文档将会探讨填充图像边界的两种方法:

    a.  **BORDER_CONSTANT**: 使用常数填充边界 (i.e. 黑色或者 0)
     b.  **BORDER_REPLICATE**: 复制原图中最临近的行或者列。

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
#import "CopyMakeborderViewController.h"

@interface CopyMakeborderViewController ()

@end

@implementation CopyMakeborderViewController
Mat src, dst;
int ctop, cbottom, cleft, cright;
int borderType;
Scalar value;
RNG rng(12345);
- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage * src1Image = [UIImage imageNamed:@"lena.jpg"];
    Mat     src = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];

    ctop = (int) (0.05*src.rows);
    cbottom = (int) (0.05*src.rows);
    cleft = (int) (0.05*src.cols);
    cright = (int) (0.05*src.cols);
    dst = src;
    
    [self createButtonFrame:CGRectMake(150, 100, 100, 50) title:@"border" Block:^NSString * _Nonnull(int hitCount) {
        if (hitCount%2==0) {
              borderType = BORDER_CONSTANT;
        }else{
              borderType = BORDER_REPLICATE;
        }
      value = Scalar(rng.uniform(0, 255), rng.uniform(0, 255), rng.uniform(0, 255) );
        copyMakeBorder( src, dst, ctop, cbottom, cleft, cright, borderType, value );
        
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
### 解释
这里其实重点就是学习函数
```
copyMakeBorder( src, dst, top, bottom, left, right, borderType, value );
```

接受参数:

+ src: 原图像
+ dst: 目标图像
+ top, bottom, left, right: 各边界的宽度，此处定义为原图像尺寸的5%。
+ borderType: 边界类型，此处可以选择常数边界或者复制边界。
+ value: 如果 borderType 类型是 BORDER_CONSTANT, 该值用来填充边界像素。

## 结果
![](https://upload-images.jianshu.io/upload_images/1682758-1a5018413ddcff8d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

-----
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-copyMakeBorder)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/imgtrans/copyMakeBorder/copyMakeBorder.html#copymakebordertutorial)