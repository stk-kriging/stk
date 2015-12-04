% STK_PARALLEL_ENGINE_SET chooses a parallelization engine.

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
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

function pareng = stk_parallel_engine_set(new_pareng)

persistent current_pareng

% initialization
if isempty(current_pareng)

    % no parallel engine, to begin with
    current_pareng = stk_parallel_engine_none();
    
    % lock the mfile in memory to prevent current_pareng from being cleared
    mlock();
    
end

if nargin > 0,
    current_pareng = new_pareng;
end

% Return the current parallel engine
pareng = current_pareng;

end % function
