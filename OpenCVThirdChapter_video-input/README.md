# OpenCV之ios OpenCV的视频输入和相似度测量

##  目标
现在找一个能拍摄视频的设备真是太容易了。结果大家都用视频来代替以前的序列图像。视频可能由两种形式得到，一个是像网络摄像头那样实时视频流，或者由其他设备产生的压缩编码后的视频文件。幸运的是，OpenCV可以使用相同的C++类、用同一种方式处理这些视频信息。在接下来的教程里你将学习如何使用摄像头或者视频文件。

*   如何打开和读取视频流
*   两种检查相似度的方法：PSNR和SSIM

## 源代码
由于项目中使用的两个视频源在调试过程中不能播放.因此,视频使用的是两个相同的视频源,命名了两个不同的文件,

```
//
//  VideoInputViewController.m
//  OpenCVThirdChapter_video-input
//
//  Created by glodon on 2019/11/19.
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
#import "VideoInputViewController.h"

@interface VideoInputViewController ()
@property (nonatomic ,strong) UIImageView * RefimageView ;
@property (nonatomic ,strong) UIImageView * tesimageView ;

@end

@implementation VideoInputViewController
VideoCapture captRefrnc;
VideoCapture  captUndTst;
int frameNum = -1;
 string sourceReference;
string sourceCompareWith;
int psnrTriggerValue;
Mat frameReference, frameUnderTest;
double psnrV;
 Scalar mssimV;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.RefimageView = [self createImageViewInRect:CGRectMake(0, 100, 200, 200)];
    [self.view addSubview:self.RefimageView];
    self.tesimageView = [self createImageViewInRect:CGRectMake(0, 300, 200, 200)];
    [self.view addSubview:self.tesimageView];
     stringstream conv;
    NSString * sourceReferenceStr =[self getFilePathInName:@"1.mp4"];
    NSString * sourceCompareWithStr = [self getFilePathInName:@"2.mp4"];
    sourceReference =sourceReferenceStr.UTF8String;
    sourceCompareWith=sourceCompareWithStr.UTF8String;
    psnrTriggerValue = 35;
         // Frame counter
    
     captRefrnc= VideoCapture(sourceReference);
     captUndTst=VideoCapture(sourceCompareWith);
    if ( !captRefrnc.isOpened())
       {
           cout  << "Could not open reference " << sourceReference << endl;
           return ;
       }
    if( !captUndTst.isOpened())
       {
           cout  << "Could not open case test " << sourceCompareWith << endl;
           return ;
       }
    cv::Size refS = cv::Size((int) captRefrnc.get(CV_CAP_PROP_FRAME_WIDTH),
    (int) captRefrnc.get(CV_CAP_PROP_FRAME_HEIGHT)),
    uTSi = cv::Size((int) captUndTst.get(CV_CAP_PROP_FRAME_WIDTH),
    (int) captUndTst.get(CV_CAP_PROP_FRAME_HEIGHT));
    
    if (refS != uTSi)
      {
          cout << "Inputs have different size!!! Closing." << endl;
          return ;
      }

  cout << "Reference frame resolution: Width=" << refS.width << "  Height=" << refS.height
         << " of nr#: " << captRefrnc.get(CV_CAP_PROP_FRAME_COUNT) << endl;

     cout << "PSNR trigger value " <<
         setiosflags(ios::fixed) << setprecision(3) << psnrTriggerValue << endl;

    [self play];
}

-(void)play{
    [self createCADisplayLinkExeBlock:^(BOOL * _Nonnull stop) {
     static BOOL begin = NO;
        if (begin) {
            begin =NO;
            return ;
        }
       BOOL  isStop = [self asyPlay];
        if (isStop) {
            * stop = YES;
        }
    }];
}

-(void)playerViewRef:(Mat)frameReference andframeUnderTest:(Mat)frameUnderTest{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.RefimageView.image = [self UIImageFromCVMat:frameReference];
        self.tesimageView.image = [self UIImageFromCVMat:frameUnderTest];
     });
}

-(BOOL)asyPlay{
    captRefrnc >> frameReference;
    captUndTst >> frameUnderTest;

    if( frameReference.empty()  || frameUnderTest.empty())
           {
               cout << " < < <  Game over!  > > > ";
               return YES;
           }
     ++frameNum;
     cout <<"Frame:" << frameNum <<"# ";
    psnrV = getPSNR(frameReference,frameUnderTest);                 //get PSNR
           cout << setiosflags(ios::fixed) << setprecision(3) << psnrV << "dB";
    if (psnrV < psnrTriggerValue && psnrV)
         {
             mssimV = getMSSIM(frameReference,frameUnderTest);

             cout << " MSSIM: "
                 << " R " << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[2] * 100 << "%"
                 << " G " << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[1] * 100 << "%"
                 << " B " << setiosflags(ios::fixed) << setprecision(2) << mssimV.val[0] * 100 << "%";
         }

         cout << endl;
    [self playerViewRef:frameReference andframeUnderTest:frameUnderTest];
    return NO;
}
Scalar getMSSIM( const Mat& i1, const Mat& i2)
{
    const double C1 = 6.5025, C2 = 58.5225;
    /***************************** INITS **********************************/
    int d     = CV_32F;

    Mat I1, I2;
    i1.convertTo(I1, d);           // cannot calculate on one byte large values
    i2.convertTo(I2, d);

    Mat I2_2   = I2.mul(I2);        // I2^2
    Mat I1_2   = I1.mul(I1);        // I1^2
    Mat I1_I2  = I1.mul(I2);        // I1 * I2

    /*************************** END INITS **********************************/

    Mat mu1, mu2;   // PRELIMINARY COMPUTING
    GaussianBlur(I1, mu1, cv::Size(11, 11), 1.5);
    GaussianBlur(I2, mu2, cv::Size(11, 11), 1.5);

    Mat mu1_2   =   mu1.mul(mu1);
    Mat mu2_2   =   mu2.mul(mu2);
    Mat mu1_mu2 =   mu1.mul(mu2);

    Mat sigma1_2, sigma2_2, sigma12;

    GaussianBlur(I1_2, sigma1_2, cv::Size(11, 11), 1.5);
    sigma1_2 -= mu1_2;

    GaussianBlur(I2_2, sigma2_2, cv::Size(11, 11), 1.5);
    sigma2_2 -= mu2_2;

    GaussianBlur(I1_I2, sigma12, cv::Size(11, 11), 1.5);
    sigma12 -= mu1_mu2;

    ///////////////////////////////// FORMULA ////////////////////////////////
    Mat t1, t2, t3;

    t1 = 2 * mu1_mu2 + C1;
    t2 = 2 * sigma12 + C2;
    t3 = t1.mul(t2);              // t3 = ((2*mu1_mu2 + C1).*(2*sigma12 + C2))

    t1 = mu1_2 + mu2_2 + C1;
    t2 = sigma1_2 + sigma2_2 + C2;
    t1 = t1.mul(t2);               // t1 =((mu1_2 + mu2_2 + C1).*(sigma1_2 + sigma2_2 + C2))

    Mat ssim_map;
    divide(t3, t1, ssim_map);      // ssim_map =  t3./t1;

    Scalar mssim = mean( ssim_map ); // mssim = average of ssim map
    return mssim;
}
double getPSNR(const Mat& I1, const Mat& I2)
{
    Mat s1;
    absdiff(I1, I2, s1);       // |I1 - I2|
    s1.convertTo(s1, CV_32F);  // cannot make a square on 8 bits
    s1 = s1.mul(s1);           // |I1 - I2|^2

    Scalar s = sum(s1);         // sum elements per channel

    double sse = s.val[0] + s.val[1] + s.val[2]; // sum channels

    if( sse <= 1e-10) // for small values return zero
        return 0;
    else
    {
        double  mse =sse /(double)(I1.channels() * I1.total());
        double psnr = 10.0*log10((255*255)/mse);
        return psnr;
    }
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

## 程序解读
### 如何读取一个视频流（摄像头或者视频文件)？
总的来说，视频捕获需要的所有函数都集成在 [VideoCapture](http://opencv.itseez.com/modules/highgui/doc/reading_and_writing_images_and_video.html#videocapture) C++ 类里面。虽然它底层依赖另一个FFmpeg开源库，但是它已经被集成在OpenCV里所以你不需要额外地关注它的具体实现方法。你只需要知道一个视频由一系列图像构成，我们用一个专业点儿的词汇来称呼这些构成视频的图像：“帧”（frame）。此外在视频文件里还有个参数叫做“帧率”（frame rate）的，用来表示两帧之间的间隔时间，帧率的单位是（帧/秒）。这个参数只和视频的播放速度有关，对于单独的一帧图像来说没有任何用途。

你需要先定义一个 [VideoCapture](http://opencv.itseez.com/modules/highgui/doc/reading_and_writing_images_and_video.html#videocapture) 类的对象来打开和读取视频流。具体可以通过 [constructor](http://opencv.itseez.com/modules/highgui/doc/reading_and_writing_images_and_video.html#videocapture-videocapture) 或者通过 [open](http://opencv.itseez.com/modules/highgui/doc/reading_and_writing_images_and_video.html#videocapture-open) 函数来完成。如果使用整型数当参数的话，就可以将这个对象绑定到一个摄像机，将系统指派的ID号当作参数传入即可。例如你可以传入0来打开第一个摄像机，传入1打开第二个摄像机，以此类推。如果使用字符串当参数，就会打开一个由这个字符串（文件名）指定的视频文件。
```
    NSString * sourceReferenceStr =[self getFilePathInName:@"1.mp4"];
    NSString * sourceCompareWithStr = [self getFilePathInName:@"2.mp4"];
    sourceReference =sourceReferenceStr.UTF8String;
    sourceCompareWith=sourceCompareWithStr.UTF8String;
    psnrTriggerValue = 35;
         // Frame counter
    
     captRefrnc= VideoCapture(sourceReference);
     captUndTst=VideoCapture(sourceCompareWith);
