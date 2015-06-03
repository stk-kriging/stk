% STK_CONFIG_RMPATH removes a copy of STK from the search path

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>

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

function stk_config_rmpath (root)

if nargin == 0,
    root = stk_config_getroot ();
end

s = path ();

regex1 = strcat ('^', escape_regexp (root));

% Safer than calling isoctave directly (this allows stk_config_rmpath to work
% even if STK has already been partially uninstalled or is not properly installed)
isoctave = (exist ('OCTAVE_VERSION', 'builtin') == 5);

if isoctave,
    regex2 = strcat (escape_regexp (octave_config_info ('api_version')), '$');
end

while ~ isempty (s)
    
    [d, s] = strtok (s, pathsep);  %#ok<STTOK>
    
    if (~ isempty (regexp (d,  regex1, 'once'))) ...
        && ((~ isoctave) || isempty (regexp (d,  regex2, 'once'))) ...
        && (~ strcmp (d, root))  % See note below
        
        rmpath (d);
        
    end
end

% Note: it is important NOT to remove STK's root folder at this point. Indeed,
% in the case where STK is used as an Octave package, this would trigger the
% PKG_DEL directive in stk_init.m, and therefore stk_config_rmpath again,
% causing an infinite loop.

end % function stk_config_rmpath


function s = escape_regexp (s)

% For backward compatibility with Octave 3.2.x, we cannot use regexprep here:
%
%    s = regexprep (s, '([\+\.\\])', '\\$1');
%
% Indeed, compare the results with Octave 3.8.x
%
%    >> regexprep ('2.2.0', '(\.)', '\$1')
%    ans = 2$12$10
%
%    >> regexprep ('2.2.0', '(\.)', '\\$1')
%    ans = 2\.2\.0
%
% and those with Octave 3.2.4
%
%    >> regexprep ('2.2.0', '(\.)', '\$1')
%    ans = 2\.2\.0
%
%    >> regexprep ('2.2.0', '(\.)', '\\$1')
%    ans = 2\\.2\\.0
%

s = strrep (s, '\', '\\');
s = strrep (s, '+', '\+');
s = strrep (s, '.', '\.');

end % function escape_regexp
