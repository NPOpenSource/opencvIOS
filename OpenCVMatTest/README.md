

# 1 图像的表示 

在正式介绍之前，先简单介绍一下数字图像的基本概念。如图 1-1 中所示 的图像，我们看到的是 Lena 的头像，但是计算机看来，这副图像只是一堆亮度各异的点。一副尺寸为 M × N 的图像可以用一个 M × N 的矩阵来表示，矩阵元素的值表示这个位置上的像素的亮度，一般来说像素值越大表示该点越 亮。如图 3.1 中白色圆圈内的区域，进行放大并仔细查看，将会如图 1-2 所
![1-1](https://upload-images.jianshu.io/upload_images/1682758-0b8572910338f95f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![1-2](https://upload-images.jianshu.io/upload_images/1682758-dfcce9cac5768f9e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

一般来说，`灰度图`用`2维矩阵`表示，`彩色(多通道)图像`用`3 维矩阵`(M × N × 3)表示。对于图像显示来说，目前大部分设备都是用无符号 8 位整 数(类型为 CV_8U)表示像素亮度。

图像数据在计算机内存中的存储顺序为以图像最左上点(也可能是最左下 点)开始，存储如表1-1 所示。
![表1-1 灰度图像的存储示意图](https://upload-images.jianshu.io/upload_images/1682758-ab11226527948fb5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

Iij 表示第 i 行 j 列的像素值。如果是多通道图像，比如 RGB 图像，则每个 像素用三个字节表示。在 OpenCV 中，RGB 图像的通道顺序为 BGR ，存储如 表 1-2 所示。

![表1-2彩色 RGB 图像的存储示意图](https://upload-images.jianshu.io/upload_images/1682758-556fcd3fa781add8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 2 Mat 类

早期的 OpenCV 中，使用 IplImage 和 CvMat 数据结构来表示图像。IplImage 和 CvMat 都是 C 语言的结构。使用这两个结构的问题是内存需要手动管理，开 发者必须清楚的知道何时需要申请内存，何时需要释放内存。这个开发者带来了 一定的负担，开发者应该将更多精力用于算法设计，因此在新版本的 OpenCV 中 引入了 Mat 类。
新加入的 Mat 类能够自动管理内存。使用 Mat 类，你不再需要花费大量精 力在内存管理上。而且你的代码会变得很简洁，代码行数会变少。但 C++接口唯 一的不足是当前一些嵌入式开发系统可能只支持 C 语言，如果你的开发平台支持 C++，完全没有必要再用 IplImage 和 CvMat。在新版本的 OpenCV 中，开发者依 然可以使用 IplImage 和 CvMat，但是一些新增加的函数只提供了 Mat 接口。以后的博客中的例程也都将采用新的 Mat 类，不再介绍 IplImage 和 CvMat。

Mat 类的定义如下所示，关键的属性如下方代码所示:

```
class CV_EXPORTS Mat
   {
   public:
//一系列函数 
...
/* flag参数中包含许多关于矩阵的信息，如: 
-Mat 的标识
-数据是否连续 
-深度
 -通道数目
*/
int flags;
//矩阵的维数，取值应该大于或等于 2
 int dims;
//矩阵的行数和列数，如果矩阵超过 2 维，这两个变量的值都为-1
 int rows, cols;
//指向数据的指针 
uchar* data;
//指向引用计数的指针
 //如果数据是由用户分配的，则为 NULL
 int* refcount;
//其他成员变量和成员函数
... };

```
# 3 UIImage 与mat之间的转换
由于ios平台不能使用`imread()` 进行读取图片,因此需要将进行单独转换

### 3.1  UIImage转换成Mat
```
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
  Mat src;
    cvtColor(cvMat, src, COLOR_BGR2RGB);
  return src;
}
```
> 上面只是简单的转换其实并不完全正确,没检查UIIimage的具体排列样式

### 3.2 Mat转换成UIImage
```
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
  Mat src;
    cvtColor(cvMat, src, COLOR_BGR2RGB);
  NSData *data = [NSData dataWithBytes:src.data length:src.elemSize()*src.total()];
  CGColorSpaceRef colorSpace;
  if (cvMat.elemSize() == 1) {
      colorSpace = CGColorSpaceCreateDeviceGray();
  } else {
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
                                     kCGRenderingIntentDefault                   //intent
                                     );
  // Getting UIImage from CGImage
  UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  CGDataProviderRelease(provider);
  CGColorSpaceRelease(colorSpace);
  return finalImage;
 }
```
> Mat 默认颜色空间是BGR  ,而UIImage 默认颜色空间是RGB .因此 我们需要将Mat的BGR转换成RGB  再转换成UIImage ,同理,UIImage 也需要将UIImage 转换成Mat 的RGB再转换成BGR 再使用

# 4创建 Mat 对象

Mat 是一个非常优秀的图像类，它同时也是一个通用的矩阵类，可以用来创
建和操作多维矩阵。有多种方法创建一个 Mat 对象。

### 4.1 构造函数方法
Mat 类提供了一系列构造函数，可以方便的根据需要创建 Mat 对象。下面是 一个使用构造函数创建对象的例子。

```
Mat M(3,2, CV_8UC3, Scalar(0,0,255));
cout << "M = " << endl << " " << M << endl;
```

> 使用cout 输出到控制台需要使用命令空间`using namespace std;` 

第一行代码创建一个行数(高度)为 3，列数(宽度)为 2 的图像，图像元 素是 8 位无符号整数类型，且有三个通道。图像的所有像素值被初始化为(0, 0, 255)。由于 OpenCV 中默认的颜色顺序为 BGR，因此这是一个全红色的图像。

![](https://upload-images.jianshu.io/upload_images/1682758-dadafbdbdbdb85a5.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
第二行代码是输出 Mat 类的实例 M 的所有像素值。Mat 重定义了<<操作符， 使用这个操作符，可以方便地输出所有像素值，而不需要使用 for 循环逐个像素 输出。

该段代码的输出结果如下
```
M = 
 [  0,   0, 255,   0,   0, 255;
   0,   0, 255,   0,   0, 255;
   0,   0, 255,   0,   0, 255]
```
##### 常用的构造函数有:

+  Mat::Mat() 
`无参数构造方法;`
+ Mat::Mat(int rows, int cols, int type)
` 创建行数为 rows，列数为 col，类型为 type 的图像;`
+ Mat::Mat(Size size, int type)
`创建大小为 size，类型为 type 的图像;`
+ Mat::Mat(int rows, int cols, int type, const Scalar& s)
`创建行数为 rows，列数为 col，类型为 type 的图像，并将所有元素初始 化为值 s;`
+ Mat::Mat(Size size, int type, const Scalar& s)
`创建大小为 size，类型为 type 的图像，并将所有元素初始化为值 s;`
+ Mat::Mat(const Mat& m)
`将 m 赋值给新创建的对象，此处不会对图像数据进行复制，m 和新对象 共用图像数据;`
+ Mat::Mat(int rows, int cols, int type, void* data, size_t step=AUTO_STEP)
` 创建行数为 rows，列数为 col，类型为 type 的图像，此构造函数不创建 图像数据所需内存，而是直接使用 data 所指内存，图像的行步长由 step 指定。`
+ Mat::Mat(Size size, int type, void* data, size_t step=AUTO_STEP) 
`创建大小为 size，类型为 type 的图像，此构造函数不创建图像数据所需 内存，而是直接使用 data 所指内存，图像的行步长由 step 指定。`
+ Mat::Mat(const Mat& m, const Range& rowRange, const Range& colRange) 
`创建的新图像为 m 的一部分，具体的范围由 rowRange 和 colRange 指 定，此构造函数也不进行图像数据的复制操作，新图像与 m 共用图像数 据;`
+ Mat::Mat(const Mat& m, const Rect& roi)
`创建的新图像为 m 的一部分，具体的范围 roi 指定，此构造函数也不进 行图像数据的复制操作，新图像与 m 共用图像数据。`

> 这些构造函数中，很多都涉及到类型 type。`type 可以是 CV_8UC1，CV_16SC1，...， CV_64FC4` 等。`里面的 8U 表示 8 位无符号整数`，`16S 表示 16 位有符号整数`，`64F 表示 64 位浮点数(即 double 类型)`;`C 后面的数表示通道数`，例如 C1 表示一个 通道的图像，C4 表示 4 个通道的图像，以此类推。

如果你需要更多的通道数，需要用宏 CV_8UC(n)，例如:

```
Mat M(3,2, CV_8UC(5));//创建行数为3，列数为2，通道数为5的图像
```

### 4.2create()函数创建对象

除了在构造函数中可以创建图像，也可以使用 Mat 类的 create()函数创建图 像。如果 create()函数指定的参数与图像之前的参数相同，则不进行实质的内存 申请操作;如果参数不同，则减少原始数据内存的索引，并重新申请内存。使用 方法如下面例程所示:

```
Mat M(2,2, CV_8UC3);//构造函数创建图像
M.create(3,2, CV_8UC2);//释放内存重新创建图像
```
`需要注意的时，使用 create()函数无法设置图像像素的初始值。`

##### 测试代码
```
   Mat M(2,2, CV_8UC3,Scalar(0,0,0));//创建红色
   cout << "M = " << endl << " " << M << endl;
    M.create(3,2, CV_8UC4);//create 方式创建
    cout << "M = " << endl << " " << M << endl;
```
结果
```
M = 
 [  0,   0, 255,   0,   0, 255;
   0,   0, 255,   0,   0, 255]
M = 
 [  0,   0,   0,   0,  91,   0,   0,   0;
 160, 197,  31,   0,   0,  96,   0,   0;
   0,   0,   0,   0,   0,   0,   0, 112]
```

### 4.3 Matlab风格的创建对象方法
OpenCV 2 中提供了 Matlab 风格的函数，如 zeros()，ones()和 eyes()。这种方 法使得代码非常简洁，使用起来也非常方便。使用这些函数需要指定图像的大小 和类型，使用方法如下:

```
Mat Z = Mat::zeros(2,3, CV_8UC1);
cout << "Z = " << endl << " " << Z << endl;
Mat O = Mat::ones(2, 3, CV_32F);
cout << "O = " << endl << " " << O << endl;
Mat E = Mat::eye(2, 3, CV_64F);  
cout << "E = " << endl << " " << E << endl;
```
该代码中，有些 type 参数如 CV_32F 未注明通道数目，这种情况下它表示单 通道。上面代码的输出结果如下所示。
```
Z = 
 [  0,   0,   0;
   0,   0,   0]
O = 
 [1, 1, 1;
 1, 1, 1]
E = 
 [1, 0, 0;
 0, 1, 0]
```

# 5 矩阵的基本元素表达

`对于单通道图像，其元素类型一般为 8U(即 8 位无符号整数)，当然也可以 是 16S、32F 等;这些类型可以直接用 uchar、short、float 等 C/C++语言中的基本 数据类型表达。`

如果多通道图像，如 RGB 彩色图像，需要用三个通道来表示。在这种情况 下，如果依然将图像视作一个二维矩阵，那么矩阵的元素不再是基本的数据类型。

OpenCV 中有模板类 Vec，可以表示一个向量。OpenCV 中使用 Vec 类预定义了一 些小向量，可以将之用于矩阵元素的表达。
```
 typedef Vec<uchar, 2> Vec2b;
   typedef Vec<uchar, 3> Vec3b;
   typedef Vec<uchar, 4> Vec4b;
   typedef Vec<short, 2> Vec2s;
   typedef Vec<short, 3> Vec3s;
   typedef Vec<short, 4> Vec4s;
   typedef Vec<int, 2> Vec2i;
   typedef Vec<int, 3> Vec3i;
   typedef Vec<int, 4> Vec4i;
   typedef Vec<float, 2> Vec2f;
   typedef Vec<float, 3> Vec3f;
   typedef Vec<float, 4> Vec4f;
   typedef Vec<float, 6> Vec6f;
   typedef Vec<double, 2> Vec2d;
   typedef Vec<double, 3> Vec3d;
   typedef Vec<double, 4> Vec4d;
   typedef Vec<double, 6> Vec6d;
```

例如 8U 类型的 RGB 彩色图像可以使用 Vec3b，3 通道 float 类型的矩阵可以 使用 Vec3f。

对于 Vec 对象，可以使用[]符号如操作数组般读写其元素，如:
```
Vec3b color; //用color变量描述一种RGB颜色 
color[0]=255; //B分量
color[1]=0; //G分量
color[2]=0; //R分量
```

# 6 像素值的读写

很多时候，我们需要读取某个像素值，或者设置某个像素值;在更多的时候， 我们需要对整个图像里的所有像素进行遍历。OpenCV 提供了多种方法来实现图 像的遍历。

### 6.1 at()函数
函数 at()来实现读去矩阵中的某个像素，或者对某个像素进行赋值操作。下
面两行代码演示了 at()函数的使用方法。
```
uchar value = grayim.at<uchar>(i,j);//读出第i行第j列像素值
grayim.at<uchar>(i,j)=128; //将第i行第j列像素值设置为128
```
如果要对图像进行遍历，可以参考下面的例程。这个例程创建了两个图像， 分别是单通道的 grayim 以及 3 个通道的 colorim，然后对两个图像的所有像素值 进行赋值，最后现实结果。
```
-(void)atFunction{
    Mat grayim(600, 800, CV_8UC1);
    Mat colorim(600, 800, CV_8UC3);
    for( int i = 0; i < grayim.rows; ++i){
        for( int j = 0; j < grayim.cols; ++j ){
             grayim.at<uchar>(i,j) = (i+j)%255;
        }
    }
   
    //遍历所有像素，并设置像素值
    for( int i = 0; i < colorim.rows; ++i){
        for( int j = 0; j < colorim.cols; ++j ) {
           Vec3b pixel;
           pixel[0] = i%255; //Blue
            pixel[1] = j%255; //Green
            pixel[2] = 0; //Red
            colorim.at<Vec3b>(i,j) = pixel;
           }
    }
    UIImageView * imageView;
    imageView = [self createImageViewInRect:CGRectMake(0, 300, 100, 100)];
       [self.view addSubview:imageView];
       imageView.image  = [self UIImageFromCVMat:grayim];
    
    imageView = [self createImageViewInRect:CGRectMake(0, 400, 100, 100)];
        [self.view addSubview:imageView];
        imageView.image  = [self UIImageFromCVMat:colorim];
    
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

```
结果如下
![使用 at()函数遍历图像的例程的输出结果](https://upload-images.jianshu.io/upload_images/1682758-00e826ebb886a54c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> `需要注意的是，如果要遍历图像，并不推荐使用 at()函数。使用这个函数的 优点是代码的可读性高，但是效率并不是很高。`

### 6.2 使用迭代器
如果你熟悉 C++的 STL 库，那一定了解迭代器(iterator)的使用。迭代器可 以方便地遍历所有元素。Mat 也增加了迭代器的支持，以便于矩阵元素的遍历。 下面的例程功能跟上一节的例程类似，但是由于使用了迭代器，而不是使用行数 和列数来遍历，所以这儿没有了 i 和 j 变量，图像的像素值设置为一个随机数。

```
-(void)IteratorFunction{
    Mat grayim(600, 800, CV_8UC1);
    Mat colorim(600, 800, CV_8UC3);
    MatIterator_<uchar> grayit, grayend;
    for( grayit = grayim.begin<uchar>(),grayend=grayim.end<uchar>(); grayit != grayend; ++grayit){
        *grayit = rand()%255;
    }
    //遍历所有像素，并设置像素值
    MatIterator_<Vec3b> colorit, colorend;
    for( colorit = colorim.begin<Vec3b>(),colorend=colorim.end<Vec3b>(); colorit != colorend; ++colorit) {
        (*colorit)[0] = rand()%255; //Blue
        (*colorit)[1] = rand()%255; //Green
        (*colorit)[2] = rand()%255; //Red
    }
    
        UIImageView * imageView;
       imageView = [self createImageViewInRect:CGRectMake(100, 300, 100, 100)];
          [self.view addSubview:imageView];
          imageView.image  = [self UIImageFromCVMat:grayim];
       
       imageView = [self createImageViewInRect:CGRectMake(100, 400, 100, 100)];
           [self.view addSubview:imageView];
           imageView.image  = [self UIImageFromCVMat:colorim];
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
```
结果如下
![ 使用迭代器遍历图像的例程的输出结果](https://upload-images.jianshu.io/upload_images/1682758-0f32c125d44d5d9c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 6.3 通过数据指针
使用 IplImage 结构的时候，我们会经常使用数据指针来直接操作像素。通过 指针操作来访问像素是非常高效的，但是你务必十分地小心。C/C++中的指针操 作是不进行类型以及越界检查的，如果指针访问出错，程序运行时有时候可能看上去一切正常，有时候却突然弹出“段错误”(segment fault)。
当程序规模较大，且逻辑复杂时，查找指针错误十分困难。对于不熟悉指针 的编程者来说，指针就如同噩梦。如果你对指针使用没有自信，则不建议直接通 过指针操作来访问像素。虽然 at()函数和迭代器也不能保证对像素访问进行充分 的检查，但是总是比指针操作要可靠一些。

如果你非常注重程序的运行速度，那么遍历像素时，建议使用指针。下面的 例程演示如何使用指针来遍历图像中的所有像素。此例程实现的操作跟第 6.1 节中的例程完全相同。例程代码如下:
```
-(void)pointFunction{
    Mat grayim(600, 800, CV_8UC1);
    Mat colorim(600, 800, CV_8UC3);
    for( int i = 0; i < grayim.rows; ++i) {
    //获取第 i 行首像素指针
        uchar * p = grayim.ptr<uchar>(i);
    //对第 i 行的每个像素(byte)操作
        for( int j = 0; j < grayim.cols; ++j )
                     p[j] = (i+j)%255;
        }
    //遍历所有像素，并设置像素值
    for( int i = 0; i < colorim.rows; ++i) {
    //获取第 i 行首像素指针
        Vec3b * p = colorim.ptr<Vec3b>(i);
        for( int j = 0; j < colorim.cols; ++j ) {
            p[j][0] = i%255; //Blue
            p[j][1] = j%255; //Green
            p[j][2] = 0; //Red
        }
    }
    
    UIImageView * imageView;
      imageView = [self createImageViewInRect:CGRectMake(100, 100, 100, 100)];
         [self.view addSubview:imageView];
         imageView.image  = [self UIImageFromCVMat:grayim];
      
      imageView = [self createImageViewInRect:CGRectMake(200, 100, 100, 100)];
          [self.view addSubview:imageView];
          imageView.image  = [self UIImageFromCVMat:colorim];
}
```
结果如图
![使用指针遍历图像的例程的输出结果](https://upload-images.jianshu.io/upload_images/1682758-354373de14cd92d9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 7 选取图像局部区域
Mat 类提供了多种方便的方法来选择图像的局部区域。使用这些方法时需要 注意，这些方法并不进行内存的复制操作。如果将局部区域赋值给新的 Mat 对 象，新对象与原始对象共用相同的数据区域，不新申请内存，因此这些方法的执 行速度都比较快。

### 7.1 单行或单列选择
提取矩阵的一行或者一列可以使用函数 row()或 col()。函数的声明如下:
```
 Mat Mat::row(int i) const
  Mat Mat::col(int j) const
```
参数 i 和 j 分别是行标和列标。例如取出 A 矩阵的第 i 行可以使用如下代码:
```
Mat line = A.row(i);
```
例如取出 A 矩阵的第 i 行，将这一行的所有元素都乘以 2，然后赋值给第 j行，可以这样写:
```
 A.row(j) = A.row(i)*2;
```
##### 测试代码
```
-(void)rowOpateration{
     Mat grayim(2, 2, CV_8UC1);
    for( int i = 0; i < grayim.rows; ++i) {
     //获取第 i 行首像素指针
         uchar * p = grayim.ptr<uchar>(i);
     //对第 i 行的每个像素(byte)操作
         for( int j = 0; j < grayim.cols; ++j )
                      p[j] = 100;
         }
    UIImageView * imageView;
         imageView = [self createImageViewInRect:CGRectMake(100, 100, 100, 100)];
            [self.view addSubview:imageView];
            imageView.image  = [self UIImageFromCVMat:grayim];
         
        
     grayim.row(1) = grayim.row(0)*2;
    imageView = [self createImageViewInRect:CGRectMake(200, 100, 100, 100)];
    [self.view addSubview:imageView];
    imageView.image  = [self UIImageFromCVMat:grayim];
}

```
测试结果
![](https://upload-images.jianshu.io/upload_images/1682758-7f60597cb864f029.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
# 7.2 用Range选择多行或多列
Range 是 OpenCV 中新增的类，该类有两个关键变量 star 和 end。Range 对 象可以用来表示矩阵的多个连续的行或者多个连续的列。其`表示的范围`为`从 start 到 end`，`包含 start`，但`不包含 end`。Range 类的定义如下:

```
  class Range
   {
   public:
...
       int start, end;
   };
```

Range 类还提供了一个静态方法 all()，这个方法的作用如同 Matlab 中的“:”， 表示所有的行或者所有的列。
```
//创建一个单位阵
Mat A = Mat::eye(10, 10, CV_32S);
//提取第 1 到 3 列(不包括 3)
Mat B = A(Range::all(), Range(1, 3));
//提取 B 的第 5 至 9 行(不包括 9)
//其实等价于 C = A(Range(5, 9), Range(1, 3)) 
Mat C = B(Range(5, 9), Range::all());
```
图解如下

![](https://upload-images.jianshu.io/upload_images/1682758-e0a8bff3b3b8a2c0.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 7.3 感兴趣区域
从图像中提取感兴趣区域(Region of interest)有两种方法，一种是使用构造
函数，如下例所示:
```
/创建宽度为 320，高度为 240 的 3 通道图像
 Mat img(Size(320,240),CV_8UC3);
//roi 是表示 img 中 Rect(10,10,100,100)区域的对象
 Mat roi(img, Rect(10,10,100,100));
```
除了使用构造函数，还可以使用括号运算符，如下:
```
Mat roi2 = img(Rect(10,10,100,100));
```
当然也可以使用 Range 对象来定义感兴趣区域，如下:
```
//使用括号运算符
Mat roi3 = img(Range(10,100),Range(10,100));
//使用构造函数
Mat roi4(img, Range(10,100),Range(10,100));
```
### 7.4 取对角线元素
矩阵的对角线元素可以使用 Mat 类的 diag()函数获取，该函数的定义如下:
```
 Mat Mat::diag(int d) const
```
`参数 d=0 时，表示取主对角线;当参数 d>0 是，表示取主对角线下方的次对 角线，如 d=1 时，表示取主对角线下方，且紧贴主多角线的元素;当参数 d<0 时， 表示取主对角线上方的次对角线。`
如同 row()和 col()函数，diag()函数也不进行内存复制操作，其复杂度也是 O(1)。

##### 测试代码
```
///对角线测试
-(void)diag{
     Mat grayim(5, 5, CV_8UC1);
    for( int i = 0; i < grayim.rows; ++i) {
    //获取第 i 行首像素指针
        uchar * p = grayim.ptr<uchar>(i);
    //对第 i 行的每个像素(byte)操作
        for( int j = 0; j < grayim.cols; ++j )
            p[j] = i*grayim.rows+j;
        }
    
    cout << "grayim = " << endl << " " << grayim << endl;
    Mat diag = grayim.diag();
    cout << "diag = " << endl << " " << diag << endl;
    Mat diag1 = grayim.diag(-1);
    cout << "diag1 = " << endl << " " << diag1 << endl;
     Mat diag2 = grayim.diag(1);
    cout << "diag2 = " << endl << " " << diag2 << endl;
}
```
结果如下
```
grayim = 
 [  0,   1,   2,   3,   4;
   5,   6,   7,   8,   9;
  10,  11,  12,  13,  14;
  15,  16,  17,  18,  19;
  20,  21,  22,  23,  24]
diag = 
 [  0;
   6;
  12;
  18;
  24]
diag1 = 
 [  5;
  11;
  17;
  23]
diag2 = 
 [  1;
   7;
  13;
  19]
```

# 8 Mat 表达式
利用 C++中的运算符重载，OpenCV 2 中引入了 Mat 运算表达式。这一新特 点使得使用 C++进行编程时，就如同写 Matlab 脚本，代码变得简洁易懂，也便于 维护。

如果矩阵 A 和 B 大小相同，则可以使用如下表达式:
```
C = A + B + 1;
```
下面给出 Mat 表达式所支持的运算。下面的列表中使用 A 和 B 表示 Mat 类 型的对象，使用 s 表示 Scalar 对象，alpha 表示 double 值。

+ `加法，减法，取负:` A+B，A-B，A+s，A-s，s+A，s-A，-A
+ `缩放取值范围:` A*alpha
+ `矩阵对应元素的乘法和除法:`  A.mul(B)，A/B，alpha/A
+ `矩阵乘法:` A*B (注意此处是矩阵乘法，而不是矩阵对应元素相乘)
+ `矩阵转置:` A.t()
+ `矩阵求逆和求伪逆:` A.inv()
+ `矩阵比较运算:` A cmpop B，A cmpop alpha，alpha cmpop A。此处 cmpop 可以是>，>=，==，!=，<=，<。如果条件成立，则结果矩阵(8U 类型矩 阵)的对应元素被置为 255;否则置 0。
+ `矩阵位逻辑运算:` A logicop B，A logicop s，s logicop A，~A，此处 logicop 可以是&，|和^。
+  `矩阵对应元素的最大值和最小值:` min(A, B)，min(A, alpha)，max(A, B)， max(A, alpha)。
+  `矩阵中元素的绝对值:`abs(A)
+  `叉积和点积:` A.cross(B)，A.dot(B)

##### 代码举例
```
-(void)matComputer{
    Mat A = Mat::eye(4,4,CV_32SC1);
    Mat B = A * 3 + 1;
    Mat C = B.diag(0) + B.col(1);
    cout << "A = " << A << endl << endl;
    cout << "B = " << B << endl << endl;
    cout << "C = " << C << endl << endl;
    cout << "C .* diag(B) = " << C.dot(B.diag(0)) << endl;

}

```
测试结果
```
A = [1, 0, 0, 0;
 0, 1, 0, 0;
 0, 0, 1, 0;
 0, 0, 0, 1]

B = [4, 1, 1, 1;
 1, 4, 1, 1;
 1, 1, 4, 1;
 1, 1, 1, 4]

C = [5;
 8;
 5;
 5]
C .* diag(B) = 92

```

# 9 Mat_类

Mat_类是对 Mat 类的一个包装，其定义如下:
```
template<typename _Tp> class Mat_ : public Mat {
public:
//只定义了几个方法
//没有定义新的属性 
};
```
这是一个非常轻量级的包装，既然已经有 Mat 类，为何还要定义一个 Mat_? 下面我们看这段代码:
```
Mat M(600, 800, CV_8UC1);
for( int i = 0; i < M.rows; ++i) {
uchar * p = M.ptr<uchar>(i);
for( int j = 0; j < M.cols; ++j ) {
double d1 = (double) ((i+j)%255);
          M.at<uchar>(i,j) = d1;
double d2 = M.at<double>(i,j);//此行有错 }
}

```
在读取矩阵元素时，以及获取矩阵某行的地址时，需要指定数据类型。这样 首先需要不停地写“<uchar>”，让人感觉很繁琐，在繁琐和烦躁中容易犯错，如上面代码中的错误，用 at()获取矩阵元素时错误的使用了 double 类型。这种错误 不是语法错误，因此在编译时编译器不会提醒。在程序运行时，at()函数获取到 的不是期望的(i,j)位置处的元素，数据已经越界，但是运行时也未必会报错。这样 的错误使得你的程序忽而看上去正常，忽而弹出“段错误”，特别是在代码规模 很大时，难以查错。

如果使用 Mat_类，那么就可以在变量声明时确定元素的类型，访问元素时 不再需要指定元素类型，即使得代码简洁，又减少了出错的可能性。上面代码可 以用 Mat_实现，实现代码如下面例程里的第二个双重 for 循环。

```
   Mat M(600, 800, CV_8UC1);
    //在变量声明时指定矩阵元素类型
    Mat_<uchar> M1 = (Mat_<uchar>&)M;
    for( int i = 0; i < M1.rows; ++i) {
    //不需指定元素类型，语句简洁
    uchar * p = M1.ptr(i);
    for( int j = 0; j < M1.cols; ++j ) {
    double d1 = (double) ((i+j)%255);
    //直接使用 Matlab 风格的矩阵元素读写，简洁 M1(i,j) = d1;
    double d2 = M1(i,j);
    }
    }
```
> 读取数据能简单点并且不容易出错

# 10 Mat 类的内存管理
使用 Mat 类，内存管理变得简单，不再像使用 IplImage 那样需要自己申请 和释放内存。虽然不了解 Mat 的内存管理机制，也无碍于 Mat 类的使用，但是 如果清楚了解 Mat 的内存管理，会更清楚一些函数到底操作了哪些数据。
Mat 是一个类，由两个数据部分组成:矩阵头(包含矩阵尺寸，存储方法， 存储地址等信息)和一个指向存储所有像素值的矩阵的指针，如下图所示。矩阵头的尺寸是常数值，但矩阵本身的尺寸会依图像的不同而不同，通常比矩阵头 的尺寸大数个数量级。复制矩阵数据往往花费较多时间，因此除非有必要，不要 复制大的矩阵。
为了解决矩阵数据的传递，OpenCV 使用了引用计数机制。其思路是让每个 Mat 对象有自己的矩阵头信息，但多个 Mat 对象可以共享同一个矩阵数据。让矩 阵指针指向同一地址而实现这一目的。很多函数以及很多操作(如函数参数传值) 只复制矩阵头信息，而不复制矩阵数据。
前面提到过，有很多中方法创建 Mat 类。如果 Mat 类自己申请数据空间， 那么该类会多申请 4 个字节，多出的 4 个字节存储数据被引用的次数。引用次数 存储于数据空间的后面，refcount 指向这个位置，如下图 所示。当计数等于 0 时，则释放该空间。
![Mat 类中的数据存储示意图，refcount 变量指向数据区后面，用 4 个字节(int 类型) 存储引用数目](https://upload-images.jianshu.io/upload_images/1682758-14bd6646de1e43f9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

关于多个矩阵对象共享同一矩阵数据，我们可以看这个例子:
```
Mat A(100,100, CV_8UC1); 
Mat B = A;
Mat C = A(Rect(50,50,30,30));
```
上面代码中有三个 Mat 对象，分别是 A，B 和 C。这三者共有同一矩阵数据， 其示意图如下图所示。
![三个矩阵头共用共用同一矩阵数据](https://upload-images.jianshu.io/upload_images/1682758-7beb66ff706ee193.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

