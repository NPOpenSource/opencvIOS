# OpenCV 之ios 腐蚀与膨胀

## 目标
本文档尝试解答如下问题:

*   如何使用OpenCV提供的两种最基本的形态学操作,腐蚀与膨胀( Erosion 与 Dilation):
    *   [erode](http://opencv.jp/opencv-2.2_org/cpp/imgproc_image_filtering.html#cv-erode)
    *   [dilate](http://opencv.jp/opencv-2.2_org/cpp/imgproc_image_filtering.html#cv-dilate)

## 原理
### 形态学操作
简单来讲，`形态学操作就是基于形状的一系列图像处理操作`。通过将 `结构元素` 作用于`输入图像`来产生`输出图像`。

最基本的形态学操作有二：腐蚀与膨胀(Erosion 与 Dilation)。 他们的运用广泛:

+ 消除噪声
+ 分割(isolate)独立的图像元素，以及连接(join)相邻的元素。
+ 寻找图像中的明显的极大值区域或极小值区域。

 通过以下图像，我们简要来讨论一下膨胀与腐蚀操作(译者注：注意这张图像中的字母为黑色，背景为白色，而不是一般意义的背景为黑色，前景为白色）:
![](https://upload-images.jianshu.io/upload_images/1682758-44e67395d824194d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 膨胀

* 此操作将图像A 与任意形状的内核 (B)，通常为正方形或圆形,进行卷积。
* 内核 B  有一个可定义的 *锚点*, 通常定义为内核中心点。
*   进行膨胀操作时，将内核B 划过图像,将内核B覆盖区域的最大相素值提取，并代替锚点位置的相素。显然，这一最大化操作将会导致图像中的亮区开始”扩展” (因此有了术语膨胀 *dilation* )。对上图采用膨胀操作我们得到:
![](https://upload-images.jianshu.io/upload_images/1682758-99d4d4910aa544c4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> 放大白色区域,缩小黑色区域

### 腐蚀
*   腐蚀在形态学操作家族里是膨胀操作的孪生姐妹。它提取的是内核覆盖下的相素最小值。

*   进行腐蚀操作时，将内核 B 划过图像,将内核B覆盖区域的最小相素值提取，并代替锚点位置的相素。

*   以与膨胀相同的图像作为样本,我们使用腐蚀操作。从下面的结果图我们看到亮区(背景)变细，而黑色区域(字母)则变大了。
![](https://upload-images.jianshu.io/upload_images/1682758-e0e4cbd9190959ce.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> > 缩小白色区域,放大黑色区域

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
#import "ErodeAndDilateViewController.h"

@implementation ErodeAndDilateViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    UIImage * src1Image = [UIImage imageNamed:@"cat.jpg"];
      Mat src1 = [self cvMatFromUIImage:src1Image];
      UIImageView *imageView;
      imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:src1];
    
   __block int erosion_elem = 0;

   __block int dilation_elem = 0;
    int const max_kernel_size = 21;

    ///膨胀
    [self createSliderFrame:CGRectMake(150, 100, 100, 50) maxValue:max_kernel_size minValue:0 block:^(float value) {
        int erosion_type ;
        if( erosion_elem == 0 ){ erosion_type = MORPH_RECT; }
         else if( erosion_elem == 1 ){ erosion_type = MORPH_CROSS; }
         else  { erosion_type = MORPH_ELLIPSE; }

        int erosion_size = value;
        Mat erosion_dst;
        Mat element = getStructuringElement( erosion_type,
                                              cv::Size( 2*erosion_size + 1, 2*erosion_size+1 ),
                                              cv::Point( erosion_size, erosion_size ) );
        erode( src1, erosion_dst, element );
        
        UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:erosion_dst];
        
    }];
   
    [self createButtonFrame:CGRectMake(250, 100, 100, 50) title:@"Rect" Block:^NSString * _Nonnull(int hitCount) {
        erosion_elem = hitCount%3;
        if (erosion_elem==0) {
            return @"Rect";
        }else if (erosion_elem==1){
            return @"CROSS";
        }else{
            return @"ELLIPSE";
        }
    }];
    
    
    [self createSliderFrame:CGRectMake(150, 150, 100, 50) maxValue:max_kernel_size minValue:0 block:^(float value) {
        int dilation_type;
        if( dilation_elem == 0 ){ dilation_type = MORPH_RECT; }
         else if( dilation_elem == 1 ){ dilation_type = MORPH_CROSS; }
         else{ dilation_type = MORPH_ELLIPSE; }
          int dilation_size = value;
        Mat dilation_dst;
        Mat element = getStructuringElement( dilation_type,
                                             cv::Size( 2*dilation_size + 1, 2*dilation_size+1 ),
                                             cv::Point( dilation_size, dilation_size ) );
       
        dilate( src1, dilation_dst, element );
        
        UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:dilation_dst];

      }];
    [self createButtonFrame:CGRectMake(250, 150, 100, 50) title:@"Rect" Block:^NSString * _Nonnull(int hitCount) {
        dilation_elem  = hitCount%3;
             if (dilation_elem==0) {
                 return @"Rect";
             }else if (dilation_elem==1){
                 return @"CROSS;";
             }else{
                 return @"ELLIPSE";
             }
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
### Erosion
```
int erosion_type ;
        if( erosion_elem == 0 ){ erosion_type = MORPH_RECT; }
         else if( erosion_elem == 1 ){ erosion_type = MORPH_CROSS; }
         else  { erosion_type = MORPH_ELLIPSE; }

        int erosion_size = value;
        Mat erosion_dst;
        Mat element = getStructuringElement( erosion_type,
                                              cv::Size( 2*erosion_size + 1, 2*erosion_size+1 ),
                                              cv::Point( erosion_size, erosion_size ) );
        erode( src1, erosion_dst, element );
        
        UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:erosion_dst];
```

进行 *腐蚀* 操作的函数是 [erode](http://opencv.jp/opencv-2.2_org/cpp/imgproc_image_filtering.html#cv-erode) 。 它接受了三个参数:
*   *src*: 原图像
*   *erosion_dst*: 输出图像
*   *element*: 腐蚀操作的内核。 如果不指定，默认为一个简单的 3x3 矩阵。否则，我们就要明确指定它的形状，可以使用函数 [getStructuringElement](http://opencv.jp/opencv-2.2_org/cpp/imgproc_image_filtering.html#cv-getstructuringelement):
```
Mat element = getStructuringElement( erosion_type,
                                     Size( 2*erosion_size + 1, 2*erosion_size+1 ),
                                     Point( erosion_size, erosion_size ) );
```
我们可以为我们的内核选择三种形状之一:
```
矩形: MORPH_RECT
交叉形: MORPH_CROSS
椭圆形: MORPH_ELLIPSE
```
然后，我们还需要指定内核大小，以及 锚点 位置。不指定锚点位置，则默认锚点在内核中心位置。

就这些了，我们现在可以对图像进行腐蚀操作了。

### Dilation
膨胀和腐蚀是差不多的操作的.这里就不过于解释了

## 结果
最终结果如图所示

![](https://upload-images.jianshu.io/upload_images/1682758-9eba583ffca09d8c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 内核形状
其实看到这个内核形状,我是一脸懵逼.当时记得还查了不少资料,也没看懂大家到底说的是啥.其实最直管的表现是把核形状打印出来看看不就行了 
我们都以核大小7做参考
### 矩形内核
```
[  1,   1,   1,   1,   1,   1,   1;
   1,   1,   1,   1,   1,   1,   1;
   1,   1,   1,   1,   1,   1,   1;
   1,   1,   1,   1,   1,   1,   1;
   1,   1,   1,   1,   1,   1,   1;
   1,   1,   1,   1,   1,   1,   1;
   1,   1,   1,   1,   1,   1,   1]

```
### 交叉形
```
[  0,   0,   0,   1,   0,   0,   0;
   0,   0,   0,   1,   0,   0,   0;
   0,   0,   0,   1,   0,   0,   0;
   1,   1,   1,   1,   1,   1,   1;
   0,   0,   0,   1,   0,   0,   0;
   0,   0,   0,   1,   0,   0,   0;
   0,   0,   0,   1,   0,   0,   0]

```
### 椭圆形
```
[  0,   0,   0,   1,   0,   0,   0;
   0,   1,   1,   1,   1,   1,   0;
   1,   1,   1,   1,   1,   1,   1;
   1,   1,   1,   1,   1,   1,   1;
   1,   1,   1,   1,   1,   1,   1;
   0,   1,   1,   1,   1,   1,   0;
   0,   0,   0,   1,   0,   0,   0]
```

-----
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-erodeAndDilate)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/erosion_dilatation/erosion_dilatation.html#eroding-and-dilating)

