% STK_SAMPLING_MAXIMINLHS generates a "maximin" LHS design
%
% CALL: X = stk_sampling_maximinlhs (N, DIM)
%
%   generates a "maximin" Latin Hypercube Sample of size N in the
%   DIM-dimensional hypercube [0; 1]^DIM. More precisely, NITER = 1000
%   independent random LHS are generated, and the one with the biggest
%   separation distance is returned.
%
% CALL: X = stk_sampling_maximinlhs (N, DIM, BOX)
%
%   does the same thing in the DIM-dimensional hyperrectangle specified by the
%   argument BOX, which is a 2 x DIM matrix where BOX(1, j) and BOX(2, j) are
%   the lower- and upper-bound of the interval on the j^th coordinate.
%
% CALL: X = stk_sampling_maximinlhs (N, DIM, BOX, NITER)
%
%   allows to change the number of independent random LHS that are used.
%
% See also: stk_mindist, stk_sampling_randomlhs

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
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

function x = stk_sampling_maximinlhs (n, d, box, niter)

if nargin > 4,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Read argument dim
if (nargin < 2) || ((nargin < 3) && (isempty (d)))
    d = 1;  % Default dimension
elseif (nargin > 2) && (~ isempty (box))
    d = size (box, 2);
end

% Read argument 'box'
if (nargin < 3) || isempty (box)
    box = stk_hrect (d);  % build a default box
else
    box = stk_hrect (box);  % convert input argument to a proper box
end

if nargin < 4,
    niter = 1000;
end

if n == 0, % no input => no output
    xdata = zeros (0, d);
else % at least one input point
    xx = lhsdesign_ (n, d, niter);
    xdata = stk_rescale (xx, [], box);
end

x = stk_dataframe (xdata, box.colnames);

end % function


%%%%%%%%%%%%%%%%%%
%%% lhsdesign_ %%%
%%%%%%%%%%%%%%%%%%

function x = lhsdesign_ (n, d, niter)

x = generatedesign_ (n, d);

if niter > 1,
    bestscore = stk_mindist (x);
    for j = 2:niter
        y = generatedesign_ (n, d);
        score = stk_mindist (y);
        if score > bestscore
            x = y;
            bestscore = score;
        end
    end
end

end % function


%%%%%%%%%%%%%%%%%%%%%%%
%%% generatedesign_ %%%
%%%%%%%%%%%%%%%%%%%%%%%

function x = generatedesign_ (n, d)

x = zeros (n, d);

for i = 1:d % for each dimension, draw a random permutation
    [ignd, x(:,i)] = sort (rand (n,1));  %#ok<ASGLU> CG#07
end

x = (x - rand (size (x))) / n;

end % function


%%
% Check error for incorrect number of input arguments

%!shared x, n, dim, box, niter
%! n = 20;  dim = 2;  box = [0, 0; 1, 1];  niter = 1;

%!error x = stk_sampling_maximinlhs ();
%!test  x = stk_sampling_maximinlhs (n);
%!test  x = stk_sampling_maximinlhs (n, dim);
%!test  x = stk_sampling_maximinlhs (n, dim, box);
%!test  x = stk_sampling_maximinlhs (n, dim, box, niter);
%!error x = stk_sampling_maximinlhs (n, dim, box, niter, pi);

%%
% Check that the output is a dataframe
% (all stk_sampling_* functions should behave similarly in this respect)

%!assert (isa (x, 'stk_dataframe'));

%%
% Check that column names are properly set, if available in box

%!assert (isequal (x.colnames, {}));

%!test
%! cn = {'W', 'H'};  box = stk_hrect (box, cn);
%! x = stk_sampling_maximinlhs (n, dim, box);
%! assert (isequal (x.colnames, cn));

%%
% Check output argument

%!test
%! for dim = 1:5,
%!   x = stk_sampling_randomlhs (n, dim);
%!   assert (isequal (size (x), [n dim]));
%!   u = double (x);  u = u(:);
%!   assert (~ any (isnan (u) | isinf (u)));
%!   assert ((min (u) >= 0) && (max (u) <= 1));
%!   assert (stk_is_lhs (x, n, dim));
%! end
