% STK_VARIANCE_EVAL [experimental]
%
% CALL: V = stk_variance_eval (NOISEMODEL, X, DIFF)
%
% EXPERIMENTAL FUNCTION WARNING
%
%   This function is currently considered experimental, since the whole
%   'noise model classes' thing is.
%
%   Classes derived from stk_model_gn must implement this to define the
%   value of the variance at any given point x.
%
%   In the future, it might be a good idea to make such a function part of
%   the "standard API" of all models in STK, together with similar
%   functions such as:
%
%    * M = stk_mean_eval (MODEL, X, DIFF)
%    * V = stk_variance_eval (NOISEMODEL, X, DIFF)
%    * Q = stk_quantile_eval (NOISEMODEL, X, DIFF)
%    * ...
%
%    STK users that wish to experiment with this function, and more
%    generally with noise model objects, are welcome to do so, but should
%    be aware that the API is very likely to change in the future.
%    Please send questions, comments and suggestions about this part of the
%    toolbox to the STK mailing list.

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
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

function v = stk_variance_eval (gn, x, diff)

% Defaut value for 'diff' (arg #3): -1
if nargin < 3,  diff = -1;  end

switch diff
    case {-1, 1}
        % -1 means "no derivative"
        % +1 means "derivative wrt log_dispersion"
        v = exp (gn.log_dispersion) * feval (gn.variance_function, double (x));
    otherwise
        stk_error ('diff should be either -1 or +1', 'IncorrectArgument');
end

end % function
