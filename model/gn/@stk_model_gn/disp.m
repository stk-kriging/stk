% DISP [overload base function]
%
% EXPERIMENTAL CLASS WARNING:  The stk_model_gn class is currently considered
%    experimental.  STK users who wish to experiment with it are welcome to do
%    so, but should be aware that API-breaking changes are likely to happen in
%    future releases.  We invite them to direct any questions, remarks or
%    comments about this experimental class to the STK mailing list.

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
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

function disp (gn)

fprintf ('<%s>\n', stk_sprintf_sizetype (gn));

loose_spacing = stk_disp_isloose ();

if loose_spacing
    fprintf ('|\n');
end

fprintf ('|   stk_model_gn is an ''abstract'' class, which is used to create\n');
fprintf ('|   derived classes  representing actual  Gaussian noise models.\n');
fprintf ('|   ==>  Normal STK users should never be reading this ;-)  <==\n');

if loose_spacing
    fprintf ('|\n');
end

end % function
