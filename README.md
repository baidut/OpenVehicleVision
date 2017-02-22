# OpenVV: Open Source Vehicle Vision Library

> The new version (openvv2) is under development, questions about papers can be sent to the email: yingzhenqiang-at-gmail-dot-com. 
>
> - [ICASSP2017 "OFFSET CORRECTION IN RGB COLOR SPACE FOR ILLUMINATION-ROBUST IMAGE PROCESSING"](https://github.com/baidut/ORGB)
> - [MM2016 "A Novel Shadow-Free Feature Extractor for Real-Time Road Detection"](https://github.com/baidut/Shaffer)
> - ICASSP2016 "Robust Lane Marking Detection using Boundary-Based Inverse Perspective Mapping"
> - [ISM2015 "An Illumination-Robust Approach for Feature-Based Road Detection"](https://github.com/baidut/s-prime)

# Open Source Projects

## Road Scene Understanding

* FSO
  * Project [http://abhijitkundu.info/projects/fso/](http://abhijitkundu.info/projects/fso/)
  * Code [https://bitbucket.org/infinitei/videoparsing](https://bitbucket.org/infinitei/videoparsing)

### Deep-Learning-Based Segmentation

* FCN
  * [Fully Convolutional Networks for Semantic Segmentation](https://github.com/shelhamer/fcn.berkeleyvision.org) by Jonathan Long*, Evan Shelhamer*, and Trevor Darrell. CVPR 2015 and PAMI 
  * [FCN.tensorflow](https://github.com/shekkizh/FCN.tensorflow): Tensorflow implementation of Fully Convolutional Networks for Semantic Segmentation
  * [Using DIGITS to train a Semantic Segmentation neural network](https://github.com/NVIDIA/DIGITS/tree/master/examples/semantic-segmentation) `fcn`
  * [KittiSeg - A Kitti Road Segmentation model implemented in tensorflow](https://github.com/MarvinTeichmann/KittiSeg) `tensorflow` `fcn`
    - [paper](https://arxiv.org/abs/1612.07695)
  * [Laplacian Pyramid Reconstruction and Refinement for Semantic Segmentation](https://github.com/golnazghiasi/LRR) `matlab` `fcn`
    - [Golnaz Ghiasi, Charless C. Fowlkes, "Laplacian Pyramid Reconstruction and Refinement for Semantic Segmentation", ECCV 2016](http://arxiv.org/abs/1605.02264)
  * [cn24: Convolutional (Patch) Networks for Semantic Segmentation](https://github.com/cvjena/cn24)  `fcn`
  * [clockwork-fcn: Clockwork Convnets for Video Semantic Segmenation](https://github.com/shelhamer/clockwork-fcn)  `caffe` `python`
    - [arxiv:1608.03609](https://arxiv.org/abs/1608.03609)
  * [TA-FCN: Fully Convolutional Instance-aware Semantic Segmentation](https://github.com/daijifeng001/TA-FCN) 
* Dilated Convolution for Semantic Image Segmentation - [Multi-Scale Context Aggregation by Dilated Convolutions](https://github.com/fyu/dilation) `caffe` `torch` `python`
  - [ICLR 2016 conference paper](http://arxiv.org/abs/1511.07122)
* [Convolutional deep network framework for semantic segmentation, implemented using Theano.](https://github.com/iborko/theano-conv-semantic)
* [MNC: Instance-aware Semantic Segmentation via Multi-task Network Cascades](https://github.com/daijifeng001/MNC)
* [ENet: A Deep Neural Network Architecture for Real-Time Semantic Segmentation](https://github.com/e-lab/ENet-training) [paper](https://arxiv.org/abs/1606.02147).
* [FRRN: Full Resolution Residual Networks for Semantic Image Segmentation](https://github.com/TobyPDE/FRRN)
* DeconvNet
  * [DeconvNet: Learning Deconvolution Network for Semantic Segmentation](https://github.com/HyeonwooNoh/DeconvNet)
    - [http://arxiv.org/abs/1505.04366](http://arxiv.org/abs/1505.04366)
  * [Tensorflow implementation of "Learning Deconvolution Network for Semantic Segmentation"](https://github.com/fabianbormann/Tensorflow-DeconvNet-Segmentation)
* [DecoupledNet: Decoupled Deep Neural Network for Semi-supervised Semantic Segmentation](https://github.com/HyeonwooNoh/DecoupledNet)
* Aerial / Satellite Images
  * [ssai-cnn Semantic Segmentation for Aerial / Satellite Images with Convolutional Neural Networks including an unofficial implementation of Volodymyr Mnih's methods](ssai-cnn Semantic Segmentation for Aerial / Satellite Images with Convolutional Neural Networks including an unofficial implementation of Volodymyr Mnih's methods)
* Collections 
  * [Semantic-Segmentation-Evaluation](https://github.com/mrgloom/Semantic-Segmentation-Evaluation)
  * [matconvnet-calvin](https://github.com/nightrome/matconvnet-calvin): Code for several state-of-the-art papers in object detection and semantic segmentation. [http://calvin.inf.ed.ac.uk/](http://calvin.inf.ed.ac.uk/)
  * [awesome-deep-vision#semantic-segmentation](https://github.com/kjw0612/awesome-deep-vision#semantic-segmentation)

# Driver Vision Datasets

## Public datasets

- [The KITTI Vision Benchmark Suite](http://www.cvlibs.net/datasets/kitti/)
- [cityscapes](https://www.cityscapes-dataset.com/)
- [6D-Vision](http://www.6d-vision.com/)
- [Robotics@QUT](https://wiki.qut.edu.au/display/cyphy/Open+datasets+and+software)
- Caltech [Lanes](http://vision.caltech.edu/malaa/datasets/caltech-lanes/)
- [ROMA (ROad MArkings)](http://www.lcpc.fr/english/products/image-databases/article/roma-road-markings-1817)
- [FRIDA (Foggy Road Image DAtabase)](http://www.lcpc.fr/english/products/image-databases/article/frida-foggy-road-image-database)
- [Leuven road dataset](http://cms.brookes.ac.uk/research/visiongroup/files/Leuven.zip)
- [EISATS]()
- [SLD2011-Santaigo Lanes Dataset](http://ral.ing.puc.cl/datasets/ldw/)
- [Playing for Data: Ground Truth from Computer Games](http://download.visinf.tu-darmstadt.de/data/from_games/index.html)
- [CVC10: Semantic Segmentation Dataset](http://adas.cvc.uab.es/elektra/enigma-portfolio/cvc10-semantic-segmentation-dataset/) adas.cvc.uab.es

## Videos from driver's perspective

- Video Clips from [videezy.com](https://www.videezy.com)
  - View my [list](https://www.videezy.com/members/zqying#favorites)
  - [Orlando to Tampa, in a minute & 18 seconds](https://www.videezy.com/time-lapse/776-orlando-to-tampa-in-a-minute-18-seconds) - freeways and roads.
  - [Skyway Bridge Time Lapse](https://www.videezy.com/time-lapse/1617-skyway-bridge-time-lapse)
  - [59s-Georgia Mountain Ride](https://www.videezy.com/time-lapse/530-georgia-mountain-ride) shadowy mountain
  - [21s-Traffic Jam Stock Video](https://www.videezy.com/travel/1594-traffic-jam-stock-video)
  - [2s Car Driving Mountain Road Stock Video](https://www.videezy.com/transportation/3030-car-driving-mountain-road-stock-video)