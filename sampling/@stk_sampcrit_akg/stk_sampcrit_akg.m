% STK_SAMPCRIT_AKG [experimental]
%
% EXPERIMENTAL CLASS WARNING:  This class is currently considered experimental.
%    STK users that wish to experiment with it are welcome to do so, but should
%    be aware that API-breaking changes are likely to happen in future releases.
%    We invite them to direct any questions, remarks or comments about this
%    experimental class to the STK mailing list.
%
% CALL: CRIT = stk_sampcrit_akg (MODEL)
%
%    creates an AKG criterion object CRIT associated to MODEL.  The input
%    argument MODEL can be empty, in which case CRIT is an uninstantiated
%    criterion object (to be instantiated later by setting the 'model'
%    property of CRIT).  The reference grid is taken to be the current set of
%    evaluation points as in [1].
%
% CALL: CRIT = stk_sampcrit_akg (MODEL, XR)
%
%    uses XR as reference grid.
%
% FOR MORE INFORMATION
%
%    Refer to the documentation of stk_sampcrit_akg_eval for more information.
%
% REFERENCES
%
%   [1] W. Scott, P. I. Frazier and W. B. Powell.  The correlated knowledge
%       gradient for simulation optimization of continuous parameters using
%       Gaussian process regression.  SIAM J. Optim, 21(3):996-1026, 2011.
%
% See also: stk_sampcrit_akg_eval

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function crit = stk_sampcrit_akg (model, xr)

if nargin > 2
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Public properties
crit.model          = [];  % read/write
crit.reference_grid = [];  % read/write

% Private (hidden, read-only) properties
crit.xr          = [];
crit.zr_mean     = []; 
crit.zr_std      = [];
crit.zr_lambdamu = [];

% Create default object
crit = class (crit, 'stk_sampcrit_akg', stk_function ());

% Set user-defined value of reference_grid
if (nargin >= 2) && (~ isempty (xr))
    crit = set (crit, 'reference_grid', xr);
end

% Instantiate the sampling criterion with a model
if (nargin >= 1) && (~ isempty (model))
    crit = set (crit, 'model', model);
end

end % function


%%
% construct with nargin == 0

%!shared F, M, AKG
%! M = stk_model_gpposterior (stk_model, [1 2 3]', [1.234 3 2]');

%!test F = stk_sampcrit_akg ()  % ending ";" omitted on purpose, to test disp

%!assert (isempty (F.model))
%!assert (isempty (get (F, 'model')))
%!assert (isempty (F.reference_grid))
%!assert (isempty (get (F, 'reference_grid')))
%!error F.toto
%!error get (F, 'toto')

%!error F.toto = 1.234;                     % field does not exist
%!error F = set (F, 'toto', 1.234);         % field does not exist

%!error AKG = feval (F, 1.0);

%!test F = stk_sampcrit_akg ();  F.model = M;
%! assert (isequal (F.model, M));
%!test F = stk_sampcrit_akg ();  F = set (F, 'model', M);
%! assert (isequal (F.model, M));
%! assert (isequal (size (F.zr_mean), [3 1]))       % n x 1
%! assert (isequal (size (F.zr_std), [3 1]))        % n x 1
%! assert (isequal (size (F.zr_lambdamu), [4 3]))   % (n+1) x n  (constant mean)
%!test F.model = [];  % remove model
%! assert (isempty (F.model));
%! assert (isempty (F.zr_mean))
%! assert (isempty (F.zr_std))
%! assert (isempty (F.zr_lambdamu))

% set reference grid when model is empty
%!test xr = [1 1.5 2 2.5 3]';
%! F.reference_grid = xr  % ending ";" omitted on purpose, to test disp
%! assert (isequal (F.reference_grid, xr))
%! assert (isempty (F.zr_mean))
%! assert (isempty (F.zr_std))
%! assert (isempty (F.zr_lambdamu))
%!test F.reference_grid = [];
%! assert (isempty (F.reference_grid))

% set reference grid when model is not empty
%!test F = stk_sampcrit_akg ();  F.model = M;
%! assert (isequal (F.model, M));
%! xr = [1 1.5 2 2.5 3]';
%! F.reference_grid = xr  % ending ";" omitted on purpose, to test disp
%! assert (isequal (F.reference_grid, xr))
%! assert (isequal (size (F.zr_mean), [5 1]))       % nr x 1
%! assert (isequal (size (F.zr_std), [5 1]))        % nr x 1
%! assert (isequal (size (F.zr_lambdamu), [4 5]))   % (n+1) x nr (constant mean)
%!test F.reference_grid = [];
%! assert (isempty (F.reference_grid))

%%
% construct with nargin == 1; M is a proper (posterior) model

%!test  F = stk_sampcrit_akg (M)  % ending ";" omitted on purpose, to test disp

%!assert (isequal (F.model, M))

%!test AKG = feval (F, [1.0; 1.1; 1.2]);
%!assert (isequal (size (AKG), [3 1]))
%!assert (all (AKG >= 0))

%!test [AKG2, zp] = feval (F, [1.0; 1.1; 1.2]);
%! assert (isequal (AKG2, AKG));
%! assert (isa (zp, 'stk_dataframe') && isequal (size (zp), [3 2]))

%%
% construct with nargin == 1; M is an improper (prior) model

%!shared F, xr
%! xr = [1 1.5 2 2.5 3]';
%!test F = stk_sampcrit_akg (stk_model ());
%!assert (isempty (F.reference_grid))

%!test F.reference_grid = xr;
%!assert (isequal (F.reference_grid, xr))
%!assert (isempty (F.zr_mean))
%!assert (isempty (F.zr_std))
%!assert (isempty (F.zr_lambdamu))

%!error AKG = feval (F, 1.0);


%%
% construct with nargin == 2; M is a proper (posterior) model

%!shared F, M, xr
%! xr = [1 1.5 2 2.5 3]';
%! M = stk_model_gpposterior (stk_model, [1 2 3]', [1.234 3 2]');

%!test F = stk_sampcrit_akg (M, xr);
%!assert (isequal (F.model, M))
%!assert (isequal (F.reference_grid, xr))
%!assert (isequal (size (F.zr_mean), [5 1]))       % nr x 1
%!assert (isequal (size (F.zr_std), [5 1]))        % nr x 1
%!assert (isequal (size (F.zr_lambdamu), [4 5]))   % (n+1) x nr (constant mean)

%!error F = stk_sampcrit_akg (M, xr, 1.234);       % too many input arguments
