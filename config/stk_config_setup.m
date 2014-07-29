% STK_CONFIG_SETUP initializes the STK

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function stk_config_setup ()

% Set default options
stk_options_set;

% Select default "parallelization engine"
stk_parallel_engine_set;

% Hide some warnings about numerical accuracy
warning ('off', 'STK:stk_predict:NegativeVariancesSetToZero');
warning ('off', 'STK:stk_cholcov:AddingRegularizationNoise');
warning ('off', 'STK:stk_param_relik:NumericalAccuracyProblem');

end % function stk_config_setup
