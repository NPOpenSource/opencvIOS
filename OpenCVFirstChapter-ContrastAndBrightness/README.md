# 1.目的
# 2.图像处理
### 2.1 点算子（像素变换）
##### 2.1.1 亮度和对比度调整
# 3 代码
# 4.说明
# 5.结果
---
# 1.目的
本篇教程中，你将学到：

*   访问像素值
*   用0初始化矩阵
*   [saturate_cast](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?highlight=saturate_cast#saturate_cast) 是做什么用的，以及它为什么有用
*   一些有关像素变换的精彩内容

# 2.图像处理
+ 一般来说，图像处理算子是带有一幅或多幅输入图像、产生一幅输出图像的函数。
+ 图像变换可分为以下两种：
> 点算子（像素变换）
> 邻域（基于区域的）算子

### 2.1 点算子（像素变换）
在这一类图像处理变换中，仅仅根据输入像素值（有时可加上某些全局信息或参数）计算相应的输出像素值。
`这类算子`包括`亮度和对比度调整` ，以及`颜色校正和变换`。
##### 2.1.1 亮度和对比度调整
两种常用的点过程（即点算子），是用常数对点进行 乘法 和 加法 运算：
![](https://upload-images.jianshu.io/upload_images/1682758-e9703e45e80a0933.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
   两个参数  α和 β 一般称作 `增益` 和 `偏置` 参数。我们往往用这两个参数来分别控制 `对比度` 和 `亮度` 。

你可以把f(x)看成源图像像素，把g(x)看成输出图像像素。这样一来，上面的式子就能写得更清楚些：
![](https://upload-images.jianshu.io/upload_images/1682758-7c2f28b5a86e0be6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
其中，i 和j 表示像素位于 *第i行* 和 *第j列* 。

# 3 代码
```
//
//  ContrashAndBrightnessViewController.m
//  OpenCVFirstChapter-ContrastAndBrightness
//
//  Created by glodon on 2019/11/1.
//  Copyright © 2019 persion. All rights reserved.
//
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
#import "ContrashAndBrightnessViewController.h"

@interface ContrashAndBrightnessViewController ()
@property (nonatomic ,assign) Mat  src1 ;
@end

@implementation ContrashAndBrightnessViewController
double alpha; /**< 控制对比度 */
int beta;  /**< 控制亮度 */
- (void)viewDidLoad {
  
    [super viewDidLoad];


    UIImage * image = [UIImage imageNamed:@"lena.jpg"];
    Mat src =  [self cvMatFromUIImage:image];
    cvtColor(src, _src1, COLOR_BGRA2BGR);
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:self.src1];
    
    [self createSliderFrame:CGRectMake(0, 450, 100, 40) maxValue:3 minValue:0 block:^(float value) {
         NSLog(@"[alpha]: %f",value);
        alpha = value;
        [self createContrashAndBrightness];
        [self createContrashAndBrightness1];
    }];
    [self createSliderFrame:CGRectMake(0, 550, 100, 40) maxValue:100 minValue:0 block:^(float value) {
           beta = value;
            NSLog(@"[beta]: %f",value);
            [self createContrashAndBrightness];
            [self createContrashAndBrightness1];
       }];
}

-(void)createContrashAndBrightness1{
    Mat new_image = Mat::zeros( self.src1.size(), self.src1.type() );
    self.src1.convertTo(new_image, -1, alpha, beta);
    UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(150, 250, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:new_image];
}


-(void)createContrashAndBrightness{
    Mat new_image = Mat::zeros( self.src1.size(), self.src1.type() );
     for( int y = 0; y < self.src1.rows; y++ )
     {
         for( int x = 0; x < self.src1.cols; x++ )
         {
             for( int c = 0; c < 3; c++ )
             {
                 new_image.at<Vec3b>(y,x)[c] = saturate_cast<uchar>( alpha*( self.src1.at<Vec3b>(y,x)[c] ) + beta );
             }
         }
     }
    UIImageView *imageView;
     imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
     [self.view addSubview:imageView];
     imageView.image  = [self UIImageFromCVMat:new_image];
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
+ 1.我们定义了两个全局变量
```
double alpha; /**< 控制对比度 */
int beta;  /**< 控制亮度 */
```
+ 2. 创建brg 三通道图像
```
UIImage * image = [UIImage imageNamed:@"lena.jpg"];
    Mat src =  [self cvMatFromUIImage:image];
    cvtColor(src, _src1, COLOR_BGRA2BGR);
```
+ 3.对图像运用公式进行计算
有两种方式进行计算
`第一种`
```
 Mat new_image = Mat::zeros( self.src1.size(), self.src1.type() );
     for( int y = 0; y < self.src1.rows; y++ )
     {
         for( int x = 0; x < self.src1.cols; x++ )
         {
             for( int c = 0; c < 3; c++ )
             {
                 new_image.at<Vec3b>(y,x)[c] = saturate_cast<uchar>( alpha*( self.src1.at<Vec3b>(y,x)[c] ) + beta );
             }
         }
     }
```
注意以下两点：
+ 为了访问图像的每一个像素，我们使用这一语法： image.at<Vec3b>(y,x)[c] 其中， y 是像素所在的行， x 是像素所在的列， c 是R、G、B（0、1、2）之一。
*   因为α*p(i,j)+β 的运算结果可能超出像素取值范围，还可能是非整数（如果α 是浮点数的话），所以我们要用  [saturate_cast](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?highlight=saturate_cast#saturate_cast) 对结果进行转换，以确保它为有效值。



`第二种`
直接运用公式
```
 Mat new_image = Mat::zeros( self.src1.size(), self.src1.type() );
    self.src1.convertTo(new_image, -1, alpha, beta);
```

# 5.结果
运行结果如图
![](https://upload-images.jianshu.io/upload_images/1682758-d092f4fa3507314f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

------
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVFirstChapter-ContrastAndBrightness)
[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/core/basic_linear_transform/basic_linear_transform.html#basic-linear-transform)