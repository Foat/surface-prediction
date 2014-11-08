function outimg = cleanomap(omapmore, imsize, coef)
% pass here image also, for debug info
if nargin < 3
    coef = 0.0015*2;
end
% min facet size
min_size = imsize(1) * imsize(2) * coef;

%% fill holes and find connected components
filled = zeros(imsize);
for i = 1:3
    % can be removed
    b = imfill(omapmore(:,:,i), 'holes');
    filled(:,:,i) = bwlabel(b);
end

%% use convex hull for each connected component
ffil = zeros(imsize);

for i = 1:3
    buf = filled(:,:,i);
    max_num = max(buf(:));
    bfill = ffil(:,:,i);
    
    % removes thin lines
    if min_size==0
    se = strel('disk',2);        
    buf = imerode(buf,se);
    end
    for j = 1:max_num
       % use fc for convex hull
       [~,col] = find(buf == j);
       len = length(col);
       if len > min_size
        % fill   
        bfill(filled(:,:,i) == j) = 1;
       end
    end
    % use this when facet display labeling is needed
    ffil(:,:,i) = bfill;
end
outimg = ffil;

end