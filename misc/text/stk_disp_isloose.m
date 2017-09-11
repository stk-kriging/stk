% STK_DISP_ISLOOSE [STK internal]
%
% CALL: ISLOOSE = stk_disp_isloose ()
%
%    returns true if a 'loose' display mode is used, and false otherwise.
%
% NOTE
%
%    This function solves a Matlab/Octave compatibility issue.  See:
%
%     * https://savannah.gnu.org/bugs/?51035
%     * https://savannah.gnu.org/bugs/?49951
%     * https://savannah.gnu.org/bugs/?46034
%     * https://sourceforge.net/p/kriging/tickets/73

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function b = stk_disp_isloose ()

[fmt, spc] = stk_disp_getformat (); %#ok<ASGLU> CG#07

b = strcmp (spc, 'loose');

end % function
