% STK_FILLDIST computes the fill distance of a set of points
%
% CALL: FD = stk_filldist(X)
% CALL: FD = stk_filldist(X, BOX)
% CALL: FD = stk_filldist(X, Y)
% CALL: [FD, YMAX] = stk_filldist(...)
%
% See also: stk_dist, stk_mindist

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author: Julien Bect <julien.bect@supelec.fr>

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

function [fd, ymax] = stk_filldist(x, arg2)

stk_narginchk(1, 2);

if isstruct(x), x = x.a; end

if nargin == 1, % defaults: "exact" over [0; 1]^d
    
    default_box = repmat([0; 1], 1, size(x, 2));
    fd = stk_filldist_exact(x, default_box);
    
else

    if isstruct(arg2), arg2 = arg2.a; end
    
    ny = size(arg2, 1);
    
    if ny == 2, % arg2 is interpreted as a box
        
        [fd, ymax] = stk_filldist_exact(x, arg2);
        
    elseif ny > 2, % arg2 is interpreted a discrete test set
        
        [fd, ymax] = stk_filldist_discretized(x, arg2);
        
    else
        
        errmsg = 'Incorrect size for argument #2: nb rows > 1 expected.';
        stk_error(errmsg, 'InvalidArgument');
        
    end
            
end % if

end % function stk_filldist


%%
% fd = 0 if X = Y (discretized filldist)

%!test
%! n = 5; % must be bigger than 2
%! for dim = 1:10,
%!     x = rand(n, dim);
%!     fd = stk_filldist(x, x);
%!     assert(stk_isequal_tolabs(fd, 0.0));
%! end

%%
% One point in the middle of [0; 1]^d (exact & discretized filldist)

%!test %%% exact
%! for dim = 1:6,
%!     x = 0.5 * ones(1, dim);
%!     fd = stk_filldist(x); % [0; 1]^d is the default box
%!     assert(stk_isequal_tolabs(fd, 0.5 * sqrt(dim)));
%! end

%!test %%% discretized
%! for dim = 1:6,
%!     x  = 0.5 * ones(1, dim);
%!     y  = stk_sampling_regulargrid(2^dim, dim);  % [0; 1]^d is the default box
%!     fd = stk_filldist(x, y);
%!     assert(stk_isequal_tolabs(fd, 0.5 * sqrt(dim)));
%! end

%%
% One point in the middle of [1; 2]^d (exact filldist)

%!test
%! for dim = [1 3 7],
%!     box = repmat([1; 2], 1, dim);
%!     x = 1 + 0.5 * ones(1, dim);
%!     fd = stk_filldist(x, box);
%!     assert(stk_isequal_tolabs(fd, 0.5 * sqrt(dim)));
%! end
