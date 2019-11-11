# 目的

你将得到以下几个问题的答案:

*   如何将文本写入YAML或XML文件，及如何从从OpenCV中读取YAML或XML文件中的文本
*   如何利用YAML或XML文件存取OpenCV数据结构
*   如何利用YAML或XML文件存取自定义数据结构?
*   OpenCV中相关数据结构的使用方法，如 ：xmlymlpers:<cite>FileStorage <filestorage></cite>, [FileNode](http://opencv.itseez.com/modules/core/doc/xml_yaml_persistence.html#filenode) 或 [FileNodeIterator](http://opencv.itseez.com/modules/core/doc/xml_yaml_persistence.html#filenodeiterator).

# 代码
以下用简单的示例代码演示如何逐一实现所有目的.
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
#import "XmlAndYmlViewController.h"


class MyData
{
public:
    MyData() : A(0), X(0), id()
    {}
    explicit MyData(int) : A(97), X(CV_PI), id("mydata1234") // explicit to avoid implicit conversion
    {}
    void write(FileStorage& fs) const                        //Write serialization for this class
    {
        fs << "{" << "A" << A << "X" << X << "id" << id << "}";
    }
    void read(const FileNode& node)                          //Read serialization for this class
    {
        A = (int)node["A"];
        X = (double)node["X"];
        id = (string)node["id"];
    }
public:   // Data Members
    int A;
    double X;
    string id;
};

void write(FileStorage& fs, const std::string&, const MyData& x)
{
    x.write(fs);
}
void read(const FileNode& node, MyData& x, const MyData& default_value = MyData()){
    if(node.empty())
        x = default_value;
    else
        x.read(node);
}

// This function will print our custom class to the console
ostream& operator<<(ostream& out, const MyData& m)
{
    out << "{ id = " << m.id << ", ";
    out << "X = " << m.X << ", ";
    out << "A = " << m.A << "}";
    return out;
}


@interface XmlAndYmlViewController ()

@end

@implementation XmlAndYmlViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString * path = NSTemporaryDirectory();
//    path = [path stringByAppendingPathComponent:@"a.xml"];
    path = [path stringByAppendingPathComponent:@"b.yaml"];

    NSLog(@"%@",path);
    string filename(path.UTF8String);
    {
        Mat R = Mat_<uchar>::eye(3, 3),
        T = Mat_<double>::zeros(3, 1);
        MyData m(1);
        FileStorage fs(filename, FileStorage::WRITE);
        
        fs << "iterationNr" << 100;
        fs << "strings" << "[";                              // text - string sequence
        fs << "image1.jpg" << "Awesomeness" << "baboon.jpg";
        fs << "]";                                           // close sequence
               
        fs << "Mapping";                              // text - mapping
        fs << "{" << "One" << 1;
        fs <<        "Two" << 2 << "}";

        fs << "R" << R;                                      // cv::Mat
        fs << "T" << T;

        fs << "MyData" << m;                                // your own data structures

        fs.release();                                       // explicit close
        cout << "Write Done." << endl;
    }
    {//read
           cout << endl << "Reading: " << endl;
           FileStorage fs;
           fs.open(filename, FileStorage::READ);

           int itNr;
           //fs["iterationNr"] >> itNr;
           itNr = (int) fs["iterationNr"];
           cout << itNr;
           if (!fs.isOpened())
           {
               cerr << "Failed to open " << filename << endl;
               return ;
           }

           FileNode n = fs["strings"];                         // Read string sequence - Get node
           if (n.type() != FileNode::SEQ)
           {
               cerr << "strings is not a sequence! FAIL" << endl;
               return ;
           }

           FileNodeIterator it = n.begin(), it_end = n.end(); // Go through the node
           for (; it != it_end; ++it)
               cout << (string)*it << endl;
           
           
           n = fs["Mapping"];                                // Read mappings from a sequence
           cout << "Two  " << (int)(n["Two"]) << "; ";
           cout << "One  " << (int)(n["One"]) << endl << endl;
           

           MyData m;
           Mat R, T;

           fs["R"] >> R;                                      // Read cv::Mat
           fs["T"] >> T;
           fs["MyData"] >> m;                                 // Read your own structure_

           cout << endl
               << "R = " << R << endl;
           cout << "T = " << T << endl << endl;
           cout << "MyData = " << endl << m << endl << endl;

           //Show default behavior for non existing nodes
           cout << "Attempt to read NonExisting (should initialize the data structure with its default).";
           fs["NonExisting"] >> m;
           cout << endl << "NonExisting = " << endl << m << endl;
       }

       cout << endl
           << "Tip: Open up " << filename << " with a text editor to see the serialized data." << endl;

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
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
# 代码分析

###  1.XML\YAML 文件的打开和关闭
在你写入内容到此类文件中前，你必须先打开它，并在结束时关闭它。在OpenCV中标识XML和YAML的数据结构是 [FileStorage](http://opencv.itseez.com/modules/core/doc/xml_yaml_persistence.html#filestorage) 。要将此结构和硬盘上的文件绑定时，可使用其构造函数或者 *open()* 函数:
```
 NSString * path = NSTemporaryDirectory();
    path = [path stringByAppendingPathComponent:@"a.xml"];
    string filename(path.UTF8String);
FileStorage fs(filename, FileStorage::WRITE);
\\...
fs.open(filename, FileStorage::READ);
```

无论以哪种方式绑定，函数中的第二个参数都以常量形式指定你要对文件进行操作的类型，包括：WRITE, READ 或 APPEND。文件扩展名决定了你将采用的输出格式。如果你指定扩展名如 .xml.gz ，输出甚至可以是压缩文件。

当 [FileStorage](http://opencv.itseez.com/modules/core/doc/xml_yaml_persistence.html#filestorage) 对象被销毁时，文件将自动关闭。当然你也可以显示调用 *release* 函数:
```
fs.release();                                       // 显示关闭
```

### 2.输入\输出文本和数字。

 数据结构使用与STL相同的 << 输出操作符。输出任何类型的数据结构时，首先都必须指定其标识符,这通过简单级联输出标识符即可实现。基本类型数据输出必须遵循此规则:
```
fs << "iterationNr" << 100;
```
读入则通过简单的寻址（通过 [] 操作符）操作和强制转换或 >> 操作符实现：
```
int itNr;
fs["iterationNr"] >> itNr;
itNr = (int) fs["iterationNr"];
```
### 3.输入\输出OpenCV数据结构
 其实和对基本类型的操作方法是相同的:
```
Mat R = Mat_<uchar >::eye  (3, 3),
    T = Mat_<double>::zeros(3, 1);

fs << "R" << R;                                      // 写 cv::Mat
fs << "T" << T;

fs["R"] >> R;                                      // 读 cv::Mat
fs["T"] >> T;
```
### 4.输入\输出 vectors（数组）和相应的map

之前提到我们也可以输出maps和序列（数组, vector)。同样，首先输出变量的标识符，接下来必须指定输出的是序列还是map。

对于序列，在第一个元素前输出”[“字符，并在最后一个元素后输出”]“字符：
```
fs << "strings" << "[";                              // 文本 - 字符串序列
fs << "image1.jpg" << "Awesomeness" << "baboon.jpg";
fs << "]";   
```

对于maps使用相同的方法，但采用”{“和”}“作为分隔符。

```
fs << "Mapping";                              // 文本 - mapping
fs << "{" << "One" << 1;
fs <<        "Two" << 2 << "}";
```
对于数据读取，可使用 [FileNode](http://opencv.itseez.com/modules/core/doc/xml_yaml_persistence.html#filenode) 和 [FileNodeIterator](http://opencv.itseez.com/modules/core/doc/xml_yaml_persistence.html#filenodeiterator) 数据结构。 [FileStorage](http://opencv.itseez.com/modules/core/doc/xml_yaml_persistence.html#filestorage) 的[] 操作符将返回一个 [FileNode](http://opencv.itseez.com/modules/core/doc/xml_yaml_persistence.html#filenode) 数据类型。如果这个节点是序列化的，我们可以使用 [FileNodeIterator](http://opencv.itseez.com/modules/core/doc/xml_yaml_persistence.html#filenodeiterator) 来迭代遍历所有元素。
```
FileNode n = fs["strings"];                         // 读取字符串序列 - 获取节点
if (n.type() != FileNode::SEQ)
{
    cerr << "strings is not a sequence! FAIL" << endl;
    return 1;
}

FileNodeIterator it = n.begin(), it_end = n.end(); // 遍历节点
for (; it != it_end; ++it)
    cout << (string)*it << endl;
```
对于maps类型，可以用 [] 操作符访问指定的元素（或者 >> 操作符）：
```
n = fs["Mapping"];                                // 从序列中读取map
cout << "Two  " << (int)(n["Two"]) << "; ";
cout << "One  " << (int)(n["One"]) << endl << endl;
```
### 5.读写自定义数据类型
假设你定义了如下数据类型：
```
class MyData
{
public:
      MyData() : A(0), X(0), id() {}
public:   // 数据成员
   int A;
   double X;
   string id;
};

```
添加内部和外部的读写函数，就可以使用OpenCV I/O XML/YAML接口对其进行序列化（就像对OpenCV数据结构进行序列化一样）。内部函数定义如下：

```
void write(FileStorage& fs) const                        //对自定义类进行写序列化
{
  fs << "{" << "A" << A << "X" << X << "id" << id << "}";
}

void read(const FileNode& node)                          //从序列读取自定义类
{
  A = (int)node["A"];
  X = (double)node["X"];
  id = (string)node["id"];
}

```
接下来在类的外部定义以下函数：
```
void write(FileStorage& fs, const std::string&, const MyData& x)
{
x.write(fs);
}

void read(const FileNode& node, MyData& x, const MyData& default_value = MyData())
{
if(node.empty())
    x = default_value;
else
    x.read(node);
}
```
这儿可以看到，如果读取的节点不存在，我们返回默认值。更复杂一些的解决方案是返回一个对象ID为负值的实例。

一旦添加了这四个函数，就可以用 >> 操作符和 << 操作符分别进行读，写操作：
```
MyData m(1);
fs << "MyData" << m;                               // 写自定义数据结构
fs["MyData"] >> m;           
```
或试着读取不存在的值:
```
fs["NonExisting"] >> m;   // 请注意不是 fs << "NonExisting" << m
cout << endl << "NonExisting = " << endl << m << endl;

```
# 结果
好的，大多情况下我们只输出定义过的成员。在控制台程序的屏幕上，你将看到：


```
2019-11-11 18:57:01.252423+0800 OpenCVFirstChapter-xmlAndYml[17015:4243747] /Users/glodon/Library/Developer/CoreSimulator/Devices/2EF925FE-8B90-44DB-B7C9-4F232F801257/data/Containers/Data/Application/53150162-5191-474C-8F3D-EFFF311F0B3B/tmp/a.xml
Write Done.

Reading: 
100image1.jpg
Awesomeness
baboon.jpg
Two  2; One  1


R = [  1,   0,   0;
   0,   1,   0;
   0,   0,   1]
T = [0;
 0;
 0]

MyData = 
{ id = mydata1234, X = 3.14159, A = 97}

Attempt to read NonExisting (should initialize the data structure with its default).
NonExisting = 
{ id = , X = 0, A = 0}

Tip: Open up /Users/glodon/Library/Developer/CoreSimulator/Devices/2EF925FE-8B90-44DB-B7C9-4F232F801257/data/Containers/Data/Application/53150162-5191-474C-8F3D-EFFF311F0B3B/tmp/a.xml with a text editor to see the serialized data.

```

然而, 在输出的xml文件中看到的结果将更加有趣：
```
<?xml version="1.0"?>
<opencv_storage>
<iterationNr>100</iterationNr>
<strings>
  image1.jpg Awesomeness baboon.jpg</strings>
<Mapping>
  <One>1</One>
  <Two>2</Two></Mapping>
<R type_id="opencv-matrix">
  <rows>3</rows>
  <cols>3</cols>
  <dt>u</dt>
  <data>
    1 0 0 0 1 0 0 0 1</data></R>
<T type_id="opencv-matrix">
  <rows>3</rows>
  <cols>1</cols>
  <dt>d</dt>
  <data>
    0. 0. 0.</data></T>
<MyData>
  <A>97</A>
  <X>3.1415926535897931e+000</X>
  <id>mydata1234</id></MyData>
</opencv_storage>
```
或YAML文件：
```
%YAML:1.0
iterationNr: 100
strings:
   - "image1.jpg"
   - Awesomeness
   - "baboon.jpg"
Mapping:
   One: 1
   Two: 2
R: !!opencv-matrix
   rows: 3
   cols: 3
   dt: u
   data: [ 1, 0, 0, 0, 1, 0, 0, 0, 1 ]
T: !!opencv-matrix
   rows: 3
   cols: 1
   dt: d
   data: [ 0., 0., 0. ]
MyData:
   A: 97
   X: 3.1415926535897931e+000
   id: mydata1234
```
--------

[github 地址](https://github.com/NPOpenSource/opencvIOS/tree/master/OpenCVFirstChapter-xmlAndYml)

[摘录博客](http://www.opencv.org.cn/opencvdoc/2.3.2/html/doc/tutorials/core/file_input_output_with_xml_yml/file_input_output_with_xml_yml.html#id2)