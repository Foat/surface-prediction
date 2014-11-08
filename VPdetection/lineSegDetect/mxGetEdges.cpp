#include<stdlib.h>
#include<string.h>
#include<math.h>
#include<assert.h>

//#define MATLAB

#ifdef MATLAB
#include<mex.h>
#endif 

#ifdef _OPENMP
#include <omp.h>
#else
#warning Not using OpenMP
#endif

#include <iostream>
#include <math.h>
#include <stdlib.h>
#include <unistd.h>
#include <vector>
#include <list>
#include <sstream>

#include <cv.h>
#include <highgui.h>
#include <vector>

#define uint8 unsigned char
#define WHITE 255
#define BLACK 0
//#define CANNY_THRESH 500
#define CANNY_THRESH 700
#define CANNY_MASK   5

//#define DEBUG

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



inline uint8 getColor(const uint8* img, int imgHeight, int x, int y)
{
  return img[x*imgHeight+y]; 
}

inline void setColor(uint8* img, int imgHeight, int x, int y, uint8 color)
{
  img[x*imgHeight+y] = color; 
}

//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
#ifdef _OPENMP
int OMP_getNbThread()
{
int nthreads=1, tid;

/* Fork a team of threads with each thread having a private tid variable */
#pragma omp parallel private(tid)
 {
   tid = omp_get_thread_num();
   //printf("[%d] thread\n", tid);
   /* Only master thread does this */
   if (tid == 0) 
     {
       nthreads = omp_get_num_threads();
       //printf("[%d] Number of threads = %d\n", tid,nthreads);
     }
 }  /* All threads join master thread and terminate */

 printf("Number of threads = %d\n", nthreads);
 return nthreads;
}
#endif
//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
#ifdef _OPENMP
//Parallel version
void
OMP_eraseBorder(IplImage* iplEdge)
{
  Image<uint8> iplEdgeT(iplEdge);

  //make sure border is off
  int tid;
#pragma omp parallel private(tid)
  {
    tid = omp_get_thread_num();
    if (tid==0)
      {
	for (int y = 0; y < iplEdge->height; y++)
	  {
	    iplEdgeT[y][0              ] = BLACK;
	    iplEdgeT[y][1              ] = BLACK;
	    iplEdgeT[y][2              ] = BLACK;
	    iplEdgeT[y][iplEdge->width-1] = BLACK;
	    iplEdgeT[y][iplEdge->width-2] = BLACK;
	    iplEdgeT[y][iplEdge->width-3] = BLACK;
	  }
      }
    else if (tid==1)
      {
	for (int x = 0; x < iplEdge->width; x++)
	  {
	    iplEdgeT[0               ][x] = BLACK;
	    iplEdgeT[1               ][x] = BLACK;
	    iplEdgeT[2               ][x] = BLACK;
	    iplEdgeT[iplEdge->height-1][x] = BLACK;
	    iplEdgeT[iplEdge->height-2][x] = BLACK;
	    iplEdgeT[iplEdge->height-3][x] = BLACK;
	  }
      }
  }
}
#define eraseBorder  OMP_eraseBorder
#else
//non-Parallel version
void
eraseBorder(IplImage* iplEdge)
{
  Image<uint8> iplEdgeT(iplEdge);

  //make sure border is off
  for (int y = 0; y < iplEdge->height; y++)
    {
      iplEdgeT[y][0              ] = BLACK;
      iplEdgeT[y][iplEdge->width-1] = BLACK;
    }
  for (int x = 0; x < iplEdge->width; x++)
    {
      iplEdgeT[0               ][x] = BLACK;
      iplEdgeT[iplEdge->height-1][x] = BLACK;
    }

}
#endif



