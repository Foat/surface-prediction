function lines = find_lines(pane, vp)
% generates lines for pane
% between pane boundary and vp
s = size(pane);
N = s(1);
% fprintf('N = %d\n', N);
lines = repmat(struct('point1', [0 0], 'point2', [0 0], 'length', 0.0,...
    'lineclass',0,'id',0,'type',1,'start',[0 0]), N*2, 1);
b = 1:3;
barr = b;
j=1;
for i=barr
    for k=1:N
        point1 = [pane(k,2) pane(k,1)];
        point2 = vp(i,:);
        length = norm(point1 - point2);
        lines(j) = struct('point1', point1, 'point2', point2,...
            'length', length,...
            'lineclass',i,'id',j,'type',1,'start',point1);
        j=j+1;
    end
end
end