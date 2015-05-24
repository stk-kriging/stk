% STK_CONFIG_CLEARPERSISTENTS clears all persistent variables in STK

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
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

function stk_config_clearpersistents ()

%--- Unlock all mlocked files --------------------------------------------------

filenames = { ...
    'isoctave', ...
    'stk_optim_hasfmincon', ...   
    'stk_options_set', ...
    'stk_parallel_engine_set', ...
    'stk_select_optimizer'};

for i = 1:(length (filenames))    
    name = filenames{i};    
    if mislocked (name),
        munlock (name);
    end
end

%--- Clear all functions that contain persistent variables ---------------------

filenames = { ...
    'isoctave', ...
    'stk_disp_progress', ...
    'stk_gausscov_iso', ...
    'stk_gausscov_aniso', ...
    'stk_materncov_aniso', ...
    'stk_materncov_iso', ...
    'stk_materncov32_aniso', ...
    'stk_materncov32_iso', ...
    'stk_materncov52_aniso', ...
    'stk_materncov52_iso', ...
    'stk_options_set', ...
    'stk_optim_hasfmincon', ...
    'stk_parallel_engine_set', ...
    'stk_select_optimizer'};

for i = 1:(length (filenames))
    clear (filenames{i});   
end

end % function stk_config_clearpersistents
