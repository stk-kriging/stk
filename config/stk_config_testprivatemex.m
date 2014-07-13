% STK_CONFIG_TESTPRIVATEMEX checks if the MEX-files located in private dirs are found

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
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

function stk_config_testprivatemex ()

try
    n = 5;  d = 2;
    x = rand (n, d);
    D = stk_dist (x);  % calls a MEX-file internally
    assert (isequal (size (D), [n n]));
catch
    err = lasterror ();
    if (~ isempty (regexp (err.message, 'stk_dist_matrixx', 'once'))) ...
        && (~ isempty (regexp (err.message, 'undefined', 'once')))
        fprintf ('\n\n');
        warning (sprintf (['\n\n' ...
            '!>>>>>> PLEASE RESTART OCTAVE BEFORE USING STK <<<<<<!\n' ...
            '!                                                    !\n' ...
            '! Some STK functions implemented as MEX-files have   !\n' ...
            '! just been compiled, but will not be detected until !\n' ...
            '! Octave is restarted.                               !\n' ...
            '!                                                    !\n' ...
            '! We apologize for this inconvenience, which is      !\n' ...
            '! related to a known Octave bug (bug #40824), that   !\n' ...
            '! will hopefully be fixed in the near future.        !\n' ...
            '! (see https://savannah.gnu.org/bugs/?40824)         !\n' ...
            '!                                                    !\n' ...          
            '!>>>>>> PLEASE RESTART OCTAVE BEFORE USING STK <<<<<<!\n' ...
            '\n']));
    else
        rethrow (err);
    end
end
    
end % function stk_config_testprivatemex

%#ok<*LERR,*CTCH,*SPERR>
