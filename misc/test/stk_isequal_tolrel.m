% STK_ISEQUAL_TOLREL tests approximate equality of two matrices or structures.
%
% CALL: BOOL = stk_isequal_tolrel(A, B, TOLREL)
%
%   returns true if A and B are numeric arrays of the same size, such that for
%   any pair (a, b) of corresponding entries,
%
%      abs(b - a) <= TOLABS,                                                (1)
%
%   where
%
%      TOLABS = max(max(A(:)), max(B(:))) * TOLREL.
%
%   For numeric array, the function returns false is either
%
%    * the array don't have identical sizes, or
%    * the array have identical sizes but (1) doesn't hold.
%
%   If A and B are structures with the same list of fieldnames, the function
%   works recursively on the fields, and returns true iff all the fields are
%   approximately equal.
%
% CALL: b = stk_isequal_tolrel(a, b)
%
%   uses the default value 1e-8 for TOLREL.
%
% See also isequal.

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (http://sourceforge.net/projects/kriging)
%
%    STK is free software: you can redistribute it and/or modify it under
%    the terms of the GNU General Public License as published by the Free
%    Software Foundation,  either version 3  of the License, or  (at your
%    option) any later version.
%
%    STK is distributed  in the hope that it will  be useful, but WITHOUT
%    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
%    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
%    License for more details.
%
%    You should  have received a copy  of the GNU  General Public License
%    along with STK.  If not, see <http://www.gnu.org/licenses/>.

function res = stk_isequal_tolrel(a, b, tolrel)

DEFAULT_TOLREL = 1e-8;

stk_narginchk(2, 3);

if nargin == 2,
    tolrel = DEFAULT_TOLREL;
end

if isstruct(a) && isstruct(b),
    
    L = fieldnames(a);
    if ~isequal(fieldnames(b), L),
        res = false;
        return;
    end
    res = true;
    for k = 1:length(L),
        if ~isfield(b, L{k}),
            res = false;
            return;
        end
        res = stk_isequal_tolrel(a.(L{k}), b.(L{k}), tolrel);
        if ~ res, return; end
    end
    
elseif isnumeric(a) && isnumeric(b)
    
    aa = a(:);
    bb = b(:);
    tolabs = max(abs(aa), abs(bb)) * tolrel;
    res = all(abs(bb - aa) <= tolabs);
    
else
    
    res = false;
    
end

end % function stk_isequal_tolrel

%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%!shared r1, r2, a, b, tolrel
%! a = 1.01; b = 1.02; tolrel = 0.1;

%!error rr = stk_isequal_tolrel();
%!error rr = stk_isequal_tolrel(a);
%!test  r1 = stk_isequal_tolrel(a, b);
%!test  r2 = stk_isequal_tolrel(a, b, tolrel);
%!error rr = stk_isequal_tolrel(a, b, tolrel, pi);

%!test assert(~r1);
%!test assert(r2);

%!test
%! a = struct('u', []); b = struct('v', []);
%! assert(~ stk_isequal_tolrel(a, b))
%!test
%! a = struct('u', 1.01); b = struct('u', 1.02);
%! assert(stk_isequal_tolrel(a, b, tolrel))
