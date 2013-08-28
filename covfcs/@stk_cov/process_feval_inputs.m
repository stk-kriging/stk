% PROCESS_FEVAL_INPUTS

% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function [x, y, diff, pairwise] = process_feval_inputs(cov, x, y, diff, pairwise)

if nargin > 5,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% arg #2: x is mandatory
if nargin < 2,
    stk_error('Not enough input arguments.', 'NotEnoughInputArgs');
end

% arg #3: y = x if y is missing or empty
if (nargin < 3) || isempty(y),
    y = x;
end

% arg #4: default -> compute the value (not a derivative)
if nargin < 4,
    diff = -1;
end

% default: compute the full "tensor product" matrix
if nargin < 5,
    pairwise = false;
end

% extract data matrices from structures, if appropriate
if isstruct(x), x = x.a; end
if isstruct(y), y = y.a; end

% sanity check
if pairwise && (size(x, 1) ~= size(y, 1))
    errmsg = 'x and y should have the same number of rows.';
    stk_error(errmsg, 'InconsistentDimensions');
end

% sanity check
if size(x, 2) ~= size(y, 2)
    errmsg = 'x and y should have the same number of columns.';
    stk_error(errmsg, 'InconsistentDimensions');
end

end % function process_feval_input_args
