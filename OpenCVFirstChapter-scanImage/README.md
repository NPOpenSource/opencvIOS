# 1.目的
# 2. 测试用例
# 3.图像矩阵是如何存储在内存之中的？
### 3.1.高效的方法 Efficient Way
### 3.2.迭代法 The iterator (safe) method
### 3.3. 通过相关返回值的On-the-fly地址计算
### 4.4. 核心函数LUT（The Core Function）
# 5 性能表现
---------
# 1.目的
我们将探索以下问题的答案：
+ 如何遍历图像中的每一个像素？
+ OpenCV的矩阵值是如何存储的？
+ 如何测试我们所实现算法的性能？
+ 查找表是什么？为什么要用它？

# 2. 测试用例
这里我们测试的，是一种简单的颜色缩减方法。如果矩阵元素存储的是单通道像素，使用C或C++的无符号字符类型，那么像素可有256个不同值。但若是三通道图像，这种存储格式的颜色数就太多了（确切地说，有一千六百多万种）。用如此之多的颜色可能会对我们的算法性能造成严重影响。其实有时候，仅用这些颜色的一小部分，就足以达到同样效果。

这种情况下，常用的一种方法是 `颜色空间缩减` 。其做法是：将现有颜色空间值除以某个输入值，以获得较少的颜色数。例如，颜色值0到9可取为新值0，10到19可取为10，以此类推。

uchar （无符号字符，即0到255之间取值的数）类型的值除以 int 值，结果仍是 char 。因为结果是char类型的，所以求出来小数也要向下取整。利用这一点，刚才提到在 uchar 定义域中进行的颜色缩减运算就可以表达为下列形式：

