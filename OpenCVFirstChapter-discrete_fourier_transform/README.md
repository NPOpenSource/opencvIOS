# 1.目标
本文档尝试解答如下问题：

*   什么是傅立叶变换及其应用?
*   如何使用OpenCV提供的傅立叶变换?
*   相关函数的使用，如： [copyMakeBorder()](http://opencv.itseez.com/modules/imgproc/doc/filtering.html#copymakeborder), [merge()](http://opencv.itseez.com/modules/core/doc/operations_on_arrays.html#merge), [dft()](http://opencv.itseez.com/modules/core/doc/operations_on_arrays.html#dft), [getOptimalDFTSize()](http://opencv.itseez.com/modules/core/doc/operations_on_arrays.html#getoptimaldftsize), [log()](http://opencv.itseez.com/modules/core/doc/operations_on_arrays.html#log) 和 [normalize()](http://opencv.itseez.com/modules/core/doc/operations_on_arrays.html#normalize) .

# 2源码
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
#import "DisccreteTransfromViewController.h"

@interface DisccreteTransfromViewController ()

@end

@implementation DisccreteTransfromViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    UIImage * src1Image = [UIImage imageNamed:@"lena.jpg"];
    UIImage * src1Image = [UIImage imageNamed:@"imageTextR.png"];

    
     Mat source = [self cvMatFromUIImage:src1Image];
    Mat I;
    cvtColor(source, I, COLOR_BGRA2GRAY);;
    UIImageView *imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 100, 150, 150)];
      [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:I];
    
    Mat padded;                            //expand input image to optimal size
       int m = getOptimalDFTSize( I.rows );
       int n = getOptimalDFTSize( I.cols );
    copyMakeBorder(I, padded, 0, m - I.rows, 0, n - I.cols, BORDER_CONSTANT, Scalar::all(0));
    imageView = [self createImageViewInRect:CGRectMake(0, 250, 150, 150)];
         [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:padded];
    
    //! [complex_and_real]
        Mat planes[] = {Mat_<float>(padded), Mat::zeros(padded.size(), CV_32F)};
        Mat complexI;
        merge(planes, 2, complexI);         // Add to the expanded another plane with zeros
    //! [complex_and_real]

    //! [dft]
        dft(complexI, complexI);            // this way the result may fit in the source matrix
    //! [dft]

        // compute the magnitude and switch to logarithmic scale
        // => log(1 + sqrt(Re(DFT(I))^2 + Im(DFT(I))^2))
    //! [magnitude]
        split(complexI, planes);                   // planes[0] = Re(DFT(I), planes[1] = Im(DFT(I))
        magnitude(planes[0], planes[1], planes[0]);// planes[0] = magnitude
        Mat magI = planes[0];
    //! [magnitude]
    
    //! [log]
        magI += Scalar::all(1);                    // switch to logarithmic scale
        log(magI, magI);
    //! [log]
    
    //! [crop_rearrange]
    // crop the spectrum, if it has an odd number of rows or columns
    magI = magI(cv::Rect(0, 0, magI.cols & -2, magI.rows & -2));

    // rearrange the quadrants of Fourier image  so that the origin is at the image center
       int cx = magI.cols/2;
       int cy = magI.rows/2;

    Mat q0(magI, cv::Rect(0, 0, cx, cy));   // Top-Left - Create a ROI per quadrant
    Mat q1(magI, cv::Rect(cx, 0, cx, cy));  // Top-Right
    Mat q2(magI, cv::Rect(0, cy, cx, cy));  // Bottom-Left
    Mat q3(magI, cv::Rect(cx, cy, cx, cy)); // Bottom-Right

       Mat tmp;                           // swap quadrants (Top-Left with Bottom-Right)
       q0.copyTo(tmp);
       q3.copyTo(q0);
       tmp.copyTo(q3);

       q1.copyTo(tmp);                    // swap quadrant (Top-Right with Bottom-Left)
       q2.copyTo(q1);
       tmp.copyTo(q2);
    
    //! [crop_rearrange]
    //! [normalize]
    normalize(magI, magI, 0, 1, NORM_MINMAX); // Transform the matrix with float values into a
                                                // viewable image form (float between values 0 and 1).

    imageView = [self createImageViewInRect:CGRectMake(0, 400, 150, 150)];
            [self.view addSubview:imageView];
          imageView.image  = [self UIImageFromCVMat:magI];
}
#pragma mark  - private
//brgx
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
# 3.原理

