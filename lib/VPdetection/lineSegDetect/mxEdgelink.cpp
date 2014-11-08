#include<stdlib.h>
#include<string.h>
#include<math.h>
#include<assert.h>

//#define MATLAB

#ifdef MATLAB
#include<mex.h>
#endif 

#include <iostream>
#include <math.h>
#include <stdlib.h>
#include <unistd.h>
#include <vector>
#include <list>
#include <sstream>

#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/core/core_c.h"
#include <vector>

#define __uint8 unsigned char
#define uint unsigned int
#define WHITE 255
//#define GRAY 128
#define BLACK 0

//#define NEIGHBORHOOD  8

int imgHeight;
int imgWidth;


template<class T> class Image
{
  private:
  IplImage* imgp;
  public:
  Image(IplImage* img=0) {imgp=img;}
  ~Image(){imgp=0;}
  void operator=(IplImage* img) {imgp=img;}
  inline T* operator[](const int rowIndx) {
    return ((T *)(imgp->imageData + rowIndx*imgp->widthStep));}
};

typedef Image<unsigned char>  BwImage;



inline __uint8 getColor(const __uint8* img, int x, int y)
{
  return img[x*imgHeight+y]; 
}

void
eraseBorder(IplImage* iplImg)
{
  Image<unsigned char> iplImgT(iplImg);

  //make sure border is off
  for (int y = 0; y < iplImg->height; y++)
    {
      iplImgT[y][0              ] = BLACK;
      iplImgT[y][iplImg->width-1] = BLACK;
      //cvSet2D(iplImg,y,0,               cvScalar(BLACK) );
      //cvSet2D(iplImg,y,iplImg->width-1, cvScalar(BLACK) );
    }
  for (int x = 0; x < iplImg->width; x++)
    {
      iplImgT[0               ][x] = BLACK;
      iplImgT[iplImg->height-1][x] = BLACK;
      //cvSet2D(iplImg,0,               x, cvScalar(BLACK) );
      //cvSet2D(iplImg,iplImg->height-1,x, cvScalar(BLACK) );
    }

}

// bool
// isEdgeBegin(IplImage* img, CvScalar edgC, CvPoint p_curr)
// {
//   CvPoint p;

//   int nbEdge = 0;
//   for (int x=-1;x<=1;x++)
//     {
//       for (int y=-1;y<=1;y++)
// 	{
// 	  p.x=p_curr.x+x;
// 	  p.y=p_curr.y+y;
// 	  //printf("%d %d\n", p.x,p.y);
// 	  CvScalar s = cvGet2D(img,p.y,p.x);
// 	  nbEdge +=  (s.val[0]==edgC.val[0]);
// 	}
//     }
//   printf("%d\n", nbEdge);
//   return (nbEdge<=2);

// }

void
eliminateJunction(IplImage* iplImg, unsigned char edgC, unsigned char backC)
{
  int W = iplImg->width;
  int H = iplImg->height;

   Image<unsigned char> iplImgT(iplImg);
 

  IplImage* iplIntImg;// = cvCreateImage( cvSize(W+1, H+1), IPL_DEPTH_32S, 1 );

  cv::Mat mat_img(iplImg );
  cv::Mat integ;
  cv::integral(mat_img, integ);
  iplIntImg = new IplImage(integ);
  Image<int>  iplIntImgT(iplIntImg);


  int nbJunctions = 0;


  for (int x = 1; x < iplImg->width-1; x++){
    for (int y = 1; y < iplImg->height-1; y++)
      {	  
	uint nbEdge = 0;
	
	//even if current pixel is not mark, we mark it
	//a junction can have no edge!
	//CvScalar s = cvGet2D(iplImg,y,x);
	double s = iplImgT[y][x];
	if (s!=edgC)
	  nbEdge+=255;	

	nbEdge += (  iplIntImgT[y-1][x-1]
		     + iplIntImgT[y+2][x+2]
		     - iplIntImgT[y+2][x-1]
		     - iplIntImgT[y-1][x+2]);

	if (nbEdge>=4*255)
	  {
	    nbJunctions++;
	    iplImgT[y][x] = backC;
	  }

      }}

  // for (int x = 1; x < iplImg->width-1; x++){
  //   for (int y = 1; y < iplImg->height-1; y++)
  //     {	  
  // 	int nbEdge = 0;
	
  // 	//even if current pixel is not mark, we mark it
  // 	//a junction can have no edge!
  // 	CvScalar s = cvGet2D(iplImg,y,x);
  // 	if (s.val[0]!=edgC.val[0])
  // 	  nbEdge++;
	
  // 	for (int xoff=-1;xoff<=1;xoff++){
  // 	  for (int yoff=-1;yoff<=1;yoff++)
  // 	    {
  // 	      CvScalar s = cvGet2D(iplImg,y+yoff,x+xoff);
  // 	      nbEdge +=  (s.val[0]==edgC.val[0]);
  // 	    }}
  // 	if (nbEdge>=4)
  // 	  {
  // 	    nbJunctions++;
  // 	    cvSet2D(iplImg,y,               x, backC);
  // 	  }
  //     }}
  

  printf("Eliminated %d junctions\n", nbJunctions);
}


