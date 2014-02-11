function e = run_length_chipscope(x)
% originally from Pankaj Joshi India 
% http://www.mathworks.com/matlabcentral/fileexchange/40728-run-length-encoding/content/run_length.m
%
% modfied to fit TikZ format
% by:
%       Steffen Mauch (C) 2014
%       email: steffen.mauch (at) gmail.com
%

c = size(x);
if c(1)==1
    n=0;
    for i=1:length(x)-1
        if x(i)~=x(i+1);
            n=n+1;
        end
    end
    for i=1:n+1
        l(i)=1;
    end
    j=1; i=1;
    while j<length(x)
        if x(j)==x(j+1)
            l(i)=l(i)+1;
        else
            b(i)=x(j);
            i=i+1;
        end
        j=j+1;
    end
    b(n+1)=x(length(x));
    i=1; j=1; e=[];
    while i<= length(l) && j<=2*length(l)
        e = [ e num2str( l(i) ) ];
        if( b(i) == 1 )
            e = [ e 'H ' ];
        else
            e = [ e 'L ' ];
        end
        i=i+1;
        j=j+2;
    end
end
