function image = APPgetLabeledImage2(image, imsegs, pv, ph)
% image = APPgetLabeledImage2(image, imsegs, pv, ph)
%
% Copyright(C) Derek Hoiem, Carnegie Mellon University, 2006
% Current Version: 2.0  04/22/2006
%image = image / double(max(image(:)));

%grayim = rgb2gray(image);
image = rgb2hsv(image);
image(:, :, 2) = 0.0*image(:, :, 2);
image = hsv2rgb(image);
           
rad = round(max(size(image))/20);
markW = ceil(rad/10);
right_arrow = struct('x', 0, 'y', 0, 'angle', 0, 'radius', rad, 'head_length', rad/2, 'head_base_angle', 30);
up_arrow = struct('x', 0, 'y', 0, 'angle', 90, 'radius', rad, 'head_length', rad/2, 'head_base_angle', 30);
up_left_arrow = struct('x', 0, 'y', 0, 'angle', 135, 'radius', rad, 'head_length', rad/2, 'head_base_angle', 30);    
up_right_arrow = struct('x', 0, 'y', 0, 'angle', 45, 'radius', rad, 'head_length', rad/2, 'head_base_angle', 30);    
left_arrow = struct('x', 0, 'y', 0, 'angle', 180, 'radius', rad, 'head_length', rad/2, 'head_base_angle', 30);
down_arrow = struct('x', 0, 'y', 0, 'angle', 270, 'radius', rad, 'head_length', rad/2, 'head_base_angle', 30);     
toward_arrow = struct('x', 0, 'y', 0, 'angle', 250, 'radius', rad*2/3, 'head_length', rad/3, 'head_base_angle', 60);

vhue = [112 0 177]/255;

if ~isstruct(imsegs)
    tmp = imsegs;
    clear imsegs;
    imsegs.segimage = tmp;
end

if ndims(pv)==2
    [vconf, vlab] = max(pv, [], 2);
    [hconf, hlab] = max(ph, [], 2);

    vlabim = vlab(imsegs.segimage);
    hlabim = hlab(imsegs.segimage);
    hconfim = hconf(imsegs.segimage);
    %vconf = max((vconf - 0.5)*2, 0);
    %vconf = max(vconf, 1);

    hueim = vhue(vlabim);
    satim = vconf(imsegs.segimage);
    valim = ones(size(hueim));
else
    [satim, vlabim] = max(pv, [], 3);
    [hconfim, hlabim] = max(ph, [], 3);
    hueim = vhue(vlabim);
    valim = ones(size(hueim));    
end

% set color 
image = image*0.5 + 0.5*hsv2rgb(hueim, satim, valim);  

% draw boundaries of main classes
% [gx, gy] = gradient(vlabim);
% g = gx.^2 + gy.^2;
% g = conv2(g, ones(2), 'same');
% edgepix = find(g>0);
% npix = numel(hueim);
% for b = 1:3
%     image((b-1)*npix+edgepix) = 0;
% end



if 1 % set do draw subclass marks
    
%hconfim = max((hconf(imsegs.segimage)-0.5)*2, 0);    

height = size(image, 1);  width = size(image, 2);

for x = rad:round(rad*1.51):(width-rad)
    for y = rad:round(rad*1.51):(height-rad)
               
        %val = 1-hconfim(y, x);
        val = [0 0 0];
        
        arrows = [];
        if vlabim(y, x)==2 % vertical
            if hlabim(y, x)==1 % left
                arrows = left_arrow;
            elseif hlabim(y, x)==2 % center
                arrows = up_arrow;
            elseif hlabim(y, x)==3 % right
                arrows = right_arrow;                
            elseif hlabim(y, x)==4 % porous
                image = draw_circle_image(image, x, y, rad/2, val, markW);
            elseif hlabim(y, x)==5 % solid
                image = draw_x_image(image, x, y, rad, val, markW);
            end
                
        end
        
        % draw arrows                     
        for a = 1:length(arrows)
            arrows(a).x = x;
            arrows(a).y = y; 
        end

        image = draw_arrow_image(image, arrows, val, markW);              
        
    end
     
end
end

