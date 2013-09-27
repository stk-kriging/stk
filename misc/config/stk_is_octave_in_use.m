% STK_IS_OCTAVE_IN_USE returns true if the STK runs in Octave
%
% CALL: octave_in_use = isoctave

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
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

function octave_in_use = stk_is_octave_in_use ()

warning ('STK:stk_is_octave_in_use:obsolete', ...
    'This function is obsolete, use isoctave instead.');

octave_in_use = isoctave;

end % function stk_is_octave_in_use
