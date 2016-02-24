% STK_LENGTH return the "length" of an array
%
% CALL:  L = stk_length (X)
%
%    returns the "length" of the data array X.
%
% NOTE:
%
%    Currently, the length of a data array (numeric array or stk_dataframe
%    object) is defined as SIZE (X, 1) but this might change in future
%    versions of STK. Note that this is not the same as length (X).

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@centralesupelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function l = stk_length (x)

l = size (x, 1);

end % function


%!assert (isequal (stk_length ([1 2; 3 4; 5 6]), 3));
