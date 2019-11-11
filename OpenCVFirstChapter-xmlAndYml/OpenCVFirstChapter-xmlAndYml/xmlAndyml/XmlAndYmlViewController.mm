//
//  XmlAndYmlViewController.m
//  OpenCVFirstChapter-xmlAndYml
//
//  Created by glodon on 2019/11/11.
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
