//
//  OCVBaseViewController.m
//  OpenCVBase
//
//  Created by glodon on 2019/10/23.
//

#import "OCVBaseViewController.h"
#import <objc/runtime.h>



@interface UIButton (exeBlock)
@property (nonatomic ,strong) NSString* (^exeBlock)(int hitCount) ;
@property (nonatomic ,strong) NSNumber * hitCount ;
@end

@implementation UIButton(exeBlock)

static int buttonExeBlockKey;
static int buttonhitCountKey;

-(void)setHitCount:(NSNumber *)hitCount{
    objc_setAssociatedObject(self, &buttonhitCountKey, hitCount, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSNumber *)hitCount{
    return  objc_getAssociatedObject(self,  &buttonhitCountKey);

}

-(void)setExeBlock:(NSString *(^)(int))exeBlock{
    objc_setAssociatedObject(self, &buttonExeBlockKey, exeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSString *(^)(int))exeBlock{
    return  objc_getAssociatedObject(self,  &buttonExeBlockKey);
}

@end


@interface UISlider (exeBlock)
@property (nonatomic ,strong) void (^exeBlock)(float value) ;
@property (nonatomic ,weak) UILabel * valuelabel;



@end
static int sliderExeBlockKey;
static int slidervalueLabelBlockKey;

@implementation UISlider(exeBlock)
- (void)setExeBlock:(void (^)(float))exeBlock{
     objc_setAssociatedObject(self, &sliderExeBlockKey, exeBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (void (^)(float))exeBlock{
     return  objc_getAssociatedObject(self,  &sliderExeBlockKey);
}

-(void)setValuelabel:(UILabel *)valuelabel{
    objc_setAssociatedObject(self, &slidervalueLabelBlockKey, valuelabel, OBJC_ASSOCIATION_ASSIGN);
}
-(UILabel *)valuelabel{
        return  objc_getAssociatedObject(self,  &slidervalueLabelBlockKey);
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

-(UISlider *)createSliderFrame:(CGRect )frame maxValue:(float)maxValue currentValue:(float)currentValue minValue:(float)minValue block:(void(^)(float value))exeBlock{
  UILabel * label =  [self createLabelFrame:CGRectMake(frame.origin.x, frame.origin.y, 50, frame.size.height)];
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(frame.origin.x+50, frame.origin.y, frame.size.width-50, frame.size.height)];
       [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
       slider.maximumValue = maxValue;
       slider.minimumValue = minValue;
       slider.exeBlock = exeBlock;
    slider.valuelabel = label;
    if (maxValue>1) {
         label.text = [NSString stringWithFormat:@"%d",(int)currentValue];
    }else{
        label.text = [NSString stringWithFormat:@"%f",currentValue];
    }
    slider.value = currentValue;
    [self.view addSubview:slider];
       return slider;
}

-(UISlider *)createSliderFrame:(CGRect )frame maxValue:(float)maxValue minValue:(float)minValue block:(void(^)(float value))exeBlock {
    return [self createSliderFrame:frame maxValue:maxValue currentValue:minValue minValue:minValue block:exeBlock];
}

-(void)sliderAction:(UISlider*)slider{
      if (slider.maximumValue>1) {
           slider.valuelabel.text = [NSString stringWithFormat:@"%d",(int)slider.value];
      }else{
           slider.valuelabel.text = [NSString stringWithFormat:@"%f",slider.value];
      }
    slider.exeBlock(slider.value);
}


-(UIButton *)createButtonFrame:(CGRect)frame title:(NSString *)title Block:(NSString*(^)(int hitCount))exeBlock{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.view addSubview:button];
    button.frame = frame;
    button.exeBlock = exeBlock;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchDown];
    return button;
}

-(void)buttonAction:(UIButton *)button{
    int m = button.hitCount.intValue;
    button.hitCount=@(++m);
    NSString * title =   button.exeBlock(m);
    if (title.length>0) {
          [button setTitle:title forState:UIControlStateNormal];
    }
}

-(NSTimer *)createTimer:(NSTimeInterval)seconds exeBlock:(void(^)(void))block{
 return [NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector(exeTimerBlock:) userInfo:[block copy] repeats:YES];
   
}

-(void)exeTimerBlock:(NSTimer *)timer{
    if ([timer userInfo]) {
        void (^block)(void) = (void (^)(void))[timer userInfo];
        block();
    }
}

-(UILabel *)createLabelFrame:(CGRect )rect{
    UILabel * label = [[UILabel alloc]initWithFrame:rect];
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = [UIColor blackColor];
    [self.view addSubview:label];
    return label;
}

@end
