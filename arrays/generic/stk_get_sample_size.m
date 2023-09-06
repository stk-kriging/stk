% STK_GET_SAMPLE_SIZE returns the size of a sample
%
% CALL:  N = stk_get_sample_size (X)
%
%    returns the size N of the sample represented by the array X, in other
%    words, the number of rows.
%
% CALL:  N = stk_get_sample_size (MODEL)
%
%    returns the size N of the underlying data if MODEL is a posterior model,
%    and N = 0 if MODEL is a prior model.

% Copyright Notice
%
%    Copyright (C) 2020 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function n = stk_get_sample_size (obj)

if isstruct (obj)

    % If we end up here, obj is expected to be a prior model struct:
    stk_assert_model_struct (obj);

    % Prior model: no data
    n = 0;
    
else  % assume that obj is some kind of array (e.g., double precision)

    n = size (obj, 1);
    
end

end % function


%!assert (stk_get_sample_size ([1 2; 3 4; 5 6]) == 3);

%!assert (stk_get_sample_size (stk_model ()) == 0);

