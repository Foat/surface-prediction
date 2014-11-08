function [lines, linesmore] = generate_lines(img,sigma)
% sigma is used for long lines only
if nargin < 2
    sigma = 30;
end
diag = sqrt(size(img,1).^2 + size(img,2).^2);

longlen = ceil(diag/sigma);
lines = pkline(rgb2gray(img), 0.1, longlen);

shortlen = ceil(diag/50);
linesmore = pkline(rgb2gray(img), [0.04 0.08], shortlen);

end