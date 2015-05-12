## Introduction
This is the source code for my "Surface prediction for a single image of urban scenes" paper. If you use this software or annotated data, please cite the [paper]:

F. Akhmadeev. Surface prediction for a single image of urban scenes. *Computer Vision - [ACCV 2014] Workshops*, volume 9008 of *Lecture Notes in Computer Science*, pages 369–382. Springer International Publishing, 2015.

## How to run

The source code has been tested under OSX 10.9 and 10.10. Pure surface prediction approach should run under linux and windows too.

To start the demo simply run ```demo_sp``` in matlab.

## Additional libraries

#### [Geometric reasoning]
The ```surface prediction``` approach uses an initial orientation map from ```geometric reasoning``` to build final orientations of surfaces. In addition, vanishing points and lines are computed using the code from ```geometric reasoning``` by default.

#### [Geometric context]
Surface prediction approach can be combined with ```geometric context```.  
To build GC you need to run ```make``` command in ```lib/segment/``` ([segmentation]) folder and build mex file from ```lib/GeometricContext/src/boosting/treevalc.c```.

#### [VP detection]
To use this algorithm you need to run ```make``` command in ```lib/VPdetection/``` folder. Then, uncomment ```[vp,f,linesmore] = main(img2);```  
line in ```demo_sp.m```. Next,  
```
[lines, linesmore] = generate_lines(img2);  
[vp, f] = compute_vp(lines, imsize2);
```  
comment those lines.

The source code for vp detection has been modified by me so that it can run under OSX and opencv 2.4.9.  
This library is not compatible with windows.

## Test images
We provide annotated data for [Delage et al. dataset] and [York Urban database]. See ```data/``` folder.

## Additional information
The paper was originally presented on the [SUAS 2014] workshop.

The project page is available [here](http://foat.me/portfolio/surface-prediction/).

[home site]: http://foat.me
[SUAS 2014]: http://www.cvc.uab.es/adas/suas2014/
[ACCV 2014]: http://www.accv2014.org

[Geometric context]: http://web.engr.illinois.edu/~dhoiem/projects/context/
[Geometric reasoning]: http://www.cs.cmu.edu/~dclee/projects/scene.html
[segmentation]: http://cs.brown.edu/~pff/segment/
[VP detection]: http://www-etud.iro.umontreal.ca/~tardifj/

[Delage et al. dataset]: http://web.hec.ca/pages/erick.delage/indoor3drecon/index.htm
[York Urban database]: http://www.elderlab.yorku.ca/YorkUrbanDB/

[paper]: http://dx.doi.org/10.1007/978-3-319-16628-5_27
