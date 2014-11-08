

MARCH		:= 
MEX_SUFFIX	:= mexglx

MEX		:= /Applications/MATLAB_R2014a.app/bin/mex
#for opencv in common location
OPENCV_PC       := opencv
#opencv in a custom location, use opencv.pc file
#OPENCV_PC       := /usr/local/opencv11/lib/pkgconfig/opencv.pc

#LAPACK_LOCATION := /opt/matlabR2009a/bin/glnx86/
#LAPACK_LOCATION := /usr/local/matlab-2007b/bin/glnx86/

MEXCFLAGS	:= -stdlib=libc++ -mmacosx-version-min=10.8 -Wall -O3  -march=$(MARCH) -mtune=$(MARCH) -fPIC  -ftree-vectorize  -funroll-loops -I
MEXCFLAGS       += $(shell pkg-config --cflags $(OPENCV_PC) | sed 's/-llibtbb\.dylib//')
#MEX_CXXFLAGS 	:= CFLAGS='$(MEXCFLAGS)' 
MEX_CXXFLAGS 	:= CXXFLAGS='$(MEXCFLAGS)' 

#print output
#MEXCFLAGS       +=-DVERBOSE
#MEXCFLAGS       +=-DVERBOSE_RANSAC

LDFLAGS		:= -lm
LDFLAGS         += $(shell pkg-config --libs $(OPENCV_PC) | sed 's/-llibtbb\.dylib//')
MEX_CFLAGS 	:= CFLAGS='$(MEXCFLAGS)' 

CFLAGS          += $(shell pkg-config --cflags $(OPENCV_PC) | sed 's/-llibtbb\.dylib//')
CXXFLAGS        += $(shell pkg-config --cflags $(OPENCV_PC) | sed 's/-llibtbb\.dylib//')
MEX_CXX         := clang++
CXX             := clang++ 

#LAPACK
MEX_CFLAGS      += -ILAPACK/ 
CFLAGS          += -ILAPACK/  -lblas -llapack
CXXFLAGS        += -ILAPACK/  -lblas -llapack 

#openmp
#in Makefile

#LAPACK_LOCATION := /opt/matlabR2009a/bin/glnx86/
MEX_LDFLAGS     = $(LDFLAGS) -lmwlapack  
#$(LAPACK_LOCATION)/libmwblas.so

