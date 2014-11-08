%% init params
addpath(genpath('.'));
img = imread('testimg.jpg');

imsize=size(img);

figure, imshow(img);

%% uncomment to use multiscaling
% imgb=img;
% rs = zeros(imsize);
% for i=0:4
% img = imresize(imgb,imsize(1:2)*(1/2+1/8*i));


%% find lines, vp using Tardif approach (faster, but needs EM approach)
% [vp,f,linesmore] = main(img);

%% Compute vanishing point and focal length (Lee et. al)
[lines, linesmore] = generate_lines(img);
% disp_lines(img, lines);
[vp, f] = compute_vp(lines, size(img));


linesmore = taglinesvp(vp, linesmore);
[vp,linesmore]=refvp(vp,linesmore,size(img));
disp_vanish(ones(imsize), linesmore, vp);

%% Compute orientation map
[omapmore,~,~,OMAP_FACTOR] = compute_omap(linesmore, vp, size(img));
disp_omap(omapmore, img, 0.6);


%% compute superpixels for different scales
% imgs=im2superpixels(img);
% %% get geometric context
% % gc here is used only for outdoor scenes to remove sky surfaces
% % 1 for outdoor, 0 for indoor
% ld=1;
% gc=getgc(img,imgs,ld);
gc=[];

%% Generate room hypothesis
% clean omap
omapnew1=cleanomap(omapmore, size(img));
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

% final prediction, used to predict more surfaces
omapnew1=cleanomap(romap, size(img));
% surface prediction
omapnew2=approxomap(omapnew1,vp,gc);
% refine omap with lines(vp)
[~,romap]=approxlines(omapnew2,vp);
romap2=cleanomap(romap, size(img));

disp_omap(romap2, img, 0.6);

%% Generate planes coordinates from omap
[X,Y,Z,planes] = omap2surf(romap2,vp,f,gc);
h=figure;
surf(-X,Y,Z, img, ...
     'edgecolor', 'none','FaceColor','texturemap');
axis equal
cameratoolbar('setmodeGUI', 'orbit')