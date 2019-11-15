# OpenCV 之ios 直方图对比

## 目标
本文档尝试解答如下问题:

*   如何使用OpenCV函数 [compareHist](http://opencv.willowgarage.com/documentation/cpp/imgproc_histograms.html?#compareHist) 产生一个表达两个直方图的相似度的数值。
*   如何使用不同的对比标准来对直方图进行比较。

## 原理
*   要比较两个直方图(H<sub>1</sub> and H<sub>2</sub>), 首先必须要选择一个衡量直方图相似度的 *对比标准* (d(H<sub>1</sub> and H<sub>2</sub>))。

*   OpenCV 函数 [compareHist](http://opencv.willowgarage.com/documentation/cpp/imgproc_histograms.html?#compareHist) 执行了具体的直方图对比的任务。该函数提供了4种对比标准来计算相似度：

> a.Correlation ( CV_COMP_CORREL )
> ![](https://upload-images.jianshu.io/upload_images/1682758-453da6178f945f7e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
> 其中
> ![](https://upload-images.jianshu.io/upload_images/1682758-1683a24a37380aef.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
> N是直方图中bin的数目。

> b. Chi-Square ( CV_COMP_CHISQR )
> ![](https://upload-images.jianshu.io/upload_images/1682758-2ccf62f34c4f9948.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

>c. Intersection ( CV_COMP_INTERSECT )
>![](https://upload-images.jianshu.io/upload_images/1682758-cf6d179f469075f6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> d.Bhattacharyya 距离( CV_COMP_BHATTACHARYYA )
> ![](https://upload-images.jianshu.io/upload_images/1682758-8144bfc28c97f4d9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 源码
本程序做什么?
+ 装载一张 基准图像 和 两张 测试图像 进行对比。
+ 产生一张取自 基准图像 下半部的图像。
+ 将图像转换到HSV格式。
+ 计算所有图像的H-S直方图，并归一化以便对比。
+ 将 基准图像 直方图与 两张测试图像直方图，基准图像半身像直方图，以及基准图像本身的直方图分别作对比。
+ 显示计算所得的直方图相似度数值。
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
#import "ZFTComparisonViewController.h"

@interface ZFTComparisonViewController ()

@end

@implementation ZFTComparisonViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    Mat src_base, hsv_base;
    Mat src_test1, hsv_test1;
    Mat src_test2, hsv_test2;
    Mat hsv_half_down;
    
    UIImage * srcImage = [UIImage imageNamed:@"handle0.jpg"];
    src_base  = [self cvMatFromUIImage:srcImage];
    UIImage * src1Image = [UIImage imageNamed:@"handle1.jpg"];
     src_test1 = [self cvMatFromUIImage:src1Image];
      UIImage * src2Image = [UIImage imageNamed:@"handle2.jpg"];
     src_test2 = [self cvMatFromUIImage:src2Image];
    
    UIImageView *imageView;
       imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
       [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:src_base];
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src_test1];
    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src_test2];
    
    /// 转换到 HSV
    cvtColor( src_base, hsv_base, CV_BGR2HSV );
    cvtColor( src_test1, hsv_test1, CV_BGR2HSV );
    cvtColor( src_test2, hsv_test2, CV_BGR2HSV );
    
    hsv_half_down = hsv_base( Range( hsv_base.rows/2, hsv_base.rows - 1 ), Range( 0, hsv_base.cols - 1 ) );
    int h_bins = 50; int s_bins = 60;
    int histSize[] = { h_bins, s_bins };

    // hue的取值范围从0到256, saturation取值范围从0到180
    float h_ranges[] = { 0, 256 };
    float s_ranges[] = { 0, 180 };

    const float* ranges[] = { h_ranges, s_ranges };

    // 使用第0和第1通道
    int channels[] = { 0, 1 };

    /// 直方图
    MatND hist_base;
    MatND hist_half_down;
    MatND hist_test1;
    MatND hist_test2;

    /// 计算HSV图像的直方图
    calcHist( &hsv_base, 1, channels, Mat(), hist_base, 2, histSize, ranges, true, false );
    normalize( hist_base, hist_base, 0, 1, NORM_MINMAX, -1, Mat() );

    calcHist( &hsv_half_down, 1, channels, Mat(), hist_half_down, 2, histSize, ranges, true, false );
    normalize( hist_half_down, hist_half_down, 0, 1, NORM_MINMAX, -1, Mat() );

    calcHist( &hsv_test1, 1, channels, Mat(), hist_test1, 2, histSize, ranges, true, false );
    normalize( hist_test1, hist_test1, 0, 1, NORM_MINMAX, -1, Mat() );

    calcHist( &hsv_test2, 1, channels, Mat(), hist_test2, 2, histSize, ranges, true, false );
    normalize( hist_test2, hist_test2, 0, 1, NORM_MINMAX, -1, Mat() );
    
   for( int i = 0; i < 4; i++ )
       { int compare_method = I;
         double base_base = compareHist( hist_base, hist_base, compare_method );
         double base_half = compareHist( hist_base, hist_half_down, compare_method );
         double base_test1 = compareHist( hist_base, hist_test1, compare_method );
         double base_test2 = compareHist( hist_base, hist_test2, compare_method );

         printf( " Method [%d] Perfect, Base-Half, Base-Test(1), Base-Test(2) : %f, %f, %f, %f \n", i, base_base, base_half , base_test1, base_test2 );
       }
   
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
1. 声明储存基准图像和另外两张对比图像的矩阵( RGB 和 HSV )
```
   Mat src_base, hsv_base;
    Mat src_test1, hsv_test1;
    Mat src_test2, hsv_test2;
    Mat hsv_half_down;
```
2. 装载基准图像(src_base) 和两张测试图像:
```
  UIImage * srcImage = [UIImage imageNamed:@"handle0.jpg"];
    src_base  = [self cvMatFromUIImage:srcImage];
    UIImage * src1Image = [UIImage imageNamed:@"handle1.jpg"];
     src_test1 = [self cvMatFromUIImage:src1Image];
      UIImage * src2Image = [UIImage imageNamed:@"handle2.jpg"];
     src_test2 = [self cvMatFromUIImage:src2Image];
    
```
3. 将图像转化到HSV格式:
```
cvtColor( src_base, hsv_base, CV_BGR2HSV );
cvtColor( src_test1, hsv_test1, CV_BGR2HSV );
cvtColor( src_test2, hsv_test2, CV_BGR2HSV );
```
4.同时创建包含基准图像下半部的半身图像(HSV格式):

```
hsv_half_down = hsv_base( Range( hsv_base.rows/2, hsv_base.rows - 1 ), Range( 0, hsv_base.cols - 1 ) );

```
5. 初始化计算直方图需要的实参(bins, 范围，通道 H 和 S ).
```
int h_bins = 50; int s_bins = 32;
int histSize[] = { h_bins, s_bins };

float h_ranges[] = { 0, 256 };
float s_ranges[] = { 0, 180 };

const float* ranges[] = { h_ranges, s_ranges };

int channels[] = { 0, 1 };
```
6. 创建储存直方图的 MatND 实例:
```
MatND hist_base;
MatND hist_half_down;
MatND hist_test1;
MatND hist_test2;
```
7. 计算基准图像，两张测试图像，半身基准图像的直方图:
```
calcHist( &hsv_base, 1, channels, Mat(), hist_base, 2, histSize, ranges, true, false );
normalize( hist_base, hist_base, 0, 1, NORM_MINMAX, -1, Mat() );

calcHist( &hsv_half_down, 1, channels, Mat(), hist_half_down, 2, histSize, ranges, true, false );
normalize( hist_half_down, hist_half_down, 0, 1, NORM_MINMAX, -1, Mat() );

calcHist( &hsv_test1, 1, channels, Mat(), hist_test1, 2, histSize, ranges, true, false );
normalize( hist_test1, hist_test1, 0, 1, NORM_MINMAX, -1, Mat() );

calcHist( &hsv_test2, 1, channels, Mat(), hist_test2, 2, histSize, ranges, true, false );
normalize( hist_test2, hist_test2, 0, 1, NORM_MINMAX, -1, Mat() );
```
8. 按顺序使用4种对比标准将基准图像(hist_base)的直方图与其余各直方图进行对比:
```
for( int i = 0; i < 4; i++ )
   { int compare_method = I;
     double base_base = compareHist( hist_base, hist_base, compare_method );
     double base_half = compareHist( hist_base, hist_half_down, compare_method );
     double base_test1 = compareHist( hist_base, hist_test1, compare_method );
     double base_test2 = compareHist( hist_base, hist_test2, compare_method );

    printf( " Method [%d] Perfect, Base-Half, Base-Test(1), Base-Test(2) : %f, %f, %f, %f \n", i, base_base, base_half , base_test1, base_test2 );
  }
```
## 结果

+ 使用下列输入图像:

![](https://upload-images.jianshu.io/upload_images/1682758-a61087e105214b30.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

第一张为基准图像，其余两张为测试图像。同时我们会将基准图像与它自身及其半身图像进行对比。

+ 我们应该会预料到当将基准图像直方图及其自身进行对比时会产生完美的匹配， 当与来源于同一样的背景环境的半身图对比时应该会有比较高的相似度， 当与来自不同亮度光照条件的其余两张测试图像对比时匹配度应该不是很好:
+ 下面显示的是结果数值:
```
 Method [0] Perfect, Base-Half, Base-Test(1), Base-Test(2) : 1.000000, 0.878367, 0.169343, 0.057082 
 Method [1] Perfect, Base-Half, Base-Test(1), Base-Test(2) : 0.000000, 5.732649, 1192.401034, 3352.254909 
 Method [2] Perfect, Base-Half, Base-Test(1), Base-Test(2) : 20.956192, 12.699314, 4.276094, 3.225612 
 Method [3] Perfect, Base-Half, Base-Test(1), Base-Test(2) : 0.000000, 0.246289, 0.675238, 0.854310 
```


对于 Correlation 和 Intersection 标准, 值越大相似度越大。因此可以看到对于采用这两个方法的对比，*基准 - 基准* 的对比结果值是最大的， 而 基准 - 半身 的匹配则是第二好(跟我们预测的一致)。而另外两种对比标准，则是结果越小相似度越大。 我们可以观察到基准图像直方图与两张测试图像直方图的匹配是最差的，这再一次印证了我们的预测。

-----


[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-histogram_comparison)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/histograms/histogram_comparison/histogram_comparison.html#histogram-comparison)