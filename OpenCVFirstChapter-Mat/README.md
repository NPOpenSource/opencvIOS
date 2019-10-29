# 1.目的
# 2.Mat
# 3.存储 方法
# 4.显式地创建一个 Mat 对象
+ + 4.1.[Mat()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-mat) 构造函数
+ + 4.2.在 C\C++ 中通过构造函数进行初始化
+ + 4.3. [Create()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-create) function: 函数
+ +  4.4. MATLAB形式的初始化方式： [zeros()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-zeros), [ones()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-ones), :[eyes()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-eye) 。使用以下方式指定尺寸和数据类型：
# 5.格式化打印
+ + 5.1默认方式
+ +  5.2 Python
+ +  5.3以逗号分隔的数值 (CSV)
+ +  5.4 Numpy
+ +  5.5 C语言
# 6打印其它常用项目
+ + 6.1 2维点
+ + 6.2 3维点
+ + 6.3 基于cv::Mat的std::vector
+ + 6.4 std::vector点
-----------------

# 1.目的
从真实世界中获取数字图像有很多方法，比如数码相机、扫描仪、CT或者磁共振成像。无论哪种方法，我们（人类）看到的是图像，而让数字设备来“看“的时候，则是在记录图像中的每一个点的数值。
![](https://upload-images.jianshu.io/upload_images/1682758-97c0b87077df418e.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

比如上面的图像，在标出的镜子区域中你见到的只是一个矩阵，该矩阵包含了所有像素点的强度值。如何获取并存储这些像素值由我们的需求而定，最终在计算机世界里所有图像都可以简化为数值矩以及矩阵信息。作为一个计算机视觉库， OpenCV 其主要目的就是通过处理和操作这些信息，来获取更高级的信息。因此，OpenCV如何存储并操作图像是你首先要学习的。

# 2.Mat

在2001年刚刚出现的时候，OpenCV基于 C 语言接口而建。为了在内存（memory）中存放图像，当时采用名为` IplImage` 的C语言结构体，时至今日这仍出现在大多数的旧版教程和教学材料。但这种方法必须接受C语言所有的不足，这其中`最大的不足`要数`手动内存管理`，其依据是用户要为开辟和销毁内存负责。虽然对于小型的程序来说手动管理内存不是问题，但一旦代码开始变得越来越庞大，你需要越来越多地纠缠于这个问题，而不是着力解决你的开发目标。

幸运的是，C++出现了，并且带来类的概念，这给用户带来另外一个选择：自动的内存管理（不严谨地说）。这是一个好消息，如果C++完全兼容C的话，这个变化不会带来兼容性问题。为此，OpenCV在2.0版本中引入了一个新的C++接口，利用自动内存管理给出了解决问题的新方法。使用这个方法，你不需要纠结在管理内存上，而且你的代码会变得简洁（少写多得）。但C++接口唯一的不足是当前许多嵌入式开发系统只支持C语言。所以，当目标不是这种开发平台时，没有必要使用 旧 方法（除非你是自找麻烦的受虐狂码农）。

`关于 Mat ，首先要知道的是你不必再手动地为其开辟空间,在不需要时立即将空间释放。`但手动地做还是可以的：大多数OpenCV函数仍会手动地为输出数据开辟空间。当传递一个已经存在的 Mat 对象时，开辟好的矩阵空间会被重用。也就是说，我们每次都使用大小正好的内存来完成任务。

`基本上讲 Mat 是一个类，由两个数据部分组成：矩阵头（包含矩阵尺寸，存储方法，存储地址等信息）和一个指向存储所有像素值的矩阵（根据所选存储方法的不同矩阵可以是不同的维数）的指针。``矩阵头的尺寸是常数值`，但矩阵本身的尺寸会依图像的不同而不同，通常比矩阵头的尺寸大数个数量级。因此，当在程序中传递图像并创建拷贝时，大的开销是由矩阵造成的，而不是信息头。OpenCV是一个图像处理库，囊括了大量的图像处理函数，为了解决问题通常要使用库中的多个函数，因此在函数中传递图像是家常便饭。同时不要忘了我们正在讨论的是计算量很大的图像处理算法，因此，`除非万不得已，我们不应该拷贝 大 的图像，因为这会降低程序速度`。

为了搞定这个问题，OpenCV使用引用计数机制。其思路是让每个 Mat 对象有自己的信息头，但共享同一个矩阵。这通过让矩阵指针指向同一地址而实现。而拷贝构造函数则 只拷贝信息头和矩阵指针 ，而不拷贝矩阵。

```
Mat A, C;                                 // 只创建信息头部分
Mat ,(300,200, CV_8UC3, Scalar(0,0,255)); // 这里为矩阵开辟内存
Mat B(A);                                 // 使用拷贝构造函数
C = A;                                    // 赋值运算符
```
以上代码中的所有Mat对象最终都指向同一个也是唯一一个数据矩阵。虽然它们的信息头不同，但通过任何一个对象所做的改变也会影响其它对象。实际上，不同的对象只是访问相同数据的不同途径而已。这里还要提及一个比较棒的功能：你可以创建只引用部分数据的信息头。比如想要创建一个感兴趣区域（ ROI ），你只需要创建包含边界信息的信息头：
```
Mat D (A, Rect(10, 10, 100, 100) ); // using a rectangle
Mat E = A(Range:all(), Range(1,3)); // using row and column boundaries
```
现在你也许会问，如果矩阵属于多个 *Mat* 对象，那么当不再需要它时谁来负责清理？简单的回答是：最后一个使用它的对象。通过引用计数机制来实现。无论什么时候有人拷贝了一个 *Mat* 对象的信息头，都会增加矩阵的引用次数；反之当一个头被释放之后，这个计数被减一；当计数值为零，矩阵会被清理。但某些时候你仍会想拷贝矩阵本身(不只是信息头和矩阵指针)，这时可以使用函数 [clone()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-clone) 或者  [copyTo()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-copyto) 。

```
Mat F = A.clone();
Mat G;
A.copyTo(G);
```
现在改变 F 或者 G 就不会影响 Mat 信息头所指向的矩阵。总结一下，你需要记住的是

*   OpenCV函数中输出图像的内存分配是自动完成的（如果不特别指定的话）。
*   使用OpenCV的C++接口时不需要考虑内存释放问题。
*   赋值运算符和拷贝构造函数（ *ctor* ）只拷贝信息头。
*   使用函数 [clone()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-clone) 或者 [copyTo()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-copyto) 来拷贝一副图像的矩阵。


# 3.存储方法

这里讲述`如何存储像素值。需要指定颜色空间和数据类型`。`颜色空间是指对一个给定的颜色，如何组合颜色元素以对其编码`。最简单的颜色空间要属灰度级空间，只处理黑色和白色，对它们进行组合可以产生不同程度的灰色。

对于 `彩色方式`则`有更多种类的颜色空间`，但不论哪种方式都是`把颜色分成三个或者四个基元素`，通过组合基元素可以产生所有的颜色。RGB颜色空间是最常用的一种颜色空间，这归功于它也是人眼内部构成颜色的方式。它的基色是红色、绿色和蓝色，有时为了表示透明颜色也会加入第四个元素 alpha (A)。

有很多的颜色系统，各有自身优势：
+ RGB是最常见的，这是因为人眼采用相似的工作机制，它也被显示设备所采用。
+ HSV和HLS把颜色分解成色调、饱和度和亮度/明度。这是描述颜色更自然的方式，比如可以通过抛弃最后一个元素，使算法对输入图像的光照条件不敏感。
+ YCrCb在JPEG图像格式中广泛使用。
+ CIE L*a*b*是一种在感知上均匀的颜色空间，它适合用来度量两个颜色之间的 距离 。

每个组成元素都有其自己的定义域，取决于其数据类型。如何存储一个元素决定了我们在其定义域上能够控制的精度。最小的数据类型是 char ，占一个字节或者8位，可以是有符号型（0到255之间）或无符号型（-127到+127之间）。尽管使用三个 char 型元素已经可以表示1600万种可能的颜色（使用RGB颜色空间），但若使用float（4字节，32位）或double（8字节，64位）则能给出更加精细的颜色分辨能力。但同时也要切记增加元素的尺寸也会增加了图像所占的内存空间。

# 4.显式地创建一个 Mat 对象
Mat 不但是一个很赞的图像容器类，它同时也是一个通用的矩阵类，所以可以用来创建和操作多维矩阵。创建一个Mat对象有多种方法：

### 4.1.[Mat()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-mat) 构造函数
```
    Mat M(2,2, CV_8UC3, Scalar(0,0,255)); 
    cout << "M = " << endl << " " << M << endl << endl;   
```
![](https://upload-images.jianshu.io/upload_images/1682758-09cc47c7ae843019.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

对于二维多通道图像，首先要定义其尺寸，即行数和列数。
然后，需要指定存储元素的数据类型以及每个矩阵点的通道数。为此，依据下面的规则有多种定义
```
CV_[The number of bits per item][Signed or Unsigned][Type Prefix]C[The channel number]
```
比如 *CV_8UC3* 表示使用8位的 unsigned char 型，每个像素由三个元素组成三通道。预先定义的通道数可以多达四个。  [Scalar](http://opencv.itseez.com/modules/core/doc/basic_structures.html#scalar) 是个short型vector。指定这个能够使用指定的定制化值来初始化矩阵。当然，如果你需要更多通道数，你可以使用大写的宏并把通道数放在小括号中，如下所示

### 4.2.在 C\C++ 中通过构造函数进行初始化
```
int sz[3] = {2,2,2}; 
Mat L(3,sz, CV_8UC(1), Scalar::all(0));
```
上面的例子演示了如何创建一个超过两维的矩阵：指定维数，然后传递一个指向一个数组的指针，这个数组包含每个维度的尺寸；其余的相同
### 4.3. [Create()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-create) function: 函数
```
 M.create(4,4, CV_8UC(2));
    cout << "M = "<< endl << " "  << M << endl << endl;
```
![](https://upload-images.jianshu.io/upload_images/1682758-5d7f4cf66a6d4d73.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
这个创建方法不能为矩阵设初值，它只是在改变尺寸时重新为矩阵数据开辟内存。
----
[github地址](https://github.com/NPOpenSource/opencvIOS)

### 4.4. MATLAB形式的初始化方式： [zeros()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-zeros), [ones()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-ones), :[eyes()](http://opencv.itseez.com/modules/core/doc/basic_structures.html#mat-eye) 。使用以下方式指定尺寸和数据类型：
```
 Mat E = Mat::eye(4, 4, CV_64F);    
    cout << "E = " << endl << " " << E << endl << endl;
    
    Mat O = Mat::ones(2, 2, CV_32F);    
    cout << "O = " << endl << " " << O << endl << endl;

    Mat Z = Mat::zeros(3,3, CV_8UC1);
    cout << "Z = " << endl << " " << Z << endl << endl;
```
![](https://upload-images.jianshu.io/upload_images/1682758-e1195e455d7ca1fc.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 5.格式化打印
> Note
> 调用函数 [randu()](http://opencv.itseez.com/modules/core/doc/operations_on_arrays.html#randu) 来对一个矩阵使用随机数填充，需要指定随机数的上界和下界：
> ```
> Mat R = Mat(3, 2, CV_8UC3);
> randu(R, Scalar::all(0), Scalar::all(255));
> ```

从上面的例子中可以看到默认格式，除此之外，OpenCV还支持以下的输出习惯
### 5.1默认方式
```
 cout << "R (default) = " << endl <<        R           << endl << endl;
```
![](https://upload-images.jianshu.io/upload_images/1682758-c7080e04888a3fc1.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
### 5.2 Python
```
 cout << "R (python)  = " << endl << format(R,"python") << endl << endl;
```
![](https://upload-images.jianshu.io/upload_images/1682758-d7ba2fe7382c6142.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
### 5.3以逗号分隔的数值 (CSV)
```
  cout << "R (csv)     = " << endl << format(R,"csv"   ) << endl << endl;
```
![](https://upload-images.jianshu.io/upload_images/1682758-c041ce19f4447792.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 5.4 Numpy
```
 cout << "R (numpy)   = " << endl << format(R,"numpy" ) << endl << endl;
```
![](https://upload-images.jianshu.io/upload_images/1682758-9108958262ee5698.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 5.5 C语言
![](https://upload-images.jianshu.io/upload_images/1682758-581f44565278433f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

# 6打印其它常用项目
OpenCV支持使用运算符<<来打印其它常用OpenCV数据结构。

### 6.1 2维点
```
 Point2f P(5, 1);
  cout << "Point (2D) = " << P << endl << endl;
```
![](https://upload-images.jianshu.io/upload_images/1682758-392714238bfbe481.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
### 6.2 3维点
```
Point3f P3f(2, 6, 7);
    cout << "Point (3D) = " << P3f << endl << endl;
```
![](https://upload-images.jianshu.io/upload_images/1682758-988371ddb09641d2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 6.3 基于cv::Mat的std::vector
```
 vector<float> v;
    v.push_back( (float)CV_PI);   v.push_back(2);    v.push_back(3.01f);
    cout << "Vector of floats via Mat = " << Mat(v) << endl << endl;
```
![](https://upload-images.jianshu.io/upload_images/1682758-59338bfb26716b3d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

### 6.4 std::vector点
```
   vector<Point2f> vPoints(20);
    for (size_t E = 0; E < vPoints.size(); ++E)
        vPoints[E] = Point2f((float)(E * 5), (float)(E % 7));

    cout << "A vector of 2D Points = " << vPoints << endl << endl;
```
  ![](https://upload-images.jianshu.io/upload_images/1682758-9a5fdb235c009ecd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

以上内容都可在github工程[OpenCVFirstProject](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVFirstChapter-Mat)查看

-----
[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVFirstChapter-Mat)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/core/mat%20-%20the%20basic%20image%20container/mat%20-%20the%20basic%20image%20container.html#matthebasicimagecontainer)