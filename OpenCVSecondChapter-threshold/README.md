# OpenCV 之ios 基本的阈值操作
## 目标：

本节简介：

*   OpenCV中的阈值(threshold)函数： [threshold](http://opencv.willowgarage.com/documentation/cpp/miscellaneous_image_transformations.html#cv-threshold) 的运用。

## 基本理论
### 什么是阈值？
+ 最简单的图像分割的方法。
+ 应用举例：从一副图像中利用阈值分割出我们需要的物体部分（当然这里的物体可以是一部分或者整体）。`这样的图像分割方法是基于图像中物体与背景之间的灰度差异`，而且`此分割属于像素级的分割`。
+ 为了从一副图像中提取出我们需要的部分，应该用图像中的每一个像素点的灰度值与选取的阈值进行比较，并作出相应的判断。（注意：阈值的选取依赖于具体的问题。即：物体在不同的图像中有可能会有不同的灰度值。
+ 一旦找到了需要分割的物体的像素点，我们可以对这些像素点设定一些特定的值来表示。（例如：可以将该物体的像素点的灰度值设定为：‘0’（黑色）,其他的像素点的灰度值为：‘255’（白色）；当然像素点的灰度值可以任意，但最好设定的两种颜色对比度较强，方便观察结果）。
![](https://upload-images.jianshu.io/upload_images/1682758-4110068fdcbfdd4b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 阈值化的类型
*   OpenCV中提供了阈值（threshold）函数： [threshold](http://opencv.willowgarage.com/documentation/cpp/miscellaneous_image_transformations.html#cv-threshold) 。

*   这个函数有5种阈值化类型，在接下来的章节中将会具体介绍。

*   为了解释阈值分割的过程，我们来看一个简单有关像素灰度的图片，该图如下。该图中的蓝色水平线代表着具体的一个阈值。
![](https://upload-images.jianshu.io/upload_images/1682758-2c3a6f7359179593.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### 阈值类型1：二进制阈值化
 该阈值化类型如下式所示:

![](https://upload-images.jianshu.io/upload_images/1682758-ca4405c84d1130a2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

 解释：在运用该阈值类型的时候，先要选定一个特定的阈值量，比如：125，这样，新的阈值产生规则可以解释为大于125的像素点的灰度值设定为最大值(如8位灰度值最大为255)，灰度值小于125的像素点的灰度值设定为0。

![](https://upload-images.jianshu.io/upload_images/1682758-8168002219268e23.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### 阈值类型2：反二进制阈值化
该阈值类型如下式所示：

![](https://upload-images.jianshu.io/upload_images/1682758-f9d74706d22fd66c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

解释：该阈值化与二进制阈值化相似，先选定一个特定的灰度值作为阈值，不过最后的设定值相反。（在8位灰度图中，例如大于阈值的设定为0，而小于该阈值的设定为255）。

![](https://upload-images.jianshu.io/upload_images/1682758-9289815b992af526.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


##### 阈值类型3：截断阈值化

该阈值化类型如下式所示：

![](https://upload-images.jianshu.io/upload_images/1682758-a631f4bf2d44fab6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

解释：同样首先需要选定一个阈值，图像中大于该阈值的像素点被设定为该阈值，小于该阈值的保持不变。（例如：阈值选取为125，那小于125的阈值不改变，大于125的灰度值（230）的像素点就设定为该阈值）。

![](https://upload-images.jianshu.io/upload_images/1682758-edee6153bc66b95a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### 阈值类型4：阈值化为0

该阈值类型如下式所示：

![](https://upload-images.jianshu.io/upload_images/1682758-695804c4c7dbd938.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

解释：先选定一个阈值，然后对图像做如下处理：1 像素点的灰度值大于该阈值的不进行任何改变；2 像素点的灰度值小于该阈值的，其灰度值全部变为0。

*   ![](https://upload-images.jianshu.io/upload_images/1682758-5140867d8fe83d1e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

##### 阈值类型5：反阈值化为0
该阈值类型如下式所示：

![](https://upload-images.jianshu.io/upload_images/1682758-4ca106cc4ca54b1b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

解释：原理类似于0阈值，但是在对图像做处理的时候相反，即：像素点的灰度值小于该阈值的不进行任何改变，而大于该阈值的部分，其灰度值全部变为0。

![](https://upload-images.jianshu.io/upload_images/1682758-bf9dc3e929fe26d1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 代码示范
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
#import "ThresholdViewController.h"

@implementation ThresholdViewController
  Mat src_gray;

int threshold_value = 0;
int threshold_type = 3;;
int const max_value = 255;
int const max_type = 4;
int const max_BINARY_value = 255;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage * src1Image = [UIImage imageNamed:@"chicky_512.png"];
         Mat     src = [self cvMatFromUIImage:src1Image];
        UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:src];
  
    cvtColor( src, src_gray, CV_RGB2GRAY );
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src_gray];
    [self createButtonFrame:CGRectMake(150, 100, 100, 50) title:@"Binary" Block:^NSString * _Nonnull(int hitCount) {
        threshold_type = hitCount%5;
        NSString * title = @"";
        switch (threshold_type) {
            case 0:
                title = @"Binary";
                break;
                case 1:
                title = @"Binary Inverted";
                break;
                case 2:
                title = @"Truncate";
                case 3:
                title = @"To Zero";
                break;
                case 4:
                title = @"To Zero Inverted";
                break;
            default:
                break;
        }
           [self Threshold_Demo];
           return title;
       }];
    
    [self createSliderFrame:CGRectMake(150, 150, 100, 50) maxValue:255 minValue:0 block:^(float value) {
        threshold_value = value;
        [self Threshold_Demo];
    }];
}

-(void)Threshold_Demo{
    Mat dst;
         UIImageView * imageView;
    /* 0: 二进制阈值
        1: 反二进制阈值
        2: 截断阈值
        3: 0阈值
        4: 反0阈值
      */
    threshold( src_gray, dst, threshold_value, max_BINARY_value,threshold_type );
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

## 解释
这里就讲解下函数的用法
```
-(void)Threshold_Demo{
    Mat dst;
         UIImageView * imageView;
    /* 0: 二进制阈值
        1: 反二进制阈值
        2: 截断阈值
        3: 0阈值
        4: 反0阈值
      */
    threshold( src_gray, dst, threshold_value, max_BINARY_value,threshold_type );
     imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
     [self.view addSubview:imageView];
     imageView.image  = [self UIImageFromCVMat:dst];
}
```

+ src_gray: 输入的灰度图像的地址。
+ dst: 输出图像的地址。
+ threshold_value: 进行阈值操作时阈值的大小。
+ max_BINARY_value: 设定的最大灰度值（该参数运用在二进制与反二进制阈值操作中）。
+ threshold_type: 阈值的类型。从上面提到的5种中选择出的结果。

## 结果
![](https://upload-images.jianshu.io/upload_images/1682758-a283b1d5e42ac068.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

----

[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-threshold)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/threshold/threshold.html#basic-threshold)