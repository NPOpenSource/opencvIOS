# OpenCV 之ios直方图计算
## 目标
本文档尝试解答如下问题:

*   如何使用OpenCV函数 [split](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?#split) 将图像分割成单通道数组。
*   如何使用OpenCV函数 [calcHist](http://opencv.willowgarage.com/documentation/cpp/imgproc_histograms.html?#calcHist) 计算图像阵列的直方图。
*   如何使用OpenCV函数 [normalize](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?#normalize) 归一化数组。

### 什么是直方图?
*   直方图是对数据的集合 *统计* ，并将统计结果分布于一系列预定义的 *bins* 中。
*   这里的 *数据* 不仅仅指的是灰度值 (如上一篇您所看到的)， 统计数据可能是任何能有效描述图像的特征。
*   先看一个例子吧。 假设有一个矩阵包含一张图像的信息 (灰度值0-255 ):

![](https://upload-images.jianshu.io/upload_images/1682758-e9f04ce7b971a5ef.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


+ 如果我们按照某种方式去 统计 这些数字，会发生什么情况呢? 既然已知数字的 范围 包含 256 个值, 我们可以将这个范围分割成子区域(称作 bins)， 如:

![](https://upload-images.jianshu.io/upload_images/1682758-d0a7248978dce5f6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
然后再统计掉入每一个bin<sub>i</sub>的像素数目。采用这一方法来统计上面的数字矩阵，我们可以得到下图( x轴表示 bin， y轴表示各个bin中的像素个数)。

![](https://upload-images.jianshu.io/upload_images/1682758-9ec5dea2ef850e12.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

*   以上只是一个说明直方图如何工作以及它的用处的简单示例。直方图可以统计的不仅仅是颜色灰度， 它可以统计任何图像特征 (如 梯度, 方向等等)。

*   让我们再来搞清楚直方图的一些具体细节:

    1.  **dims**: 需要统计的特征的数目， 在上例中， **dims = 1** 因为我们仅仅统计了灰度值(灰度图像)。
    2.  **bins**: 每个特征空间 **子区段** 的数目，在上例中, **bins = 16**
    3.  **range**: 每个特征空间的取值范围，在上例中， **range = [0,255]**
*   怎样去统计两个特征呢? 在这种情况下， 直方图就是3维的了，x轴和y轴分别代表一个特征， z轴是掉入(bin<sub>x</sub>,bin<sub>y</sub>)组合中的样本数目。 同样的方法适用于更高维的情形 (当然会变得很复杂)。

### OpenCV的直方图计算
OpenCV提供了一个简单的计算数组集(通常是图像或分割后的通道)的直方图函数 [calcHist](http://opencv.willowgarage.com/documentation/cpp/imgproc_histograms.html?#calcHist) 。 支持高达 32 维的直方图。下面的代码演示了如何使用该函数计算直方图!

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
#import "ZFTCalculationViewController.h"

@interface ZFTCalculationViewController ()

@end

@implementation ZFTCalculationViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    Mat src, dst;
    UIImage * src1Image = [UIImage imageNamed:@"env.jpg"];
     src  = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];
    /// 转为灰度图
   vector<Mat> rgb_planes;
    split( src, rgb_planes );

    /// 设定bin数目
    int histSize = 255;

    /// 设定取值范围 ( R,G,B) )
    float range[] = { 0, 255 } ;
    const float* histRange = { range };

    bool uniform = true; bool accumulate = false;

    Mat r_hist, g_hist, b_hist;

    /// 计算直方图:
    calcHist( &rgb_planes[0], 1, 0, Mat(), r_hist, 1, &histSize, &histRange, uniform, accumulate );
    calcHist( &rgb_planes[1], 1, 0, Mat(), g_hist, 1, &histSize, &histRange, uniform, accumulate );
    calcHist( &rgb_planes[2], 1, 0, Mat(), b_hist, 1, &histSize, &histRange, uniform, accumulate );

    int hist_w = 400; int hist_h = 400;
    int bin_w = cvRound( (double) hist_w/histSize );

    Mat histImage( hist_w, hist_h, CV_8UC3, Scalar( 0,0,0) );

    /// 将直方图归一化到范围 [ 0, histImage.rows ]
    normalize(r_hist, r_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
    normalize(g_hist, g_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
    normalize(b_hist, b_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );

    /// 在直方图画布上画出直方图
    for( int i = 1; i < histSize; i++ )
      {
          line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(r_hist.at<float>(i-1)) ) ,
                         cv::Point( bin_w*(i), hist_h - cvRound(r_hist.at<float>(i)) ),
                         Scalar( 0, 0, 255), 2, 8, 0  );
        line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(g_hist.at<float>(i-1)) ) ,
                         cv::Point( bin_w*(i), hist_h - cvRound(g_hist.at<float>(i)) ),
                         Scalar( 0, 255, 0), 2, 8, 0  );
        line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(b_hist.at<float>(i-1)) ) ,
                             cv::Point( bin_w*(i), hist_h - cvRound(b_hist.at<float>(i)) ),
                             Scalar( 255, 0, 0), 2, 8, 0  );
       }

    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
       [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:histImage];
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
1. 创建一些矩阵:
```
Mat src, dst;
```
2. 装载原图像
```
UIImage * src1Image = [UIImage imageNamed:@"env.jpg"];
     src  = [self cvMatFromUIImage:src1Image];
```
3. 使用OpenCV函数 [split](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?#split) 将图像分割成3个单通道图像:
```
 vector<Mat> rgb_planes;
    split( src, rgb_planes );
```
输入的是要被分割的图像 (这里包含3个通道)， 输出的则是Mat类型的的向量。

4. 现在对每个通道配置 **直方图** 设置， 既然我们用到了 R, G 和 B 通道， 我们知道像素值的范围是[0,255]
+ a.设定bins数目 (5, 10...):
```
int histSize = 255;
```
+ b.设定像素值范围 (前面已经提到,在 0 到 255之间 )
```
/// 设定取值范围 ( R,G,B) )
float range[] = { 0, 255 } ;
const float* histRange = { range };
```
+ c.我们要把bin范围设定成同样大小(均一)以及开始统计前先清除直方图中的痕迹:(我也不知道为啥)
```
bool uniform = true; bool accumulate = false;
```
+ d.最后创建储存直方图的矩阵:
```
Mat r_hist, g_hist, b_hist;
```
+ e.下面使用OpenCV函数 [calcHist](http://opencv.willowgarage.com/documentation/cpp/imgproc_histograms.html?#calcHist) 计算直方图:
```
// 计算直方图:
calcHist( &rgb_planes[0], 1, 0, Mat(), r_hist, 1, &histSize, &histRange, uniform, accumulate );
calcHist( &rgb_planes[1], 1, 0, Mat(), g_hist, 1, &histSize, &histRange, uniform, accumulate );
calcHist( &rgb_planes[2], 1, 0, Mat(), b_hist, 1, &histSize, &histRange, uniform, accumulate );
```

参数说明如下:

> &rgb_planes[0]: 输入数组(或数组集)
> 1: 输入数组的个数 (这里我们使用了一个单通道图像，我们也可以输入数组集 )
> 0: 需要统计的通道 (dim)索引 ，这里我们只是统计了灰度 (且每个数组都是单通道)所以只要写 0 就行了。
> Mat(): 掩码( 0 表示忽略该像素)， 如果未定义，则不使用掩码
> r_hist: 储存直方图的矩阵
> 1: 直方图维数
> histSize: 每个维度的bin数目
> histRange: 每个维度的取值范围
> uniform 和 accumulate: bin大小相同，清楚直方图痕迹

5. 创建显示直方图的画布:
```
// 创建直方图画布
int hist_w = 400; int hist_h = 400;
int bin_w = cvRound( (double) hist_w/histSize );

Mat histImage( hist_w, hist_h, CV_8UC3, Scalar( 0,0,0) );
```
6. 在画直方图之前，先使用 [normalize](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?#normalize) 归一化直方图，这样直方图bin中的值就被缩放到指定范围:
```
/// 将直方图归一化到范围 [ 0, histImage.rows ]
normalize(r_hist, r_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
normalize(g_hist, g_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
normalize(b_hist, b_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
```
该函数接受下列参数:

> r_hist: 输入数组
> r_hist: 归一化后的输出数组(支持原地计算)
> 0 及 histImage.rows: 这里，它们是归一化 r_hist 之后的取值极限
> NORM_MINMAX: 归一化方法 (例中指定的方法将数值缩放到以上指定范围)
> -1: 指示归一化后的输出数组与输入数组同类型
> Mat(): 可选的掩码
7. 请注意这里如何读取直方图bin中的数据 (此处是一个1维直方图):
```
   {
          line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(r_hist.at<float>(i-1)) ) ,
                         cv::Point( bin_w*(i), hist_h - cvRound(r_hist.at<float>(i)) ),
                         Scalar( 0, 0, 255), 2, 8, 0  );
        line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(g_hist.at<float>(i-1)) ) ,
                         cv::Point( bin_w*(i), hist_h - cvRound(g_hist.at<float>(i)) ),
                         Scalar( 0, 255, 0), 2, 8, 0  );
        line( histImage, cv::Point( bin_w*(i-1), hist_h - cvRound(b_hist.at<float>(i-1)) ) ,
                             cv::Point( bin_w*(i), hist_h - cvRound(b_hist.at<float>(i)) ),
                             Scalar( 255, 0, 0), 2, 8, 0  );
       }
```


## 结果
![](https://upload-images.jianshu.io/upload_images/1682758-d96b67c28f0ca220.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

----
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-histogram_calculation)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/histograms/histogram_calculation/histogram_calculation.html)