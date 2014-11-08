function [lines, spdata, edgeIm] = APPgetLargeConnectedEdges(grayIm, minLen, imsegs)
% [lines, spdata, edgeIm] = APPgetLargeConnectedEdges(grayIm, minLen,
%                                 imsegs)
% 
% Uses the method of Video Compass [Kosecka, et al 2002] to get long,
% straight edges.
% 
% Input:
%   grayIm: grayscale image to be analyzed
%   minLen: minimum length in pixels for edge (suggested 0.025*diagonal)
%   imsegs: superpixel image structure (used to store sp statistics)
% Output:
%   lines: parameters for long, straight lines
%   spdata: statistics for lines in each superpixel
%   edgeIm (optional): for displaying lines found
%
% Copyright(C) Derek Hoiem, Carnegie Mellon University, 2005
% Current Version: 1.0  09/30/2005


[dX, dY] = gradient(conv2(grayIm, fspecial('gaussian', 7, 1.5), 'same'));

im_canny = edge(grayIm, 'canny');
% remove border edges
im_canny([1 2 end-1 end], :) = 0;
im_canny(:, [1 2 end-1 end]) = 0;
width = size(im_canny, 2);
height = size(im_canny, 1);

ind = find(im_canny > 0);

num_dir = 8;

dX_ind = dX(ind);
dY_ind = dY(ind);
a_ind = atan(dY_ind ./ (dX_ind+1E-10));

% a_ind ranges from 1 to num_dir with bin centered around pi/2
a_ind = ceil(mod(a_ind/pi*num_dir-0.5, num_dir));
%[g, gn] = grp2idx(a_ind);

% get the indices of edges in each direction
for i = 1:num_dir
    direction(i).ind = ind(find(a_ind==i));
end


% remove edges that are too small and give all edges that have the same
% direction a unique id
% edges(height, width, [angle id])
if nargout>2
    edgeIm = grayIm*0.75;
end
lines = zeros(2000, 6);

nspdata = length(imsegs.npixels);
spdata = repmat(struct('lines', zeros(5, 1), 'edge_count', 0), nspdata,1);
bcount = zeros(nspdata, 1);

used = zeros(size(im_canny));

line_count = 0;
for k = 1:num_dir
    
    num_ind = 0;
    for m = (k-1):k+1
        num_ind = num_ind + sum(~used(direction(mod(m-1, num_dir)+1).ind));
    end
    
    ind = zeros(num_ind, 1);
    dir_im = zeros(size(im_canny));
  
    count = 0;
    for m = (k-1):k+1
        m2 = mod(m-1, num_dir)+1;
        tind = direction(m2).ind(find(~used(direction(m2).ind)));
        tmpcount = length(tind);
        ind(count+1:count+tmpcount) = tind;
        count = count + tmpcount;
    end
    dir_im(ind) = 1;
        
    [tmpL, num_edges] = bwlabel(dir_im, 8); 
    
    % get the number of pixels in each edge
    edge_size = zeros(num_edges, 1);
    edges = repmat(struct('ind', zeros(200, 1)), num_edges, 1);
    for i = 1:length(ind)
        id = tmpL(ind(i));
        edge_size(id) = edge_size(id) + 1;
        edges(id).ind(edge_size(id)) = ind(i);
    end          
    for i = 1:num_edges
        edges(i).ind = edges(i).ind(1:edge_size(i));
    end        
       
    % get the endpoints of the long edges and an image of the long edges
    for id = 1:num_edges
        if edge_size(id) > minLen         
                                    
            y = mod(edges(id).ind-1, height)+1;
            x = floor((edges(id).ind-1) / height)+1;            
            
            %by = min(floor(y/block_size), ny-1);
            %bx = min(floor(x/block_size), nx-1);
            
            mean_x = mean(x);
            mean_y = mean(y);
            zmx = (x-mean_x);
            zmy = (y-mean_y);
            D = [sum(zmx.^2) sum(zmx.*zmy); sum(zmx.*zmy) sum(zmy.^2)];
            [v, lambda] = eig(D);
            theta = atan2(v(2, 2) , v(1, 2));                       
            if lambda(1,1)>0
                conf = lambda(2,2)/lambda(1,1);
            else
                conf = 100000;
            end
                
            %disp(conf)
            
            if conf >= 400 
                line_count = line_count+1;
                
                used(edges(id).ind) = 1;
                bi = double(imsegs.segimage(edges(id).ind));
                [g, gn] = grp2idx(bi);
                for k = 1:length(bi)
                    if bi(k) > 0
                        spdata(bi(k)).edge_count = spdata(bi(k)).edge_count + 1;
                    end
                end
                for k = 1:length(gn)
                    tmpbi = str2num(gn{k});
                    if tmpbi>0
                        bcount(tmpbi) = bcount(tmpbi)+1;
                        spdata(tmpbi).lines(bcount(tmpbi)) = line_count;                
                    end
                end                
                
                %disp(num2str([lambda(1,1) lambda(2,2)]))
                r = sqrt((max(x)-min(x))^2 + (max(y)-min(y))^2);
                x1 = mean_x - cos(theta)*r/2;
                x2 = mean_x + cos(theta)*r/2;
                y1 = mean_y - sin(theta)*r/2;
                y2 = mean_y + sin(theta)*r/2;            
                
                r = mean_x*cos(theta)+mean_y*sin(theta);
                %tr = x1*cos(theta) + y1*sin(theta);
                %disp(num2str([r tr]))
                
                lines(line_count, 1:6) = [x1 x2 y1 y2 theta r];
	
            end
        end
    end

end


if nargout>2
    for i = 1:line_count
        edgeIm = draw_line_image2(edgeIm, lines(i, 1:4)', i);
    end
end

for k = 1:length(spdata)
    spdata(k).lines = spdata(k).lines(1:bcount(k))';
end
lines = lines(1:line_count, :);

imsize = size(grayIm);
lines = normalizeLines(lines, imsize(1:2));
