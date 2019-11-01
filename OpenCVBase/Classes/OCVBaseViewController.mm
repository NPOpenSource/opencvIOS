//
//  OCVBaseViewController.m
//  OpenCVBase
//
//  Created by glodon on 2019/10/23.
//

#import "OCVBaseViewController.h"
#import <objc/runtime.h>

@interface UISlider (exeBlock)
@property (nonatomic ,strong) void (^exeBlock)(float value) ;
@end
static int sliderExeBlockKey;
@implementation UISlider(exeBlock)
- (void)setExeBlock:(void (^)(float))exeBlock{
     objc_setAssociatedObject(self, &sliderExeBlockKey, exeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^)(float))exeBlock{
     return  objc_getAssociatedObject(self,  &sliderExeBlockKey);
}

@end

@interface OCVBaseViewController ()

@end

@implementation OCVBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
}

-(UIImageView *)createImageViewInRect:(CGRect)frame{
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:frame];
    return imageView;
}

-(UISlider *)createSliderFrame:(CGRect )frame maxValue:(float)maxValue minValue:(float)minValue block:(void(^)(float value))exeBlock{
    UISlider *slider = [[UISlider alloc] initWithFrame:frame];
    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    slider.maximumValue = maxValue;
    slider.minimumValue = minValue;
    slider.exeBlock = exeBlock;
      [self.view addSubview:slider];
    return slider;
}

-(void)sliderAction:(UISlider*)slider{
    slider.exeBlock(slider.value);
}


@end
