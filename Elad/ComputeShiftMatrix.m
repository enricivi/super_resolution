function [ s ] = ComputeShiftMatrix(rows, columns, shift)
% input:
% [rows, columns] = size(image);
% shift = [ x_shift, y_shift ]; x_shift > 0 shift to the right
%                               y_shift > 0 shift down
%         (0,0)
%           . -----> x
%           |
%           |
%           v y
%
% output:
% s is a sparse matrix
    dim = rows*columns;
    s = sparse(dim, dim);
    if shift(1) ~= 0
        iter = dim - rows;
        for i = 1:iter
            s(i, rows + i) = 1;
        end
        if shift(1) > 0
            s = s';
            shift(1) = shift(1) - 1;
        else
            shift(1) = shift(1) + 1;
        end
        s = s * ComputeShiftMatrix(rows, columns, [shift(1), shift(2)]);

    elseif shift(2) ~= 0
        iter = dim - columns;
        i = 1;
        j = 1;
        while i <= iter
            if mod(j, rows) ~= 0
                s(j, j + 1) = 1;
                i = i + 1;
            end
            j = j + 1;
        end
        if shift(2) > 0
            s = s';
            shift(2) = shift(2) - 1;
        else
            shift(2) = shift(2) + 1;
        end
        s = s * ComputeShiftMatrix(rows, columns, [shift(1), shift(2)]);

    else
        s = speye(dim);
        return
    end
    
end
