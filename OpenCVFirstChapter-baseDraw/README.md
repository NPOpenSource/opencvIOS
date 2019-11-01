# 1.目的
# 2.OpenCV 原理
### 2.1 Point
### 2.2 Scalar
# 3.代码
# 4 结果展示
# 5.代码分析
### 5.1 如何绘制线
### 5.2 椭圆绘制
### 5.3 绘制圆
### 5.4 多边形绘制
### 5.5 rectangle
----

# 1.目的
本节你将学到:
*   如何用  [Point](http://opencv.willowgarage.com/documentation/cpp/basic_structures.html?#point) 在图像中定义 2D 点
*   如何以及为何使用  [Scalar](http://opencv.willowgarage.com/documentation/cpp/core_basic_structures.html?#scalar)
*   用OpenCV的函数 [line](http://opencv.willowgarage.com/documentation/cpp/core_drawing_functions.html?#cv-line) 绘 **直线**
*   用OpenCV的函数 [ellipse](http://opencv.willowgarage.com/documentation/cpp/core_drawing_functions.html?#cv-ellipse) 绘 **椭圆**
*   用OpenCV的函数 [rectangle](http://opencv.willowgarage.com/documentation/cpp/core_drawing_functions.html?#cv-rectangle) 绘 **矩形**
*   用OpenCV的函数 [circle](http://opencv.willowgarage.com/documentation/cpp/core_drawing_functions.html?#cv-circle) 绘 **圆**
*   用OpenCV的函数 [fillPoly](http://opencv.willowgarage.com/documentation/cpp/core_drawing_functions.html?#cv-fillpoly) 绘 **填充的多边形**

# 2.OpenCV 原理
本节中，我门将大量使用 [Point](http://opencv.willowgarage.com/documentation/cpp/basic_structures.html?#point) 和 [Scalar](http://opencv.willowgarage.com/documentation/cpp/core_basic_structures.html?#scalar) 这两个结构：

# 2.1 Point
次数据结构表示了由其图像坐标 x和y 指定的2D点。可定义为：
```
Point pt;
pt.x = 10;
pt.y = 8;
```
或者
```
Point pt =  Point(10, 8);
```
> 注意
> 因为ios平台已经对Point 游过定义, 因此 上述写法会报错,,需要进行加上命令空间进行使用

```
 cv::Point pt;
    pt.x = 10;
    pt.y = 8;
   
    cv::Point pt1 =  cv::Point(10, 8);
```
### 2.2 Scalar
 表示了具有4个元素的数组。次类型在OpenCV中被大量用于传递像素值。

 本节中，我们将进一步用它来表示RGB颜色值（三个参数）。`如果用不到第四个参数，则无需定义`。

我们来看个例子，如果给出以下颜色参数表达式：
```
Scalar( a, b, c )
```
那么定义的RGB颜色值为： Red = c, Green = b and Blue = a

# 3.代码
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
#import "DrawViewController.h"

@interface DrawViewController ()

@end

@implementation DrawViewController
 static int w = 300;
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
    [self createDuGun];
}

void MyEllipse(cv::Mat img, double angle )
{
  int thickness = 2;
  int lineType = 8;
  ellipse( img,
          cv::Point(w/2.0, w/2.0 ),
           cv::Size( w/4.0, w/16.0 ),
           angle,
           0,
           360,
           Scalar( 255, 0, 0 ),
           thickness,
           lineType );
}

void MyFilledCircle( Mat img, cv::Point center )
{
 int thickness = -1;
 int lineType = 8;

 circle( img,
         center,
         w/32.0,
         Scalar( 0, 0, 255 ),
         thickness,
         lineType );
}

void MyPolygon( Mat img )
{
  int lineType = 8;

  /** 创建一些点 */
  cv::Point rook_points[1][20];
    rook_points[0][0] = cv::Point( w/4.0, 7*w/8.0 );
  rook_points[0][1] = cv::Point( 3*w/4.0, 7*w/8.0 );
  rook_points[0][2] = cv::Point( 3*w/4.0, 13*w/16.0 );
  rook_points[0][3] = cv::Point( 11*w/16.0, 13*w/16.0 );
  rook_points[0][4] = cv::Point( 19*w/32.0, 3*w/8.0 );
  rook_points[0][5] = cv::Point( 3*w/4.0, 3*w/8.0 );
  rook_points[0][6] = cv::Point( 3*w/4.0, w/8.0 );
  rook_points[0][7] = cv::Point( 26*w/40.0, w/8.0 );
  rook_points[0][8] = cv::Point( 26*w/40.0, w/4.0 );
  rook_points[0][9] = cv::Point( 22*w/40.0, w/4.0 );
  rook_points[0][10] = cv::Point( 22*w/40.0, w/8.0 );
  rook_points[0][11] = cv::Point( 18*w/40.0, w/8.0 );
  rook_points[0][12] = cv::Point( 18*w/40.0, w/4.0 );
  rook_points[0][13] = cv::Point( 14*w/40.0, w/4.0 );
  rook_points[0][14] = cv::Point( 14*w/40.0, w/8.0 );
  rook_points[0][15] = cv::Point( w/4.0, w/8.0 );
  rook_points[0][16] = cv::Point( w/4.0, 3*w/8.0 );
  rook_points[0][17] = cv::Point( 13*w/32.0, 3*w/8.0 );
  rook_points[0][18] = cv::Point( 5*w/16.0, 13*w/16.0 );
  rook_points[0][19] = cv::Point( w/4.0, 13*w/16.0) ;

  const cv::Point* ppt[1] = { rook_points[0] };
  int npt[] = { 20 };

  fillPoly( img,
            ppt,
            npt,
            1,
            Scalar( 255, 255, 255 ),
            lineType );
 }

void MyLine( Mat img, cv::Point start, cv::Point end )
{
  int thickness = 2;
  int lineType = 8;
  line( img,
        start,
        end,
        Scalar( 0, 0, 0 ),
        thickness,
        lineType );
}

-(void)createDuGun{
      Mat rook_image = Mat::zeros( w, w, CV_8UC3 );
        MyPolygon( rook_image );
    rectangle( rook_image,
              cv:: Point( 0, 7*w/8.0 ),
              cv::Point( w, w),
    Scalar( 0, 255, 255 ),
    -1,
    8 );
    MyLine( rook_image, cv::Point( 0, 15*w/16 ), cv::Point( w, 15*w/16 ) );
    MyLine( rook_image, cv::Point( w/4, 7*w/8 ), cv::Point( w/4, w ) );
    MyLine( rook_image, cv::Point( w/2, 7*w/8 ), cv::Point( w/2, w ) );
    MyLine( rook_image, cv::Point( 3*w/4, 7*w/8 ), cv::Point( 3*w/4, w ) );
    UIImageView *imageView;
       imageView = [self createImageViewInRect:CGRectMake(0, 200, 150, 150)];
       [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:rook_image];
}

-(void)createUI{
  
    Mat atom_image = Mat::zeros( w, w, CV_8UC3 );
    
    MyEllipse( atom_image, 90 );
    MyEllipse( atom_image, 0 );
    MyEllipse( atom_image, 45 );
    MyEllipse( atom_image, -45 );

    MyFilledCircle( atom_image, cv::Point( w/2.0, w/2.0) );

    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:atom_image];
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
# 4 结果展示
![](https://upload-images.jianshu.io/upload_images/1682758-7aa2703680fb764b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


# 5.代码分析

### 5.1 如何绘制线
```
void MyLine( Mat img, cv::Point start, cv::Point end )
{
  int thickness = 2;
  int lineType = 8;
  line( img,
        start,
        end,
        Scalar( 0, 0, 0 ),
        thickness,
        lineType );
}
```
+ 画一条从点 start 到点 end 的直线段
+ 此线段将被画到图像 img 上
+ 线的颜色由 Scalar( 0, 0, 0) 来定义，在此其相应RGB值为 黑色
+ 线的粗细由 thickness 设定(此处设为 2)
+ 此线为8联通 (lineType = 8)

### 5.2 椭圆绘制
```
void MyEllipse(cv::Mat img, double angle )
{
  int thickness = 2;
  int lineType = 8;
  ellipse( img,
          cv::Point(w/2.0, w/2.0 ),
           cv::Size( w/4.0, w/16.0 ),
           angle,
           0,
           360,
           Scalar( 255, 0, 0 ),
           thickness,
           lineType );
}
```
+ 椭圆将被画到图像 img 上
+ 椭圆中心为点 (w/2.0, w/2.0) 并且大小位于矩形 (w/4.0, w/16.0) 内
+ 椭圆旋转角度为 angle
+ 椭圆扩展的弧度从 0 度到 360 度
+ 图形颜色为 Scalar( 255, 255, 0) ，既蓝色
+ 绘椭圆的线粗为 thickness ，此处是2

### 5.3 绘制圆
```
void MyFilledCircle( Mat img, cv::Point center )
{
 int thickness = -1;
 int lineType = 8;

 circle( img,
         center,
         w/32.0,
         Scalar( 0, 0, 255 ),
         thickness,
         lineType );
}
```
+ 圆将被画到图像 ( img )上
+ 圆心由点 center 定义
+ 圆的半径为: w/32.0
+ 圆的颜色为: Scalar(0, 0, 255) ，按BGR的格式为 红色
+ `线粗定义为 thickness = -1, 因此次圆将被填充`

### 5.4 多边形绘制
```

void MyPolygon( Mat img )
{
  int lineType = 8;

  /** 创建一些点 */
  cv::Point rook_points[1][20];
    rook_points[0][0] = cv::Point( w/4.0, 7*w/8.0 );
  rook_points[0][1] = cv::Point( 3*w/4.0, 7*w/8.0 );
  rook_points[0][2] = cv::Point( 3*w/4.0, 13*w/16.0 );
  rook_points[0][3] = cv::Point( 11*w/16.0, 13*w/16.0 );
  rook_points[0][4] = cv::Point( 19*w/32.0, 3*w/8.0 );
  rook_points[0][5] = cv::Point( 3*w/4.0, 3*w/8.0 );
  rook_points[0][6] = cv::Point( 3*w/4.0, w/8.0 );
  rook_points[0][7] = cv::Point( 26*w/40.0, w/8.0 );
  rook_points[0][8] = cv::Point( 26*w/40.0, w/4.0 );
  rook_points[0][9] = cv::Point( 22*w/40.0, w/4.0 );
  rook_points[0][10] = cv::Point( 22*w/40.0, w/8.0 );
  rook_points[0][11] = cv::Point( 18*w/40.0, w/8.0 );
  rook_points[0][12] = cv::Point( 18*w/40.0, w/4.0 );
  rook_points[0][13] = cv::Point( 14*w/40.0, w/4.0 );
  rook_points[0][14] = cv::Point( 14*w/40.0, w/8.0 );
  rook_points[0][15] = cv::Point( w/4.0, w/8.0 );
  rook_points[0][16] = cv::Point( w/4.0, 3*w/8.0 );
  rook_points[0][17] = cv::Point( 13*w/32.0, 3*w/8.0 );
  rook_points[0][18] = cv::Point( 5*w/16.0, 13*w/16.0 );
  rook_points[0][19] = cv::Point( w/4.0, 13*w/16.0) ;

  const cv::Point* ppt[1] = { rook_points[0] };
  int npt[] = { 20 };

  fillPoly( img,
            ppt,
            npt,
            1,
            Scalar( 255, 255, 255 ),
            lineType );
 }

```
+ 多边形将被画到图像 img 上
+ 多边形的顶点集为 ppt
+ 要绘制的多边形顶点数目为 npt
+ 要绘制的多边形数量仅为 1
+ 多边形的颜色定义为 Scalar( 255, 255, 255), 既BGR值为 白色

### 5.5 rectangle
```
rectangle( rook_image,
           Point( 0, 7*w/8.0 ),
           Point( w, w),
           Scalar( 0, 255, 255 ),
           -1,
           8 );
```

+ 矩形将被画到图像 rook_image 上
+ 矩形两个对角顶点为 Point( 0, 7*w/8.0 ) 和 Point( w, w)
+ 矩形的颜色为 Scalar(0, 255, 255) ，既BGR格式下的 黄色
+ `由于线粗为 -1, 此矩形将被填充`

------
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVFirstChapter-baseDraw)
[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/core/basic_geometric_drawing/basic_geometric_drawing.html#drawing-1)