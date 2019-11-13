# OpenCV 之ios 更多形态学变换

## 目标

本文档尝试解答如下问题:

*   如何使用OpenCV函数 [morphologyEx](http://opencv.jp/opencv-2.2_org/cpp/imgproc_image_filtering.html?highlight=morphology#morphologyEx) 进行形态学操作：
    *   开运算 (Opening)
    *   闭运算 (Closing)
    *   形态梯度 (Morphological Gradient)
    *   顶帽 (Top Hat)
    *   黑帽(Black Hat)

## 原理

前一节我们讨论了两种最基本的形态学操作:
+ 腐蚀 (Erosion)
+  膨胀 (Dilation)
运用这两个基本操作，我们可以实现更高级的形态学变换。这篇文档将会简要介绍OpenCV提供的5种高级形态学操作：

### 开运算 (Opening)

*   开运算是通过先对图像腐蚀再膨胀实现的。
    ![](https://upload-images.jianshu.io/upload_images/1682758-a06426613063aaab.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

*   `能够排除小团块物体(假设物体较背景明亮)`

*   请看下面，左图是原图像，右图是采用开运算转换之后的结果图。 观察发现字母拐弯处的白色空间消失。

![](https://upload-images.jianshu.io/upload_images/1682758-b8361c91f3003efc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> `腐蚀 缩小白色区域,放大黑色区域`
> `膨胀 扩大白色区域,缩小黑色区域`
> `开运算 就是先缩小白色区域再放大白色区域`

### 闭运算(Closing)

*   闭运算是通过先对图像膨胀再腐蚀实现的。

    ![](https://upload-images.jianshu.io/upload_images/1682758-bc2bb434eb2d1e89.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

*  ` 能够排除小型黑洞(黑色区域)。`

![](https://upload-images.jianshu.io/upload_images/1682758-9ea3583041b721bb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> `闭运算 就是先缩小黑色区域再放大黑色区域`

### 形态梯度(Morphological Gradient)

+ 膨胀图与腐蚀图之差
![](https://upload-images.jianshu.io/upload_images/1682758-906ed969d84cf338.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
+ 能够保留物体的边缘轮廓，如下所示:
![](https://upload-images.jianshu.io/upload_images/1682758-b4440749171c48e6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 顶帽(Top Hat)
+ 原图像与开运算结果图之差
![](https://upload-images.jianshu.io/upload_images/1682758-98d3651accbe9c49.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![](https://upload-images.jianshu.io/upload_images/1682758-2f18a67f8f43bda0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 黑帽(Black Hat)
+ 闭运算结果图与原图像之差

![](https://upload-images.jianshu.io/upload_images/1682758-ecb3127077910f9d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1682758-3b30feadac832e8c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

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
#import "MoreStateViewController.h"

@interface MoreStateViewController ()

@end

@implementation MoreStateViewController
int morph_operator = 0;
int morph_elem = 0;
int morph_size=0;
Mat src1;
- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage * src1Image = [UIImage imageNamed:@"baboon.jpg"];
        src1 = [self cvMatFromUIImage:src1Image];
         UIImageView *imageView;
         imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
         [self.view addSubview:imageView];
         imageView.image  = [self UIImageFromCVMat:src1];
     int const max_kernel_size = 21;
    
     [self createSliderFrame:CGRectMake(150, 100, 100, 50) maxValue:max_kernel_size minValue:0 block:^(float value) {
         morph_size = (int)value;
         [self Morphology_Operations];
     }];
 
    [self createButtonFrame:CGRectMake(250, 100, 100, 50) title:@"Opening" Block:^NSString * _Nonnull(int hitCount) {
         morph_operator = hitCount%5;
        [self Morphology_Operations];
         if (morph_operator==0) {
             return @"Opening";
         }else if (morph_operator==1){
             return @"Closeing";
         }else if (morph_operator==2){
             return @"Gradient";
         }else if (morph_operator==3){
             return @"Top Hat";
         }else{
             return @"Black Hat";
         }
     }];

    [self createButtonFrame:CGRectMake(250, 150, 100, 50) title:@"Rect" Block:^NSString * _Nonnull(int hitCount) {
         morph_elem = hitCount%3;
        [self Morphology_Operations];
         if (morph_elem==0) {
             return @"Rect";
         }else if (morph_elem==1){
             return @"CROSS";
         }else{
             return @"ELLIPSE";
         }
     }];
    
}

-(void)Morphology_Operations{
    Mat dst;
    int operation = morph_operator + 2;
    Mat element = getStructuringElement( morph_elem, cv::Size( 2*morph_size + 1, 2*morph_size+1 ), cv::Point( morph_size, morph_size ) );
    morphologyEx( src1, dst, operation, element );
      UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
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
运行形态学操作的核心函数是 [morphologyEx](http://opencv.jp/opencv-2.2_org/cpp/imgproc_image_filtering.html?highlight=morphology#morphologyEx) 。在本例中，我们使用了4个参数(其余使用默认值):
+ src : 原 (输入) 图像
+ dst: 输出图像
+ operation: 需要运行的形态学操作。 我们有5个选项:
+ + Opening: MORPH_OPEN : 2
+ + Closing: MORPH_CLOSE: 3
+ + Gradient: MORPH_GRADIENT: 4
+ + Top Hat: MORPH_TOPHAT: 5
+ + Black Hat: MORPH_BLACKHAT: 6

你可以看到， 它们的取值范围是 <2-6>, 因此我们要将从tracker获取的值增加(+2):
+ element: 内核，可以使用函数:get_structuring_element:getStructuringElement <> 自定义。

## 结果
原图
![](https://upload-images.jianshu.io/upload_images/1682758-14759c931e3ee565.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这里是显示窗口的两个截图。第一幅图显示了使用交错内核和 开运算 之后的结果， 第二幅图显示了使用椭圆内核和 黑帽 之后的结果。
![](https://upload-images.jianshu.io/upload_images/1682758-7368e22df19daaff.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![](https://upload-images.jianshu.io/upload_images/1682758-154ddf6fced924d5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

----
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-moreState)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/opening_closing_hats/opening_closing_hats.html#morphology-2)