//Two pass flood filling to make sure points are ordered
//this is robust to loop!
//must be no crossing -> we could check however, but we could probably
std::vector< CvPoint> 
floodfill(CvPoint seed, unsigned char edgC,  unsigned char bckV, IplImage* img)
{
  Image<unsigned char> imgT(img);

  std::vector<CvPoint> vPt;
  unsigned char bckV2 = bckV+10;
  
  unsigned char s = imgT[seed.y][seed.x];
  if (s != edgC)  //not an edge
    return vPt; 

  vPt.push_back(seed);
  imgT[seed.y][seed.x] = bckV2;
  
  uint i =0;
  uint lastPush=0;
  uint lastPushPrev=0;
  //pass one: this is just a naive floodfill
  while (true)
    {
      CvPoint p_curr = vPt[i];
      CvPoint p = p_curr;
      
      for (int x=-1;x<=1;x++)
	{
	  for (int y=-1;y<=1;y++)
	    {
	      p.x=p_curr.x+x;
	      p.y=p_curr.y+y;
	      //printf("%d %d\n", p.x,p.y);
	      //s = cvGet2D(img,p.y,p.x);
	      s = imgT[p.y][p.x];
	      if (s==edgC)  {
		vPt.push_back(p);		//cvSet2D(img,p.y,p.x, bckV2);
		imgT[p.y][p.x] = bckV2;
		lastPushPrev = i;
		lastPush     = vPt.size()-1;
	      }
	    }
	}
      i++;

      if (i==vPt.size())
	break;

    }
  if (vPt.size() < 3)
    return vPt;

  CvPoint p1 = vPt[lastPush]; //this the last push on the stack
  CvPoint p2 = vPt[lastPushPrev]; //this the connected pixel to this last push
  imgT[p1.y][p1.x] = bckV;
  imgT[p2.y][p2.x] = bckV;

  vPt.clear(); //reset list

  vPt.push_back(p1); //going reverse, this is the new beginning
  vPt.push_back(p2); //go to next and make sure we go in the right direction
  i=1;
  //pass two start from the ending: that will make sure the data are sorted
  while (true)
    {
      CvPoint p_curr = vPt[i];
      CvPoint p = p_curr;
      
      for (int x=-1;x<=1;x++)
  	{
  	  for (int y=-1;y<=1;y++)
  	    {
  	      p.x=p_curr.x+x;
  	      p.y=p_curr.y+y;
  	      s = imgT[p.y][p.x]; // cvGet2D(img,p.y,p.x);
  	      if (s==bckV2)  {
  		vPt.push_back(p);
  		imgT[p.y][p.x] = bckV; //cvSet2D(img,p.y,p.x, bckV);
  	      }
  	    }
  	}

      i++;

      if (i>=vPt.size())
  	break;

    }
  // printf("%d \n-------------\n", vPt.size() );
  
  // for (int i=0;i<vPt.size()-1; i++)
  //   {
  //     CvPoint p1 = vPt[i];
  //     CvPoint p2 = vPt[i+1];
  //     double dist = sqrt(pow(p1.x-p2.x,2)+pow(p1.y-p2.y,2));
  //     //if (dist > 2)
  // 	printf("%d %d -> %f\n", i,i+1,dist);
       
      
  //   }



  return vPt;
  
}


//groupe edges by floodfilling
std::vector< std::vector <CvPoint> >
getEdgeGroup(IplImage* iplImg, uint minLength)
{
  
  Image<unsigned char> iplImgT(iplImg);

  std::vector< std::vector <CvPoint> > vComp;

  eraseBorder(iplImg);
  eliminateJunction(iplImg, WHITE, BLACK); //make sure there are no crossing
  
  for (int x = 1; x < iplImg->width-1; x++)
    {
      for (int y = 1; y < iplImg->height-1; y++)
	{
	  
	  //CvPoint p = cvPoint(x,y);

	  unsigned char s = iplImgT[y][x];//cvGet2D(iplImg,p.y,p.x);
	  if (s!=WHITE) continue;   //already included in a list
	  
	  //bool b = isEdgeBegin(iplImg, cvWHITE, p);
	  //if (~b) continue;
	  
	  std::vector<CvPoint> vPt = floodfill(cvPoint(x,y), WHITE,  BLACK, iplImg);
	  
	  if (vPt.size() >= minLength)
	    vComp.push_back(vPt);
	  
	}
    }

  return vComp;

}


