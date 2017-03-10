% STK_SPRINTF ...

% Copyright Notice
%
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@centralesupelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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
df = x.stk_dataframe;
s = stk_sprintf (df, 'basic', data_col_width);

% Print the levels first, if in verbose mode
if strcmp (verbosity, 'verbose'),
    
    spstr = stk_options_get ('stk_dataframe', 'disp_spstr');
    L = length (x.levels);
    
    s = char (...
        ... %--------------------------------------------------------------
        '.colnames =', ...  % alias for .stk_dataframe.colnames
        horzcat (spstr, stk_sprintf_colnames (df)), ...
        ... %--------------------------------------------------------------
        '.rownames =', ...  % alias for .stk_dataframe.rownames
        horzcat (spstr, stk_sprintf_rownames (df)), ...
        ... %--------------------------------------------------------------
        sprintf ('.levels = <%s>', stk_sprintf_sizetype (x.levels)), ...
        horzcat (repmat (spstr, L, 1), stk_sprintf_levels (x)), ...
        ... %--------------------------------------------------------------
        '.data =', ...      % alias for .stk_dataframe.data
        horzcat (repmat (spstr, size (s, 1), 1), s) ...
        ); %---------------------------------------------------------------
    
end

end % function
