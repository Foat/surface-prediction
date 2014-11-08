function main_YDB()
%includes
addpath(genpath('JLinkage'));
addpath 'lineSegDetect/'

ARGS = FACADE_ARGS_default();
const = FACADE_const();
ARGS.mKinv = [];

%arguments for Vanishing point detection
ARGS.plot = 0; 
ARGS.savePlot = false;%true;

ARGS.manhattanVP = true; %set to false if the focal length is unknown
ARGS.REF_remNonManhantan = true;
ARGS.ALL_calibrated = false;
ARGS.ERROR = const.ERROR_DIST;

%load K for the image of the YDB, we need the principal point to estimate the focal length
load cameraParameters.mat
focal = focal / pixelSize;

FCprintf('Focal length is %f\n', focal);
%this is use normlization, The choice of f is irrelevant if ARGS.manhattanVP=false
ARGS.mK = [[focal,0,pp(1)];[0,focal,pp(2)];[0,0,1]];
ARGS.mKinv = inv(ARGS.mK);
%ARGS.imgS = norm([imgW/2,imgH/2]);
ARGS.imgS = focal;
%------------------------------------------------------------------------------
%                                Edges and VP
%------------------------------------------------------------------------------
%get data (edges)
%read image

vFilename = textread('YDB.lst','%s\n')';
vF123 = [];
vF12 = [];


for f=1:length(vFilename)
  
  imgStr = vFilename{f};
  
  im = imread(imgStr);
  im = rgb2gray(im);
  if ARGS.plot
    f1 = sfigure(1); clf; imshow(im);
  end
  ARGS.imgS = max(size(im));
  
  
  %getting edges
  [vsEdges,ARGS.imE] = FACADE_getEdgelets2(im, ARGS);
  
  %get vp
  ARGS.JL_ALGO=2;
  [vsVP,vClass] = FACADE_getVP_JLinkage(vsEdges, im,ARGS);
  
  vbOutliers = FACADE_getOutliers(ARGS,vsEdges, vClass, vsVP);           

  if ARGS.manhattanVP
    [vsVP, vClass] = FACADE_orderVP_Mahattan(vsVP, vsEdges, vClass);
  else
    [vsVP, vClass] = FACADE_orderVP_nbPts(vsVP, vsEdges, vClass);
  end
  [f123,f12] = FACADE_selfCalib(ARGS,vsVP, vsEdges, vClass, vbOutliers);
  
  vF123 = [vF123, f123];
  vF12 = [vF12, f12];
  
  %ploting
  if ARGS.plot
    FACADE_plotSegmentation(im,  vsEdges,  vClass, [], vbOutliers); %-1->don't save
  end

end


sfigure(2); clf
plot(real(vF123)); hold all
plot(real(vF12));
legend('f123','f12');
hold off