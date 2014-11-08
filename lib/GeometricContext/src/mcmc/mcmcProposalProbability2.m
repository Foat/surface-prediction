function p =  mcmcProposalProbability2(pE, adjlist, pWhole, smap1, origseg, smap2, newseg, niter)
% compute probability of proposing newseg from smap1
% 1) Randomly select superpixel s1, then randomly selects different superpixel
% s2 within same segment (if one exists); remove s1,s2 from s
% 2) Then, for randomly ordered i:
%     if si is adjacent to s1, assign si to s1 with probability pE(si, s1)
%     if si is adjacent to s2, assign si to s2 with probability pE(si, s2)
%     remove si from s
% 3) Repeat (2) until s is empty

nsp = numel(smap1);

ind1 = find(smap1==origseg);
ind2 = find(smap2==newseg);
n1 = numel(ind1);
n2 = numel(ind2);
if n1 == n2 % entire original segment selected
    if n1==1
        p = 1/nsp;
        disp('one')
    else
        p = pWhole*n2/nsp;
        disp('whole')
    end
else % subset of segment selected
    disp('subset')
    p = (1-pWhole)*n2/nsp;
    
    adjmat = zeros(n1, n1);
    for k = 1:size(adjlist, 1)
        if smap1(adjlist(k, 1))==origseg && smap1(adjlist(k, 2))==origseg
            i1 = logical(ind1==adjlist(k, 1));
            i2 = logical(ind1==adjlist(k, 2));
            adjmat(i1, i2) = k;
            adjmat(i2, i1) = k;
        end
    end    

    assntrue = 2*ones(n1, 1);
    for k = 1:n1
        if any(ind2==ind1(k))
            assntrue(k) = 1;
        end
        adj{k} = find(adjmat(k, :));
        adjlog{k} = logical(adjmat(k, :)>0);
    end
    notselectedind = find(assntrue==2);        
    
    p = p * (n1-n2) / (n1-1); % prob of selecting valid starting point for s2
    
    cpos = 0;
    cneg = 0;            
    assn = zeros(n1, 1);
    for k = 1:niter        
        s1 = ind2(ceil(rand(1)*n2));
        ts1 = find(ind1==s1);
               
        ts2 = notselectedind(ceil(rand(1)*numel(notselectedind)));
    
        if assntrue(ts2)~=2
            cneg = cneg+1;
        else        
            assn(:)=0;
            assn(ts1)=1;
            assn(ts2)=2;          
            rind = randperm(n1);
            rind([ts1 ts2]) = [];
            c = 0;
            while ~isempty(rind)                   
                for t = 1:numel(rind)
                    r = rind(t);
                    if ~assn(r)
                        assnr = assn(adjlog{r});
                    end
                    if ~assn(r) && sum(assnr)>0 
                        assnr1 = logical(assnr==1);
                        assnr2 = logical(assnr==2);
                        isadj1 = any(assnr1);
                        isadj2 = any(assnr2);
                        if isadj1 && ~isadj2
                            adj1 = adj{r}(assnr1);
                            p = 1-prod(1-pE(adjmat(r, adj1)));
                            if rand(1) < p
                                assn(r) = 1;                                
                            end
                        elseif isadj2 && ~isadj1
                            adj2 = adj{r}(assnr2);
                            p = 1-prod(1-pE(adjmat(r, adj2)));
                            if rand(1) < p
                                assn(r) = 2;
                            end
                        else
                            adj1 = adj{r}(assnr1);
                            adj2 = adj{r}(assnr2);
                            p1 = 1-prod(1-pE(adjmat(r, adj1)));
                            p2 = 1-prod(1-pE(adjmat(r, adj2)));
                            p1 = p1 / (p1 + p2);
                            if rand(1) < p1
                                assn(r) = 1;
                            else
                                assn(r) = 2;
                            end
                        end
                        if (assn(r)==1 && assntrue(r)==2) || (assn(r)==2 && assntrue(r)==1)
                            assn(logical(assn==0)) = 3;
                            break;
                        end                                         
                    end % end: if unassigned and has assigned adjacent sp                    
                end % end: loop through randomly ordered indices
                rind = rind(logical(assn(rind)==0));
            end % end: loop until all assigned while any(~assn)
            
            if any(assn~=assntrue)
                cneg = cneg + 1;
            else
                cpos = cpos + 1;
            end            
        end % end: if ts2 matches profile
    end % end: loop over iterations    
    
    p = p * max(cpos/(cpos+cneg), 1/niter);
   
    
end % compute prob for subset

