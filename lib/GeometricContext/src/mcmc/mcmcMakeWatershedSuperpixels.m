function [imw, imsegs] = mcmcMakeWatershedSuperpixels(im, dostats)

if ~exist('dostats')
    dostats = 0;
end

im = rgb2lab(im);

scale = mean([size(im, 1), size(im, 2)]);

sigma = scale/100;
fsize = round(2*sqrt(-log(0.05)*2*sigma^2));
fsize = fsize + 1 - mod(fsize, 2); % make fsize odd

[gx, gy] = gradient(imfilter(single(im), fspecial('gaussian', fsize, sigma)));
gradim = sqrt(sum(gx.^2, 3) + sum(gy.^2, 3));

imw = watershed(gradim);

%spstats = regionprops(imw, 'Area', 'PixelIdxList', 'BoundingBox', 'Orientation');

imsegs.segimage = imw;
%imsegs.area = [spstats(:).Area];



% if dostats   
%     imsegs.nseg = max(imw(:));    
%     imsegs.segimage = uint16(expand(imw));          
%     imsegs = APPgetSpStats(imsegs);
%     %imsegs.segimage = uint16(imw);
% else
%     imsegs = uint16(imw);
% end