function B = unique_us(A,varargin)
% function returns a vector B containing the unique values of A in unsorted
% order. (us in the function name stands for unsorted)
okargin = {'first'};
[As, SortVec] = sort(A(:));
UV(SortVec) = [1;diff(As)]~=0;
B = A(UV);
    if nargin > 1
        k = strncmp(varargin{1},okargin,5);
            if ~k
                error('unique_us: ', 'Unknown parameter name: %s.', varargin{1});
            else
                switch(k)
                    case 1  % first
                        howmany = varargin{2};
                end
                if length(B) >= howmany
                    B = B(1:howmany);
                else
                    disp('Warning: Sorted vector is shorter than demanded.');
                end
            end
    end
end