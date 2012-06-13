% STK_NARGCHK checks whether the number of input arguments is acceptable.

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%

function err_msg = stk_nargchk(n_low, n_high, n_argin)

if nargin ~= 3,
    error('stk_nargchk must be called with exactly 3 input arguments.');
end

% find caller name
s = dbstack();
if length(s) == 1,
    caller_name = 'base workspace';
else
    caller_name = s(2).name;
end

err_msg = [];
if n_argin < n_low,
    err_msg = 'not enough input arguments provided';
elseif n_argin > n_high,
    err_msg = 'too many output arguments requested';
end

if (nargout == 0) && ~isempty(err_msg),
    error(sprintf('Error in %s: %s.', caller_name, err_msg));
end

end % stk_nargchk
