function [bestpg, bestmap, segs, segpg, pg2, energyIter, bestsp] = ...
    mcmcTestImageSA2(im, imsegs, vclassifierSP, hclassifierSP, ...
    eclassifier, ecal, vclassifier, hclassifier, segclassifier, ...
    priors, maxiter, spdata, adjlist, edata)
% Computes the marginals of the geometry for the given input image
% spdata, adjlist, edata are optional inputs

T = 0.005;
dT = 0.95;

DO_DISPLAY = 0;

% Initialize
nsp = imsegs.nseg;

usedFeatures = get_used_features(vclassifier) + get_used_features(hclassifier);

grayim = rgb2gray(im);

if ~exist('spdata') || isempty(spdata)
    spdata = mcmcGetSuperpixelData(im, imsegs); 
end

if ~exist('adjlist') || ~exist('edata') || isempty(adjlist) || isempty(edata)
    [edata, adjlist] = mcmcGetEdgeData(imsegs, spdata);
end    

[pvSP, phSP, pE, smap] = mcmcInitialize(spdata, edata, ...
    adjlist, imsegs, vclassifierSP, hclassifierSP, eclassifier, ecal, 'label');

imdata = mcmcComputeImageData(im, imsegs);

plabSP = [pvSP(:, 1) repmat(pvSP(:, 2), 1, 5).*phSP pvSP(:, 3)];

nseg = max(smap);

segProb = zeros(nsp, 1);
segProb = updateSegProb(segclassifier, pvSP, phSP, pE, adjlist, imsegs.npixels, smap, 1:nseg, segProb);

pg = zeros(imsegs.nseg, 7);
segs = cell(imsegs.nseg, 1);
segpg = cell(imsegs.nseg, 1);
[pg, segs, segpg] = updateLabProb(vclassifier, hclassifier, imsegs, spdata, ...
        imdata, smap, (1:nseg), segProb, priors, pg, segs, segpg, usedFeatures);

if DO_DISPLAY
    figure(1), hold off, displayMarginal(pg, imsegs.segimage, grayim);
    figure(2), hold off, displaySegments(smap, imsegs.segimage, grayim)    
    figure(4), hold off, displayConfidence(imsegs.segimage, segProb, pg, smap)
    drawnow;
end

energy = getEnergy(segProb, pg, imsegs.npixels, smap);

bestpg = pg;
bestmap = smap;
bestenergy = energy;  %+log(lognpdf(max(smap), 2.55, 0.69));
bestsp = segProb;


energyIter = zeros(1, min(nsp,250)*maxiter);
beIter = zeros(1, min(nsp,250)*maxiter);
vacc = zeros(1, min(nsp,250)*maxiter);
hacc = zeros(1, min(nsp,250)*maxiter);

[bv, v] = max([bestpg(:, 1) sum(bestpg(:, 2:6), 2) bestpg(:, 7)], [], 2);
vacc(1) = sum((v==imsegs.vert_labels(:)).*imsegs.npixels(:))/...
    sum(imsegs.npixels(:).*(imsegs.vert_labels(:)>0));
[bh, h] = max(bestpg(:, 2:6), [], 2);
hacc(1) = sum((h==imsegs.horz_labels(:)).*imsegs.npixels(:))/...
    sum(imsegs.npixels(:).*(imsegs.horz_labels(:)>0));

energyIter(1) = energy;
beIter(1) = bestenergy;

disp(num2str([max(smap) bestenergy vacc(1) hacc(1)]))

c = 1;

lastbest = 1;