#ifdef MATLAB

void
mexFunction(int nout, mxArray *out[], 
            int nin, const mxArray *in[])
{
  int K1;
  __uint8* img;
  
  enum {img_i=0, minLength_i} ;
  enum {c_edgeGroups_i=0} ;


  // int i =cvUseOptimized(1);
  // printf("optimized -> %d\n", i);
  /* ------------------------------------------------------------------
  **                                                Check the arguments
  ** --------------------------------------------------------------- */ 
  if (nin != 2) {
    mexErrMsgTxt("At least 1 input arguments required");
  } 
  if (nout != 1) {
    mexErrMsgTxt("Too many output arguments");
  }

  img = (__uint8*) mxGetData(in[img_i]) ;
  uint minLength = (uint) mxGetScalar(in[minLength_i]);

  imgHeight = mxGetM(in[img_i]) ;
  imgWidth  = mxGetN(in[img_i]) ;

  //copy image to OPENCV format
  IplImage* iplImg = cvCreateImage (cvSize(imgWidth, imgHeight),
				    8, 1);
  for (int x = 0; x < imgWidth; x++)
    for (int y = 0; y < imgHeight; y++)
      cvSet2D(iplImg,y,x, cvScalar( getColor(img, x,y) ) );	   

  //get edgelist
  //printf("Computing\n");
  std::vector< std::vector <CvPoint> > vComp = getEdgeGroup(iplImg, minLength);

  //copy to cell
  mxArray* vCell = (mxArray*) mxCreateCellMatrix(1,vComp.size() );

  //printf("Copying data\n");
  for (int i=0; i<vComp.size();i++)
    {
      std::vector<CvPoint> vPt = vComp[i];
      int nbPt = vPt.size();
	    
      mxArray* mxMat = (mxArray*) mxCreateDoubleMatrix(nbPt,2,mxREAL) ; //arrange un columns
      double* mat = (double*) mxGetPr(mxMat);

      for (int p=0; p<nbPt;p++)
      	{
      	  mat[p]     = vPt[p].y;
      	  mat[p+nbPt]= vPt[p].x;
	  
      	}
      mxSetCell(vCell, i, mxMat);

    }

  out[c_edgeGroups_i] = vCell;


}

#else

//g++  -Wall  -I/usr/local/include/opencv    -lm   -L/usr/local/lib -lcxcore -lcv -lhighgui -lcvaux -lml     mxEdgelink.cpp -o mxEdgelink


int main()
{
  //char imgName[] = "edge.jpg";
  //#define DIRECT
#ifdef DIRECT
  char imgName[] = "../fig/__tmp_edge.png";
  IplImage* iplEdge=cvLoadImage(imgName, 0);
#else
  //char imgName[] = "../../RandomImages/camrect2_1199740292_793000_+39.953758_-75.210335.jpg";
  char imgName[] = "../../YorkUrbainDB/P1020171/P1020171.jpg";
  IplImage* iplImg=cvLoadImage(imgName, 0);
  IplImage* iplEdge=cvCreateImage(cvSize(iplImg->width, iplImg->height),IPL_DEPTH_8U,1);
  cvCanny(iplImg,iplEdge,150,300,5); 
  cvSaveImage("edge.jpg", iplEdge);
#endif

  if(!iplEdge){
    printf("Could not load image file: %s\n",imgName);
    return 0;
  }

  std::vector< std::vector <CvPoint> > vComp = getEdgeGroup(iplEdge, 15);
  
  IplImage* iplEdgeF=cvCreateImage(cvSize(iplEdge->width, iplEdge->height),IPL_DEPTH_8U,1);
  
  Image<unsigned char> iplEdgeFT(iplEdgeF);
  
  for (uint i=0; i<vComp.size();i++)
    {
      std::vector<CvPoint> vPt = vComp[i];
      int nbPt = vPt.size();
	    
      for (int p=0; p<nbPt;p++)
	iplEdgeFT[ vPt[p].y ][ vPt[p].x ] = 255;
      	
    }


  cvSaveImage("comp.jpg", iplEdgeF);


  return 0;


}

#endif
