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

regex1 = ['^' root];

% Safer than calling isoctave directly (this allows stk_config_rmpath to work
% even if STK has already been partially uninstalled or is not properly installed)
isoctave = (exist ('OCTAVE_VERSION', 'builtin') == 5);

if isoctave,
    regex2 = strrep ([octave_config_info('api_version') '$'], '+', '\+');
end

while ~ isempty (s)
    
    [d, s] = strtok (s, ':');  %#ok<STTOK>
    
    if (~ isempty (regexp (d,  regex1, 'once'))) ...
        && ((~ isoctave) || isempty (regexp (d,  regex2, 'once'))) ...
        && (~ strcmp (d, root))  % See note below
        
        rmpath (d);
        
    end
end

% Note: it is important NOT to remove STK's root folder at this point. Indeed,
% in the case where STK is used as an Octave package, this would result in
% calling PKG_DEL, and therefore stk_config_rmpath again, causing an infinite
% loop.

end % function stk_config_rmpath