% do simulated annealing
for iter = 2:maxiter+1                 
    
    maxn = max(smap);
    for n = 1:maxn
    
        c = c + 1;
        
        pWhole = 0.25;
        [smap2, newseg, origseg, neighborsegs] = ...
            mcmcGenerateProposals2(pE, adjlist, smap, pWhole, 1-max(pg, [], 2));
                
        neighborsegs =  [newseg neighborsegs];             
        if numel(neighborsegs) > 1
           neighborsegs = setdiff(neighborsegs, origseg);
        end
              
        % uniformly sample neighbor
        neighbor = neighborsegs(ceil(rand(1)*numel(neighborsegs)));
        if neighbor~=origseg
            if neighbor~=newseg
                sind = find(smap2==newseg);                       
                smap2(sind) = neighbor;
                sind2 = find(smap2 > newseg);
                smap2(sind2) = smap2(sind2) - 1;
                neighbor2 = neighbor - (neighbor > newseg); 
                origseg2 = origseg - (origseg > newseg);
                if sum(smap2==origseg2)==0
                    origseg2 = [];
                end
            else
                origseg2 = origseg;
                neighbor2 = neighbor;
            end

            newSegProb = updateSegProb(segclassifier, pvSP, phSP, pE, adjlist, ...
                imsegs.npixels, smap2, [origseg2 neighbor2], segProb);    
            
            % get geometry likelihood for proposed segmentation
            [newpg, segs, segpg] = updateLabProb(vclassifier, hclassifier, imsegs, spdata, ...
                imdata, smap2, [origseg2 neighbor2], segProb, priors, pg, segs, segpg, usedFeatures);           
           
            newenergy = getEnergy(newSegProb, newpg, imsegs.npixels, smap2);

            [bestsp2, bestpg2, bestmap2, bestenergy2, changed] = ...
               updateBest(bestsp, bestpg, bestmap, newSegProb, newpg, smap2, imsegs.npixels);
            if changed && bestenergy2 < bestenergy
                bestenergy = bestenergy2;
                bestsp = bestsp2;
                bestpg = bestpg2;
                bestmap = bestmap2;                
                lastbest = iter;
            end            
            
            
            % reassign current if rand(1) < acceptance threshold
            if (newenergy < energy) || (rand(1) < exp((energy - newenergy)/T))
                smap = smap2;
                segProb = newSegProb;
                pg = newpg;
                energy = newenergy;

                if energy < bestenergy
                    lastbest = iter;
                    bestenergy = energy;
                    bestmap = smap;
                    bestpg = pg;
                    bestsp = segProb;
                end
            end
        end
        
        energyIter(c) = energy;
        beIter(c) = bestenergy;
        [bv, v] = max([bestpg(:, 1) sum(bestpg(:, 2:6), 2) bestpg(:, 7)], [], 2);
        vacc(c) = sum((v==imsegs.vert_labels(:)).*imsegs.npixels(:))/...
            sum(imsegs.npixels(:).*(imsegs.vert_labels(:)>0));
        [bh, h] = max(bestpg(:, 2:6), [], 2);
        hacc(c) = sum((h==imsegs.horz_labels(:)).*imsegs.npixels(:))/...
            sum(imsegs.npixels(:).*(imsegs.horz_labels(:)>0)+1E-10);                
        
        if mod(c, 25)==0        
            figure(3), hold off, plot([1:c], exp(-energyIter(1:c)), 'LineWidth', 1)
            hold on, plot([1:c], exp(-beIter(1:c)), 'g', 'LineWidth', 1)
            plot([1:c], vacc(1:c), 'r', 'LineWidth', 1)
            plot([1:c], hacc(1:c), 'y', 'LineWidth', 1)            
            drawnow;
        end
                
    end
    
    T = T * dT;
   
    if mod(iter, 1)==0
        disp(num2str([iter bestenergy])) 
        if DO_DISPLAY
            figure(1), hold off, displayMarginal(bestpg, imsegs.segimage, grayim); 
            figure(4), hold off, displayConfidence(imsegs.segimage, bestsp, bestpg, bestmap)
            figure(2), hold off, displaySegments(bestmap, imsegs.segimage, grayim)
            drawnow;
        end
    end        
    
    if lastbest < iter-2
        break;
    end
    
end
    
pg2 = zeros(size(bestpg));
for i = 1:numel(segs)
    for j  = 1:numel(segs{i})
        sind = segs{i}{j};
        pg2(sind, :) = pg2(sind, :) + repmat(segpg{i}{j}, [numel(sind) 1]);
    end
end
pg2 = pg2 ./ repmat(sum(pg2, 2), [1 size(pg2, 2)]);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function energy = getEnergy(segProb, pg, npixels, smap)

tmppg = [pg(:, 1) sum(pg(:, 2:6), 2) pg(:, 7)];
energy = -log(sum(max(tmppg, [], 2).*npixels(:))/sum(npixels));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function segProb = updateSegProb(segclassifier, pvSP, phSP, pE, adjlist, npixels, smap, sind, segProb)

nseg = numel(sind);
for i = 1:nseg    
    s = sind(i);    
    data = mcmcGetSegmentationFeatures(pvSP, phSP, pE, adjlist, npixels, smap, s);
    val = treeval(segclassifier, data);
    ind = find(smap==s);
    segProb(ind) = val;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [pg, segs, segpg] = updateLabProb(vclassifier, hclassifier, imsegs, spdata, imdata, ...
    smap, sind, segProb, priors, pg, segs, segpg, usedFeatures)

nseg = numel(sind);

