% STK_SAMPLING_NESTEDLHS builds a Nested Latin Hypercube Sampling (NLHS)
%
% CALL: X = stk_sampling_nestedlhs (N, DIM)
%
%   builds a NLHS, with length(N) levels, N(k) points at the k-th level,
%   and a dimension DIM. X has sum(N) rows and (DIM + 1) columns, the last
%   column begin the levels.
%   A design is nested when all points observed at the (k+1)-th level are
%   also observed at the k-th level.
%   A nested design is a Latin Hypercube Sampling (LHS), if every
%   sub-design corresponding to a specified level is a LHS.
%   Remark: N(k) must divide N(k + 1).
%
% CALL: X = stk_sampling_nestedlhs (N, DIM, BOX)
%
%   does the same thing in the DIM-dimensional hyperrectangle specified by the
%   argument BOX, which is a 2 x DIM matrix where BOX(1, j) and BOX(2, j) are
%   the lower- and upper-bound of the interval on the j^th coordinate.
%   Default value for BOX: [0; 1]^DIM.
%   If BOX is provided, DIM = size(BOX, 2).
%   Warning: size(X, 2) == (DIM + 1)
%
% CALL: X = stk_sampling_nestedlhs (N, DIM, BOX, NITER)
%
%   allows to change the number of independent random LHS that are used at
%   each level to complete the design.
%   Default value for NITER: 1000.
%   Put NITER to 1 to generate a random NLHS.
%
% CALL: X = stk_sampling_nestedlhs (N, DIM, BOX, NITER, LEVELS)
%
%   does the same thing, but the levels are indexed by the vector LEVELS.
%   The length of LEVELS must be greater or equal than the length of N.
%   Default value for LEVELS: 1:length(N).
%
% EXAMPLE
%
%   n = [48, 12, 6, 2]; dim = 2;
%   bnd = stk_hrect([-5, 1; 7, 2]);
%   levels = [100; 50; 33; 25; 20;];
%   x = stk_sampling_nestedlhs(n, dim, bnd, [], levels);
%
% REFERENCE
%
%   [1] Peter Z. G. Qian, "Nested latin hypercube designs", Biometrika,
%       96(4):957-970, 2009.
%
% See also: stk_sampling_nesteddesign, stk_sampling_randomlhs

% Copyright Notice
%
%    Copyright (C) 2017 LNE
%    Copyright (C) 2017 CentraleSupelec
%
%    Authors:  Remi Stroh  <remi.stroh@lne.fr>

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

function nested_LHS = stk_sampling_nestedlhs(n, dim, box, niter, levels)

if nargin > 5,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin < 1,
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
end

%% Read input arguments
% number of points
n = n(:);     % assert vector
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

%% Quotient between each level
quotient = floor(n(1:(nLev - 1))./n(2:nLev));
remainder = n(1:(nLev - 1)) - quotient.*n(2:nLev);
if any( remainder ~= 0 )
    %assert n(2)|n(1); n(3)|n(2); n(4)|n(3); etc, ...
    stk_error(['This method supposes that the number of points',...
        ' at level t + 1 divides the number of points at level t.'],...
        'InvalidArgument');
end

%% Build the nested design
% Nested Latin hypercube designs
% BY PETER Z. G. QIAN, 2009

best_LHS = NaN(n(1), dim);
X_prev   = NaN(0, dim);     % at the beginning there is not any point
n = [n; 0];                 % no point are asked at the level nLev + 1
quotient = [1; quotient];	% no multiplication at the first level

% Two functions to find points of a level
row_highLevels   = @(M, k, numb)(numb(M) - ( (numb(k) - 1):-1:0));
row_currentLevel = @(M, k, numb)(numb(M) - ( (numb(k) - 1):-1:numb(k + 1)) );