![](https://upload-images.jianshu.io/upload_images/1682758-f785b5f87ea2a805.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

看上面的图可能不直观,我们用25个方格以10做区分来做实例说明
![](https://upload-images.jianshu.io/upload_images/1682758-f413df34a42d214d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这样的话，`简单的颜色空间缩减算法`就可由下面两步组成：一、`遍历图像矩阵的每一个像素`；二、`对像素应用上述公式`。**值得注意的是，我们这里用到了除法和乘法运算，而这两种运算又特别费时**，所以，`我们应尽可能用代价较低的加、减、赋值等运算替换它们`。此外，还应注意到，上述运算的输入仅能在某个有限范围内取值，如 uchar 类型可取256个值。

由此可知，`对于较大的图像，有效的方法是预先计算所有可能的值`，然后需要这些值的时候，利用查找表直接赋值即可。查找表是一维或多维数组，存储了不同输入值所对应的输出值，其优势在于只需读取、无需计算。

上述代码实现展示如下
```
static uchar table[256];
static int divideWith;
-(void)_setTable{
    if (divideWith<=0) {
        divideWith = 10;
    }
    for (int i = 0; i < 256; ++i)
         table[i] = divideWith* (i/divideWith);
}

```

目前，OpenCV主要有三种逐像素遍历图像的方法。我们将分别用这三种方法扫描图像，并将它们所用时间输出到控制台。

既然需要将所用时间输出到控制台,那么需要计时器.

OpenCV提供了两个简便的可用于计时的函数 [getTickCount()](http://opencv.itseez.com/modules/core/doc/utility_and_system_functions_and_macros.html#gettickcount) 和 [getTickFrequency()](http://opencv.itseez.com/modules/core/doc/utility_and_system_functions_and_macros.html#gettickfrequency) 。第一个函数返回你的CPU自某个事件（如启动电脑）以来走过的时钟周期数，第二个函数返回你的CPU一秒钟所走的时钟周期数。这样，我们就能轻松地以秒为单位对某运算计时：

封装成函数如下
```
-(void)_computerBlockTime:(void(^)(void))exeBlock{
    double t = (double)getTickCount();
    exeBlock();
    t = ((double)getTickCount() - t)/getTickFrequency();
    cout << "Times passed in seconds: " << t << endl;
}
```
其实ios 中也有专有的计时工具,这里就不做介绍了

# 3.图像矩阵是如何存储在内存之中的？

在前面的博客[OpenCV 之ios Mat-基本图像容器](https://www.jianshu.com/p/56dadb90f5e2)中，你或许已了解到，图像矩阵的大小取决于我们所用的颜色模型，确切地说，取决于所用通道数。如果是灰度图像，矩阵就会像这样：
![灰度图像](https://upload-images.jianshu.io/upload_images/1682758-5bd4819a3746b36c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

而对多通道图像来说，矩阵中的列会包含多个子列，其子列个数与通道数相等。例如，RGB颜色模型的矩阵：
![对多通道图像](https://upload-images.jianshu.io/upload_images/1682758-b540e0c8c3d717b6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
注意到，子列的通道顺序是反过来的：BGR而不是RGB。很多情况下，因为内存足够大，可实现连续存储，因此，图像中的各行就能一行一行地连接起来，形成一个长行。连续存储有助于提升图像扫描速度，我们可以使用 [isContinuous()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-iscontinuous) 来去判断矩阵是否是连续存储的. 相关示例会在接下来的内容中提供。

在高效遍历图像之前我们需要获取cv::Mat一张图像.

通过下面代码转换UIImage成 cv::Mat
```
//rgbX
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
  CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
  CGFloat cols = image.size.width;
  CGFloat rows = image.size.height;
  cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
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
  return cvMat;
}
```
以上方法获取的cv::Mat 是RGBX
我们需要将RGBX转换成RGB 再使用
转换代码如下
```
  Mat sourceMat = [self cvMatFromUIImage:image];
    Mat rgbSourceMat;
    cvtColor(sourceMat, rgbSourceMat, COLOR_RGBA2BGR);
```

### 3.1.高效的方法 Efficient Way
说到性能，经典的C风格运算符[]（指针）访问要更胜一筹. 因此，我们推荐的效率最高的查找表赋值方法，还是下面的这种：
```
-(cv::Mat)ScanImageAndReduceC:(cv::Mat)I {
    CV_Assert(I.depth() != sizeof(uchar));
    int channels = I.channels();
    int nRows = I.rows * channels;
    int nCols = I.cols;
    if (I.isContinuous())
    {
        nCols *= nRows;
        nRows = 1;
    }
    int i,j;
    uchar* p;
    for( i = 0; i < nRows; ++i)
    {
        p = I.ptr<uchar>(i);
        for ( j = 0; j < nCols; ++j)
        {
            p[j] = table[p[j]];
        }
    }
    return I;
}
```
这里，我们获取了每一行开始处的指针，然后遍历至该行末尾。如果`矩阵`是以`连续方式存储`的，我们只需`请求一次指针`、然后一路遍历下去就行。`彩色图像的情况有必要加以注意：因为三个通道的原因，我们需要遍历的元素数目也是3倍。`

### 3.2.迭代法 The iterator (safe) method
在高性能法（the efficient way）中，我们可以通过遍历正确的 uchar 域并跳过行与行之间可能的空缺-你必须自己来确认是否有空缺，来实现图像扫描，`迭代法则被认为是一种以更安全的方式来实现这一功能`。在迭代法中，你所需要做的仅仅是获得图像矩阵的begin和end，然后增加迭代直至从begin到end。将*操作符添加在迭代指针前，即可访问当前指向的内容。

```
-(cv::Mat)ScanImageAndReduceIterator:(cv::Mat)I{
    CV_Assert(I.depth() != sizeof(uchar));
       const int channels = I.channels();
       switch(channels)
       {
       case 1:
           {
               MatIterator_<uchar> it, end;
               for( it = I.begin<uchar>(), end = I.end<uchar>(); it != end; ++it)
                   *it = table[*it];
               break;
           }
       case 3:
           {
               MatIterator_<Vec3b> it, end;
               for( it = I.begin<Vec3b>(), end = I.end<Vec3b>(); it != end; ++it)
               {
                   (*it)[0] = table[(*it)[0]];
                   (*it)[1] = table[(*it)[1]];
                   (*it)[2] = table[(*it)[2]];
               }
           }
       }
       
       return I;
}
```
对于彩色图像中的一行，每列中有3个uchar元素，这可以被认为是一个小的包含uchar元素的vector，在OpenCV中用 Vec3b 来命名。如果要访问第n个子列，我们只需要简单的利用[]来操作就可以。需要指出的是，OpenCV的迭代在扫描过一行中所有列后会自动跳至下一行，所以说如果在彩色图像中如果只使用一个简单的 uchar 而不是 Vec3b 迭代的话就只能获得蓝色通道(B)里的值。

### 3.3. 通过相关返回值的On-the-fly地址计算
`事实上这个方法并不推荐被用来进行图像扫描，它本来是被用于获取或更改图像中的随机元素`。它的基本用途是要确定你试图访问的元素的所在行数与列数。在前面的扫描方法中，我们观察到知道所查询的图像数据类型是很重要的。这里同样的你得手动指定好你要查找的数据类型。
```
-(cv::Mat)ScanImageAndReduceRandomAccess:(cv::Mat)I{
    CV_Assert(I.depth() != sizeof(uchar));
    const int channels = I.channels();
    switch(channels)
    {
    case 1:
        {
            for( int i = 0; i < I.rows; ++i)
                for( int j = 0; j < I.cols; ++j )
                    I.at<uchar>(i,j) = table[I.at<uchar>(i,j)];
            break;
        }
    case 3:
        {
         Mat_<Vec3b> _I = I;
            
         for( int i = 0; i < I.rows; ++i)
            for( int j = 0; j < I.cols; ++j )
               {
                   _I(i,j)[0] = table[_I(i,j)[0]];
                   _I(i,j)[1] = table[_I(i,j)[1]];
                   _I(i,j)[2] = table[_I(i,j)[2]];
            }
         I = _I;
         break;
        }
    }
    
    return I;
}
```

### 4.4. 核心函数LUT（The Core Function）
这是`最被推荐`的用于实现批量图像元素查找和更该操作图像方法。在图像处理中，对于一个给定的值，将其替换成其他的值是一个很常见的操作，OpenCV 提供里一个函数直接实现该操作，并不需要你自己扫描图像，就是:operationsOnArrays:LUT() <lut> ，一个包含于core module的函数. 首先我们建立一个mat型用于查表:
```
 lookUpTable =Mat(1,256, CV_8U);
      uchar* p = lookUpTable.data;
    for( int i = 0; i < 256; ++i)
                p[i] = table[I];

```

然后我们调用函数 (I 是输入 J 是输出):
```
 LUT(I, lookUpTable, J);
```

> `注意:`
> 这里需要说明的是输出的j需要分配好内存空间. 否则会报错

# 5 性能表现
上述方式,我使用了一个相当大的图片(1920*1080).如图
![1.jpg](https://upload-images.jianshu.io/upload_images/1682758-669954529e515334.jpeg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

 性能测试用的是上述彩色图片，结果是数百次测试的平均值.
上面测试结果如下
```
Times passed in seconds: 1.50465  //c 方式
Times passed in seconds: 6.41172  ///迭代器
Times passed in seconds: 7.55413  // on the fly
Times passed in seconds: 0.100994  //lut 方式
```

我们得出一些结论: `尽量使用 OpenCV 内置函数`. `调用LUT 函数可以获得最快的速度. 这是因为OpenCV库可以通过英特尔线程架构启用多线程`. 当然,如果你喜欢使用指针的方法来扫描图像，迭代法是一个不错的选择，不过速度上较慢。在debug模式下使用on-the-fly方法扫描全图是一个最浪费资源的方法，在release模式下它的表现和迭代法相差无几，但是从安全性角度来考虑，迭代法是更佳的选择.

# 6 测试代码如下
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
#import "ScanImageViewController.h"

@interface ScanImageViewController ()

@end

@implementation ScanImageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self _setTable];
   UIImage * image =  [UIImage imageNamed:@"1.jpeg"];
    Mat sourceMat = [self cvMatFromUIImage:image];
    Mat rgbSourceMat;
    cvtColor(sourceMat, rgbSourceMat, COLOR_RGBA2BGR);
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:rgbSourceMat];
    
    Mat sourceCMat = rgbSourceMat.clone();
    [self _computerBlockTime:^{
        for (int i=0; i<100; i++) {
              [self  ScanImageAndReduceC:sourceCMat];
        }
    }];
    
    imageView = [self createImageViewInRect:CGRectMake(0, 200, 100, 100)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:sourceCMat];
  
      Mat sourceIteratorMat = rgbSourceMat.clone();
    [self _computerBlockTime:^{
          for (int i=0; i<100; i++) {
        [self  ScanImageAndReduceIterator:sourceIteratorMat];
          }
    }];
    
    imageView = [self createImageViewInRect:CGRectMake(0, 300, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:sourceIteratorMat];
    
    Mat sourceAccessMat = rgbSourceMat.clone();
    [self _computerBlockTime:^{
          for (int i=0; i<100; i++) {
              [self  ScanImageAndReduceRandomAccess:sourceAccessMat];
        }
    }];
    
    
    imageView = [self createImageViewInRect:CGRectMake(0, 400, 100, 100)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:sourceIteratorMat];
    
    lookUpTable =Mat(1,256, CV_8U);
      uchar* p = lookUpTable.data;
    for( int i = 0; i < 256; ++i)
                p[i] = table[I];
    Mat j = rgbSourceMat.clone();
    [self _computerBlockTime:^{
           for (int i=0; i<100; i++) {
               [self  ScanImageAndLUPMethod:rgbSourceMat src:j];
         }
     }];
   
     imageView = [self createImageViewInRect:CGRectMake(100, 400, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:j];
       
    // Do any additional setup after loading the view.
}

static Mat lookUpTable;


-(void)_computerBlockTime:(void(^)(void))exeBlock{
    double t = (double)getTickCount();
    exeBlock();
    t = ((double)getTickCount() - t)/getTickFrequency();
    cout << "Times passed in seconds: " << t << endl;
}

#pragma mark  - test
-(cv::Mat)ScanImageAndLUPMethod:(cv::Mat)I src:(cv::Mat)src{
    LUT(I, lookUpTable, src);
    return src;
}

-(cv::Mat)ScanImageAndReduceRandomAccess:(cv::Mat)I{
    CV_Assert(I.depth() != sizeof(uchar));
    const int channels = I.channels();
    switch(channels)
    {
    case 1:
        {
            for( int i = 0; i < I.rows; ++i)
                for( int j = 0; j < I.cols; ++j )
                    I.at<uchar>(i,j) = table[I.at<uchar>(i,j)];
            break;
        }
    case 3:
        {
         Mat_<Vec3b> _I = I;
            
         for( int i = 0; i < I.rows; ++i)
            for( int j = 0; j < I.cols; ++j )
               {
                   _I(i,j)[0] = table[_I(i,j)[0]];
                   _I(i,j)[1] = table[_I(i,j)[1]];
                   _I(i,j)[2] = table[_I(i,j)[2]];
            }
         I = _I;
         break;
        }
    }
    
    return I;
}

-(cv::Mat)ScanImageAndReduceIterator:(cv::Mat)I{
    CV_Assert(I.depth() != sizeof(uchar));
       const int channels = I.channels();
       switch(channels)
       {
       case 1:
           {
               MatIterator_<uchar> it, end;
               for( it = I.begin<uchar>(), end = I.end<uchar>(); it != end; ++it)
                   *it = table[*it];
               break;
           }
       case 3:
           {
               MatIterator_<Vec3b> it, end;
               for( it = I.begin<Vec3b>(), end = I.end<Vec3b>(); it != end; ++it)
               {
                   (*it)[0] = table[(*it)[0]];
                   (*it)[1] = table[(*it)[1]];
                   (*it)[2] = table[(*it)[2]];
               }
           }
       }
       
       return I;
}

-(cv::Mat)ScanImageAndReduceC:(cv::Mat)I {
    CV_Assert(I.depth() != sizeof(uchar));
    int channels = I.channels();
    int nRows = I.rows * channels;
    int nCols = I.cols;
    if (I.isContinuous())
    {
        nCols *= nRows;
        nRows = 1;
    }
    int i,j;
    uchar* p;
    for( i = 0; i < nRows; ++i)
    {
        p = I.ptr<uchar>(i);
        for ( j = 0; j < nCols; ++j)
        {
            p[j] = table[p[j]];
        }
    }
    return I;
}


#pragma mark  - private
static uchar table[256];
static int divideWith;
-(void)_setTable{
    if (divideWith<=0) {
        divideWith = 10;
    }
    for (int i = 0; i < 256; ++i)
         table[i] = divideWith* (i/divideWith);
}

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
  return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
//    mat 是brg 而 rgb
    Mat src;
    NSData *data=nil;
  CGColorSpaceRef colorSpace;
  if (cvMat.elemSize() == 1) {
      colorSpace = CGColorSpaceCreateDeviceGray();
      data= [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
  } else {
      cvtColor(cvMat, src, COLOR_BGR2RGB);
       data= [NSData dataWithBytes:src.data length:src.elemSize()*src.total()];
      colorSpace = CGColorSpaceCreateDeviceRGB();
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
 打印结果
```
Times passed in seconds: 1.50465
Times passed in seconds: 6.41172
Times passed in seconds: 7.55413
Times passed in seconds: 0.100994
```
图片结果
![](https://upload-images.jianshu.io/upload_images/1682758-8c2f8a65b0e0b526.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

----
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVFirstChapter-scanImage)
[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/core/how_to_scan_images/how_to_scan_images.html)