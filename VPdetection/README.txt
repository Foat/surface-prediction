Non-iterative Approach for Fast and Accurate Vanishing Point Detection, ICCV 2009
Author:  Jean-Philippe Tardif
Contact: tardifj@{cim.mcgill.ca, gmail.com}

This code  computes vanishing points as described in:

Jean-Philippe Tardif, Non-iterative Approach for Fast and Accurate Vanishing Point Detection, 12th IEEE International Conference on Computer Vision, Kyoto, Japan, September 27--October 4, 2009.

******Please cite the paper if you use it.*******

Use the code at your own risk. 

This is a trimmed down version of my research code.  The code includes:

     -edge detection using opencv
     -estimation of the vanishing points using J-Linkage
     -selection of 3-most orthogonal vp
     -estimation of the focal length given the principal point

I did not clean up the code, so many options won't work. Unfortunately, I don't have much time to make it nicer.

This is part of my research on facade detection hence the prefix "FACADE" to many file names.

The J-Linkage implementation is my own. I did it in C++ and I believe it is cleaner than Toldo's. Its code is also available online and it would be relatively easy to use his instead of mine.

*** Please contact me if you find any bug or if things really don't work for you. I will do my best to find what's wrong, especially if you make a comparison of your own approach with mine.

The code has been tested under Ubuntu Linux 9.04 with Matlab 2008a and opencv 1.1.0pre1, with gcc 4.3. If you use a more recent distribution with, say, gcc 4.4, you might have to install gcc-4.3 and compile opencv with that version of the compiler. It all depends on the version of Matlab you are using.

Requirements:

Matlab
g++/gcc
opencv 1.1 (not tested with the more recent version such as 1.2 and above, but it might work)
lapack


Instructions

1) An example of Makefile.spec is given if Makefile.spec.jaunty, modify it for your machine

2) compile using make

3a) start matlab and run main('image_filename')
3b) or modify YDB.list according the location the York database images and launch main_YDB()

Example

An image from the York database is provided: P1020830.jpg

run the software:  main('P1020830.jpg')



Acknowledgment:

Patrick Denis for the York Database (see paper for detail)
Frédéric Devernay for CMINPACK
Peter Kovesi for some inspiration on the edge detection code and the function lineseg2.m
