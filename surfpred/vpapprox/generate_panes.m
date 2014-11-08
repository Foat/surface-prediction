function omap = generate_panes(pane,lines,vp,type,omap3)
%GENERATE_PANES generates possible omap for a pane

l=length(lines);
poss = [1 2;2 2;1 1;2 1;1 3;3 3;3 1];
prev=struct('point1', [0 0], 'point2', [0 0], 'length', 0.0,...
    'lineclass',0,'id',0,'type',-1,'start',[0 0]);

omap=zeros([size(pane) 3]);

for i=1:l
    bl=lines(i);
    if bl.lineclass~=type
        continue
    end
    
    if prev.type==-1
        prev=bl;
        continue
    end
    
    % [prev.type bl.type]
    % [1 2],[2 2],[1 1],[2 1],[1 3],[3 3],[3 1]
    check = [prev.type bl.type];
    
    % 1: point2 - vp, point1 - boundary
    % 2: start, vp
    % 3: start, boundary
    bmap=zeros(size(pane));
    t=type;
    if find(ismember(poss,check),1)
        % draw pane
        if check(1)==check(2)
%             bmap=roipoly(bmap,...
%                 [prev.point1(1) bl.point1(1) bl.point2(1) prev.point2(1)],...
%                 [prev.point1(2) bl.point1(2) bl.point2(2) prev.point2(2)]);
%                 
                if isequal(check,[1 1])
                    t=get_type([prev.start bl.start],vp,type);
                    bmap=get_roi(prev.start,bl.start,...
                        omap3,vp,t,type,1);
                elseif isequal(check,[2 2])
                    t=get_type([prev.point1 bl.point1],vp,type);
                    bmap=get_roi(prev.point1,bl.point1,...
                        omap3,vp,t,type,2);
                elseif isequal(check,[3 3])
                    t=get_type([bl.point1 prev.point1],vp,type);
                    bmap=get_roi(prev.point1,bl.point1,...
                        omap3,vp,t,type,3);
                end
        else
            if isequal(check,[1 2])
%                 bmap=roipoly(bmap,...
%                 [prev.start(1) bl.point1(1) bl.point2(1) prev.point2(1)],...
%                 [prev.start(2) bl.point1(2) bl.point2(2) prev.point2(2)]);
                t=get_type([prev.start bl.point1],vp,type);
                
                bmap=get_roi(prev.start,bl.point1,...
                        omap3,vp,t,type,2);
            elseif isequal(check,[2 1])
%                 bmap=roipoly(bmap,...
%                 [prev.point1(1) bl.start(1) bl.point2(1) prev.point2(1)],...
%                 [prev.point1(2) bl.start(2) bl.point2(2) prev.point2(2)]);
                t=get_type([prev.point1 bl.start],vp,type);
                
                bmap=get_roi(prev.point1,bl.start,...
                        omap3,vp,t,type,2);
            elseif isequal(check,[1 3])
%                 bmap=roipoly(bmap,...
%                 [prev.start(1) bl.point1(1) bl.point2(1) prev.point1(1)],...
%                 [prev.start(2) bl.point1(2) bl.point2(2) prev.point1(2)]);
                t=get_type([prev.start bl.point1],vp,type);
                
                bmap=get_roi(prev.start,bl.point1,...
                        omap3,vp,t,type,3);
            elseif isequal(check,[3 1])
%                 bmap=roipoly(bmap,...
%                 [prev.point1(1) bl.start(1) bl.point1(1) prev.point2(1)],...
%                 [prev.point1(2) bl.start(2) bl.point1(2) prev.point2(2)]);
                t=get_type([prev.point1 bl.start],vp,type);
                
                bmap=get_roi(prev.point1,bl.start,...
                        omap3,vp,t,type,3);
            end
        end
    end

%     disp([t check]);
%     disp(bl)
%     disp(prev)
%     imshow(bmap);
%     pause;
    omap(:,:,t)=omap(:,:,t)+bmap;
    prev=bl;
end

end


function t = get_type(line,vp,type)
% disp(line)
b=1:3;
b=b(b~=type);
bt=[type 0];
dist=consist_measure(line,vp(b,:));
[~,pos]=min(dist);
bt(2)=b(pos);
b=1:3;
t=b(b~=bt(1)&b~=bt(2));
end
