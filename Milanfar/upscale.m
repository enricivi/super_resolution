function [B] = upscale(A, scale)
    B = zeros(scale*size(A));
    [hb, wb] = size(B);
    
    int32S = int32(scale);
    for i = 1:scale:hb
        int32I = int32(i);
        for j = 1:scale:wb
            int32J = int32(j);
            B(i,j) = A(idivide(int32I, int32S)+1, ...
                       idivide(int32J, int32S)+1);
        end
    end
    
end

