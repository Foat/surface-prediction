%% init params
addpath(genpath('.'));
img = imread('testimg.jpg');

imsize=size(img);

% resize to ~ 640x480
img=imresize(img,imsize(1:2)/fix(imsize(1)/480));
imsize=size(img);

figure, imshow(img);

% in some cases this improves line extraction
% imghsv = rgb2hsv(img);
% imghsv(:,:,2) = histeq(imghsv(:,:,2));
% imghsv(:,:,3) = histeq(imghsv(:,:,3));
% img2 = hsv2rgb(imghsv);
img2=img;

%% uncomment to use multiscaling
% imgb=img;
% rs = zeros(imsize);
% for i=0:4
% img2=imresize(imgb,imsize(1:2)*(1/2+1/8*i));
% img=img2;

imsize2=size(img2);
%% find lines, vp using Tardif approach (faster, but needs EM approach)
% [vp,f,linesmore] = main(img2);

%% Compute vanishing point and focal length (Lee et al.)
[lines, linesmore] = generate_lines(img2);
% disp_lines(img, lines);
[vp, f] = compute_vp(lines, imsize2);


linesmore = taglinesvp(vp, linesmore);
[vp,linesmore]=refvp(vp,linesmore,imsize2);
disp_vanish(img, linesmore, vp);

%% Compute orientation map
[omapmore,~,~,OMAP_FACTOR] = compute_omap(linesmore,vp,imsize2);
disp_omap(omapmore, img, 0.6);


%% compute superpixels and gc
% imgs=im2superpixels(img);
% %% get geometric context
% % gc here is used only for outdoor scenes to remove sky surfaces
% % 1 for outdoor, 0 for indoor
% ld=1;
% gc=getgc(img,imgs,ld);
gc=[];

%% Generate room hypothesis
% clean omap
omapnew1=cleanomap(omapmore, imsize2);
% surface prediction
omapnew2=approxomap(omapnew1,vp,gc);
% refine omap with lines(vp)
[~,romap]=approxlines(omapnew2,vp);

%% uncomment to use multiscaling
% rs = rs+imresize(romap,imsize(1:2));
% end
% img = imgb;
% % find max from rs
% [~,p]=max(rs,[],3);
% for i=1:3
%     rs(:,:,i)=rs(:,:,i)&(p==i);
% end

%% final prediction, used to predict more surfaces
omapnew1=cleanomap(romap, imsize);
% surface prediction
omapnew2=approxomap(omapnew1,vp,gc);
% refine omap with lines(vp)
[~,romap]=approxlines(omapnew2,vp);
romap2=cleanomap(romap, imsize);

disp_omap(romap2, img, 0.6);

%% Generate planes coordinates from omap
[X,Y,Z,planes] = omap2surf(romap2,vp,f,gc);
h=figure;
surf(-X,Y,Z, img, ...
     'edgecolor', 'none','FaceColor','texturemap');
axis equal
cameratoolbar('setmodeGUI', 'orbit')