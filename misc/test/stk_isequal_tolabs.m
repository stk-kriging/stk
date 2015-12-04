% STK_ISEQUAL_TOLABS tests approximate equality of two matrices or structures.
%
% CALL: BOOL = stk_isequal_tolabs(A, B, TOLABS)
%
%   returns true if A and B are numeric arrays of the same size, such that for
%   any pair (a, b) of corresponding entries,
%
%      abs(b - a) <= TOLABS.                                                (1)
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
% CALL: b = stk_isequal_tolabs(a, b)
%
%   uses the default value 1e-8 for TOLABS.
%
% See also isequal.

% Copyright Notice
%
%    Copyright (C) 2012, 2013 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@centralesupelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@centralesupelec.fr>

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

function res = stk_isequal_tolabs(a, b, tolabs)

DEFAULT_TOLABS = 1e-8;

if nargin > 3,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin == 2,
    tolabs = DEFAULT_TOLABS;
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
        res = stk_isequal_tolabs(a.(L{k}), b.(L{k}), tolabs);
        if ~ res,
            return;
        end
    end
    
elseif isnumeric(a) && isnumeric(b)
    
    res = all(abs(b(:) - a(:)) <= tolabs);
    
elseif ischar (a) && ischar (b)
    
    res = strcmp (a, b);
    
elseif iscell (a) && iscell (b)
    
    for i = 1:numel(a),
        if ~stk_isequal_tolabs (a{i}, b{i}, tolabs);
            res = false;
            return;
        end
    end
    
    res = true;
    
elseif (isa (a, 'stk_dataframe') || isa (a, 'stk_kreq_qr')) ...
    && (strcmp (class (a), class (b)))
    
    res = stk_isequal_tolabs (struct (a), struct (b), tolabs);
    
else
    
    res = false;
    
end

end % function


%!shared r1, r2, a, b, tolabs
%! a = 1.01; b = 1.02; tolabs = 0.1;

%!error rr = stk_isequal_tolabs();
%!error rr = stk_isequal_tolabs(a);
%!test  r1 = stk_isequal_tolabs(a, b);
%!test  r2 = stk_isequal_tolabs(a, b, tolabs);
%!error rr = stk_isequal_tolabs(a, b, tolabs, pi);

%!test assert(~r1);
%!test assert(r2);

%!test
%! a = struct('u', []); b = struct('v', []);
%! assert(~ stk_isequal_tolabs(a, b))
%!test
%! a = struct('u', 1.01); b = struct('u', 1.02);
%! assert(stk_isequal_tolabs(a, b, tolabs))
