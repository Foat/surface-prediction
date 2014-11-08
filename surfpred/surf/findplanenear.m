function planes = findplanenear(boundaries)
%findplanenear finds neighbors for each panel
% boundaries - labeled boundaries of the plane
% result - struct
[h,w,c]=size(boundaries);

m=reshape(max(max(boundaries,[],1),[],2),[1 c]);
planes=repmat(struct('layer',0,'idx',0,'perim',0,'namt',0,'nidx',[],'npts',[]), sum(m), 1);

pos=0;
for i=1:c
    b=boundaries(:,:,i);
for j=1:m(i)
    namt=0;
    nidx=[];
    npts=[];
    
    pane=zeros([h w]);
    pane(b==j)=1;
    
    for la=1:3
        [idx,pts] = getpoints(boundaries(:,:,la),la,m(la),pane);
        if ~isempty(idx)
            sl=size(idx);
            l=namt+sl(1);
            namt=namt+1;
            nidx(namt:l)=panearrpos(idx(:,1),idx(:,2),m);
            npts(namt:l,:)=pts;
            namt=l;
        end
    end
    pos=pos+1;
    planes(pos)=struct('layer',i,'idx',j,'perim',sum(pane(:)==1),'namt',namt,'nidx',nidx,'npts',npts);
end
end
%% test drawing
% for i=1:pos
%     buf=zeros([h w c]);
%     p=planes(i);
%     b=boundaries(:,:,p.layer);
%     bb=zeros([h w]);
%     bb(b==p.idx)=1;
%     buf(:,:,p.layer)=buf(:,:,p.layer)+bb;
%     imshow(buf)
%     pause
%     for j=1:p.namt
%         ni=p.nidx(j);
%         l=planes(ni).layer;
%         idx=planes(ni).idx;
%         b=boundaries(:,:,l);
%         bb=zeros([h w]);
%         bb(b==idx)=1;
%         buf(:,:,l)=buf(:,:,l)+bb;
%     end
%     imshow(buf)
%     pause
% end

end

function pos = panearrpos(layer,idx,mx)
    pos=sum(mx(1:layer-1))+idx;
end

function [idx,pts] = getpoints(bound,layer,mx,pane)
% mx - max value on bound
idx=[];
pts=[];
% todo : remove self from result
kernel=strel('disk',2,4);
pane=imdilate(pane,kernel);
found=bound&pane;
bound(found==0)=0;
amt=0;
for i=1:mx
    [r,c]=find(bound==i);
    if ~isempty(r)
        amt=amt+1;
        idx(amt,:)=[layer i];
        pts(amt,:)=[c(1) r(1)];
    end
end
end

