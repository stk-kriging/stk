% STK_PARALLEL_START starts the parallelization engine.

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
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

function eng = stk_parallel_start ()

eng = stk_parallel_engine_get ();

if strcmp (class (eng), 'stk_parallel_engine_none')  %#ok<STISA>
    
    % use Mathworks' PCT if available
    if (exist ('OCTAVE_VERSION', 'builtin') ~= 5) ...  % no Octave
            && (exist ('matlabpool', 'file'))
        eng = stk_parallel_engine_parfor ();
        stk_parallel_engine_set (eng);
    end
    
else
    
    warning (['A parallel computing engine ' ...
        'is already started (or so it seems).']);  %#ok<WNTAG>
    
end

end % function
