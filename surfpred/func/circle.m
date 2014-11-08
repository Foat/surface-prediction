function circle(center,radius,style)
% plots circle with specified center, radius and style
if (nargin <2),
 error('Please see help for INPUT DATA.');
elseif (nargin==2)
    style='b-';
end;
t=0:0.1:2*pi;
%x_o and y_o = center of circle
x = center(1) + radius*sin(t);
y = center(2) + radius*cos(t);
plot(x,y,style);
end