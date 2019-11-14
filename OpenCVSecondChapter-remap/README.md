#  OpenCV 之ios  Remapping 重映射
## 目标
本教程向你展示如何使用OpenCV函数 [remap](http://opencv.willowgarage.com/documentation/cpp/imgproc_geometric_image_transformations.html?#remap) 来实现简单重映射.

## 理论
### 重映射是什么意思?
+ 把一个图像中一个位置的像素放置到另一个图片指定位置的过程.
+ 为了完成映射过程, 有必要获得一些插值为非整数像素坐标,因为源图像与目标图像的像素坐标不是一一对应的.
+ 我们通过重映射来表达每个像素的位置(x,y)

![](https://upload-images.jianshu.io/upload_images/1682758-423ec6787d46411c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这里g()是目标图像,f()是源图像,h(x,y)是作用于(x,y)的映射方法函数.
+ 让我们来思考一个快速的例子. 想象一下我们有一个图像 I 我们想满足下面的条件作重映射:
![](https://upload-images.jianshu.io/upload_images/1682758-5c70f139b292e3cf.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
会发生什么? 图像会按照x轴方向发生翻转. 例如, 源图像如下:
![](https://upload-images.jianshu.io/upload_images/1682758-598b73b29d107c2f.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
看到红色圈关于 x 的位置改变(x轴水平翻转):

![](https://upload-images.jianshu.io/upload_images/1682758-253fe4239f9b854b.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

*   通过 OpenCV 的函数 [remap](http://opencv.willowgarage.com/documentation/cpp/imgproc_geometric_image_transformations.html?#remap) 提供一个简单的重映射实现.

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
#import "RemapViewController.h"

@interface RemapViewController ()

@end

@implementation RemapViewController

Mat src, dst;
Mat map_x, map_y;
 int ind = 0;
- (void)viewDidLoad {
    [super viewDidLoad];

    UIImage * src1Image = [UIImage imageNamed:@"dog.jpg"];
     src  = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];
    dst.create( src.size(), src.type() );
    map_x.create( src.size(), CV_32FC1 );
    map_y.create( src.size(), CV_32FC1 );
    
    [self createTimer:1 exeBlock:^{
        [self update_map];
        remap( src, dst, map_x, map_y, CV_INTER_LINEAR, BORDER_CONSTANT, Scalar(0,0, 0) );
        UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:dst];
    }];
}
-(void)update_map{
    ind = ind%4;

      for( int j = 0; j < src.rows; j++ )
      { for( int i = 0; i < src.cols; i++ )
          {
            switch( ind )
            {
              case 0:
                if( i > src.cols*0.25 && i < src.cols*0.75 && j > src.rows*0.25 && j < src.rows*0.75 )
                  {
                    map_x.at<float>(j,i) = 2*( i - src.cols*0.25 ) + 0.5 ;
                    map_y.at<float>(j,i) = 2*( j - src.rows*0.25 ) + 0.5 ;
                   }
                else
                  { map_x.at<float>(j,i) = 0 ;
                    map_y.at<float>(j,i) = 0 ;
                  }
                    break;
              case 1:
                    map_x.at<float>(j,i) = i ;
                    map_y.at<float>(j,i) = src.rows - j ;
                    break;
              case 2:
                    map_x.at<float>(j,i) = src.cols - I ;
                    map_y.at<float>(j,i) = j ;
                    break;
              case 3:
                    map_x.at<float>(j,i) = src.cols - I ;
                    map_y.at<float>(j,i) = src.rows - j ;
                    break;
            } // end of switch
          }
       }
     ind++;
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
## 说明
+ 1.首先准备程序用到的变量:
```
Mat src, dst;
Mat map_x, map_y;
 int ind = 0;
```

+ 2.加载一幅图像:

```
UIImage * src1Image = [UIImage imageNamed:@"dog.jpg"];
     src  = [self cvMatFromUIImage:src1Image];
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:src];
```

+ 3.创建目标图像和两个映射矩阵.( x 和 y )

```
dst.create( src.size(), src.type() );
map_x.create( src.size(), CV_32FC1 );
map_y.create( src.size(), CV_32FC1 );
```

+ 4.建立一个间隔1000毫秒的循环,每次循环执行更新映射矩阵参数并对源图像进行重映射处理(使用 mat_x 和 mat_y),然后把更新后的目标图像显示出来:

```
 [self createTimer:1 exeBlock:^{
        [self update_map];
        remap( src, dst, map_x, map_y, CV_INTER_LINEAR, BORDER_CONSTANT, Scalar(0,0, 0) );
        UIImageView *imageView;
        imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:dst];
    }];
```
上面用到的重映射函数 [remap](http://opencv.willowgarage.com/documentation/cpp/imgproc_geometric_image_transformations.html?#remap). 参数说明:
*   **src**: 源图像
*   **dst**: 目标图像，与 *src* 相同大小
*   **map_x**: x方向的映射参数. 它相当于方法h(i,j)的第一个参数
*   **map_y**: y方向的映射参数. 注意 *map_y* 和 *map_x* 与 *src* 的大小一致。
*   **CV_INTER_LINEAR**: 非整数像素坐标插值标志. 这里给出的是默认值(双线性插值).
*   **BORDER_CONSTANT**: 默认

如何更新重映射矩阵 mat_x 和 mat_y? 请继续看:

+ `5.更新重映射矩阵: 我们将分别使用4种不同的映射:`
 > 图像宽高缩小一半，并显示在中间:
 > ![](https://upload-images.jianshu.io/upload_images/1682758-45ee03fcc62e9f46.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
 > 所有成对的参数(i,j)处理后都符合
 > ![](https://upload-images.jianshu.io/upload_images/1682758-07ff2d8db03d7c1a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
 >   ![](https://upload-images.jianshu.io/upload_images/1682758-dd8441d1782add12.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> 图像上下颠倒
> ![](https://upload-images.jianshu.io/upload_images/1682758-0dd0264ae76de0dd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> 图像左右颠倒
> ![](https://upload-images.jianshu.io/upload_images/1682758-274394dcf278927e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> 同时执行b和c的操作:
> ![](https://upload-images.jianshu.io/upload_images/1682758-ce1b6ac5d9cd40f4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

## 结果

![QQ20191114-192717.gif](https://upload-images.jianshu.io/upload_images/1682758-15c28e37e7e3a2fb.gif?imageMogr2/auto-orient/strip)

-----

[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVSecondChapter-remap)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/imgproc/imgtrans/remap/remap.html)