//---------------------------------------------------------------------
//---------------------------------------------------------------------
//---------------------------------------------------------------------
#ifdef _OPENMP
//Parallel version
void
OMP_eliminateJunction(IplImage* iplEdge, uint8 edgC, uint8 backC)
{
  int W = iplEdge->width;
  int H = iplEdge->height;

   Image<uint8> iplEdgeT(iplEdge);
 

  IplImage* iplIntImg = cvCreateImage( cvSize(W+1, H+1), IPL_DEPTH_32S, 1 );
  cvIntegral(iplEdge, iplIntImg,NULL, NULL );
  Image<int>  iplIntImgT(iplIntImg);

  int nthreads = OMP_getNbThread();

  int tid;
#pragma omp parallel private(tid)
  {
    tid = omp_get_thread_num();
    int bg = tid+1;
    printf("[%d] Starting at %d\n", tid,bg);
    for (int y = bg; y < iplEdge->height-1; y+=nthreads) {
      //printf("%d %d %d %d\n", tid,y,iplEdge->height-1, nthreads );
      for (int x = 1; x < iplEdge->width-1; x++) {
	//even if current pixel is not mark, we mark it
	//a junction can have no edge!
	//double s = iplEdgeT[y][x];
	//if (s!=edgC)
	//  nbEdge+=255;

	//faster than above
	uint nbEdge=255 - iplEdgeT[y][x]; //if no edge, add 255, otherwise, start at 0, will be added below
	
	nbEdge += (  iplIntImgT[y-1][x-1]
		     + iplIntImgT[y+2][x+2]
		     - iplIntImgT[y+2][x-1]
		     - iplIntImgT[y-1][x+2]);
	
	if (nbEdge>=4*255)
	  iplEdgeT[y][x] = backC;
	
      }}
  }  //end pragma omp parallel private(tid)
 
}
#define eliminateJunction OMP_eliminateJunction
#else
void
eliminateJunction(IplImage* iplEdge, uint8 edgC, uint8 backC)
{
  Image<uint8> iplEdgeT(iplEdge);
 

   //IplImage* iplIntImg = cvCreateImage( cvSize(W+1, H+1), IPL_DEPTH_32S, 1 );
  //cvIntegral(iplEdge, iplIntImg,NULL, NULL );
  //Image<int>  iplIntImgT(iplIntImg);


  for (int x = 1; x < iplEdge->width-1; x++){
    for (int y = 1; y < iplEdge->height-1; y++)
      {	  
	uint nbEdge=0;

	nbEdge = ( iplEdgeT[y-1][x] +
		   iplEdgeT[y+1][x] +
		   iplEdgeT[y][x+1] +
		   iplEdgeT[y][x-1]);
	

	if (nbEdge>=3*255)
	  {
	    iplEdgeT[y][x]   = backC;
	    iplEdgeT[y-1][x] = backC;
	    iplEdgeT[y+1][x] = backC;
	    iplEdgeT[y][x-1] = backC;
	    iplEdgeT[y][x+1] = backC;
	  }
	// nbEdge = ( iplEdgeT[y-1][x] +
	// 	   iplEdgeT[y+1][x] +
	// 	   iplEdgeT[y][x+1] +
	// 	   iplEdgeT[y][x-1] +
	// 	   iplEdgeT[y-1][x-1] +
	// 	   iplEdgeT[y+1][x-1] +
	// 	   iplEdgeT[y-1][x+1] +
	// 	   iplEdgeT[y+1][x+1] );
	

	// if (nbEdge>=5*255)
	//   {
	//     iplEdgeT[y][x]   = backC;
	//     iplEdgeT[y-1][x] = backC;
	//     iplEdgeT[y+1][x] = backC;
	//     iplEdgeT[y][x-1] = backC;
	//     iplEdgeT[y][x+1] = backC;
	//     iplEdgeT[y][x]   = backC;
	//     iplEdgeT[y-1][x-1] = backC;
	//     iplEdgeT[y+1][x-1] = backC;
	//     iplEdgeT[y-1][x+1] = backC;
	//     iplEdgeT[y+1][x+1] = backC;
	//   }

      }
  }

}

#endif

