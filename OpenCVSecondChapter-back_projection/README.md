# OpenCV 之ios 反向投影

## 目标
本文档尝试解答如下问题:

*   什么是反向投影，它可以实现什么功能？
*   如何使用OpenCV函数 [calcBackProject](http://opencv.willowgarage.com/documentation/cpp/imgproc_histograms.html?#calcBackProject) 计算反向投影？
*   如何使用OpenCV函数 [mixChannels](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?#mixChannels) 组合图像的不同通道？

## 原理
### 什么是反向投影？
+ 反向投影是一种记录给定图像中的像素点如何适应直方图模型像素分布的方式。
+ 简单的讲， 所谓反向投影就是首先计算某一特征的直方图模型，然后使用模型去寻找图像中存在的该特征。
+ 例如， 你有一个肤色直方图 ( Hue-Saturation 直方图 ),你可以用它来寻找图像中的肤色区域:

### 反向投影的工作原理?
+ 我们使用肤色直方图为例来解释反向投影的工作原理:
+ 假设你已经通过下图得到一个肤色直方图(Hue-Saturation)， 旁边的直方图就是 模型直方图 ( 代表手掌的皮肤色调).你可以通过掩码操作来抓取手掌所在区域的直方图.
+ 我们要做的就是使用 模型直方图 (代表手掌的皮肤色调) 来检测测试图像中的皮肤区域。以下是检测的步骤

>  对测试图像中的每个像素 (p(i,j)),获取色调数据并找到该色调((h<sub>i,j</sub>,s<sub>i,j</sub>))在直方图中的bin的位置。
>  查询 *模型直方图* 中对应的bin - (h<sub>i,j</sub>,s<sub>i,j</sub>)- 并读取该bin的数值。
>  将此数值储存在新的图像中(*BackProjection*)。 你也可以先归一化 *模型直方图* ,这样测试图像的输出就可以在屏幕显示了。
>  通过对测试图像中的每个像素采用以上步骤， 我们得到了下面的 BackProjection 结果图:
>  ![](https://upload-images.jianshu.io/upload_images/1682758-c0d7aa1b85855e66.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
>  使用统计学的语言, BackProjection 中储存的数值代表了测试图像中该像素属于皮肤区域的 概率 。比如以上图为例， 亮起的区域是皮肤区域的概率更大(事实确实如此),而更暗的区域则表示更低的概率(注意手掌内部和边缘的阴影影响了检测的精度)。

### 源码
   **本程序做什么?**
    *   装载图像
    *   转换原图像到 HSV 格式，再分离出 *Hue* 通道来建立直方图 (使用 OpenCV 函数 [mixChannels](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?#mixChannels))
    * 让用户输入建立直方图所需的bin的数目
>   计算同一图像的直方图 (如果bin的数目改变则更新直方图) 和反向投影图。

* 显示反向投影图和直方图。

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
#import "BackProjectionViewController.h"

@interface BackProjectionViewController ()

@end

@implementation BackProjectionViewController
Mat src; Mat hsv; Mat hue;
int bins = 25;

- (void)viewDidLoad {
    [super viewDidLoad];
    Mat src_base, hsv_base;
    Mat src_test1, hsv_test1;
    Mat src_test2, hsv_test2;
    Mat hsv_half_down;
    
    UIImage * srcImage = [UIImage imageNamed:@"handle1.jpg"];
    src  = [self cvMatFromUIImage:srcImage];
  UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:src];
    cvtColor( src, hsv, CV_BGR2HSV );
    hue.create( hsv.size(), hsv.depth());
     int ch[] = { 0, 0 };
     mixChannels( &hsv, 1, &hue, 1, ch, 1 );

    [self createSliderFrame:CGRectMake(150, 100, 150, 50) maxValue:180 minValue:2 block:^(float value) {
        bins= value;
        [self Hist_and_Backproj];
    }];
    [self Hist_and_Backproj];
}

-(void)Hist_and_Backproj{
    MatND hist;
     int histSize = MAX( bins, 2 );
     float hue_range[] = { 0, 180 };
     const float* ranges = { hue_range };

     /// 计算直方图并归一化
     calcHist( &hue, 1, 0, Mat(), hist, 1, &histSize, &ranges, true, false );
     normalize( hist, hist, 0, 255, NORM_MINMAX, -1, Mat() );

     /// 计算反向投影
     MatND backproj;
     calcBackProject( &hue, 1, 0, hist, backproj, &ranges, 1, true );
    UIImageView *imageView;
              imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
              [self.view addSubview:imageView];
              imageView.image  = [self UIImageFromCVMat:backproj];
     /// 显示反向投影

     /// 显示直方图
     int w = 400; int h = 400;
     int bin_w = cvRound( (double) w / histSize );
     Mat histImg = Mat::zeros( w, h, CV_8UC3 );

     for( int i = 0; i < bins; i ++ )
        { rectangle( histImg, cv::Point( i*bin_w, h ), cv::Point( (i+1)*bin_w, h - cvRound( hist.at<float>(i)*h/255.0 ) ), Scalar( 0, 0, 255 ), -1 );
        }
    calcBackProject( &hue, 1, 0, hist, backproj, &ranges, 1, true );
    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
            [self.view addSubview:imageView];
             imageView.image  = [self UIImageFromCVMat:histImg];
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
1. 申明图像矩阵，初始化bin数目:
```
Mat src; Mat hsv; Mat hue;
int bins = 25;

```
1. 读取输入图像并转换到HSV 格式:
```
 UIImage * srcImage = [UIImage imageNamed:@"handle1.jpg"];
    src  = [self cvMatFromUIImage:srcImage];
```
2.本教程仅仅使用Hue通道来创建1维直方图 (你可以从上面的链接下载增强版本,增强版本使用了更常见的H-S直方图，以获取更好的结果):
```
hue.create( hsv.size(), hsv.depth() );
int ch[] = { 0, 0 };
mixChannels( &hsv, 1, &hue, 1, ch, 1 );
```
你可以看到这里我们使用 [mixChannels](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?#mixChannels) 来抽取 HSV图像的0通道(Hue)。 该函数接受了以下的实参:
+ &hsv: 一系列输入图像的数组， 被拷贝的通道的来源
+ 1: 输入数组中图像的数目
+ &hue: 一系列目的图像的数组， 储存拷贝的通道
+ 1: 目的数组中图像的数目
+ ch[] = {0,0}: 通道索引对的数组，指示如何将输入图像的某一通道拷贝到目的图像的某一通道。在这里，&hsv图像的Hue(0) 通道被拷贝到&hue图像(单通道)的0 通道。
+ 1: 通道索引对德数目

+ 4. 创建滑块
```
[self createSliderFrame:CGRectMake(150, 100, 150, 50) maxValue:180 minValue:2 block:^(float value) {
        bins= value;
        [self Hist_and_Backproj];
    }];
```
5. **Hist_and_Backproj 函数:** 初始化函数 [calcHist](http://opencv.willowgarage.com/documentation/cpp/imgproc_histograms.html?#calcHist) 需要的实参，
```
void Hist_and_Backproj(int, void* )
{
  MatND hist;
  int histSize = MAX( bins, 2 );
  float hue_range[] = { 0, 180 };
  const float* ranges = { hue_range };
```

6. 计算直方图并归一化到范围[0,255]
```
calcHist( &hue, 1, 0, Mat(), hist, 1, &histSize, &ranges, true, false );
normalize( hist, hist, 0, 255, NORM_MINMAX, -1, Mat() );
```
7. 调用函数 [calcBackProject](http://opencv.willowgarage.com/documentation/cpp/imgproc_histograms.html?#calcBackProject) 计算同一张图像的反向投影
```
MatND backproj;
calcBackProject( &hue, 1, 0, hist, backproj, &ranges, 1, true );
```
8. 显示1维 Hue 直方图:
```
int w = 400; int h = 400;
int bin_w = cvRound( (double) w / histSize );
Mat histImg = Mat::zeros( w, h, CV_8UC3 );

for( int i = 0; i < bins; i ++ )
   { rectangle( histImg, Point( i*bin_w, h ), Point( (i+1)*bin_w, h - cvRound( hist.at<float>(i)*h/255.0 ) ), Scalar( 0, 0, 255 ), -1 ); }
```
## 结果
![](https://upload-images.jianshu.io/upload_images/1682758-edc647f927c53277.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

------

[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-back_projection)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/histograms/back_projection/back_projection.html)