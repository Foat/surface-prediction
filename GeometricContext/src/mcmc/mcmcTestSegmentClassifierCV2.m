function pg = mcmcTestSegmentClassifierCV2(vclassifier, hclassifier, ...
    imsegs, segfeatures, labels, cvind, weights)
% [vacc, hacc] = mcmcTestSegmentClassifierCV(vclassifier, hclassifier, imsegs, segfeatures, labels, cvind, ncv)
ncvim = numel(cvind);
ncv = numel(vclassifier);

%areafeature = 54;

if ~exist('weights') || isempty(weights)
    for f = 1:numel(labels)
        weights{f} = ones(size(labels{f})) / numel(labels{f});
        %weights{f} = segfeatures{f}(:, areafeature);
    end
end
    
vlabels = labels;
hlabels = labels;
for f = 1:size(labels,1)
    if size(labels, 2)>1
        labels{f} = cat(1, labels{f, :});
        segfeatures{f} = cat(1, segfeatures{f, :});
    end
    vlabels{f} = 1*(labels{f}==1) + 2*((labels{f}>1) & (labels{f}<7)) + ...
        3*(labels{f}==7);
    hlabels{f} = (labels{f}-1).*((labels{f}>1) & (labels{f}<7));
end

totalv = 0;
totalh = 0;
vacc = 0;
hacc = 0;
tacc = 0;

vcm = zeros(3);
hcm = zeros(5);

for k = 1:ncv
    
    disp(num2str(k))
    
    testind = cvind(floor([(k-1)*ncvim/ncv+1:k*ncvim/ncv]));

    for f = testind
        
        for j = 1:size(segfeatures{f}, 1)
            if vlabels{f}(j)~=0
                vconf = test_boosted_dt_mc(vclassifier(k), segfeatures{f}(j, :));
                vconf = 1 ./ (1+exp(-vconf));
                [maxval, maxlabv] = max(vconf);
                %disp(num2str([j size(segfeatures{f}) size(vlabels{f}) areafeature]))
                vacc = vacc + weights{f}(j)*(vlabels{f}(j)==maxlabv);
                vcm(vlabels{f}(j), maxlabv) = vcm(vlabels{f}(j), maxlabv) + weights{f}(j);
                if maxlabv~=2
                    tacc = tacc + weights{f}(j)*(vlabels{f}(j)==maxlabv);
                end
            end
            if vlabels{f}(j)~=0 && hlabels{f}(j)~=0
                hconf = test_boosted_dt_mc(hclassifier(k), segfeatures{f}(j, :));
                hconf = 1 ./ (1+exp(-hconf));
                [maxval, maxlabh] = max(hconf);
                hacc = hacc + weights{f}(j)*(hlabels{f}(j)==maxlabh);
                hcm(hlabels{f}(j), maxlabh) = hcm(hlabels{f}(j), maxlabh) + weights{f}(j);                
                tacc = tacc + weights{f}(j)*((vlabels{f}(j)==maxlabv)&&(hlabels{f}(j)==maxlabh));
            end
        end        
    end
end

totalv = sum(vcm(:));
totalh = sum(hcm(:));
                
vacc = vacc / totalv;
hacc = hacc / totalh;
tacc = tacc / totalv;

vcm = vcm ./ repmat(sum(vcm, 2), [1 size(vcm, 2)]);
hcm = hcm ./ repmat(sum(hcm, 2), [1 size(hcm, 2)]);

disp(['vacc: ' num2str(vacc) '   hacc: ' num2str(hacc)  '   tacc: ' num2str(tacc)])



