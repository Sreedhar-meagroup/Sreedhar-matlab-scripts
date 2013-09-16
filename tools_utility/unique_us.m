function B = unique_us(A,varargin)
% function returns a vector B containing the unique values of A in unsorted
% order. (us in the function name stands for unsorted)
%input: A is the vector to be sorted
%         'first'(optional) -- to choose the first n unique elements of A
%         'last'(optional) -- to choose the last n unique elements of A
%         n(optional) -- the number of elements to choose. (default: n = 1)

okargin = {'first','last'};
[As, SortVec] = sort(A(:));
UV(SortVec) = [1;diff(As)]~=0;
B = A(UV);
    if nargin > 1
        k = strncmp(varargin{1},okargin,5);
        if any(k)
            if varargin{2}
                howmany = varargin{2};
            else
                howmany = 1;
            end
            if length(B) >= howmany & k(1)
                B = B(1:howmany);
            elseif length(B) >= howmany & k(2)
                B = B(end+1-howmany:end);
            else
                disp('Warning: Sorted vector is shorter than demanded.');
            end
        else
            error('Unknown parameter name: %s.', varargin{1});
        end
    end
            
end