for i = 1:nseg

    s = sind(i); 
    spind = find(smap==s);
    
    [ispresent, pgs] = checksegs(segs, segpg, spind);
    
    if ~ispresent
        data = mcmcGetSegmentFeatures(imsegs, spdata, imdata, smap, s, usedFeatures);

        vconf = test_boosted_dt_mc(vclassifier, data);
        vconf = 1 ./ (1+exp(-vconf));
        vconf = vconf / sum(vconf);    

        hconf = test_boosted_dt_mc(hclassifier, data);
        hconf = 1 ./ (1+exp(-hconf));
        hconf = hconf / sum(hconf);     
        
        pgs = [vconf(1) vconf(2)*hconf vconf(3)];    

        % P(label) = P(label|pixel in majority region)*P(majority) + 
        %               P(label|~majority)*P(~majority) 
        ps = segProb(spind(1));
        %pgs = ps*pgs + (1-ps)*priors.*(sum(pgs./(1-priors))-pgs./(1-priors));
        pgs = ps*pgs;
        
        segs{spind(1)}{end+1} = spind;
        segpg{spind(1)}{end+1} = pgs;
        
    end
                
    pg(spind, :) = repmat(pgs, numel(spind), 1);
    
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ispresent, pg] = checksegs(segs, segpg, ind)
% Checks whether this segment has been seen before

ispresent = 0;
pg = [];
oldsegs = segs{ind(1)};
for k = 1:numel(oldsegs)
    if (numel(oldsegs{k})==numel(ind)) && all(oldsegs{k}==ind)
        ispresent = 1;
        pg = segpg{ind(1)}{k};
        break;
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function displayConfidence(segimage, segProb, pg, smap)
conf = max(pg, [], 2);
imagesc(conf(segimage), [0 1]), axis image, colormap(gray)
conf = segProb(smap);
figure(gcf+1), imagesc(conf(segimage), [0 1]), axis image, colormap(gray)
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function displaySegments(smap, segim, grayim)

pixim = smap(segim);

[gx, gy] = gradient(double(pixim));
edgepix = find(gx~=0 | gy~=0);

im = repmat(grayim, [1 1 3]);
for b = 1:3
    im((b-1)*prod(size(segim))+edgepix) = (b==1);
end
imagesc(im), axis image

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function displayMarginal(pg, segim, grayim)

p000 = pg(:, 1);
p090 = sum(pg(:, 2:6), 2);
psky = pg(:, 7);

im = zeros(size(segim, 1), size(segim, 2), 3);
im(:, :, 1) = p090(segim);
im(:, :, 2) = p000(segim);
im(:, :, 3) = psky(segim);
%imagesc(im.*repmat(grayim, [1 1 3])), axis image
imagesc(im), axis image


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [bestsp2, bestpg2, bestmap2, bestenergy, changed] = ...
    updateBest(bestsp, bestpg, bestmap, segProb, pg, smap, npixels)

changed = 0;

bestsp = bestsp(:);
bestval = max(bestpg, [], 2); %.*bestsp(:);

segProb = segProb(:);
currval = max(pg, [], 2); %.*segProb(:);

bestmap2 = bestmap;
bestsp2 = bestsp;
bestpg2 = bestpg;

% get segments for which bestmap is a superset of smap
[super, sub] = supersets(bestmap, smap);
for k = 1:numel(super)
    ind = find(bestmap == super(k));
    ebest = -log(sum(bestval(ind).*npixels(ind)) / sum(npixels(ind)));
    ecurr = -log(sum(currval(ind).*npixels(ind)) / sum(npixels(ind)));
    
    if ecurr < ebest
        changed = 1;
        bestsp2(ind) = segProb(ind);
        bestpg2(ind, :) = pg(ind, :);
        oldind = find(bestmap2>super(k));
        bestmap2(oldind) = bestmap2(oldind)-1;
        nseg2 = max(bestmap2);
        for j = 1:numel(sub{k})
            ind2 = find(smap==sub{k}(j));
            bestmap2(ind2) = nseg2 + j;
        end
    end
end

% get segments for which smap is a superset of bestmap
[super, sub] = supersets(smap, bestmap);
for k = 1:numel(super)
    ind = find(smap == super(k));
    ebest = -log(sum(bestval(ind).*npixels(ind)) / sum(npixels(ind)));
    ecurr = -log(sum(currval(ind).*npixels(ind)) / sum(npixels(ind)));
    
    %origenergy = getEnergy(bestsp2, bestpg2, npixels);   
    if ecurr < ebest
        changed = 1;
        nseg2 = max(bestmap2);
        bestsp2(ind) = segProb(ind);
        bestpg2(ind, :) = pg(ind, :); 
        for j = 1:nseg2           
            if sum(j > sub{k}) > 0
                jind = find(bestmap2==j);
                bestmap2(jind) = bestmap2(jind) - sum(j > sub{k});
            end
        end
        bestmap2(ind) = max(bestmap2) + 1;
        %newenergy = getEnergy(bestsp2, bestpg2, npixels);  
        %disp(num2str([origenergy newenergy]));        
    end
end
            
bestenergy = getEnergy(bestsp2, bestpg2, npixels, smap);                
                        
