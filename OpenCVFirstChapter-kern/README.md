# 1.测试用例
# 2.基本方法
# 3.filter2D函数
------
矩阵的掩码操作很简单。其思想是：根据掩码矩阵（也称作核）`重新计算图像中每个像素的值`。`掩码矩阵中的值`表示`近邻像素值`（包括该像素自身的值）对新像素值有多大影响。从数学观点看，我们用自己设置的权值，对像素邻域内的值做了个加权平均。

# 1.测试用例

思考一下图像对比度增强的问题。我们可以对图像的每个像素应用下面的公式：

![](https://upload-images.jianshu.io/upload_images/1682758-0a7f1f8b081cc4b9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

上面那种表达法是公式的形式，而下面那种是以掩码矩阵表示的紧凑形式。使用掩码矩阵的时候，我们先把矩阵中心的元素（上面的例子中是(0,0)位置的元素，也就是5）对齐到要计算的目标像素上，再把邻域像素值和相应的矩阵元素值的乘积加起来。虽然这两种形式是完全等价的，但在大矩阵情况下，下面的形式看起来会清楚得多。

现在，我们来看看实现掩码(核)操作的两种方法。一种方法是用基本的像素访问方法，另一种方法是用 [filter2D](http://opencv.itseez.com/modules/imgproc/doc/filtering.html#filter2d) 函数。

我们使用的图像如下
![](https://upload-images.jianshu.io/upload_images/1682758-027724949939251c.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 2基本方法
下面是实现了上述功能的函数：
```
-(cv::Mat)SharpenSourceMat:(cv::Mat) myImage {
    CV_Assert(myImage.depth() == CV_8U);  // 仅接受uchar图像
    Mat Result;
    Result.create(myImage.size(),myImage.type());
    const int nChannels = myImage.channels();

    for(int j = 1 ; j < myImage.rows-1; ++j)
    {
        const uchar* previous = myImage.ptr<uchar>(j - 1);
        const uchar* current  = myImage.ptr<uchar>(j    );
        const uchar* next     = myImage.ptr<uchar>(j + 1);
        uchar* output = Result.ptr<uchar>(j);
        for(int i= nChannels;i < nChannels*(myImage.cols-1); ++i)
        {
            *output++ = saturate_cast<uchar>(5*current[I]
                         -current[i-nChannels] - current[i+nChannels] - previous[i] - next[I]);
        }
    }

    Result.row(0).setTo(Scalar(0));
    Result.row(Result.rows-1).setTo(Scalar(0));
    Result.col(0).setTo(Scalar(0));
    Result.col(Result.cols-1).setTo(Scalar(0));
    return Result;
}

```
刚进入函数的时候，我们要确保输入图像是无符号字符类型的。为了做到这点，我们使用了 [CV_Assert](http://opencv.itseez.com/modules/core/doc/utility_and_system_functions_and_macros.html#cv-assert) 函数。若该函数括号内的表达式为false，则会抛出一个错误。
```
CV_Assert(myImage.depth() == CV_8U);  // 仅接受uchar图像
```
然后，我们创建了一个与输入有着相同大小和类型的输出图像。在 前面的章节中知道，根据图像的通道数，我们有一个或多个子列。我们用指针在每一个通道上迭代，因此通道数就决定了需计算的元素总数。
```
Result.create(myImage.size(),myImage.type());
const int nChannels = myImage.channels();
```
利用C语言的[]操作符，我们能简单明了地访问像素。因为要同时访问多行像素，所以我们获取了其中每一行像素的指针（分别是前一行、当前行和下一行）。此外，我们还需要一个指向计算结果存储位置的指针。有了这些指针后，我们使用[]操作符，就能轻松访问到目标元素。为了让输出指针向前移动，我们在每一次操作之后对输出指针进行了递增（移动一个字节）：

```
for(int j = 1 ; j < myImage.rows-1; ++j)
{
    const uchar* previous = myImage.ptr<uchar>(j - 1);
    const uchar* current  = myImage.ptr<uchar>(j    );
    const uchar* next     = myImage.ptr<uchar>(j + 1);

    uchar* output = Result.ptr<uchar>(j);

    for(int i= nChannels;i < nChannels*(myImage.cols-1); ++i)
    {
        *output++ = saturate_cast<uchar>(5*current[I]
                     -current[i-nChannels] - current[i+nChannels] - previous[i] - next[I]);
    }
}
```
在图像的边界上，上面给出的公式会访问不存在的像素位置（比如(0,-1)）。因此我们的公式对边界点来说是未定义的。一种简单的解决方法，是不对这些边界点使用掩码，而直接把它们设为0：
```
Result.row(0).setTo(Scalar(0));             // 上边界
Result.row(Result.rows-1).setTo(Scalar(0)); // 下边界
Result.col(0).setTo(Scalar(0));             // 左边界
Result.col(Result.cols-1).setTo(Scalar(0)); // 右边界
```
# 3filter2D函数
滤波器在图像处理中的应用太广泛了，因此OpenCV也有个用到了滤波器掩码（某些场合也称作核）的函数。不过想使用这个函数，你必须先定义一个表示掩码的 Mat 对象：
```
Mat kern = (Mat_<char>(3,3) <<  0, -1,  0,
                               -1,  5, -1,
                                0, -1,  0);
```
然后调用 [filter2D](http://opencv.itseez.com/modules/imgproc/doc/filtering.html#filter2d) 函数，参数包括输入、输出图像以及用到的核：
它还带有第五个可选参数——指定核的中心，和第六个可选参数——指定函数在未定义区域（边界）的行为。使用该函数有一些优点，如代码更加清晰简洁、通常比 自己实现的方法 速度更快（因为有一些专门针对它实现的优化技术）等等。

```
-(cv::Mat)filter2DSourceMat:(cv::Mat) myImage {
    Mat kern = (Mat_<char>(3,3) <<  0, -1,  0,
    -1,  5, -1,
     0, -1,  0);
    Mat Result;
    filter2D(myImage, Result, myImage.depth(), kern );
    return Result;
}

```

# 代码测试
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
#import "KernViewController.h"

@interface KernViewController ()

@end

@implementation KernViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage * image =  [UIImage imageNamed:@"lena.jpg"];
    Mat sourceMat = [self cvMatFromUIImage:image];
    Mat rgbSourceMat;
    cvtColor(sourceMat, rgbSourceMat, COLOR_RGBA2BGR);
    UIImageView *imageView;
      imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
      [self.view addSubview:imageView];
      imageView.image  = [self UIImageFromCVMat:rgbSourceMat];
    
    Mat result = [self SharpenSourceMat:rgbSourceMat];
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
         [self.view addSubview:imageView];
         imageView.image  = [self UIImageFromCVMat:result];
    
    result = [self filter2DSourceMat:rgbSourceMat];
    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
         [self.view addSubview:imageView];
         imageView.image  = [self UIImageFromCVMat:result];
    // Do any additional setup after loading the view.
}


-(cv::Mat)SharpenSourceMat:(cv::Mat) myImage {
    CV_Assert(myImage.depth() == CV_8U);  // 仅接受uchar图像
    Mat Result;
    Result.create(myImage.size(),myImage.type());
    const int nChannels = myImage.channels();

    for(int j = 1 ; j < myImage.rows-1; ++j)
    {
        const uchar* previous = myImage.ptr<uchar>(j - 1);
        const uchar* current  = myImage.ptr<uchar>(j    );
        const uchar* next     = myImage.ptr<uchar>(j + 1);
        uchar* output = Result.ptr<uchar>(j);
        for(int i= nChannels;i < nChannels*(myImage.cols-1); ++i)
        {
            *output++ = saturate_cast<uchar>(5*current[I]
                         -current[i-nChannels] - current[i+nChannels] - previous[i] - next[I]);
        }
    }

    Result.row(0).setTo(Scalar(0));
    Result.row(Result.rows-1).setTo(Scalar(0));
    Result.col(0).setTo(Scalar(0));
    Result.col(Result.cols-1).setTo(Scalar(0));
    return Result;
}

-(cv::Mat)filter2DSourceMat:(cv::Mat) myImage {
    Mat kern = (Mat_<char>(3,3) <<  0, -1,  0,
    -1,  5, -1,
     0, -1,  0);
    Mat Result;
    filter2D(myImage, Result, myImage.depth(), kern );
    return Result;
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
结果
![](https://upload-images.jianshu.io/upload_images/1682758-c288301cd280a007.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

------
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVFirstChapter-kern)
[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/core/mat-mask-operations/mat-mask-operations.html#maskoperationsfilter)