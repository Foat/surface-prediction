function romap = extsuperpix(omap,img,extend,imgs)
% use segments to fill holes on image surfaces
%% get superpixels
if nargin==3
    imgs = im2superpixels(img);
end
% use buffer or debug information
% imgs = bufimgs;
% data example
% imname: 'tmpimsp8147236.jpg'
% imsize: [480 640]
% segimage: [480x640 uint16]
% nseg: 314
% npixels: [314x1 double]
% adjmat: [314x314 logical]

s = size(img);
s = s(1:2);

% superpixels classes
ns = imgs.nseg;
supcl = zeros(ns);

for i=1:ns
    currim = zeros(s);
    currim(imgs.segimage == i) = 1;
    
    if sum(sum(currim)) <= 0
        continue;
    end
    
    surfclass = checkclass(omap, currim);
    
    supcl(i) = surfclass;
end

romap = zeros([s 3]);
% creates omap from superpixels
for i=1:ns
    cl = supcl(i);
    if cl > 0
        buf = zeros(s);
        buf(imgs.segimage == i) = 1;
        romap(:,:,cl) = romap(:,:,cl) + buf;
    end
end

if extend
    omapb = double(omap(:,:,1)+omap(:,:,2)+omap(:,:,3));

    nomap = ~omapb;
    fd = double(omap);
    % fills empty holes on original omap with omap obtained from superpixels
    romap(:,:,1) = fd(:,:,1) + romap(:,:,1).*nomap;
    romap(:,:,2) = fd(:,:,2) + romap(:,:,2).*nomap;
    romap(:,:,3) = fd(:,:,3) + romap(:,:,3).*nomap;
end

end


function cl = checkclass(fsurf, im)
% returns superpixel class basing on omap
% uses max overlap woth omap
err = -1;
idx = -1;
for i=1:3
    surf = fsurf(:,:,i);
    surf = logical(im.*surf);
    s = sum(sum(surf));
    if s > err
        idx = i;
        err = s;
    end    
end
cl = idx;   
end

