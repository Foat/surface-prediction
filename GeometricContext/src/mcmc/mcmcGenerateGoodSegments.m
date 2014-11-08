function [features, labels, labelprobs, weights] = ...
    mcmcGenerateGoodSegments(im, imsegs, vclassifierSP, hclassifierSP,eclassifier, ...
    segclassifier, spdata, adjlist, edata)
% Computes the marginals of the geometry for the given input image
% spdata, adjlist, edata are optional inputs

niter = 2500;

features = zeros(imsegs.nseg*6, 102);
labels = zeros(imsegs.nseg*6, 1);
labelprobs = zeros(imsegs.nseg*6, 7);
weights = zeros(imsegs.nseg*6, 1);

count = 0;

[pvSP, phSP, pE, smap] = mcmcInitialize(spdata, edata, ...
    adjlist, imsegs, vclassifierSP, hclassifierSP, eclassifier, 'labels');

imdata = mcmcComputeImageData(im, imsegs);
imdata.pvSP = pvSP;
imdata.phSP = phSP;

nseg = max(smap);

segProb = computeSegProb(segclassifier, pvSP, phSP, pE, adjlist, smap, 1:nseg);

[features, labels, labelprobs, weights, count] = ...
    addFeatures(features, labels, labelprobs, weights, count, ...
    imsegs, spdata, imdata, smap);

% do mcmc
for iter = 2:niter                 
    
    [smap, newseg, origseg, segadjmat] = mcmcGenerateProposals(pE, adjlist, smap);
   % disp(num2str(iter))
    
    nseg2 = max(smap);
    
    tmpSegProb = segProb;    
    if nseg2 > nseg        
        tmpSegProb(newseg) = computeSegProb(segclassifier, pvSP, phSP, pE, adjlist, smap, newseg);
        if origseg~=newseg
            tmpSegProb(origseg) = computeSegProb(segclassifier, pvSP, phSP, pE, adjlist, smap, origseg);
        end
    end    
    
    % get all possible segmentation labelings for newseg
    neighborseg = [newseg find(segadjmat(newseg, :))];
    nn = numel(neighborseg);
    
    % compute transition probability to each neighbor
    transprob = zeros(nn, 1);
    
    sind = find(smap==newseg); 
    adj1 = find((smap(adjlist(:, 1))==newseg) | (smap(adjlist(:, 2))==newseg));
    for ni = 1:nn
        
        s = neighborseg(ni);        
        
        if s==newseg
            transprob(ni) = 1;
        else
            eind = adj1(find((smap(adjlist(adj1, 1))==s) | (smap(adjlist(adj1, 2))==s)));
            smap2 = smap;
            smap2(sind) = s;
            
            sind2 = find(smap2 > newseg);
            smap2(sind2) = smap2(sind2) - 1;
            s2 = s - (s > newseg);            

            probni = computeSegProb(segclassifier, pvSP, phSP, pE, adjlist, smap2, s2);                        
            transprob(ni) = probni / tmpSegProb(newseg) / tmpSegProb(s);                        
            transprob(ni) = transprob(ni)*prod(1-pE(eind));
        end
        
    end

    %disp(num2str(transprob'))
    
    % randomly select neighbor according to transprob
    transprob = cumsum(transprob / sum(transprob));    
    s = neighborseg(find(rand(1) < transprob));
    s = s(1);
    
    sind = find(smap==newseg);
    segProb = tmpSegProb;    
    if origseg==newseg && s==newseg  % nothing changed
        % do nothing
    elseif origseg~=newseg && s==newseg  % newseg split from origseg     
    else % s~=newseg - newseg merged into s

        smap(sind) = s;
        sind2 = find(smap > newseg);
        smap(sind2) = smap(sind2) - 1;
        s = s - (s > newseg);
        
        segProb(1:end-1) = segProb([1:newseg-1 newseg+1:end]);
        segProb(s) = computeSegProb(segclassifier, pvSP, phSP, pE, adjlist, smap, s);
        
    end
        
    if mod(iter, 500)==0
        disp(num2str(iter))
        [features, labels, labelprobs, weights, count] = ...
            addFeatures(features, labels, labelprobs, weights, count, ...
            imsegs, spdata, imdata, smap);
    end    
        
end
    
features = features(1:count, :);
labels = labels(1:count);
labelprobs = labelprobs(1:count, :);
weights = weights(1:count);

    

    
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function segProb = computeSegProb(segclassifier, pvSP, phSP, pE, adjlist, smap, sind)

nseg = numel(sind);
segProb = zeros(nseg, 1);

for i = 1:nseg
    
    s = sind(i);
    
    data = mcmcGetSegmentationFeatures(pvSP, phSP, pE, adjlist, smap, s);
    conf = test_boosted_dt_mc(segclassifier, data);
    segProb(i) = 1 / (1+exp(-conf));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [features, labels, labelprobs, weights, count] = ...
    addFeatures(features, labels, labelprobs, weights, count, ...
    imsegs, spdata, imdata, smap)

nseg = max(smap);

for s = 1:nseg      
    
    features(count+s, :) = mcmcGetSegmentFeatures(imsegs, spdata, imdata, smap, s);

    spind = find(smap==s);  
    labelcount = zeros(1, 7);
    for sp = spind
        if imsegs.labels(sp)~=0
            labelcount(imsegs.labels(sp)) = ...
                labelcount(imsegs.labels(sp)) + imsegs.npixels(sp);
        end
    end
    labels(count+s) = 0;
    if sum(labelcount)>0
        labelprobs(count+s, :) = labelcount / sum(labelcount);
        [maxval, maxind] = max(labelprobs(count+s, :));        
        if maxval >= 0.99
            labels(count+s) = maxind;
        end
    else
        labelprobs(count+s, :) = 0;        
    end
    weights(count+s) = features(count+s, 54);
        
end

count = count + nseg;


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



