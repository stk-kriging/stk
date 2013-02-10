% STK_DATASTRUCT converts its input into an STK data structure, if possible

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
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

function y = stk_datastruct(x)
stk_narginchk(0, 1);

if (nargin == 0) || isempty(x)
    y = struct('a', []);
    return;
end
    
if isstruct(x) && isfield(x, 'a')
    y = x;
    return;
end

try
    y = struct('a', double(x));
catch
    xname = inputname(1);
    if isempty(xname),
        errmsg = 'x must be a matrix or a structure with an ''a'' field.';
        stk_error(errmsg, 'IncorrectArgument');
    else
        stack = dbstack();
        errmsg = sprintf('%s must be a matrix or a structure with an ''a'' field.', xname);
        stk_error(errmsg, 'IncorrectArgument', stack(2:end));
    end
end

end % function stk_datastruct


%%
% Tests

% Incorrect number of input arguments
%!error y = stk_datastruct(23, 47);

% Empty datastruct
%!shared y1, y2
%!test y1 = stk_datastruct();
%!test y2 = stk_datastruct([]);
%!assert (isequal (y1, y2));

% Ones
%!shared y1, y2
%!test y1 = stk_datastruct(ones(3));
%!test y2 = stk_datastruct(true(3));
%!assert (isequal (y1, y2));
