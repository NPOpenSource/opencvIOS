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
         << " of nr#: " << captRefrnc.get(CV_CAP_PROP_FRAME_COUNT)<<"  FPS: "<< captRefrnc.get(CV_CAP_PROP_FPS) << endl;

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
        begin =YES;
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
