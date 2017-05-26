% STK_SAMPCRIT_EI [experimental]
%
% EXPERIMENTAL CLASS WARNING:  This class is currently considered experimental.
%    STK users that wish to experiment with it are welcome to do so, but should
%    be aware that API-breaking changes are likely to happen in future releases.
%    We invite them to direct any questions, remarks or comments about this
%    experimental class to the STK mailing list.
%
% CALL: CRIT = stk_sampcrit_ei (MODEL)
%
%    creates an EI criterion object CRIT associated to MODEL.  The input
%    argument MODEL can be empty, in which case CRIT is an uninstantiated
%    criterion object (to be instantiated later by setting the 'model'
%    property of CRIT).
%
% See also: stk_sampcrit_eqi

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

function crit = stk_sampcrit_ei (model)

if nargin > 1
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Public properties
crit.model           = [];   % read/write
crit.current_minimum = inf;  % read only

% Create default object
crit = class (crit, 'stk_sampcrit_ei', stk_function ());

% Instantiate the sampling criterion with a model
if (nargin >= 1) && (~ isempty (model))
    crit = set (crit, 'model', model);
end

end % function


%!error F = stk_sampcrit_ei ([], 1.234);  % too many input arguments

%%
% construct with nargin == 0

%!shared F, M, EI
%! M = stk_model_gpposterior (stk_model, [1 2 3]', [1.234 3 2]');

%!test F = stk_sampcrit_ei ()  % ending ";" omitted on purpose, to test disp

%!assert (isempty (F.model))
%!assert (isempty (get (F, 'model')))
%!assert (F.current_minimum == +inf)
%!assert (get (F, 'current_minimum') == +inf)
%!error F.toto
%!error get (F, 'toto')

%!error F.current_min = 1.234;              % read-only
%!error F = set (F, 'current_min', 1.234);  % read-only
%!error F.toto = 1.234;                     % field does not exist
%!error F = set (F, 'toto', 1.234);         % field does not exist

%!error EI = feval (F, 1.0);

%!test F = stk_sampcrit_ei ();  F.model = M;
%! assert (~ isempty (F.model));
%!test F = stk_sampcrit_ei ();  F = set (F, 'model', M);
%! assert (~ isempty (F.model));
%!test F.model = [];  % remove model
%! assert (isempty (F.model));
%! assert (F.current_minimum == +inf);

%%
% construct with nargin == 1; M is a proper (posterior) model

%!test  F = stk_sampcrit_ei (M)  % ending ";" omitted on purpose, to test disp

%!assert (isequal (F.model, M))
%!assert (F.current_minimum == 1.234);

%!test EI = feval (F, [1.0; 1.1; 1.2]);
%!assert (isequal (size (EI), [3 1]))
%!assert (all (EI >= 0))

%%
% construct with nargin == 1; M is an improper (prior) model

%!shared F
%!test F = stk_sampcrit_ei (stk_model ());
%!assert (F.current_minimum == +inf);
%!error feval (F, 1.0);
