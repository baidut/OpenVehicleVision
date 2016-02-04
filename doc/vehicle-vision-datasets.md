
[TOC]

# KITTI

## KITTI-ROAD dataset  

[Road/Lane Detection Evaluation 2013](http://www.cvlibs.net/datasets/kitti/eval_road.php)
    
    Please note the license conditions of this software / dataset!

[youtube video](https://www.youtube.com/watch?v=KXpZ6B1YB_k)

- `kitti/data_road.zip` [base kit with: left color images, calibration and training labels (0.5 GB)](http://kitti.is.tue.mpg.de/kitti/data_road.zip)
- `kitti/data_road_right.zip` [right color image extension (0.5 GB)](http://kitti.is.tue.mpg.de/kitti/data_road_right.zip)
- `NA` grayscale image extension (0.3 GB)
- `NA` Velodyne laser point extension (1 GB)
- `NA` OXTS GPS/IMU extension (1 MB)
- `kitti/devkit_road.zip` [development kit (1 MB)](http://kitti.is.tue.mpg.de/kitti/devkit_road.zip)
- `kitti/devkit_road_mapping.zip` [Mapping of training set to raw data sequences (1 MB)](http://kitti.is.tue.mpg.de/kitti/devkit_road_mapping.zip)

# 6D Vison

[The Daimler Urban Segmentation Dataset](http://www.6d-vision.com/scene-labeling)

# QUT

## The UQ St Lucia Dataset

视频数据集 双目视觉 
可用于立体视觉
https://www.youtube.com/watch?v=Sm06SnxB0YE&feature=youtu.be 
https://wiki.qut.edu.au/display/cyphy/UQ+St+Lucia

# Alderley Day/Night Dataset

https://wiki.qut.edu.au/pages/viewpage.action?pageId=181178395

# Caltech

http://vision.caltech.edu/malaa/datasets/caltech-lanes/

# IFSTTAR

## ROMA (ROad MArkings) 

http://www.lcpc.fr/english/products/image-databases/article/roma-road-markings-1817

Evaluation of Road Marking Feature Extraction [view on IEEE.org](http://ieeexplore.ieee.org/xpl/articleDetails.jsp?arnumber=4732564) 【下文为摘要翻译】
本文提出了一种以评估车道线提取算法（从图像中提取出车道标记特征）的系统方法。尽管已经有很多车道线提取算法被提出，但有关该主题（评价方法）的讨论很少在文献中出现。大多数算法可以分解成三个步骤：提取道路标记的特征，估计几何标记模型，沿图像序列跟踪的几何模型的参数。本文的工作重点是第一步，即特征提取。本文提供了一个包含超过100张图像的自然道路场景的参考数据库，该数据库是通过手动标注ground truth构建的（下载链接http://www.lcpc.fr/en/produits/ride/）。该数据库使得对提取算法进行系统的评估和比较成为可能。车道线特征提取算法使用了不同的技术：阈值，梯度分析和卷积，本文对基于这些不同技术的不同的算法进行了评估。分析结果提供了根据特定应用应当选择哪种给定的提取算法的建议。

[官方下载](http://www.lcpc.fr/english/products/image-databases/article/roma-road-markings-1817)(找了半天下载位置，原来点击图标可以下载。。。汗。。。)

注意：按照说明，该数据集只能用于研究用途，且需要在网站上注册后才能使用。有疑问请联系 Jean-Philippe.Tarel@lcpc.fr

> The ROMA image database can be downloaded from
> http://www.lcpc.fr/en/produits/ride/
> and used for research purpose only after registration on the website.

## FRIDA (Foggy Road Image DAtabase) 
图像去雾

http://www.lcpc.fr/english/products/image-databases/article/frida-foggy-road-image-database

提供了深度图，可以学习鸟瞰图变换

# Leuven road dataset (Univ of Leuven and Oxford-Brookes)

download via http://cms.brookes.ac.uk/research/visiongroup/files/Leuven.zip

# EISATS

>The .enpeda.. Image Sequence Analysis Test Site (EISATS) offers sets of image sequences for the purpose of comparative performance evaluation of stereo vision, optic flow, motion analysis, or further techniques in computer vision.

* [EISATS立体视觉数据集](http://ccv.wordpress.fos.auckland.ac.nz/eisats/set-7/) 很多车辆视角的数据集 有分割结果 http://ccv.wordpress.fos.auckland.ac.nz/eisats/
SET 7: Grey-level stereo for scene labeling analysis (Daimler AG)

# SLD2011

**Santaigo Lanes Dataset (SLD2011)** [下载地址](http://ral.ing.puc.cl/datasets/ldw/)
发表的文献：
[A comparison of gradient versus color and texture analysis for lane detection and tracking](http://ieeexplore.ieee.org/xpls/abs_all.jsp?arnumber=5418326)

[Santaigo Lanes Dataset (SLD2011) - Lane changing maneuvers at dusk]   [youtube]
(https://www.youtube.com/watch?v=4MSNXvYYR2Y)
Lane tracking with shadows 2 - Bird Eye View - Santaigo Lanes Dataset (SLD2011) [youtube](https://www.youtube.com/watch?v=kHDMUQWIadk)

# Oxford

[The Oxford Mobile Robotics Group](http://www.robots.ox.ac.uk/~mobile/wikisite/pmwiki/pmwiki.php?n=Main.Datasets)
镭射数据集

# Others

* [web road images](http://www.mathworks.com/matlabcentral/fileexchange/45153-images-for-lane-detection-and-colorization)
* [TME Motorway dataset 车辆检测](http://cmp.felk.cvut.cz/data/motorway/)
* 道路图像理解分割  [Motion-based Segmentation and Recognition Dataset](http://web4.cs.ucl.ac.uk/staff/g.brostow/MotionSegRecData/) 