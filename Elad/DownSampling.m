function [ D ] = DownSampling( rows, columns, rescale )
% [rows, columns] = size(LRimage)
    r = rows*columns;
    c = rows*columns*rescale^2;
    D = sparse(r, c);   
    i = 0;
    for j = 1:c
        if mod(floor((j-1)/(rows*rescale)),rescale)==0
            if mod(j-1,rescale)==0 && (i<r)
                i=i+1;
                D(i,j)=1;
            end
        end
    end
    
end

