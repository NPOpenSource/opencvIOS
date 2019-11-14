Opencv 中文网学习



> `仓库中所有的demo都是用xcode11工程创建的,如果在xcode11以下版本运行,需要对工程进行改造`
>
> 步骤如下
>
> 1.删除工程中SceneDelegate文件
>
> 2.修改AppDelegate.m文件  将
>
> ```
> - (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
>     // Called when a new scene session is being created.
>     // Use this method to select a configuration to create the new scene with.
>     return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
> }
> 
> 
> - (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
>     // Called when the user discards a scene session.
>     // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
>     // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
> }
> ```
>
> 两个方法注销掉





# 第一章 core 模块. 核心功能

[OpenCV 之ios 环境搭建](/OpenCVFirstProject)

[OpenCV 之ios 图像的基本操作](/OpenCVMatTest)

[OpenCV 之ios Mat-基本图像容器](/OpenCVFirstChapter-Mat)

[OpenCV 之ios OpenCV如何扫描图像、利用查找表和计时](/OpenCVFirstChapter-scanImage)

[OpenCV 之ios 矩阵的掩码(核)操作](/OpenCVFirstChapter-kern)

[OpenCV 之ios  使用OpenCV对两幅图像求和（求混合(blending)](/OpenCVFirstChapter-blending)

[OpenCV 之ios 改变图像的对比度和亮度](/OpenCVFirstChapter-ContrastAndBrightness)

[OpenCV 之ios 基本绘制](/OpenCVFirstChapter-baseDraw)

[OpenCV 之ios 随机数发生器&绘制文字](/OpenCVFirstChapter-randomGeneratorAndText)

[OpenCV 之ios 离散傅立叶变换](/OpenCVFirstChapter-discrete_fourier_transform)

[OpenCV 之ios 输入输出XML和YAML文件](/OpenCVFirstChapter-xmlAndYml)



# 第二章 *imgproc* 模块. 图像处理

[OpenCV 之ios 图像平滑处理](/OpenCVSecondChapter-imageDeal)

[OpenCV 之ios 腐蚀与膨胀](/OpenCVSecondChapter-erodeAndDilate)

[OpenCV 之ios 更多形态学变换](/OpenCVSecondChapter-moreState)

[OpenCV 之ios 图像金字塔](/OpenCVSecondChapter-pyramids)

[OpenCV 之ios 基本的阈值操作](/OpenCVSecondChapter-threshold)

[OpenCV 之ios 实现自己的线性滤波器](/OpenCVSecondChapter-filter)

[OpenCV 之ios 给图像添加边界](/OpenCVSecondChapter-copyMakeBorder)

[OpenCV 之ios  Sobel 导数](OpenCVSecondChapter-Sobel)

[OpenCV 之ios Laplace 算子](OpenCVSecondChapter-Laplace)

[OpenCV 之ios Canny 边缘检测](OpenCVSecondChapter-Canny)

[OpenCV 之ios 霍夫线变换](/OpenCVSecondChapter-hough_lines)

# 



