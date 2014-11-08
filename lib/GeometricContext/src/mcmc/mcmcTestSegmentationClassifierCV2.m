function errors = mcmcTestSegmentationClassifierCV2(classifier, data, labels)

ncv = numel(classifier);

nimages = size(labels, 1);

disp([num2str(ncv) '-fold cross-validation']);


if size(labels, 2)>1
    for f = 1:size(labels,1)    
        labels2{f} = cat(1, labels{f, :});
        data2{f} = cat(1, data{f, :});
        imind{f} = repmat(f, numel(labels2{f}), 1);
        %disp(num2str([size(imind{f}) size(labels{f})]))
    end
end

labels = cat(1, labels2{:});
data = cat(1, data2{:});
imind = cat(1, imind{:});

ind = find(labels~=0);
data = data(ind, :);
labels = labels(ind);
imind = imind(ind);

conf = zeros(size(labels));

for k = 1:ncv
    
    testind = [floor((k-1)*nimages/ncv)+1:floor(k*nimages/ncv)]; 
    keep = zeros(size(labels));
    for j = 1:numel(testind)
        keep(find(imind==testind(j))) = 1;
    end
    ind = find(keep);       
    
    for j = 1:numel(ind)                
        conf(ind(j)) = test_boosted_dt_mc(classifier(k), data(ind(j), :));
    end

end
    
conf = 1 ./ (1+exp(-conf));
error = mean((conf>0.5)~=(labels+1)/2);
    
disp(['error: ' num2str(error)])

ind1 = find(labels==-1);
ind2 = find(labels==1);
px = [0.025:0.05:0.975];
f1 = ksdensity(conf(ind1), px, 'support', [0 1]);
f1 = f1 / sum(f1);
f2 = ksdensity(conf(ind2), px, 'support', [0 1]);
f2 = f2 / sum(f2);
figure(1), hold off, plot(px, f1, 'r', 'LineWidth', 1);
hold on, plot(px, f2, 'g', 'LineWidth', 1);

disp(['ave conf: ' num2str(mean([1-conf(ind1) ; conf(ind2)]))])

figure(2), plot(px, f2*numel(ind2) ./ (f1*numel(ind1)+f2*numel(ind2)))
hold on, plot(px, px, '--k')
errors.err = error;
errors.sqerror = sqrt(mean((conf-(labels==1)).^2));
errors.pneg = f1;
errors.ppos = f2;
errors.px = px;    

n1 = numel(ind1)/(numel(ind1)+numel(ind2));
n2 = 1-n1;
confmat = zeros(2);
confmat(1, 1) = n1*mean(conf(ind1)<0.5);
confmat(1, 2) = n1 - confmat(1,1);
confmat(2, 1) = n2*mean(conf(ind2)<0.5);
confmat(2, 2) = n2 - confmat(2, 1);
errors.confmat = confmat;
