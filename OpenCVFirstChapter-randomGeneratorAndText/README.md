# 1.目的

本节你将学到:
*   使用 *随机数发生器类* ([RNG](http://opencv.willowgarage.com/documentation/cpp/core_operations_on_arrays.html?#rng)) 并得到均匀分布的随机数。
*   通过使用函数 [putText](http://opencv.willowgarage.com/documentation/cpp/core_drawing_functions.html?#putText) 显示文字。

# 2代码
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
const int NUMBER = 100;
float window_height =900;
float window_width =600;
int x_1 = -window_width/2;
int x_2 = window_width*3/2;
int y_1 = -window_width/2;
int y_2 = window_width*3/2;

#import "RandomAndTextViewController.h"

@interface RandomAndTextViewController ()

@end
@implementation RandomAndTextViewController

RNG rng( 0xFFFFFFFF);
- (void)viewDidLoad {
    [super viewDidLoad];

    Mat image = Mat::zeros( window_height, window_width, CV_8UC3);
    UIImageView *imageView;
    [self Drawing_Random_Lines:image];
    [self Drawing_Random_Rectangles:image];
    [self Drawing_Random_Ellipses:image];
    [self Drawing_Random_Polylines:image];
    [self Drawing_Random_Filled_Polygons:image];
    [self Drawing_Random_Circles:image];
    [self Displaying_Random_Text:image];
    imageView = [self createImageViewInRect:self.view.bounds];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:image];

//    [self Displaying_Big_End:image];


}
-(void)Drawing_Random_Lines:(Mat)image{
    cv::Point pt1, pt2;

     for( int i = 0; i < NUMBER; i++ )
     {
       pt1.x = rng.uniform( x_1, x_2 );
       pt1.y = rng.uniform( y_1, y_2 );
       pt2.x = rng.uniform( x_1, x_2 );
       pt2.y = rng.uniform( y_1, y_2 );

       line(image, pt1, pt2, [self randomColor], rng.uniform(1, 10), 8 );
     }
}
-(void)Drawing_Random_Rectangles:(Mat)image{
    cv::Point pt1, pt2;
     int lineType = 8;
     int thickness = rng.uniform( -3, 10 );

     for( int i = 0; i < NUMBER; i++ )
     {
       pt1.x = rng.uniform( x_1, x_2 );
       pt1.y = rng.uniform( y_1, y_2 );
       pt2.x = rng.uniform( x_1, x_2 );
       pt2.y = rng.uniform( y_1, y_2 );

       rectangle( image, pt1, pt2, [self randomColor], MAX( thickness, -1 ), lineType );

     }
}

-(void)Drawing_Random_Ellipses:(Mat)image{
    int lineType = 8;
    for ( int i = 0; i < NUMBER; i++ )
    {
        cv::Point center;
      center.x = rng.uniform(x_1, x_2);
      center.y = rng.uniform(y_1, y_2);

        cv::Size axes;
      axes.width = rng.uniform(0, 200);
      axes.height = rng.uniform(0, 200);

      double angle = rng.uniform(0, 180);

      ellipse( image, center, axes, angle, angle - 100, angle + 200,
               [self randomColor], rng.uniform(-1,9), lineType );

    }

}

-(void)Drawing_Random_Polylines:(Mat)image{
    int lineType = 8;

     for( int i = 0; i< NUMBER; i++ )
     {
         cv::Point pt[2][3];
       pt[0][0].x = rng.uniform(x_1, x_2);
       pt[0][0].y = rng.uniform(y_1, y_2);
       pt[0][1].x = rng.uniform(x_1, x_2);
       pt[0][1].y = rng.uniform(y_1, y_2);
       pt[0][2].x = rng.uniform(x_1, x_2);
       pt[0][2].y = rng.uniform(y_1, y_2);
       pt[1][0].x = rng.uniform(x_1, x_2);
       pt[1][0].y = rng.uniform(y_1, y_2);
       pt[1][1].x = rng.uniform(x_1, x_2);
       pt[1][1].y = rng.uniform(y_1, y_2);
       pt[1][2].x = rng.uniform(x_1, x_2);
       pt[1][2].y = rng.uniform(y_1, y_2);

         const  cv::Point* ppt[2] = {pt[0], pt[1]};
       int npt[] = {3, 3};

       polylines(image, ppt, npt, 2, true,  [self randomColor], rng.uniform(1,10), lineType);

     }
}

-(void)Drawing_Random_Filled_Polygons:(Mat)image{
    int lineType = 8;

     for ( int i = 0; i < NUMBER; i++ )
     {
         cv::Point pt[2][3];
       pt[0][0].x = rng.uniform(x_1, x_2);
       pt[0][0].y = rng.uniform(y_1, y_2);
       pt[0][1].x = rng.uniform(x_1, x_2);
       pt[0][1].y = rng.uniform(y_1, y_2);
       pt[0][2].x = rng.uniform(x_1, x_2);
       pt[0][2].y = rng.uniform(y_1, y_2);
       pt[1][0].x = rng.uniform(x_1, x_2);
       pt[1][0].y = rng.uniform(y_1, y_2);
       pt[1][1].x = rng.uniform(x_1, x_2);
       pt[1][1].y = rng.uniform(y_1, y_2);
       pt[1][2].x = rng.uniform(x_1, x_2);
       pt[1][2].y = rng.uniform(y_1, y_2);

         const cv::Point* ppt[2] = {pt[0], pt[1]};
       int npt[] = {3, 3};
       fillPoly( image, ppt, npt, 2,[self randomColor], lineType );
     }
}

-(void)Drawing_Random_Circles:(Mat)image{
    int lineType = 8;

     for (int i = 0; i < NUMBER; I++)
     {
         cv::Point center;
       center.x = rng.uniform(x_1, x_2);
       center.y = rng.uniform(y_1, y_2);

       circle( image, center, rng.uniform(0, 300), [self randomColor],
               rng.uniform(-1, 9), lineType );
     }
}

-(void)Displaying_Random_Text:(Mat)image{
    int lineType = 8;

    for ( int i = 1; i < NUMBER; i++ )
    {
        cv::Point org;
      org.x = rng.uniform(x_1, x_2);
      org.y = rng.uniform(y_1, y_2);

      putText( image, "Testing text rendering", org, rng.uniform(0,8),
               rng.uniform(0,100)*0.05+0.1,[self randomColor], rng.uniform(1, 10), lineType);
    }

}

-(void)Displaying_Big_End:(Mat)image{
    cv::Size textsize = getTextSize("OpenCV forever!", FONT_HERSHEY_COMPLEX, 3, 5, 0);
    cv::Point org((window_width - textsize.width)/2, (window_height - textsize.height)/2);
     int lineType = 8;

     Mat image2;
  UIImageView * imageView;
     for( int i = 0; i < 255; i += 2 )
     {
       image2 = image - Scalar::all(i);
       putText( image2, "OpenCV forever!", org, FONT_HERSHEY_COMPLEX, 3,
                Scalar(i, i, 255), 5, lineType );
        imageView = [self createImageViewInRect:self.view.bounds];
              [self.view addSubview:imageView];
              imageView.image  = [self UIImageFromCVMat:image2];

     }
  
  
}



-(Scalar)randomColor{
    int icolor = (unsigned) rng;
    return Scalar( icolor&255, (icolor>>8)&255, (icolor>>16)&255 );
}


#pragma mark  - private
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

```
# 3.说明

+ 1.让我们检视 main 函数。我们发现第一步是实例化一个 Random Number Generator（随机数发生器对象） (RNG):
```
RNG rng( 0xFFFFFFFF );
```
RNG的实现了一个随机数发生器。 在上面的例子中, rng 是用数值 0xFFFFFFFF 来实例化的一个RNG对象。

+ 2.然后我们初始化一个 0 矩阵(代表一个全黑的图像), 并且指定它的宽度，高度，和像素格式:
```
Mat image = Mat::zeros( window_height, window_width, CV_8UC3 );

```
+ 3.然后我们开始疯狂的绘制。看过代码时候你会发现它主要分八个部分，正如函数定义的一样：
```
    [self Drawing_Random_Lines:image];
    [self Drawing_Random_Rectangles:image];
    [self Drawing_Random_Ellipses:image];
    [self Drawing_Random_Polylines:image];
    [self Drawing_Random_Filled_Polygons:image];
    [self Drawing_Random_Circles:image];
    [self Displaying_Random_Text:image];
    [self Displaying_Big_End:image];
```
所有这些范数都遵循相同的模式，所以我们只分析其中的一组，因为这适用于所有。

+ 4. 查看函数 Drawing_Random_Lines:
```
-(void)Drawing_Random_Lines:(Mat)image{
    cv::Point pt1, pt2;

     for( int i = 0; i < NUMBER; i++ )
     {
       pt1.x = rng.uniform( x_1, x_2 );
       pt1.y = rng.uniform( y_1, y_2 );
       pt2.x = rng.uniform( x_1, x_2 );
       pt2.y = rng.uniform( y_1, y_2 );

       line(image, pt1, pt2, [self randomColor], rng.uniform(1, 10), 8 );
     }
}
```
> +  *for* 循环将重复 **NUMBER** 次。 并且函数 [line](http://opencv.willowgarage.com/documentation/cpp/core_drawing_functions.html?#cv-line) 在循环中, 这意味着要生成 **NUMBER** 条线段。
> + 线段的两个端点分别是 pt1 和 pt2. 对于 pt1 我们看到:
> > 我们知道 rng 是一个 随机数生成器 对象。在上面的代码中我们调用了 rng.uniform(a,b) 。这指定了一个在 a 和 b 之间的均匀分布(包含 a, 但不含 b)。
> > 由上面的说明，我们可以推断出 pt1 和 pt2 将会是随机的数值，因此产生的线段是变幻不定的，这会产生一个很好的视觉效果（从下面绘制的图片可以看出）。
> > 我们还可以发现, 在 [line](http://opencv.willowgarage.com/documentation/cpp/core_drawing_functions.html?#cv-line) 的参数设置中，对于 *color* 的设置我们用了：
> > ```
> > -(Scalar)randomColor{
> > int icolor = (unsigned) rng;
> > return Scalar( icolor&255, (icolor>>8)&255, (icolor>>16)&255 );
> > }
> > ```
> > 正如我们看到的，函数的返回值是一个用三个随机数初始化的 Scalar 对象，这三个随机数代表了颜色的 R, G, B 分量。所以，线段的颜色也是随机的！

+ 5上面的解释同样适用于其它的几何图形，比如说参数 center（圆心） 和 vertices（顶点） 也是随机的。
+ 6. 在结束之前，我们还应该看看函数 Display_Random_Text 和 Displaying_Big_End, 因为它们有一些有趣的特征:
+ 7.Display_Random_Text:
```
-(void)Displaying_Random_Text:(Mat)image{
    int lineType = 8;

    for ( int i = 1; i < NUMBER; i++ )
    {
        cv::Point org;
      org.x = rng.uniform(x_1, x_2);
      org.y = rng.uniform(y_1, y_2);

      putText( image, "Testing text rendering", org, rng.uniform(0,8),
               rng.uniform(0,100)*0.05+0.1,[self randomColor], rng.uniform(1, 10), lineType);
    }

}
```
函数 [putText](http://opencv.willowgarage.com/documentation/cpp/core_drawing_functions.html?#putText) 都做了些什么？在我们的例子中：
> *   在 **image** 上绘制文字 **“Testing text rendering”** 。
> *   文字的左下角将用点 **org** 指定。
> *   字体参数是用一个在[0,8)之间的整数来定义。
> *   字体的缩放比例是用表达式 **rng.uniform(0, 100)x0.05 + 0.1** 指定(表示它的范围是 [0.1,5.1)
> *   字体的颜色是随机的 (记为 **[self randomColor]**)。
> *   字体的粗细范围是从 1 到 10, 表示为 **rng.uniform(1,10)** 。
> 因此, 我们将绘制 (与其余函数类似) NUMBER 个文字到我们的图片上，以位置随机的方式。

+ 8 Displaying_Big_End
```
-(void)Displaying_Big_End:(Mat)image{
    cv::Size textsize = getTextSize("OpenCV forever!", FONT_HERSHEY_COMPLEX, 3, 5, 0);
    cv::Point org((window_width - textsize.width)/2, (window_height - textsize.height)/2);
     int lineType = 8;

     Mat image2;

     for( int i = 0; i < 255; i += 2 )
     {
       image2 = image - Scalar::all(i);
       putText( image2, "OpenCV forever!", org, FONT_HERSHEY_COMPLEX, 3,
                Scalar(i, i, 255), 5, lineType );

     }
}
```
除了 getTextSize (用于获取文字的大小参数), 我们可以发现在 for 循环里的新操作：
```
  image2 = image - Scalar::all(i)

**image2** 是 **image** 和 **Scalar::all(i)** 的差。事实上，**image2** 的每个像素都是 **image** 的每个像素减去 **i** (对于每个像素，都是由R，G，B三个分量组成，每个分量都会独立做差)的差。
```
我们还要知道，减法操作 总是 保证是 合理 的操作, 这表明结果总是在合理的范围内 (这个例子里结果不会为负数，并且保证在 0～255的合理范围内)。
# 5结果
截取一部分结果展示
![](https://upload-images.jianshu.io/upload_images/1682758-a6a7c610ca3f1a5e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![](https://upload-images.jianshu.io/upload_images/1682758-94c0c42152ec17cb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
![](https://upload-images.jianshu.io/upload_images/1682758-f3fc7bcee6439d5c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

------
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVFirstChapter-randomGeneratorAndText)
[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/core/random_generator_and_text/random_generator_and_text.html#drawing-2)
[源码地址](https://github.com/opencv/opencv/blob/master/samples/cpp/tutorial_code/ImgProc/basic_drawing/Drawing_2.cpp#L16)