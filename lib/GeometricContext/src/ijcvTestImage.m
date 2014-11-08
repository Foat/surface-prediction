function [pg, data, imsegs] = ijcvTestImage(im, imsegs, classifiers, smaps, spdata, adjlist, edata)
%  [pg, data, imsegs] = ijcvTestImage(im, imsegs, classifiers, smaps,
%  spdata, adjlist, edata)
%
% Computes the marginals of the geometry for the given input image
% spdata, adjlist, edata are optional inputs
% Note: only first three arguments are required

nsegments = [5 10 20 30 40 50 60 80 100];

if isempty(imsegs)
    imsegs = im2superpixels(im);
end

vclassifier = classifiers.vclassifier;
hclassifier = classifiers.hclassifier;
sclassifier = classifiers.sclassifier;

if ~exist('spdata', 'var') || isempty(spdata)
    spdata = mcmcGetSuperpixelData(im, imsegs); 
end

if ~exist('adjlist', 'var') || ~exist('edata', 'var') || isempty(adjlist) || isempty(edata)
    [edata, adjlist] = mcmcGetEdgeData(imsegs, spdata);
end    

imdata = mcmcComputeImageData(im, imsegs);

if ~exist('smaps', 'var') || isempty(smaps)       
    eclassifier = classifiers.eclassifier; 
    ecal = classifiers.ecal;
    if isfield(classifiers, 'vclassifierSP')
        vclassifierSP = classifiers.vclassifierSP;
        hclassifierSP = classifiers.hclassifierSP;            
        [pvSP, phSP, pE] = mcmcInitialize(spdata, edata, ...
            adjlist, imsegs, vclassifierSP, hclassifierSP, eclassifier, ecal, 'none');    
    else     
        pE = test_boosted_dt_mc(eclassifier, edata);
        pE = 1 ./ (1+exp(ecal(1)*pE+ecal(2)));
    end
    smaps = generateMultipleSegmentations2(pE, adjlist, imsegs.nseg, nsegments);
    
%     for k = 1:size(smaps, 2)
%         segim = displaySegments(smaps(:, k), imsegs.segimage, ...
%             rgb2gray(im), true, 'color', [1 0 0], 'width', 3);        
%         imwrite(segim, ['../tmp/surf_segs' num2str(k) '.jpg'], 'Quality', 100);
%     end
end


nsp = imsegs.nseg;  

if exist('pvSP', 'var')
    pg = [pvSP(:, 1) repmat(pvSP(:, 2), 1, 5).*phSP pvSP(:, 3)];   
else
    pg = zeros(nsp, 7);
end
    
segs = cell(nsp, 1);
    
for k = 1:size(smaps, 2)

%     tmppg = zeros(nsp, 3);
    for s = 1:max(smaps(:, k))

        [segs, ind] = checksegs(segs, smaps(:, k), s);            
        %ind = find(smaps(:, k)==s);
        
        if ~isempty(ind)

            labdata = mcmcGetSegmentFeatures(imsegs, spdata, imdata, smaps(:, k), s);
            
            vconf = test_boosted_dt_mc(vclassifier, labdata);
            vconf = 1 ./ (1+exp(-vconf));
            vconf = vconf / sum(vconf); 

            hconf = test_boosted_dt_mc(hclassifier, labdata);
            hconf = 1 ./ (1+exp(-hconf));
            hconf = hconf / sum(hconf);            

            sconf = test_boosted_dt_mc(sclassifier, labdata);
            sconf = 1 ./ (1+exp(-sconf));           

            pgs = [vconf(1) vconf(2)*hconf vconf(3)]*sconf;

            %tmppg(ind, :) = repmat(vconf*sconf, numel(ind), 1);
            
            pg(ind, :) = pg(ind, :) + repmat(pgs, numel(ind), 1);
        end            
        
    end
    
%     labim = APPgetLabeledImage2(im, imsegs, tmppg, repmat(tmppg(:, 1), [1 5]));
%     imwrite(labim, ['../tmp/surf_confim_seg' num2str(k) '.jpg'], 'quality', 100);

end
        
pg = pg ./ max(repmat(sum(pg, 2), 1, size(pg, 2)), 0.00001);    
   
data.smaps = smaps;
data.edata = edata;
data.adjlist = adjlist;
data.spdata = spdata;
data.imdata = imdata;

% for k = 1:size(pg, 2)
%     tmppg = pg(:, k);
%     tmpim = tmppg(imsegs.segimage);
%     imwrite(tmpim, ['../tmp/surf_confim' num2str(k) '.jpg'], 'quality', 100);
% end
% tmppg = sum(pg(:, 2:6),2);
% tmpim = tmppg(imsegs.segimage);
% imwrite(tmpim, ['../tmp/surf_confim_v.jpg'], 'quality', 100);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [segs, ind] = checksegs(segs, map, s)
% Checks whether this segment has been seen before

ind = find(map==s);

if isempty(ind)
    return;
end

% if numel(ind)==1 % already accounted for by superpixels
%     ind = [];
%     return;
% end

oldsegs = segs{ind(1)};

for k = 1:numel(oldsegs)
    if (numel(oldsegs{k})==numel(ind)) && all(oldsegs{k}==ind)
        ind = [];
        return;
    end
end

segs{ind(1)}{end+1} = ind;