//Two pass flood fill to make sure points are ordered
//this is robust to loop!
//there must be no junctions
std::vector< CvPoint> 
floodfill(CvPoint seed, uint8 edgC,  uint8 bckV, IplImage* img)
{
  Image<uint8> imgT(img);

  std::vector<CvPoint> vPt;
  uint8 bckV2 = bckV+10;
  
  uint8 s = imgT[seed.y][seed.x];
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

double
isLine(std::vector<CvPoint>& vPt, uint bg, uint ed, double threshold=1)
{
  CvPoint p1 = vPt[bg];
  CvPoint p2 = vPt[ed];

  double D =  sqrt( (p1.x-p2.x)*(p1.x-p2.x) +  (p1.y-p2.y)*(p1.y-p2.y));

  //double mxLD = 0;
  if (D > 0.0001)
    {
      double y1my2 = p1.y- p2.y;                       // Pre-compute parameters
      double x2mx1 = p2.x-p1.x;
      double C = p2.y*p1.x - p1.y*p2.x;
      
      for (uint i=bg+1;i<ed;i++){
	double x = vPt[i].x;
	double y = vPt[i].y;
	double d = fabs(x*y1my2 + y*x2mx1 + C)/D;  
      
	if (d > threshold)
	  return false;
      }
      
    }
  return true;
}

//split edged to straight lines
//TODO
#warning edge split not implemented yet
void
splitEdgeGroup(std::vector<CvPoint>& vPt)
{
  uint bg = 0;
  uint ed = vPt.size();

  //check if this is a line
  if (isLine(vPt, bg, ed))
    return;

  double isLine;


}

//groupe edges by floodfilling
std::vector< std::vector <CvPoint> >
getEdgeGroup(IplImage* iplEdge, uint minLength)
{
  
  Image<uint8> iplEdgeT(iplEdge);

  std::vector< std::vector <CvPoint> > vComp;

  eraseBorder(iplEdge);
  eliminateJunction(iplEdge, WHITE, BLACK); //make sure there are no crossing
  IplImage* iplEdgeCpy = cvCloneImage(iplEdge);

#ifdef DEBUG
  cvSaveImage("edge-nojunc.png", iplEdge);
#endif

  for (int x = 1; x < iplEdge->width-1; x++)
    {
      for (int y = 1; y < iplEdge->height-1; y++)
	{
	  uint8 s = iplEdgeT[y][x];//cvGet2D(iplEdge,p.y,p.x);
	  if (s!=WHITE) continue;   //already included in a list
	  
	  std::vector<CvPoint> vPt = floodfill(cvPoint(x,y), WHITE,  BLACK, iplEdgeCpy);
	  
	  if (vPt.size() >= minLength)
	    vComp.push_back(vPt);
	  
	}
    }

  cvReleaseImage(&iplEdgeCpy);
  return vComp;

}


#ifdef MATLAB

void
mexFunction(int nout, mxArray *out[], 
            int nin, const mxArray *in[])
{
  uint8* img;
  
  enum {img_i=0, minLength_i} ;
  enum {c_edgeGroups_i=0, imgEdge_i} ;


  // int i =cvUseOptimized(1);
  // printf("optimized -> %d\n", i);
  /* ------------------------------------------------------------------
  **                                                Check the arguments
  ** --------------------------------------------------------------- */ 
  if (nin != 2) {
    mexErrMsgTxt("At least 1 input arguments required");
  } 
  if (nout > 2) {
    mexErrMsgTxt("Too many output arguments");
  }

  img = (uint8*) mxGetData(in[img_i]) ;
  uint minLength = (uint) mxGetScalar(in[minLength_i]);

  int imgHeight = mxGetM(in[img_i]) ;
  int imgWidth  = mxGetN(in[img_i]) ;

  //copy image to OPENCV format
  IplImage* iplImg = cvCreateImage (cvSize(imgWidth, imgHeight),
				    8, 1);
  Image<uint8> iplImgT(iplImg);

  for (int x = 0; x < imgWidth; x++)
    for (int y = 0; y < imgHeight; y++)
      iplImgT[y][x] =  getColor(img,imgHeight, x,y);

  //get edge map
  IplImage* iplEdge=cvCreateImage(cvSize(iplImg->width, iplImg->height),IPL_DEPTH_8U,1);
  cvCanny(iplImg,iplEdge,CANNY_THRESH,CANNY_THRESH*2,CANNY_MASK); 

  //get edgelist
  //printf("Computing\n");
  std::vector< std::vector <CvPoint> > vComp = getEdgeGroup(iplEdge, minLength);

  //copy to cell
  mxArray* vCell = (mxArray*) mxCreateCellMatrix(1,vComp.size() );

  //printf("Copying data\n");
  for (uint i=0; i<vComp.size();i++)
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

  if (nout >= 2) //return edge image, mostly for debugging
    {
      mxArray* mxImgEdge = (mxArray*) mxCreateNumericMatrix(imgHeight,imgWidth,mxUINT8_CLASS,mxREAL);
      uint8* imgEdge = (uint8*) mxGetPr(mxImgEdge); 
      
      Image<uint8> iplEdgeT(iplEdge);
      for (int x = 0; x < imgWidth; x++)
	for (int y = 0; y < imgHeight; y++)
	  setColor(imgEdge,imgHeight, x,y, iplEdgeT[y][x]);
      
      out[imgEdge_i] = mxImgEdge;
    }

  
  cvReleaseImage(&iplEdge);
  cvReleaseImage(&iplImg);
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
  char imgName[] = "../../YorkUrbainDB/P1020822/P1020822.jpg";
  //char imgName[] = "../../YorkUrbainDB/P1020171/P1020171.jpg";
  IplImage* iplImg    =cvLoadImage(imgName, 0);//grayscale loading
  IplImage* iplEdge   =cvCreateImage(cvSize(iplImg->width, iplImg->height),IPL_DEPTH_8U,1);

  cvCanny(iplImg,iplEdge,CANNY_THRESH, 2*CANNY_THRESH,CANNY_MASK); 
#ifdef DEBUG
  cvSaveImage("edge.jpg", iplEdge);
#endif
#endif

  if(!iplEdge){
    printf("Could not load image file: %s\n",imgName);
    return 0;
  }

  std::vector< std::vector <CvPoint> > vComp = getEdgeGroup(iplEdge, 30);
  
  IplImage* iplEdgeF=cvCreateImage(cvSize(iplEdge->width, iplEdge->height),IPL_DEPTH_8U,1);
  cvSet(iplEdgeF, cvScalar(0));

  Image<uint8> iplEdgeFT(iplEdgeF);
  for (uint i=0; i<vComp.size();i++)
    {
      std::vector<CvPoint> vPt = vComp[i];
      int nbPt = vPt.size();
	    
      for (int p=0; p<nbPt;p++)
	iplEdgeFT[ vPt[p].y ][ vPt[p].x ] = 255;
      	
    }


#ifdef DEBUG
  cvSaveImage("comp.png", iplEdgeF);
#endif

  return 0;


}

#endif