```
下面这种写法也可以.上面这种写法我只是将其定义为了全局变量而已
```
VideoCapture captRefrnc(sourceReference);
// 或者
VideoCapture captUndTst;
captUndTst.open(sourceCompareWith);
```

你可以用 [isOpened](http://opencv.itseez.com/modules/highgui/doc/reading_and_writing_images_and_video.html#video-isopened) 函数来检查视频是否成功打开与否:
```
 if ( !captRefrnc.isOpened())
       {
           cout  << "Could not open reference " << sourceReference << endl;
           return ;
       }
    if( !captUndTst.isOpened())
       {
           cout  << "Could not open case test " << sourceCompareWith << endl;
           return ;
       }
```
当析构函数调用时，会自动关闭视频。如果你希望提前关闭的话，你可以调用 [release](http://opencv.itseez.com/modules/highgui/doc/reading_and_writing_images_and_video.html#videocapture-release) 函数. 视频的每一帧都是一幅普通的图像。因为我们仅仅需要从 [VideoCapture](http://opencv.itseez.com/modules/highgui/doc/reading_and_writing_images_and_video.html#videocapture)对象里释放出每一帧图像并保存成 *Mat* 格式。因为视频流是连续的，所以你需要在每次调用 [read](http://opencv.itseez.com/modules/highgui/doc/reading_and_writing_images_and_video.html#videocapture-read) 函数后及时保存图像或者直接使用重载的>>操作符。
```
Mat frameReference, frameUnderTest;
captRefrnc >> frameReference;
```
如果视频帧无法捕获（例如当视频关闭或者完结的时候），上面的操作就会返回一个空的 Mat 对象。我们可以用下面的代码检查是否返回了空的图像：
```
if( frameReference.empty()  || frameUnderTest.empty())
{
 // 退出程序
}
```
读取视频帧的时候也会自动进行解码操作。你可以通过调用 [grab](http://opencv.itseez.com/modules/highgui/doc/reading_and_writing_images_and_video.html#videocapture-grab) 和 [retrieve](http://opencv.itseez.com/modules/highgui/doc/reading_and_writing_images_and_video.html#videocapture-retrieve) 函数来显示地进行这两项操作。(本程序没使用)

视频通常拥有很多除了视频帧图像以外的信息，像是帧数之类，有些时候数据较短，有些时候用4个字节的字符串来表示。所以 [get](http://opencv.itseez.com/modules/highgui/doc/reading_and_writing_images_and_video.html#videocapture-get) 函数返回一个double（8个字节）类型的数据来表示这些属性。然后你可以使用位操作符来操作这个返回值从而得到想要的整型数据等。这个函数有一个参数，代表着试图查询的属性ID。在下面的例子里我们会先获得食品的尺寸和帧数。


当你需要设置这些值的时候你可以调用 [set](http://opencv.itseez.com/modules/highgui/doc/reading_and_writing_images_and_video.html#videocapture-set) 函数。函数的第一个参数是需要设置的属性ID，第二个参数是需要设定的值，如果返回true的话就表示成功设定，否则就是false。接下来的这个例子很好地展示了如何设置视频的时间位置或者帧数：
```
captRefrnc.set(CV_CAP_PROP_POS_MSEC, 1.2);  // 跳转到视频1.2秒的位置
captRefrnc.set(CV_CAP_PROP_POS_FRAMES, 10); // 跳转到视频的第10帧
```

### 图像比较 - PSNR and SSIM

当我们想检查压缩视频带来的细微差异的时候，就需要构建一个能够逐帧比较视频差异的系统。最常用的比较算法是PSNR( Peak signal-to-noise ratio)。这是个使用“局部均值误差”来判断差异的最简单的方法，假设有这两幅图像：I1和I2，它们的行列数分别是i，j，有c个通道。
![](https://upload-images.jianshu.io/upload_images/1682758-f729422a2863c49b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

PSNR公式如下:
![](https://upload-images.jianshu.io/upload_images/1682758-65b0f1fa4414caea.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

每个像素的每个通道的值占用一个字节，值域[0,255]。这里每个像素会有MAX<sub>1</sub><sup>2</sup>个有效的最大值 注意当两幅图像的相同的话，MSE的值会变成0。这样会导致PSNR的公式会除以0而变得没有意义。所以我们需要单独的处理这样的特殊情况。此外由于像素的动态范围很广，在处理时会使用对数变换来缩小范围。这些变换的C++代码如下:

```
double getPSNR(const Mat& I1, const Mat& I2)
{
 Mat s1;
 absdiff(I1, I2, s1);       // |I1 - I2|
 s1.convertTo(s1, CV_32F);  // 不能在8位矩阵上做平方运算
 s1 = s1.mul(s1);           // |I1 - I2|^2

 Scalar s = sum(s1);         // 叠加每个通道的元素

 double sse = s.val[0] + s.val[1] + s.val[2]; // 叠加所有通道

 if( sse <= 1e-10) // 如果值太小就直接等于0
     return 0;
 else
 {
     double  mse =sse /(double)(I1.channels() * I1.total());
     double psnr = 10.0*log10((255*255)/mse);
     return psnr;
 }
}
```
在考察压缩后的视频时，这个值大约在30到50之间，数字越大则表明压缩质量越好。如果图像差异很明显，就可能会得到15甚至更低的值。PSNR算法简单，检查的速度也很快。但是其呈现的差异值有时候和人的主观感受不成比例。所以有另外一种称作 结构相似性 的算法做出了这方面的改进。

建议你阅读一些关于SSIM算法的文献来更好的理解算法，然而你直接看下面的源代码，应该也能建立一个不错的映像。

```
Scalar getMSSIM( const Mat& i1, const Mat& i2)
{
 const double C1 = 6.5025, C2 = 58.5225;
 /***************************** INITS **********************************/
 int d     = CV_32F;

 Mat I1, I2;
 i1.convertTo(I1, d);           // 不能在单字节像素上进行计算，范围不够。
 i2.convertTo(I2, d);

 Mat I2_2   = I2.mul(I2);        // I2^2
 Mat I1_2   = I1.mul(I1);        // I1^2
 Mat I1_I2  = I1.mul(I2);        // I1 * I2

 /***********************初步计算 ******************************/

 Mat mu1, mu2;   //
 GaussianBlur(I1, mu1, Size(11, 11), 1.5);
 GaussianBlur(I2, mu2, Size(11, 11), 1.5);

 Mat mu1_2   =   mu1.mul(mu1);
 Mat mu2_2   =   mu2.mul(mu2);
 Mat mu1_mu2 =   mu1.mul(mu2);

 Mat sigma1_2, sigma2_2, sigma12;

 GaussianBlur(I1_2, sigma1_2, Size(11, 11), 1.5);
 sigma1_2 -= mu1_2;

 GaussianBlur(I2_2, sigma2_2, Size(11, 11), 1.5);
 sigma2_2 -= mu2_2;

 GaussianBlur(I1_I2, sigma12, Size(11, 11), 1.5);
 sigma12 -= mu1_mu2;

 ///////////////////////////////// 公式 ////////////////////////////////
 Mat t1, t2, t3;

 t1 = 2 * mu1_mu2 + C1;
 t2 = 2 * sigma12 + C2;
 t3 = t1.mul(t2);              // t3 = ((2*mu1_mu2 + C1).*(2*sigma12 + C2))

 t1 = mu1_2 + mu2_2 + C1;
 t2 = sigma1_2 + sigma2_2 + C2;
 t1 = t1.mul(t2);               // t1 =((mu1_2 + mu2_2 + C1).*(sigma1_2 + sigma2_2 + C2))

 Mat ssim_map;
 divide(t3, t1, ssim_map);      // ssim_map =  t3./t1;

 Scalar mssim = mean( ssim_map ); // mssim = ssim_map的平均值
 return mssim;
}
```
这个操作会针对图像的每个通道返回一个相似度，取值范围应该在0到1之间，取值为1时代表完全符合。然而尽管SSIM能产生更优秀的数据，但是由于高斯模糊很花时间，所以在一个实时系统（每秒24帧）中，人们还是更多地采用PSNR算法。
正是这个原因，最开始的源码里，我们用PSNR算法去计算每一帧图像，而仅当PSNR算法计算出的结果低于输入值的时候，用SSIM算法去验证。为了展示数据，我们在例程里用两个窗口显示了原图像和测试图像并且在控制台上输出了PSNR和SSIM数据。就像下面显示的那样:
![](https://upload-images.jianshu.io/upload_images/1682758-f5d38fa4c26ceb81.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> 上面是应该展示的结果,可是项目中提供的视频播放不了,因此,我们获取的结过都是一样的.

播放动图如下:
![](https://upload-images.jianshu.io/upload_images/1682758-92cf65139de56369.gif?imageMogr2/auto-orient/strip)


`提示,上面的程序只是播放视频,没有考虑内存以及内存泄露等问题`
`上面的代码没法验证ssIm`

------
[github地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVThirdChapter_video-input)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/highgui/video-input-psnr-ssim/video-input-psnr-ssim.html#videoinputpsnrmssim)

