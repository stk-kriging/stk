% STK_SAMPCRIT_EI_EVAL ...

% Copyright Notice
%
%    Copyright (C) 2016 CentraleSupelec
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

function crit_val = stk_sampcrit_ei_eval (xt, arg2, varargin)

if isa (arg2, 'stk_model_gpposterior')
    
    % Construct a complete stk_sampcrit object (with an underlying model)
    crit = stk_sampcrit_ei (arg2, varargin{:});
    
    % Evaluate
    crit_val = feval (crit, xt);
    
else  % Assume that arg2 is an stk_dataframe with 'mean' and 'var' columns
    
    % Construct an incomplete stk_sampcrit object (without an underlying model)
    crit = stk_sampcrit_ei ([], varargin{:});
    
    % Evaluate
    crit_val = msfeval (crit, arg2.mean, sqrt (arg2.var));
    
end

end % function
