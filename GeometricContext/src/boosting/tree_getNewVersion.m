function dt = tree_getNewVersion(dt)

cut_old = dt.cut;
dt.cut = num2cell(dt.cut);
ind = find(dt.var<0);
for k = 1:numel(ind)
    dt.cut{ind(k)} = dt.catsplit(cut_old(ind(k)), :);
end
