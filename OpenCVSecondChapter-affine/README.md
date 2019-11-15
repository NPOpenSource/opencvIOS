# OpenCV 之ios 仿射变换

## 目标
在这个教程中你将学习到如何:

1.  使用OpenCV函数 [warpAffine](http://opencv.willowgarage.com/documentation/cpp/imgproc_geometric_image_transformations.html?#cv-warpaffine) 来实现一些简单的重映射.
2.  使用OpenCV函数 [getRotationMatrix2D](http://opencv.willowgarage.com/documentation/cpp/imgproc_geometric_image_transformations.html?#cv-getrotationmatrix2d) 来获得一个2*3  旋转矩阵

## 原理
### 什么是仿射变换?
一个任意的仿射变换都能表示为 乘以一个矩阵 (线性变换) 接着再 加上一个向量 (平移).

综上所述, 我们能够用仿射变换来表示:

+ 旋转 (线性变换)
+ 平移 (向量加)
+ 缩放操作 (线性变换)

你现在可以知道, 事实上, 仿射变换代表的是两幅图之间的 关系 .

我们通常使用2*3矩阵来表示仿射变换.
![](https://upload-images.jianshu.io/upload_images/1682758-83d88337e76f920a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

考虑到我们要使用矩阵A 和B对二维向量 X=[x y]做变换, 所以也能表示为下列形式:
![](https://upload-images.jianshu.io/upload_images/1682758-ceda9085eff67b1e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

 or  ![T = M \cdot  [x, y, 1]^{T}](https://upload-images.jianshu.io/upload_images/1682758-65f3464202f534bf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![](https://upload-images.jianshu.io/upload_images/1682758-dbdae887a8216ce7.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 怎样才能求得一个仿射变换?
1. 好问题. 我们在上文有提到过仿射变换基本表示的就是两幅图片之间的 联系 . 关于这种联系的信息大致可从以下两种场景获得:

+ 我们已知X 和 T 而且我们知道他们是有联系的. 接下来我们的工作就是求出矩阵M

+  我们已知 MandX,要想求得 T . 我们只要应用算式T=M ·T即可. 对于这种联系的信息可以用矩阵M 清晰的表达 (即给出明确的2×3矩阵) 或者也可以用两幅图片点之间几何关系来表达.

2. 让我们形象地说明一下. 因为矩阵M联系着两幅图片, 我们以其表示两图中各三点直接的联系为例. 见下图:

![](https://upload-images.jianshu.io/upload_images/1682758-2ab3652d982b6445.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

点1, 2 和 3 (在图一中形成一个三角形) 与图二中三个点一一映射, 仍然形成三角形, 但形状已经大大改变. 如果我们能通过这样两组三点求出仿射变换 (你能选择自己喜欢的点), 接下来我们就能把仿射变换应用到图像中所有的点.

## 例程
```
//
//  AffineViewController.m
//  OpenCVSecondChapter-affine
//
//  Created by glodon on 2019/11/15.
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
#import "AffineViewController.h"

@interface AffineViewController ()

@end

@implementation AffineViewController

Point2f srcTri[3];
Point2f dstTri[3];
- (void)viewDidLoad {
    [super viewDidLoad];
    Mat rot_mat( 2, 3, CV_32FC1 );
      Mat warp_mat( 2, 3, CV_32FC1 );
      Mat src, warp_dst, warp_rotate_dst;
    
    UIImage * src1Image = [UIImage imageNamed:@"dog.jpg"];
     src  = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];
   warp_dst = Mat::zeros( src.rows, src.cols, src.type() );

      /// 设置源图像和目标图像上的三组点以计算仿射变换
      srcTri[0] = Point2f( 0,0 );
      srcTri[1] = Point2f( src.cols - 1, 0 );
      srcTri[2] = Point2f( 0, src.rows - 1 );

      dstTri[0] = Point2f( src.cols*0.0, src.rows*0.33 );
      dstTri[1] = Point2f( src.cols*0.85, src.rows*0.25 );
      dstTri[2] = Point2f( src.cols*0.15, src.rows*0.7 );

    warp_mat = getAffineTransform( srcTri, dstTri );

    /// 对源图像应用上面求得的仿射变换
    warpAffine( src, warp_dst, warp_mat, warp_dst.size() );
    cv::Point center = cv::Point( warp_dst.cols/2, warp_dst.rows/2 );
    double angle = -50.0;
    double scale = 0.6;

    /// 通过上面的旋转细节信息求得旋转矩阵
    rot_mat = getRotationMatrix2D( center, angle, scale );

    /// 旋转已扭曲图像
    warpAffine( warp_dst, warp_rotate_dst, rot_mat, warp_dst.size() );
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:warp_dst];
    
    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
     [self.view addSubview:imageView];
     imageView.image  = [self UIImageFromCVMat:warp_rotate_dst];
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
1. 定义一些需要用到的变量, 比如需要用来储存中间和目标图像的Mat和两个需要用来定义仿射变换的二维点数组.
```
Point2f srcTri[3];
Point2f dstTri[3];

Mat rot_mat( 2, 3, CV_32FC1 );
Mat warp_mat( 2, 3, CV_32FC1 );
Mat src, warp_dst, warp_rotate_dst;
```
2. 加载源图像:

```
 UIImage * src1Image = [UIImage imageNamed:@"dog.jpg"];
     src  = [self cvMatFromUIImage:src1Image];
```

3. 以与源图像同样的类型和大小来对目标图像初始化:
```
warp_dst = Mat::zeros( src.rows, src.cols, src.type() );

```
4. 仿射变换: 正如上文所说, 我们需要源图像和目标图像上分别一一映射的三个点来定义仿射变换:
```
srcTri[0] = Point2f( 0,0 );
srcTri[1] = Point2f( src.cols - 1, 0 );
srcTri[2] = Point2f( 0, src.rows - 1 );

dstTri[0] = Point2f( src.cols*0.0, src.rows*0.33 );
dstTri[1] = Point2f( src.cols*0.85, src.rows*0.25 );
dstTri[2] = Point2f( src.cols*0.15, src.rows*0.7 );
```

你可能想把这些点绘出来以获得对变换的更直观感受. 他们的位置大概就是在上面图例中的点的位置 (原理部分). 你会注意到由三点定义的三角形的大小和方向改变了.

5. 通过这两组点, 我们能够使用OpenCV函数 [getAffineTransform](http://opencv.willowgarage.com/documentation/cpp/imgproc_geometric_image_transformations.html?#cv-getaffinetransform) 来求出仿射变换:

```
warp_mat = getAffineTransform( srcTri, dstTri );
```

我们获得了用以描述仿射变换的 2*3 矩阵 (在这里是 warp_mat)

6. 将刚刚求得的仿射变换应用到源图像
```
warpAffine( src, warp_dst, warp_mat, warp_dst.size() );

```

函数有以下参数:

+ src: 输入源图像
+ warp_dst: 输出图像
+ warp_mat: 仿射变换矩阵
+ warp_dst.size(): 输出图像的尺寸

这样我们就获得了变换后的图像! 我们将会把它显示出来. 在此之前, 我们还想要旋转它...

7. 旋转: 想要旋转一幅图像, 你需要两个参数:

+ 旋转图像所要围绕的中心
+ 旋转的角度. 在OpenCV中正角度是逆时针的
+ 可选择: 缩放因子
我们通过下面的代码来定义这些参数:
```
Point center = Point( warp_dst.cols/2, warp_dst.rows/2 );
double angle = -50.0;
double scale = 0.6;
```
我们利用OpenCV函数 [getRotationMatrix2D](http://opencv.willowgarage.com/documentation/cpp/imgproc_geometric_image_transformations.html?#cv-getrotationmatrix2d) 来获得旋转矩阵, 这个函数返回一个2*3 的矩阵(这里是 rot_mat)
```
rot_mat = getRotationMatrix2D( center, angle, scale );
```

##  结果
![](https://upload-images.jianshu.io/upload_images/1682758-f091c112e01fee52.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)





----


[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-affine)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/imgtrans/warp_affine/warp_affine.html)