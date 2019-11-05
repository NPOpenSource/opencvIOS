//
//  RandomAndTextViewController.m
//  OpenCVFirstChapter-randomGeneratorAndText
//
//  Created by glodon on 2019/11/1.
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

     for (int i = 0; i < NUMBER; i++)
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
