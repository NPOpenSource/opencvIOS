# OpenCV 之ios 模板匹配
## 目标

在这节教程中您将学到:

*   使用OpenCV函数 [matchTemplate](http://opencv.willowgarage.com/documentation/cpp/imgproc_object_detection.html?#matchTemplate) 在模板块和输入图像之间寻找匹配,获得匹配结果图像
*   使用OpenCV函数 [minMaxLoc](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?#minMaxLoc) 在给定的矩阵中寻找最大和最小值(包括它们的位置).

## 原理
### 什么是模板匹配?
模板匹配是一项在一幅图像中寻找与另一幅模板图像最匹配(相似)部分的技术.
### ### 它是怎么实现的?
+ 我们需要2幅图像:
> 原图像 (I): 在这幅图像里,我们希望找到一块和模板匹配的区域
> 模板 (T): 将和原图像比照的图像块

我们的目标是检测最匹配的区域:

![](https://upload-images.jianshu.io/upload_images/1682758-68add4a0a2dfffb6.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

+ 为了确定匹配区域, 我们不得不滑动模板图像和原图像进行 比较 :

![](https://upload-images.jianshu.io/upload_images/1682758-854f493e0016eafb.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

+ 通过 滑动, 我们的意思是图像块一次移动一个像素 (从左往右,从上往下). 在每一个位置, 都进行一次度量计算来表明它是 “好” 或 “坏” 地与那个位置匹配 (或者说块图像和原图像的特定区域有多么相似).

+ 对于 **T** 覆盖在 **I** 上的每个位置,你把度量值 *保存* 到 *结果图像矩阵* **(R)** 中. 在 **R** 中的每个位置(x,y)都包含匹配度量值:

![](https://upload-images.jianshu.io/upload_images/1682758-e0fa08b27c49bd62.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

*   上图就是 **TM_CCORR_NORMED** 方法处理后的结果图像 **R** . 最白的位置代表最高的匹配. 正如您所见, 红色椭圆框住的位置很可能是结果图像矩阵中的最大数值, 所以这个区域 (以这个点为顶点,长宽和模板图像一样大小的矩阵) 被认为是匹配的.

*   实际上, 我们使用函数 [minMaxLoc](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?#minMaxLoc) 来定位在矩阵 *R* 中的最大值点 (或者最小值, 根据函数输入的匹配参数) .
### OpenCV中支持哪些匹配算法?
问得好. OpenCV通过函数 [matchTemplate](http://opencv.willowgarage.com/documentation/cpp/imgproc_object_detection.html?#matchTemplate) 实现了模板匹配算法. 可用的方法有6个:
+ 平方差匹配 method=CV_TM_SQDIFF

这类方法利用平方差来进行匹配,最好匹配为0.匹配越差,匹配值越大.
![](https://upload-images.jianshu.io/upload_images/1682758-aab9900f34508393.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

+ 标准平方差匹配 method=CV_TM_SQDIFF_NORMED
![](https://upload-images.jianshu.io/upload_images/1682758-e856c02ac69b6b9e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

+ 相关匹配 method=CV_TM_CCORR

这类方法采用模板和图像间的乘法操作,所以较大的数表示匹配程度较高,0标识最坏的匹配效果.
![](https://upload-images.jianshu.io/upload_images/1682758-aa9dcc8c0ff62310.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

+ 标准相关匹配 method=CV_TM_CCORR_NORMED

![](https://upload-images.jianshu.io/upload_images/1682758-2b56c701f6ded144.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

+ 相关匹配 method=CV_TM_CCOEFF

这类方法将模版对其均值的相对值与图像对其均值的相关值进行匹配,1表示完美匹配,-1表示糟糕的匹配,0表示没有任何相关性(随机序列).

![](https://upload-images.jianshu.io/upload_images/1682758-484dc18a1fd6bf26.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

在这里

![](https://upload-images.jianshu.io/upload_images/1682758-441c8f39a27f4d9c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

+ 标准相关匹配 method=CV_TM_CCOEFF_NORMED

![](https://upload-images.jianshu.io/upload_images/1682758-002cc33ad636d128.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

通常,随着从简单的测量(平方差)到更复杂的测量(相关系数),我们可获得越来越准确的匹配(同时也意味着越来越大的计算代价). 最好的办法是对所有这些设置多做一些测试实验,以便为自己的应用选择同时兼顾速度和精度的最佳方案.

## 代码
*   **在这程序实现了什么?**

    *   载入一幅输入图像和一幅模板图像块 (*template*)
    *   通过使用函数 [matchTemplate](http://opencv.willowgarage.com/documentation/cpp/imgproc_object_detection.html?#matchTemplate) 实现之前所述的6种匹配方法的任一个. 用户可以通过滑动条选取任何一种方法.
    *   归一化匹配后的输出结果
    *   定位最匹配的区域
    *   用矩形标注最匹配的区域

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
#import "TemplateMatchingViewController.h"

@interface TemplateMatchingViewController ()

@end

@implementation TemplateMatchingViewController
/// 全局变量
Mat img; Mat templ; Mat result;
int match_method;
int max_Trackbar = 5;


- (void)viewDidLoad {
    [super viewDidLoad];
   
    UIImage * srcImage = [UIImage imageNamed:@"Template.jpg"];
    img  = [self cvMatFromUIImage:srcImage];
  UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:img];
     UIImage * src1Image = [UIImage imageNamed:@"Template_Matching.jpg"];
    templ=[self cvMatFromUIImage:src1Image];
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:templ];
    
    [self createSliderFrame:CGRectMake(150, 400, 150, 50) maxValue:max_Trackbar minValue:0 block:^(float value) {
        match_method= value;
        [self MatchingMethod];
    }];
    [self MatchingMethod];
}

-(void)MatchingMethod{
   Mat img_display;
   img.copyTo( img_display );

   /// 创建输出结果的矩阵
   int result_cols =  img.cols - templ.cols + 1;
   int result_rows = img.rows - templ.rows + 1;

   result.create( result_cols, result_rows, CV_32FC1 );

   /// 进行匹配和标准化
   matchTemplate( img, templ, result, match_method );
   normalize( result, result, 0, 1, NORM_MINMAX, -1, Mat() );

   /// 通过函数 minMaxLoc 定位最匹配的位置
    double minVal; double maxVal; cv::Point minLoc; cv::Point maxLoc;
    cv::Point matchLoc;

   minMaxLoc( result, &minVal, &maxVal, &minLoc, &maxLoc, Mat() );

   /// 对于方法 SQDIFF 和 SQDIFF_NORMED, 越小的数值代表更高的匹配结果. 而对于其他方法, 数值越大匹配越好
   if( match_method  == CV_TM_SQDIFF || match_method == CV_TM_SQDIFF_NORMED )
     { matchLoc = minLoc; }
   else
     { matchLoc = maxLoc; }

   /// 让我看看您的最终结果
    rectangle( img_display, matchLoc, cv::Point( matchLoc.x + templ.cols , matchLoc.y + templ.rows ), Scalar::all(0), 2, 8, 0 );
    rectangle( result, matchLoc, cv::Point( matchLoc.x + templ.cols , matchLoc.y + templ.rows ), Scalar::all(0), 2, 8, 0 );
    
    UIImageView *imageView;
           imageView = [self createImageViewInRect:CGRectMake(150, 100, 150, 150)];
           [self.view addSubview:imageView];
           imageView.image  = [self UIImageFromCVMat:img_display];
    
    imageView = [self createImageViewInRect:CGRectMake(150, 250, 150, 150)];
          [self.view addSubview:imageView];
          imageView.image  = [self UIImageFromCVMat:result];
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

## 代码说明

执行模板匹配操作:
```
matchTemplate( img, templ, result, match_method );
```

很自然地,参数是输入图像 I, 模板图像 T, 结果图像 R 还有匹配方法 (通过滑动条给出)

## 结果

![](https://upload-images.jianshu.io/upload_images/1682758-82933ea79b736af6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


下面是其他博客测试结果展示

![](https://upload-images.jianshu.io/upload_images/1682758-d2f54405ca0cc45a.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![](https://upload-images.jianshu.io/upload_images/1682758-64ef08f3113f8a05.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1682758-7fafde8c7381b312.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1682758-c036553db6fdb20b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![](https://upload-images.jianshu.io/upload_images/1682758-a7d45788725071bb.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![](https://upload-images.jianshu.io/upload_images/1682758-d3c8cdc5e9fb5546.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

 



----

[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-emplate_matching)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/histograms/template_matching/template_matching.html#template-matching)

