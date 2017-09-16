% STK_SAMPCRIT_EQI [experimental]
%
% EXPERIMENTAL CLASS WARNING:  This class is currently considered experimental.
%    STK users that wish to experiment with it are welcome to do so, but should
%    be aware that API-breaking changes are likely to happen in future releases.
%    We invite them to direct any questions, remarks or comments about this
%    experimental class to the STK mailing list.
%
% CALL: CRIT = stk_sampcrit_eqi (MODEL)
%
%    creates an EQI criterion object CRIT associated to MODEL, where the
%    quantile of interest is the median of the output.  The input argument
%    MODEL can be empty, in which case CRIT is an uninstantiated criterion
%    object (which can be instantiated later by setting the 'model' property
%    of CRIT).
%
% CALL: CRIT = stk_sampcrit_eqi (MODEL, P)
%
%    uses quantile order P instead of the default 0.5.
%
% See also: stk_sampcrit_ei

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

function crit = stk_sampcrit_eqi (model, quantile_order, point_batch_size)

if nargin > 3
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Public properties
crit.model            = [];
crit.quantile_order   = 0.5;
crit.point_batch_size = 1;
crit.current_minimum  = inf;

% Private (hidden, read-only) properties
crit.quantile_value   = 0.0;

crit = class (crit, 'stk_sampcrit_eqi', stk_function ());

% Set user-defined value of quantile_order
if (nargin >= 2) && (~ isempty (quantile_order))
    crit = set (crit, 'quantile_order', quantile_order);
end

% Set user-defined value of point_batch_size
if (nargin >= 3) && (~ isempty (point_batch_size))
    crit = set (crit, 'point_batch_size', point_batch_size);
end

% Instantiate the sampling criterion with a model  (it is important to do this
% one last, to avoid re-computing current_minimum several times)
if (nargin >= 1) && (~ isempty (model))
    crit = set (crit, 'model', model);
end

end % function


%!error F = stk_sampcrit_eqi ([], 0.5, 10, 1.234);  % too many input arguments

%%
% construct with nargin == 0

%!shared F, M, EQI
%! M = stk_model_gpposterior (stk_model, [1 2 3]', [1.234 3 2]');

%!test F = stk_sampcrit_eqi ()  % ending ";" omitted on purpose, to test disp

%!assert (isempty (F.model))
%!assert (isempty (get (F, 'model')))
%!assert (F.quantile_order == 0.5)
%!assert (get (F, 'quantile_order') == 0.5)
%!assert (F.current_minimum == +inf)
%!assert (get (F, 'current_minimum') == +inf)
%!error F.toto
%!error get (F, 'toto')

%!error F.current_min = 1.234;              % read-only
%!error F = set (F, 'current_min', 1.234);  % read-only
%!error F.toto = 1.234;                     % field does not exist
%!error F = set (F, 'toto', 1.234);         % field does not exist
%!test F.quantile_order = 0.9;  assert (F.quantile_order == 0.9)
%!test F = set (F, 'quantile_order', 0.8);  assert (F.quantile_order == 0.8)
%!error F.quantile_order = 1.1;
%!error F.quantile_order = -0.1;
%!error F.quantile_order = [1 2];
%!error F.current_minimum = 3.333;          % read-only
%!error F.quantile_value = 2.222;           % read-only

%!error EQI = feval (F, 1.0);

%!test F = stk_sampcrit_eqi ();  F.model = M;
%! assert (~ isempty (F.model));
%!test F = stk_sampcrit_eqi ();  F = set (F, 'model', M);
%! assert (~ isempty (F.model));
%!test F.model = [];  % remove model
%! assert (isempty (F.model));
%! assert (F.current_minimum == +inf);

%%
% construct with nargin == 1; M is a proper (posterior) model

%!test F = stk_sampcrit_eqi (M)  % ending ";" omitted on purpose, to test disp

%!assert (isequal (F.model, M))
%!assert (stk_isequal_tolrel (F.current_minimum, 1.234, 10 * eps));

%!test EQI = feval (F, [1.0; 1.1; 1.2]);
%!assert (isequal (size (EQI), [3 1]))
%!assert (all (EQI >= 0))

%!test F.quantile_order = 0.9;  assert (F.quantile_order == 0.9)

%%
% same as the one before, but with a noisy model

%!shared F, M, EQI
%! prior_model = stk_model ();
%! prior_model.lognoisevariance = 0.678;
%! M = stk_model_gpposterior (prior_model, [1 2 3]', [1.234 3 2]');

%!test F = stk_sampcrit_eqi (M);

%!assert (isequal (F.model, M))
%!assert (stk_isequal_tolrel (F.current_minimum, 2.077997, 1e-5));

%!test EQI = feval (F, [1.0; 1.1; 1.2]);
%!assert (isequal (size (EQI), [3 1]))
%!assert (all (EQI >= 0))

%!test F.quantile_order = 0.9;  assert (F.quantile_order == 0.9)

%%
% construct with nargin == 1; M is an improper (prior) model

%!shared F
%!test F = stk_sampcrit_eqi (stk_model ());
%!assert (F.current_minimum == +inf);
%!error feval (F, 1.0);

%%
% construct with nargin == 2

%!shared F, M
%! M = stk_model_gpposterior (stk_model (), [1 2 3]', [1.234 3 2]');

%!error F = stk_sampcrit_eqi (M, [], 0);
%!error F = stk_sampcrit_eqi (M, [], 1.5);
%!error F = stk_sampcrit_eqi (M, [], nan);
%!error F = stk_sampcrit_eqi (M, [], [10 20]);
%!test  F = stk_sampcrit_eqi (M, [], 10);

%!assert (isequal (F.quantile_order, 0.5));
%!assert (isequal (F.point_batch_size, 10));

%!error F = stk_sampcrit_eqi (M, 0.8, 0);
%!error F = stk_sampcrit_eqi (M, 0.8, 1.5);
%!error F = stk_sampcrit_eqi (M, 0.8, nan);
%!error F = stk_sampcrit_eqi (M, 0.8, [10 20]);
%!test  F = stk_sampcrit_eqi (M, 0.8, 5);

%!assert (isequal (F.quantile_order, 0.8));
%!assert (isequal (F.point_batch_size, 5));

%%
% test various forms for point_batch_size

%!shared F, M, EQI
%! prior_model = stk_model ();
%! prior_model.lognoisevariance = 0.678;
%! M = stk_model_gpposterior (prior_model, [1 2 3]', [1.234 3 2]');
%! F = stk_sampcrit_eqi (M);

%!test F.point_batch_size = 10;  % numeric
%!assert (isequal (F.point_batch_size, 10))
%!test EQI = feval (F, [1.0; 1.1; 1.2]);

%!test F.point_batch_size = @(x, n) 100 - n;  % function handle
%!assert (isa (F.point_batch_size, 'function_handle'))
%!test EQI = feval (F, [1.0; 1.1; 1.2]);

%!test F.point_batch_size = 'sin';  % char
%!assert (isa (F.point_batch_size, 'function_handle'))
