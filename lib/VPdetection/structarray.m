%===============================================================================
% Build an n-array of structures st
%
%
%by Jean-Philippe Tardif (tardifj@{iro.umontreal.ca, gmail.com, seas.upenn.edu}
%================================================================================
function vSt = structarray(st,n)
    
    if n ==0
        vSt = [];
        return;
    end
    
    %for i =
        vSt(1:n) = deal(st);
        %end
    