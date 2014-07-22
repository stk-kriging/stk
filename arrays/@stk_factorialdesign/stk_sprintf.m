% STK_PRETTYPRINT ...

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
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

function s = stk_sprintf (x, verbosity, data_col_width)

if (nargin < 2) || (isempty (verbosity)),
    verbosity = stk_options_get ('stk_dataframe', 'disp_format');
end
if ~ ismember (verbosity, {'basic', 'verbose'})
    errmsg = 'verbosity should be ''basic'' or ''verbose''.';
    stk_error (errmsg, 'InvalidArgument');
end

if (nargin < 3) || (isempty (data_col_width)),
    data_col_width = [];
end

% Print the stk_dataframe
s = stk_sprintf (x.stk_dataframe, verbosity, data_col_width);

% Print the levels first, if in verbose mode
if strcmp (verbosity, 'verbose'),

    spstr = stk_options_get ('stk_dataframe', 'disp_spstr');
             
    s1 = sprintf ('.levels = <%s>', stk_sprintf_sizetype (x.levels));    
    s2 = stk_sprintf_levels (x);
    
    s = char (s1, horzcat (repmat (spstr, size (s2, 1), 1), s2), ...
        '.stk_dataframe =', horzcat (repmat (spstr, size (s, 1), 1), s));
    
end

end % function stk_sprintf