`对一张图像使用傅立叶变换就是将它分解成正弦和余弦两部分`。也就是`将图像从空间域(spatial domain)转换到频域(frequency domain)`。 这一转换的理论基础来自于以下事实：任一函数都可以表示成无数个正弦和余弦函数的和的形式。傅立叶变换就是一个用来将函数分解的工具。 2维图像的傅立叶变换可以用以下数学公式表达:
![](https://upload-images.jianshu.io/upload_images/1682758-b59dccafd015aeec.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

式中 `f 是空间域(spatial domain)值`，` F 则是频域(frequency domain)值`。 `转换之后的频域值是复数`， 因此，显示`傅立叶变换之后的结果需要使用实数图像(real image) 加虚数图像(complex image)`, 或者`幅度图像(magitude image)加相位图像(phase image)`。 在实际的图像处理过程中，仅仅使用了幅度图像，因为幅度图像包含了原图像的几乎所有我们需要的几何信息。 然而，如果你想通过修改幅度图像或者相位图像的方法来间接修改原空间图像，你需要使用逆傅立叶变换得到修改后的空间图像，这样你就必须同时保留幅度图像和相位图像了。


在此示例中，我将展示如何计算以及显示傅立叶变换后的幅度图像。由于数字图像的离散性，像素值的取值范围也是有限的。比如在一张灰度图像中，像素灰度值一般在0到255之间。 因此，我们这里讨论的也仅仅是离散傅立叶变换(DFT)。 如果你需要得到图像中的几何结构信息，那你就要用到它了。请参考以下步骤(假设输入图像为单通道的灰度图像 I):

### 1.将图像延扩到最佳尺寸
离散傅立叶变换的运行速度与图片的尺寸息息相关。当图像的尺寸是2， 3，5的整数倍时，计算速度最快。 因此，为了达到快速计算的目的，经常通过添凑新的边缘像素的方法获取最佳图像尺寸。函数[getOptimalDFTSize()](http://opencv.itseez.com/modules/core/doc/operations_on_arrays.html#getoptimaldftsize) 返回最佳尺寸，而函数 [copyMakeBorder()](http://opencv.itseez.com/modules/imgproc/doc/filtering.html#copymakeborder) 填充边缘像素:
```
Mat padded;                            //将输入图像延扩到最佳的尺寸
int m = getOptimalDFTSize( I.rows );
int n = getOptimalDFTSize( I.cols ); // 在边缘添加0
copyMakeBorder(I, padded, 0, m - I.rows, 0, n - I.cols, BORDER_CONSTANT, Scalar::all(0));
```
添加的像素初始化为0.

### 2.为傅立叶变换的结果(实部和虚部)分配存储空间
 傅立叶变换的结果是复数，这就是说对于每个原图像值，结果是两个图像值。 此外，`频域值范围远远超过空间值范围`， 因此至少要`将频域储存在 float 格式`中。 结果我们`将输入图像转换成浮点类型`，并多`加一个额外通道来储存复数部分`
```
Mat planes[] = {Mat_<float>(padded), Mat::zeros(padded.size(), CV_32F)};
Mat complexI;
merge(planes, 2, complexI);         // 为延扩后的图像增添一个初始化为0的通道
```
### 3.进行离散傅立叶变换. 支持图像原地计算 (输入输出为同一图像):
```
dft(complexI, complexI);            // 变换结果很好的保存在原始矩阵中
```
### 4.将复数转换为幅度
复数包含实数部分(Re)和复数部分 (imaginary - Im)。 离散傅立叶变换的结果是复数，对应的幅度可以表示为:

![](https://upload-images.jianshu.io/upload_images/1682758-b610ea0818334cc2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
转化为OpenCV代码:
```
split(complexI, planes);                   // planes[0] = Re(DFT(I), planes[1] = Im(DFT(I))
magnitude(planes[0], planes[1], planes[0]);// planes[0] = magnitude
Mat magI = planes[0];
```
### 5.对数尺度(logarithmic scale)缩放
傅立叶变换的幅度值范围大到不适合在屏幕上显示。高值在屏幕上显示为白点，而低值为黑点，高低值的变化无法有效分辨。为了在屏幕上凸显出高低变化的连续性，我们可以用对数尺度来替换线性尺度:
![](https://upload-images.jianshu.io/upload_images/1682758-408afec826d9adf1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> 这里加1 是为了防止对m取对数值是复数.   对小于1的数去对数是负值.

转化为OpenCV代码:
```
magI += Scalar::all(1);                    // 转换到对数尺度
log(magI, magI);
```
### 6.剪切和重分布幅度图象限

还记得我们在第一步时延扩了图像吗? 那现在是时候将新添加的像素剔除了。为了方便显示，我们也可以重新分布幅度图象限位置(注：将第五步得到的幅度图从中间划开得到四张1/4子图像，将每张子图像看成幅度图的一个象限，重新分布即将四个角点重叠到图片中心)。 这样的话原点(0,0)就位移到图像中心。
```
magI = magI(Rect(0, 0, magI.cols & -2, magI.rows & -2));
int cx = magI.cols/2;
int cy = magI.rows/2;

Mat q0(magI, Rect(0, 0, cx, cy));   // Top-Left - 为每一个象限创建ROI
Mat q1(magI, Rect(cx, 0, cx, cy));  // Top-Right
Mat q2(magI, Rect(0, cy, cx, cy));  // Bottom-Left
Mat q3(magI, Rect(cx, cy, cx, cy)); // Bottom-Right

Mat tmp;                           // 交换象限 (Top-Left with Bottom-Right)
q0.copyTo(tmp);
q3.copyTo(q0);
tmp.copyTo(q3);

q1.copyTo(tmp);                    // 交换象限 (Top-Right with Bottom-Left)
q2.copyTo(q1);
tmp.copyTo(q2);

```
### 7.归一化
这一步的目的仍然是为了显示。 现在我们有了重分布后的幅度图，但是幅度值仍然超过可显示范围[0,1] 。我们使用 [normalize()](http://opencv.itseez.com/modules/core/doc/operations_on_arrays.html#normalize) 函数将幅度归一化到可显示范围。
```
normalize(magI, magI, 0, 1, CV_MINMAX); // 将float类型的矩阵转换到可显示图像范围
                                        // (float [0， 1]).
```

# 结果
![](https://upload-images.jianshu.io/upload_images/1682758-f66c42468b68ba8b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image.png](https://upload-images.jianshu.io/upload_images/1682758-f97db16604486ec6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

观察这两张幅度图你会发现频域的主要内容(幅度图中的亮点)是和空间图像中物体的几何方向相关的。 通过这点我们可以计算旋转角度并修正偏差。
-----
上面的知识还是很不好理解的,因此需要多看看才行,我找了一篇讲解傅里叶变换的比较好的文章供大家参考

[傅里叶变换](https://zhuanlan.zhihu.com/p/19763358)
[傅里叶变换](https://www.jianshu.com/p/d30230dcc443)

-----
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVFirstChapter-discrete_fourier_transform)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/core/discrete_fourier_transform/discrete_fourier_transform.html#discretfouriertransform)
