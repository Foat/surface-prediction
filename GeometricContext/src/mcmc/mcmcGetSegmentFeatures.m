function features = mcmcGetSegmentFeatures(imsegs, spdata, imdata, smap, sinds, usedFeatures)
% features = mcmcGetSegmentFeatures(imsegs, spdata, imdata, smap, sinds)
%
% Input:
%   im - the rgb image
%   imsegs - superpixel structure
%   spdata - superpixel features
%   imdata - data computed once for each image
%   smap - mapping from superpixels to segments
%   sinds - which segments to compute features for
%
% Output:
%   features(nsegments, nfeatures)

% spdata(nseg, nf)
%   spdata feature descriptions:
%      01 - 03: mean rgb
%      04 - 06: hsv conversion
%      07 - 11: hue histogram
%      12 - 14: sat histogram
%      15 - 29: mean texture response
%      30 - 44: texture response histogram
%      45 - 46: mean x-y
%      47 - 48: 10th, 90th perc. x
%      49 - 50: 10th, 90th perc. y
%      51 - 51: h / w 
%      52 - 52: area

nfeatures = 94;
if isfield(imdata, 'pvSP')
    nfeatures = nfeatures+8;
end
nsegments = numel(sinds);
features = zeros(nsegments, nfeatures);

yim = imdata.yim;
xim = imdata.xim;
gradim = imdata.gradim;
vpdata = imdata.vpdata;

[imh, imw] = size(yim);

for k = 1:nsegments
    
    spind = find(smap==sinds(k));

    %pixind = getPixels(imdata.pixlist, smap, imsegs.npixels, k);   
    %bndpixind = getPixels(imdata.bndpixlist, smap, imdata.bndnpix, k);
    
    pixindsm =  getPixels(imdata.smpixlist, smap, imdata.nsmpix, sinds(k));   
    bndpixindsm =  getPixels(imdata.smbndpixlist, smap, imdata.nsmbndpix, sinds(k));  
    
    sparea = imsegs.npixels(spind);             
    npix = sum(sparea);
    nsmpix = numel(pixindsm);      
    spnorm = sparea / npix;
    
    features(k, 1:3) = sum( spdata(spind, 1:3).*repmat(spnorm, [1 3]), 1);
    
    features(k, 4:6) = rgb2hsv(features(k, 1:3));

    features(k, 7:46) = sum(spdata(spind, 7:46) .* repmat(spnorm, [1 40]), 1);
    
   
    
    
    % location - 10% and 90% percentiles of y and x
    rx = xim(pixindsm);
    sortx = sort(rx);
    features(k, 47) = sortx(ceil(nsmpix/10));
    features(k, 48) = sortx(ceil(9*nsmpix/10));        
    ry = yim(pixindsm);
    sorty = sort(ry);
    features(k, 49) = sorty(ceil(nsmpix/10));
    features(k, 50) = sorty(ceil(9*nsmpix/10));    

    rgrad = gradim(pixindsm);
    % center of edginess x and y
    if ~exist('usedFeatures', 'var') || usedFeatures(51)>0 
        if (features(k, 47)==features(k, 48)) || sum(rgrad==0) % x min-max equal
            features(k, 51) = 0.5;
        else
            center_x = sum(rgrad.*rx) / sum(rgrad);
            features(k, 51) = sum((rx < center_x).*rx)/sum(rx);
        end    
    end
    if ~exist('usedFeatures', 'var') || usedFeatures(52)>0 
        if (features(k, 49)==features(k, 50)) || sum(rgrad==0)% y min-max equal
            features(k, 52) = 0.5;
        else
            center_y = sum(rgrad.*ry) / sum(rgrad);
            features(k, 52) = sum((ry < center_y).*ry)/sum(ry);
        end    
    end
    
    % num superpixels, % of image area
    features(k, 53) = numel(spind);
    features(k, 54) = npix / imw / imh;
    
    % polygon: num sides, area ratio    
    % note: a bug kept this from being computed in ijcv data
    if 0 && (~exist('usedFeatures', 'var') || usedFeatures(55)>0 || usedFeatures(56)>0)
        try
            [polyi, polya] = convhull(xim(bndpixindsm), yim(bndpixindsm));
            features(k, 55) = length(polyi)-1;
            features(k, 56) = npix / (polya*imw*imh);
        catch        
            features(k, 55:56) = [4 0.75];
        end      
    end    
    
    nf = 56;    
    
    % vanishing point features
    region_center = [sorty(ceil(nsmpix/2)) sortx(ceil(nsmpix/2))];  
    rbounds = [sortx(1) sortx(end) 1-sorty(end) 1-sorty(1)];
    features(k, nf+(1:16)) = ...
        APPvp2regionFeatures(spind, vpdata, region_center, rbounds, imsegs);
    
    % y-location with respect to estimated horizon
    if ~isnan(vpdata.hpos)        
        features(k, nf+17) = features(k, 49) - (1-vpdata.hpos); % bottom 10 pct wrt horizon
        features(k, nf+18) = features(k, 50) - (1-vpdata.hpos); % top 10 pct wrt horizon
        % 1 -> completely under horizon, 2-> straddles horizon, 3-> completely above horizon
        features(k, nf+19) = (features(k, nf+17)>0) + (features(k, nf+18)>0) + 1;
    else % horizon was not estimated with high confidence
        features(k, nf+(17:18)) = features(k, [49:50])-0.5;
        features(k, nf+19) = 4;  % signifies no data-estimated horizon
    end
    
    region_center(1) = region_center(1) - 0.5;
    region_center(2) = region_center(2) - 0.5;    
    features(k, nf+(20:38)) = ...
        APPgetVpFeatures(vpdata.spinfo(spind), vpdata.lines, region_center, [imh imw]);  

    % average superpixel confidences
    if isfield(imdata, 'pvSP')    
        features(k, nf+(39:41)) = mean(imdata.pvSP(spind, :), 1);
        features(k, nf+(42:46)) = mean(imdata.phSP(spind, :), 1);
    end
    
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function pixind = getPixels(pixlist, smap, npixels, s)

ind = find(smap==s);
npix = sum(npixels(ind));
pixind = zeros(npix, 1);

pixlist = pixlist(ind);

c = 0;
for k = 1:numel(pixlist)
    nkpix = numel(pixlist{k});
    pixind(c+1:c+nkpix) = pixlist{k};
    c = c + nkpix;
end
