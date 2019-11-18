//
//  OCVBaseViewController.h
//  OpenCVBase
//
//  Created by glodon on 2019/10/23.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCVBaseViewController : UIViewController
-(UIImageView *)createImageViewInRect:(CGRect)frame;
-(UISlider *)createSliderFrame:(CGRect )frame maxValue:(float)maxValue minValue:(float)intValue block:(void(^)(float value))exeBlock;
-(UISlider *)createSliderFrame:(CGRect )frame maxValue:(float)maxValue currentValue:(float)currentValue minValue:(float)minValue block:(void(^)(float value))exeBlock;

-(UIButton *)createButtonFrame:(CGRect)frame title:(NSString *)title Block:(NSString*(^)(int hitCount))exeBlock;

-(NSTimer *)createTimer:(NSTimeInterval)seconds exeBlock:(void(^)(void))block;
@end

NS_ASSUME_NONNULL_END
