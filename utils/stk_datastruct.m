% STK_DATASTRUCT converts its input into an STK data structure, if possible

% Copyright Notice
%
%    Copyright (C) 2012 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>
%
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

if isstruct(x) && isfield(x, 'a')
    y = x;
    return;
end

if isa(x, 'double')
    y = struct('a', x);
    return;
end

if isempty(x)
    y = struct('a', []);
end

xname = inputname(1);
if isempty(xname), 
    errmsg = 'x must be a matrix or a structure with an ''a'' field.';
    stk_error(errmsg, 'IncorrectArgument');
else
    stack = dbstack();
    errmsg = sprintf('%s must be a matrix or a structure with an ''a'' field.', xname);
    stk_error(errmsg, 'IncorrectArgument', stack(2:end));
end

end % function stk_datastruct
