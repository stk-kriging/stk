% STK_SAMPLING_NESTEDDESIGN generates a nested design
%
% CALL: X = stk_sampling_nesteddesign (N, DIM)
%
%   generates a nested design with length(N) levels, with N(k) points at
%   the k-th level. X has sum(N) rows and (DIM + 1) columns, the last
%   column begin the levels.
%   A design is nested when all points at the (k+1)-th level are also at
%   the k-th level.
%
% CALL: X = stk_sampling_nesteddesign (N, DIM, BOX)
%
%   does the same thing in the DIM-dimensional hyperrectangle specified by the
%   argument BOX, which is a 2 x DIM matrix where BOX(1, j) and BOX(2, j) are
%   the lower- and upper-bound of the interval on the j^th coordinate.
%   Default value for BOX: [0; 1]^DIM.
%   If BOX is provided, DIM = size(BOX, 2).
%   Warning: size(X, 2) == (DIM + 1)
%
% CALL: X = stk_sampling_nesteddesign (N, DIM, BOX, NITER)
%
%   allows to change the number of independent random LHS that are used,
%   when generating a maximin LHS.
%   Default value for NITER: 1000. 
%
% CALL: X = stk_sampling_nesteddesign (N, DIM, BOX, NITER, LEVELS)
%
%   does the same thing, but the levels are indexed by the vector LEVELS.
%   The length of LEVELS must be greater or equal than the length of N.
%   Default value for levels: 1:length(N).
%
% EXAMPLE
%
%   n = [30, 14, 5, 2]; dim = 2;
%   bnd = stk_hrect([-5, 1; 7, 2]);
%   levels = [100; 50; 33; 25; 20;];
%   x = stk_sampling_nesteddesign(n, dim, bnd, [], levels);
%
% REFERENCE
%
%   [1] Loic Le Gratiet, "Multi-fidelity Gaussian process regression for
%       computer experiments", PhD thesis, Universite Paris-Diderot -
%       Paris VII, 2013.
%
% See also: stk_sampling_nestedlhs, stk_sampling_maximinlhs

% Copyright Notice
%
%    Copyright (C) 2017 LNE
%    Copyright (C) 2017 CentraleSupelec
%
%    Authors:   Remi Stroh         <remi.stroh@lne.fr>

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

function nested_design = stk_sampling_nesteddesign(n, dim, box, niter, levels)


if nargin > 5,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin < 1,
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
end

%% Read the input arguments

% number of points
n = n(:);
if any(n <= 0)
    stk_error('Number of points at each level must be strictly positive.',...
        'InvalidArgument');
end
nLev = length(n);

% Read argument dim
if (nargin > 2) && (~ isempty (box))
    dim = size (box, 2);
elseif (nargin < 2) || (isempty (dim))
    dim = 1;  % Default dimension
end

% Read argument box
if (nargin < 3) || isempty (box)
    box = stk_hrect (dim);
else
    % Check that box is a box
    if ~ isa (box, 'stk_hrect')
        box = stk_hrect (box);
    end
end

% niter, number of interation
if (nargin < 4) || isempty(niter)
    niter = 1000;
end

% Read argument levels
level_name = 'Level';   % Column name of the column level
if (nargin < 5) || isempty (levels)
    levels = (1:nLev)';
else
    % Find the colnames of the levels
    if isa(levels, 'stk_dataframe')
        % If isa data frame with a non-empty colname, return the first
        % non-empty colnames
        empty_colnames = ~cellfun(@isempty, levels.colnames);
        if any(empty_colnames)
            level_name = levels.colnames{find(empty_colnames, 1)};
        end
    end
    
    % Assert vector
    levels = double(levels(:));
    % Assert unique values of levels
    if ~isequal(unique(levels), sort(levels))
        stk_error('Levels are not unique.', 'InvalidArgument')  
    end
    
    % Check number of proposed levels
    if length(levels) < nLev
        stk_error('You do not have enough levels, or the array ''n'' is too long.',...
            'InvalidArgument');
    end
    levels = levels(1:nLev);
