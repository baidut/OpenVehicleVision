 InvariantImage = GetInvariantImage(inputImage,angle,tipus,regularize)
 Computes the invariant image given a RGB image 
 generated using Matlab: 7.14.0.739 (R2012a)
 
 Input parameters:
    inputImage: 
        InputImage in RGB
    angle: 
        Intrinsic parameter of the camera (the invariant direction in
            degrees)
    tipus: 
        Selects the 'norm' method:
           0 -> (default) The normalization is done using the green (G)
                channel
           1 -> Normalize input data
    regularize: 
        Discard outliers if set to 1 (default)
 Output parameters:
    InvariantImage: 
            The invariant image (standarized between 0 and 1).
    inv: 
            The invariant image, no post-processing.
 
 Further references:
 
 -Illuminant-Invariant Model-Based Road-Segmentation
  Jose M. Alvarez, Antonio M. Lopez, R. Baldrich
  In IEEE Intelligent Vehicles Symposium (IV), 2008
 
 -Road Detection Based on Illuminant Invariance
  Jose M. Alvarez and Antonio M. Lopez. 
  In IEEE Trans. Intelligent Transportation Systems (ITS), 2011.
 
 We have also succesfully used the invariant image in:
 
 -3D Scene Priors for Road Detection. 
  Jose M. Alvarez, Theo Gevers and Antonio M. Lopez
  Int. Conference Computer Vision and Pattern Recognition (CVPR), 2010
 
 -Road Geometry Classification by Adaptive Shape Models. 
  Jose M. Alvarez, Theo Gevers, F. Diego and Antonio M. Lopez
  IEEE Trans. Intelligent Transportation Systems (ITS), 2013
 
  Example:
 
  inputImage = imread('exampleImage.tif');
  subplot(3,3,2);imshow(inputImage);
  title('Input RGB image');
  subplot(3,3,4);imshow(GetInvariantImage(inputImage,10));
  title('Inv. Image using $\theta = 10^{\circ}$','interpreter','latex');
  subplot(3,3,5);imshow(GetInvariantImage(inputImage,40));
  title('Inv. Image using $\theta = 40^{\circ}$','interpreter','latex');
  subplot(3,3,6);imshow(GetInvariantImage(inputImage,150));
  title('Inv. Image using $\theta = 150^{\circ}$','interpreter','latex');
  for theta=1:3:180
   subplot(3,3,8);imshow(GetInvariantImage(inputImage,theta));
   title(['Inv. Image using $\theta =$ ' num2str(theta) '$^{\circ}$','interpreter','latex']);
   drawnow;
   end
 
 
 
  Jose M. Alvarez
  jalvarez@cvc.uab.es
  www.josemalvarez.net





  Copyright (c) 2012, Jose M. Alvarez
  All rights reserved.
  
  Redistribution and use in source and binary forms, with or without 
  modification, are permitted provided that the following conditions are 
  met:
  
      * Redistributions of source code must retain the above copyright 
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above copyright 
        notice, this list of conditions and the following disclaimer in 
        the documentation and/or other materials provided with the distribution
        
  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
  POSSIBILITY OF SUCH DAMAGE.



