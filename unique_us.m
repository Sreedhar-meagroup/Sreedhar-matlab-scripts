function B = unique_us(A)
% function returns a vector B containing the unique values of A in unsorted
% order. (us in the function name stands for unsorted)
[As, SortVec] = sort(A(:));
UV(SortVec) = [1;diff(As)]~=0;
B = A(UV);