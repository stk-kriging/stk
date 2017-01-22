% STK_PARALLEL_ENGINE_PARFOR [overload STK function]

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
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

function pareng = stk_parallel_engine_parfor()

if exist ('parpool')
    
    try
        parpool ();
    catch
        e = lasterror ();
        if strfind (e.identifier, 'ConnectionOpen')
            warning ('A worker pool is already open.');
        else
            rethrow (e);
        end
    end
    
else  % try the old syntax
    
    if matlabpool ('size') > 0
        warning ('A worker pool is already open.');
    else
        matlabpool open;
    end
    
end

pareng = class (struct(), 'stk_parallel_engine_parfor');

end % function

%#ok<*DPOOL>


%!test
%! if exist ('matlabpool') || exist ('parpool')
%!     stk_test_class ('stk_parallel_engine_parfor')
%! end
