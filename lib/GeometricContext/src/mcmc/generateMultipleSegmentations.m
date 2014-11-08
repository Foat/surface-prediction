function smaps =  generateMultipleSegmentations(pE, adjlist, nsp, nsegall)
% 1) Randomly select superpixel s1, then randomly selects different superpixel
% s2 within same segment (if one exists); remove s1,s2 from s
% 2) Then, for randomly ordered i:
%     if si is adjacent to s1, assign si to s1 with probability pE(si, s1)
%     if si is adjacent to s2, assign si to s2 with probability pE(si, s2)
%     remove si from s
% 3) Repeat (2) until s is empty


% randomly split each segment further into connected components
%adjmat2 = curradjmat;
nmaps = numel(nsegall);

smaps = zeros(nsp, nmaps);

adjmat = zeros(nsp, nsp);
for k = 1:size(adjlist, 1)
    s1 = adjlist(k, 1);
    s2 = adjlist(k, 2);
    adjmat(s1, s2) = k;
    adjmat(s2, s1) = k;
end
    
nadj = zeros(nsp, 1);
for k = 1:nsp
    adj{k} = find(adjmat(k, :));
    nadj(k) = numel(adj{k});
end
for k = 1:nsp
    normalization = 2./(nadj(r)+nadj(adj{k})');
    pOffAll{k} = (1-pE(adjmat(k, adj{k}))).^normalization;
    pOnAll{k} = pE(adjmat(k, adj{k})).^normalization;     
end

for m = 1:nmaps
    rind = randperm(nsp);
    smap = zeros(nsp, 1);
    nseg = nsegall(m);
    
    nseg = min(nseg, nsp);
    smap(rind(1:nseg)) = (1:nseg);
    
    rind(1:nseg) = [];   

    while sum(nadj(rind))>0 % do until all possible sp are assigned
        for r = rind
            for k = 1:nseg
                kadj = find(smap(adj{r})==k);
                if ~isempty(sadj)
                    normalization = 2./(nadj(r)+nadj(sadj)');
                    pOn = prod(pOnAll(kadj));
                    pOff = prod((1-pE(adjmat(r, sadj))).^normalization);
                    if rand(1) < pOn / (pOn+pOff)
                        smap(r) = k;
                    end
                end
            end
        end

        rind(smap(rind)>0) = [];                
        
    end
 
    
    count = zeros(nseg, 1);
    for k = 1:nseg
        count(k) = sum(smap==k);
    end
    
    %disp(['0: ' num2str(evaluateEdgeProb(adjlist, pE, smap))])

    for t = 1:20
        lastmap = smap;
        rind = randperm(nsp);
        for r = rind
            if smap(r) > 0
                p = zeros(nseg, 1);
                normalization = 2./(nadj(r)+nadj(adj{r})');
                pOff = (1-pE(adjmat(r, adj{r}))).^normalization;
                pOn = pE(adjmat(r, adj{r})).^normalization;                
                if count(smap(r)) > 1
                    for k = 1:nseg
                        if any(smap(adj{r})==k)
                            sOn = adj{r}(smap(adj{r})==k);
                            sOff = setdiff(adj{r}, sOn);
                            pOn = prod(pE(adjmat(r, sOn)).^normalization(sOn));
                            pOff = prod((1-pE(adjmat(r, sOffadj)).^normalization(sOff));                            
                            p(k) = 1-prod(1-pE(adjmat(r, sadj)));                            
                        end
                    end
                    [kval, kmax] = max(p);
                    if kmax~=smap(r)
                        count(smap(r)) = count(smap(r))-1;
                        smap(r) = kmax;
                    end
                end
            end
        end
        if all(lastmap==smap)
            break;
        end
    end 
    %disp(['1: ' num2str(evaluateEdgeProb(adjlist, pE, smap))])

    smaps(:, m) = smap;
end




function p = evaluateEdgeProb(adjlist, pE, smap)
hasedge = zeros(size(adjlist, 1), 1);
for k = 1:size(adjlist, 1)
    if smap(adjlist(k, 1))==smap(adjlist(k, 2))
        hasedge(k)=1;
    end
end
p = 0;
p = sum(log(pE(hasedge==1)));
p = p+sum(log(1-pE(hasedge==0)));