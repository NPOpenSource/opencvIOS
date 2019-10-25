想在ios上使用opencv 还是挺简单的,用pod 加载就可以了

```
pod 'OpenCV', '~> 3.4.6'
```

这里需要提示的是,由于 `pod install` 的时候 ,更新库比较慢,看不见进度条.因此建议使用`pod install  --verbose `进行安装,能看见加载的进度条以及是否加载成功

# opencv 基本介绍
OpenCV 的全称是 Open Source Computer Vision Library，是一个开放源代码的 计算机视觉库。OpenCV 是最初由英特尔公司发起并开发，以 BSD 许可证授权发 行，可以在商业和研究领域中免费使用，现在美国 Willow Garage 为 OpenCV 提 供主要的支持。OpenCV 可用于开发实时的图像处理、计算机视觉以及模式识别 程序，目前在工业界以及科研领域广泛采用。

### OpenCV 的来源
OpenCV 诞生于 Intel。Intel 最初希望提供一个计算机视觉库，使之能充分发掘 CPU 的计算能力，当然更希望以此促进 Intel 的产品的销售。OpenCV 最初的开发工作是由 Intel 在俄罗斯的团队实现。这里面有两个关键人物，一个是Intel 性能团队(Intel’s Performance Library Team)的李信弘(Shinn Lee)先生，他是团队的经理，负责 IPP 等库，给予 OpenCV 很大的支持。另一个关键物是 VadimPisarevsky，Vadim 在 Intel 负责 OpenCV 的项目管理、代码集成、代码优化等工作。在后期 Intel 支持渐少的时候，是 Vadim Pisarevsky 一直在维护着 OpenCV。2007 年 6 月，受本书作者之邀，李信弘和 Vadim Pisarevsky 作为嘉宾参加了在北京举行的“开放源代码计算机视觉(OpenCV)研讨会” ，并做了非常有价值的报 告。

在 2008 年，一家美国公司，Willow Garage，开始大力支持 OpenCV，Vadim Pisarevsky 和 Gary Bradski 都加入了 Willow Garage。Gary Bradski 也是OpenCV 开 发者中的元老级人物，他曾出版《Leaning OpenCV》一书，广受欢迎。

Willow Garage 是一家机器人公司，致力于为个人机器人开发开放的硬件平台和软件。现在已经开发了 PR2 机器人，并支持 ROS、OpenCV、PCL 等软件。ROS (Robot Operating System)是用于机器人的操作系统，是一个开放源代码的软件， OpenCV 作为 ROS 的视觉模块嵌入。

自从获得 Willow Garage 支持后，OpenCV 的更新速度明显加快。大量的新特 性被被加入 OpenCV 中，很多算法都是最近一两年的新的科研成果。OpenCV 正日益成为算法研究和产品开发不可缺少的工具。

### OpenCV 的协议
OpenCV 采用 BSD 协议，这是一个非常宽松的协议。简而言之，用户可以修改OpenCV 的源代码，可以将 OpenCV 嵌入到自己的软件中，可以将包含 OpenCV 的软件销售，可以用于商业产品，也可以用于科研领域。BSD 协议并不具有“传染性”，如果你的软件中使用了 OpenCV，你不需要公开代码。你可以对 OpenCV 做任何操作，协议对用户的唯一约束是要在软件的文档或者说明中注明使用了 OpenCV，并附上 OpenCV 的协议。
在这个宽松协议下，企业可以在 OpenCV 基础之上进行产品开发，而不需要 担心版权问题(当然你要注明使用了 OpenCV，并附上 OpenCV 的协议)。科研领域的研究者，可以使用 OpenCV 快速地实现系统原型。因此可以这样说，OpenCV 的协议保证了计算机视觉技术快速的传播，让更多的人从 OpenCV 受益。

---------

今天开始这就算是学习openCV 开篇



