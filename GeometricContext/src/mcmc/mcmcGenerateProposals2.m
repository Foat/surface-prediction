function [smapNew, newseg, origseg, neighbors] =  ...
    mcmcGenerateProposals2(pE, adjlist, smap, pWhole, w)
% 1) Randomly select superpixel s1, then randomly selects different superpixel
% s2 within same segment (if one exists); remove s1,s2 from s
% 2) Then, for randomly ordered i:
%     if si is adjacent to s1, assign si to s1 with probability pE(si, s1)
%     if si is adjacent to s2, assign si to s2 with probability pE(si, s2)
%     remove si from s
% 3) Repeat (2) until s is empty


% randomly split each segment further into connected components
%adjmat2 = curradjmat;
nsp = numel(smap);

if ~exist('w') || isempty(w)
    w = ones(nsp, 1);
end
w = cumsum(w / sum(w));
    
s1 = min(find(rand(1)<w));
seg = smap(s1);

sind = find(smap==seg);
nind = numel(sind);
adjmat = zeros(nind, nind);
for k = 1:size(adjlist, 1)
    if smap(adjlist(k, 1))==seg && smap(adjlist(k, 2))==seg
        i1 = find(sind==adjlist(k, 1));
        i2 = find(sind==adjlist(k, 2));
        adjmat(i1, i2) = k;
        adjmat(i2, i1) = k;
    end
end
    
ts1 = find(sind==s1);

if (rand(1) < pWhole) || (nind==1)
    ind1 = sind;
    origseg = smap(s1);
    newseg = smap(s1);
    smapNew = smap;
else
    nind = numel(sind);
    ts2 = ceil(rand(1)*(nind-1)+1);
    if ts2==ts1
        ts2 = 1;
    end
    
    assn = zeros(nind, 1);
    assn(ts1)=1;
    assn(ts2)=2;
    rind = randperm(nind);
    while(any(~assn))       
        for r = rind
            if ~assn(r) && any(assn(find(adjmat(r, :)))) 
                adj = find(adjmat(r, :));
                
                if all(assn(adj)==1)
                    assn(r) = 1;
                elseif all(assn(adj)==2)
                    assn(r) = 2;
                else % only some of adjacent sp are assigned
                    isadj1 = any(assn(adj)==1);
                    isadj2 = any(assn(adj)==2);                    
                    
                    if isadj1 && ~isadj2 % no adjacent assigned to 2
                        adj1 = adj(find(assn(adj)==1));
                        pOff = prod(1-pE(adjmat(r, adj1)));
                        pOn = prod(pE(adjmat(r, adj1)));
                        if rand(1) < pOn / (pOn+pOff)+0.01
                            assn(r) = 1;
                        end
                    elseif isadj2 && ~isadj1 % no adjacent assigned to 1
                        adj2 = adj(find(assn(adj)==2));
                        pOff = prod(1-pE(adjmat(r, adj2)));
                        pOn = prod(pE(adjmat(r, adj2)));
                        if rand(1) < pOn / (pOn+pOff)+0.01
                            assn(r) = 2;
                        end
                    else % some adjacent assigned to 1, some to 2
                        adj1 = adj(find(assn(adj)==1));
                        adj2 = adj(find(assn(adj)==2));
                        pOff1 = prod(1-pE(adjmat(r, adj1)));
                        pOn1 = prod(pE(adjmat(r, adj1)));
                        pOff2 = prod(1-pE(adjmat(r, adj2)));
                        pOn2 = prod(pE(adjmat(r, adj1)));
                        p1 = (pOn1*pOff2) / (pOn1*pOff2 + pOn2*pOff1);
                        if rand(1) < p1
                            assn(r) = 1;
                        else
                            assn(r) = 2;
                        end
                    end
                end
            end
        end
    end
    ind1 = sind(find(assn==1));
    
    smapNew = smap;    
    newseg = max(smap)+1;    
    smapNew(ind1) = newseg;
    origseg = smap(s1);
    
end

neighbors = [];
for k=1:size(adjlist, 1)
    % if exactly one adjacent sp is in segment 1, two segments are adjacent
    if (smapNew(adjlist(k, 1))==newseg) && (smapNew(adjlist(k, 2))~=newseg)
        neighbors(end+1) = smap(adjlist(k, 2));
    elseif (smapNew(adjlist(k, 1))~=newseg) && (smapNew(adjlist(k, 2))==newseg)
        neighbors(end+1) = smap(adjlist(k, 1));
    end
end

    
 