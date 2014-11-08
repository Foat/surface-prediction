function [vp,f,linesmore] = main(im,plot)
if nargin==1
    plot=0;
end
%includes
ARGS = FACADE_ARGS_default();
const = FACADE_const();
ARGS.mKinv = [];

%read image
diag = sqrt(size(im,1).^2 + size(im,2).^2);
ARGS.minEdgeLength = ceil(diag/50);

%arguments for Vanishing point detection
ARGS.plot = plot; 
ARGS.savePlot = false;%true;

ARGS.manhattanVP = true;
%ARGS.manhattanVP = false;
ARGS.REF_remNonManhantan = true;
ARGS.ALL_calibrated = false;
ARGS.ERROR = const.ERROR_DIST;
load cameraParameters.mat
focal = focal / pixelSize;

RES.focal = focal;
FCprintf('Ground truth Focal length is %f\n', focal);
ARGS.mK = [[focal,0,pp(1)];[0,focal,pp(2)];[0,0,1]];
ARGS.mKinv = inv(ARGS.mK);
%ARGS.imgS = norm([imgW/2,imgH/2]);
ARGS.imgS = focal;
ARGS.imgStr = 'testimg';
%------------------------------------------------------------------------------
%                                Edges and VP
%------------------------------------------------------------------------------
%get data (edges)
im = rgb2gray(im);
if ARGS.plot
  f1 = sfigure(1); clf; imshow(im);
end
ARGS.imgS = max(size(im));


%getting edges
[vsEdges,ARGS.imE] = FACADE_getEdgelets2(im, ARGS);

%get vp
ARGS.JL_ALGO=2;
ARGS.JL_solveVP  = const.SOLVE_VP_MAX;
[vsVP,vClass] = FACADE_getVP_JLinkage(vsEdges, im,ARGS);
%vsVP = vsVP(1:3);


vbOutliers = FACADE_getOutliers(ARGS,vsEdges, vClass, vsVP);          


[vsVP, vClass] = FACADE_orderVP_Mahattan(vsVP, vsEdges, vClass);
%[vsVP, vClass] = FACADE_orderVP_nbPts(vsVP, vsEdges, vClass);
[f123,f12] = FACADE_selfCalib(ARGS,vsVP, vsEdges, vClass, vbOutliers);

if ARGS.plot 
  %ploting
  FACADE_plotSegmentation(im,  vsEdges,  vClass, [], vbOutliers); %-1->don't save
end


%vanishing point in image space are:
VPimage = mToUh(ARGS.mK*[vsVP.VP]);

%% return result for omap
for i=1:3
    vp{i}=VPimage(:,i)';
end
f=f123;
edsize=length(vsEdges);
linesmore = repmat(struct('point1', [0 0], 'point2', [0 0], 'length', 0.0,...
    'lineclass',0,'id',0), edsize, 1);
for i=1:edsize
point1 = vsEdges(i).vPointUn1';
point2 = vsEdges(i).vPointUn2';
len = norm(point1 - point2);
lc=vClass(i);
if lc>3
    lc=0;
end
linesmore(i) = struct('point1', point1, 'point2', point2, 'length', len,...
    'lineclass',lc,'id',i);
end

%% plot result
%this will plot the vanishing points that are inside the image
% sfigure(1);
% hold on
% plot(VPimage(1,1:3), VPimage(2,1:3), '*', 'MarkerSize', 20, 'Color', [1,1,0]);
% hold off