end

%% Nested design
best_design = NaN(n(1), dim);

row_highLevels   = @(M, k, numb)(numb(M) - ( (numb(k) - 1):-1:0));
row_currentLevel = @(M, k, numb)(numb(M) - ( (numb(k) - 1):-1:numb(k + 1)) );

% k_lev = nLev
best_design(row_highLevels(1, nLev, n), :) = ...
    double( stk_sampling_maximinlhs(n(nLev), dim, box, niter) );

for k_lev = (nLev - 1):-1:1
    % 1: Generate a LHS design
    X_new_k = stk_sampling_maximinlhs(n(k_lev), dim, box, niter);
    
    % 2: Compute minimal distance between any proposed points, and points
    % already in the design
    X_prev = best_design(row_highLevels(1, k_lev + 1, n), :);
    dist_new_prev = min( stk_dist(X_new_k, X_prev), [], 2);
    
    % 3: Keep the farthest
    [ignd, ind_dist] = sort(dist_new_prev, 'descend');  %#ok<ASGLU> CG#07
    ind_select = ind_dist( 1:((n(k_lev) - n(k_lev + 1)) ), 1);
    
    best_design(row_currentLevel(1, k_lev, n), :) = double( X_new_k(ind_select, :) );
end

%% Create a nested design
nested_design = NaN(sum(n), dim + 1);
% The total number of points in the nested design
nCumNb = [0; cumsum(n)];

% Add points + the corresponding level
for knL = 1:nLev
    nested_design((nCumNb(knL) + 1):(nCumNb(knL + 1)), :) = [
        best_design(row_highLevels(1, knL, n), :), repmat(levels(knL), n(knL), 1)];
end

% Add columns names
colnames = cell(1, dim + 1);
if ~isempty(box.colnames)
    colnames(1, 1:dim) = box.colnames;
end
colnames{1, dim + 1} = level_name;

% Return a nested design
nested_design = stk_dataframe(nested_design, colnames);
end

% Check error for incorrect number of input arguments
%!shared x, n, dim, box, niter, levels
%! n = [23; 14; 5; 2];  dim = 2;  box = [0, 0; 4, 4];  niter = 10;
%! levels = [10.1; 15.2; -9.3; 2.4; 17.5];

%!error x = stk_sampling_nesteddesign ();
%!test  x = stk_sampling_nesteddesign (n);
%!test  x = stk_sampling_nesteddesign (n, dim);
%!test  x = stk_sampling_nesteddesign (n, dim, box);
%!test  x = stk_sampling_nesteddesign (n, dim, box, niter);
%!test  x = stk_sampling_nesteddesign (n, dim, box, niter, levels);
%!error x = stk_sampling_nesteddesign (n, dim, box, niter, levels, pi);

% Check type of ouputs => assert is Nested Design
%!assert ( isequal(size(x), [sum(n), dim + 1]) );
%!assert ( isa(x, 'stk_dataframe') );
%! cn = [0; cumsum(n)];
%! for lev = 1:length(n),
%!   y = x( (cn(lev) + 1):(cn(lev + 1)), 1:dim );
%!   assert (isequal (size (y), [n(lev) dim]));
%!   if lev > 1
%!       assert ( isequal(z((end - n(lev) + 1):end, :), y) );
%!   end
%!   if lev == length(n)
%!       assert (stk_is_lhs (y, n(lev), dim, box));
%!   end
%!   z = y;
%! end

% Check column names
%!assert (isequal (x.colnames{dim + 1}, 'Level'));
%! levels = stk_dataframe(levels, {'t'});
%! box = stk_hrect(box, {'x1', 'x2', 'x3', 'x4'});
%!test  x = stk_sampling_nesteddesign (n, [], box, [], levels);
%!assert (isequal(x.colnames, {'x1', 'x2', 'x3', 'x4', 't'}) );