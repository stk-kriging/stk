% STK_ISEQUAL_TOLREL tests approximate equality of two matrices or structures.
%
% CALL: b = stk_isequal_tolrel(a, b)
% CALL: b = stk_isequal_tolrel(a, b, tolrel)
%
% Returns true if any(abs(b - a) <= abs(b) * tolrel)). If the third argument is
% omitted, a default relative tolerance of 1e-8 is used.
%
% If both a and b are structures, then stk_iequal_tolrel works recursively on
% the fields of the structures, and returns true if the two structures have the
% same fields and if they are pairwise equal.
%
% See also isequal.

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%
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
    
    res = any(abs(b - a) <= max(abs(a), abs(b)) * tolrel);
    
else
    
    res = false;
    
end

end % function stk_isequal_tolrel

%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

% STK_ISEQUAL_TOLREL tests approximate equality of two matrices or structures.
%
% CALL: b = stk_isequal_tolrel(a, b)
% CALL: b = stk_isequal_tolrel(a, b, tolrel)
%
% Returns true if any(abs(b - a) <= abs(b) * tolrel)). If the third argument is
% omitted, a default relative tolerance of 1e-8 is used.
%
% If both a and b are structures, then stk_iequal_tolrel works recursively on
% the fields of the structures, and returns true if the two structures have the
% same fields and if they are pairwise equal.
%
% See also isequal.

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
