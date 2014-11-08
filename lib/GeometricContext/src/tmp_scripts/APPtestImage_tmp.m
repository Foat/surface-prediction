function [labels, conf_map, maps, pmaps] = APPtestImage(image, imsegs, ...
    vClassifier, hClassifier, segDensity)
% [labels, conf_map, maps, pmaps] = APPtestImage(image, imsegs,
%                                  vClassifier, hClassifier, segDensity)
% 
% Gets the geometry for a single image.
%
% Input:
%   image: the image to process
%   imsegs: the sp structure
%   vClassifier: region classifier for main classes
%   hClassifier: region classifier for vertical subclasses
%   segDensity: density for superpixel clustering
% Output:
%   labels: structure containing labeling results for each image
%   conf_map: the likelihoods for each sp for each class for each image
%   maps: the segmentation region maps (from superpixels to regions)
%   pmaps: probabilities for each region
%
% Copyright(C) Derek Hoiem, Carnegie Mellon University, 2005
% Current Version: 1.0  09/30/2005


% mix class must be the last class in each classifier

%exclude mix class
nvclasses = length(vClassifier.names)-1; 
nhclasses = length(hClassifier.names)-1;

[doog_filters, texton_data] = APPgetImageFilters;

imsegs.seginds = APPgetSpInds(imsegs);

% compute features
spdata = APPgetSpData(image, doog_filters, texton_data.tim, imsegs);
[spdata.hue, spdata.sat, tmp] = rgb2hsv(image);


imsize = size(image);
minEdgeLen = sqrt(imsize(1)^2+imsize(2)^2)*0.02;
[vpdata.lines, vpdata.spinfo] = ...
    APPgetLargeConnectedEdges(rgb2gray(image), minEdgeLen, imsegs);
[vpdata.v, vpdata.vars, vpdata.p, vpdata.hpos] = ...
    APPestimateVp(vpdata.lines, imsize(1:2), 0);

% create multiple partitions
num_partitions = [3 4 5 7 9 11 15 20 25];
num_maps = length(num_partitions);
maps = APPsp2regions(segDensity, spdata, num_partitions);                

nsegs = imsegs.nseg;
pV = ones(nsegs, nvclasses);
pH = ones(nsegs, nhclasses);

% compute the probability of each block having each possible label
for m = 1:num_maps
    
    currMap = maps(:, m);  
    
    %cluster_image = get_cluster_overlay_s2(rgb2gray(image), currMap, imsegs.segimage);                                
    %imwrite(cluster_image, ['../results/tmp/alley09.c.' num2str(max(currMap)) '.jpg'], 'Quality', 80);    
    
    currNSegments = max(currMap(:));
    
    regionFeatures = APPgetRegionFeatures(image, imsegs, currMap, (1:currNSegments), spdata, vpdata);    
       
    nregions = size(regionFeatures, 1);

    % get probability of vertical classes P(y|x) for each region
    tmpV = test_boosted_dt_mc(vClassifier, regionFeatures);
    tmpV = 1 ./ (1+exp(-tmpV));    
    
    % get probability of horizontal classes P(y|x) for each region
    tmpH = test_boosted_dt_mc(hClassifier, regionFeatures);  
    tmpH = 1 ./ (1+exp(-tmpH));
    
    % normalize probabilities so that each is P(label|~mixed)P(~mixed)
    % normalize probabilities and sum over maps
    for r = 1:nregions
        indices = find(currMap == r);  
        % get P(y=v or mix|x)
        tmpV(r, 1:end-1) = tmpV(r, 1:end-1) + tmpV(r, end);
%        tmpV(r, 1:end-1) = tmpV(r, 1:end-1) / sum(tmpV(r, 1:end-1));
%        tmpV(r, 1:end-1) = tmpV(r, 1:end-1) * (1-tmpV(r, end));
        for c = 1:nvclasses        
            pV(indices, c) = pV(indices, c) * tmpV(r, c);%*pYv(c, r);
        end
        tmpH(r, 1:end-1) = tmpH(r, 1:end-1) + tmpH(r, end);
%        tmpH(r, 1:end-1) = tmpH(r, 1:end-1) / sum(tmpH(r, 1:end-1));
%        tmpH(r, 1:end-1) = tmpH(r, 1:end-1) * (1-tmpH(r, end));
        for c = 1:nhclasses       
            pH(indices, c) = pH(indices, c) * tmpH(r, c);%*pYh(c, r);
        end
                                    
    end

    pmaps.v{m} = tmpV;
    pmaps.h{m} = tmpH;
    
end

% re-normalize weighted vote from classifiers
for s = 1:size(pV, 1)
    pV(s, :) = pV(s, :) / sum(pV(s, :));
end
for s = 1:size(pH, 1)
    pH(s, :) = pH(s, :) / sum(pH(s, :));
end

conf_map.vmap = pV;
conf_map.hmap = pH;
conf_map.vnames = vClassifier.names(1:end-1);
conf_map.hnames = hClassifier.names(1:end-1);


% get label for each block with confidence
% total_labels = char(zeros(num_blocks, 7));
labels.vert_labels = cell(nsegs, 1);
labels.vert_conf = zeros(nsegs, 1);
labels.horz_labels = cell(nsegs, 1);
labels.horz_conf = zeros(nsegs, 1);
for s = 1:nsegs
    [labels.vert_conf(s), c] = max(pV(s, :));
    labels.vert_labels(s) = vClassifier.names(c);
    [labels.horz_conf(s), c] = max(pH(s, :));
    labels.horz_labels(s) = hClassifier.names(c);        
end

[tmp, vlabels] = max(pV, [], 2);
[tmp, hlabels] = max(pH, [], 2);

if 0 
[hy, estType] = geometry2horizon(imsegs, vlabels, hlabels, vpdata);

labels.hy = 1-hy;
labels.hestType = estType;
end