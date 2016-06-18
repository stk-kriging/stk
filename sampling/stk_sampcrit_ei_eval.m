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

function crit_val = stk_sampcrit_ei_eval (xt, arg2, goal)

if isa (arg2, 'stk_model_gpposterior')
    
    zp = stk_predict (arg2, xt);
    
else  % Assume that arg2 is an stk_dataframe with 'mean' and 'var' columns
    
    zp = arg2;
    
end

% Minimize or maximize?
if (nargin < 3) || (strcmp (goal, 'minimize'))
    minimize = true;
    threshold = min (zp.mean);
elseif strcmp (goal, 'maximize')
    minimize = false;
    threshold = max (zp.mean);
else
    stk_error (['Incorrect value for argumen ''goal'': should be either ' ...
        '''minimize'' or ''maximize''.'], 'InvalidArgument');
end

% Evaluate the sampling criterion
crit_val = stk_distrib_normal_ei (threshold, zp.mean, sqrt (zp.var), minimize);

end % function