for k_lev = nLev:-1:1; %begin by the end
    
    list_nb = (1:n(k_lev))';           % list of all values we must get after this loop
    n_new_k = n(k_lev) - n(k_lev + 1);	% number of new value to add
    
    list_nb_new_k = NaN(n_new_k, dim);
    for id = 1:dim
        list_nb_new_k(:, id) = list_nb(~ismember(list_nb,  X_prev(:, id)), 1);
        % Find every element in the complete list of number, which are not
        % chosen in the previous level
    end
    
    best_score = -Inf;
    for k_try = 1:niter
        
        X_new_kl = NaN(n_new_k, dim);    %the matrix to add
        
        [ignd, random_index] = sort(rand(n_new_k, dim), 1);  %#ok<ASGLU> CG#07
        for i = 1:dim
            X_new_kl(:, i) = list_nb_new_k(random_index(:, i), i);
        end
        
        LHS_cand_kl = NaN(n(k_lev), dim);
        LHS_cand_kl(row_highLevels(k_lev, k_lev + 1, n), :) = X_prev;
        LHS_cand_kl(row_currentLevel(k_lev, k_lev, n)  , :) = X_new_kl;
        % add new results (only observed at this level, and not any higher)
        % to previous results (corresponding to point observed at higher levels,
        % and so, at this level too)
        
        % Random moves
        LHS_cand_kl = LHS_cand_kl - rand(n(k_lev), dim);
        % Extend on a larger space for next loop
        LHS_cand_kl = ceil(quotient(k_lev)*LHS_cand_kl);	
        
        if n(k_lev) > 1 && niter > 1
            score = stk_mindist(LHS_cand_kl);
        else % particular case where n(kl) == 1 (no distance)
            score = 0;
        end
        if score > best_score
            % Save the best design in the lhs.
            best_score = score;
            best_LHS   = LHS_cand_kl;
        end
    end % end k_try
    % For the next loop, get the points of the previous levels
    X_prev = best_LHS;
end
% Remove the 0 from the end
n = n(1:nLev);

% Random move + scaling in [0; 1]
best_LHS = (best_LHS - rand(n(1), dim))/n(1);
% Rescale in box
best_LHS = stk_rescale(best_LHS, [], box);

%% Create a nested design
nested_LHS = NaN(sum(n), dim + 1);
% The total number of points in the LHS design
nCumNb = [0; cumsum(n)];

% Add points + the corresponding level
for knL = 1:nLev
    nested_LHS((nCumNb(knL) + 1):(nCumNb(knL + 1)), :) = [
        best_LHS(row_highLevels(1, knL, n), :), repmat(levels(knL), n(knL), 1)];
end

% Add columns names
colnames = cell(1, dim + 1);
if ~isempty(box.colnames)
    colnames(1, 1:dim) = box.colnames;
end
colnames{1, dim + 1} = level_name;

% Return a nested LHS
nested_LHS = stk_dataframe(nested_LHS, colnames);

end

% Check error for incorrect number of input arguments
%!shared x, n, dim, box, niter, levels
%! n = [48; 12; 4; 2];  dim = 2;  box = [0, 0; 4, 4];  niter = 10;
%! levels = [10.1; 15.2; -9.3; 2.4; 17.5];

%!error x = stk_sampling_nestedlhs ();
%!test  x = stk_sampling_nestedlhs (n);
%!test  x = stk_sampling_nestedlhs (n, dim);
%!test  x = stk_sampling_nestedlhs (n, dim, box);
%!test  x = stk_sampling_nestedlhs (n, dim, box, niter);
%!test  x = stk_sampling_nestedlhs (n, dim, box, niter, levels);
%!error x = stk_sampling_nestedlhs (n, dim, box, niter, levels, pi);

% Check type of ouputs => assert is Nested LHS
%!assert ( isequal(size(x), [sum(n), dim + 1]) );
%!assert ( isa(x, 'stk_dataframe') );
%! cn = [0; cumsum(n)];
%! for lev = 1:length(n),
%!   y = x( (cn(lev) + 1):(cn(lev + 1)), 1:dim );
%!   assert (isequal (size (y), [n(lev) dim]));
%!   assert (stk_is_lhs (y, n(lev), dim, box));
%!   if lev > 1
%!       assert ( isequal(z((end - n(lev) + 1):end, :), y) );
%!   end
%!   z = y;
%! end

% Check column names
%!assert (isequal (x.colnames{dim + 1}, 'Level'));
%! levels = stk_dataframe(levels, {'t'});
%! box = stk_hrect(box, {'x1', 'x2', 'x3', 'x4'});
%!test  x = stk_sampling_nestedlhs (n, [], box, [], levels);
%!assert (isequal(x.colnames, {'x1', 'x2', 'x3', 'x4', 't'}) );