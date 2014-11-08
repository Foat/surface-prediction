% 
% The above copyright notice and this permission notice shall be included in 
% all copies or substantial portions of the Software.
%
% The Software is provided "as is", without warranty of any kind.

% December 2000 - Original version
% February 2003 - Added the returning of nedgelist data.
% December 2006 - Changed so that separate cell arrays of line segments are
%                 formed, in the same format used for edgelists


function seglist = lineseg2(edgelist, tol)
    
    Nedge = length(edgelist);
    seglist = {};%cell(1,Nedge);
    
    ee=1;
    for e = 1:Nedge
        %disp('---------------------');
        %[e,length(seglist)]
        y = edgelist{e}(:,1);   % Note that (col, row) corresponds to (x,y)
	x = edgelist{e}(:,2);

	fst = 1;                % Indices of first and last points in edge
	lst = length(x);        % segment being considered.

	Npts = 1;	
	%seglist{e}(Npts,:) = [y(fst) x(fst)];
	
	while  fst<lst
	    [m,i] = maxlinedev(x(fst:lst),y(fst:lst));  % Find size & posn of
                                                        % maximum deviation.
	    
	    while m > tol       % While deviation is > tol  
		lst = i+fst-1;  % Shorten line to point of max deviation by adjusting lst
		[m,i] = maxlinedev(x(fst:lst),y(fst:lst));
	    end
            %[fst,lst]
            
	    seglist{ee} = [y(fst:lst), x(fst:lst)];
	    ee=ee+1;
            
	    fst = lst;        % reset fst and lst for next iteration
	    lst = length(x);
	end
    end

    
