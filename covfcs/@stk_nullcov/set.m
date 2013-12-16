% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
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

function cov = set (cov, propname, value)

switch propname,        
        
    case {'cparam', 'x', 'v'}
        if ~isempty(value)
            errmsg = sprintf ('Property ''%s'' is immutable.', propname);
            stk_error (errmsg, 'SettingImmutableProperty');
        end        
        
    case 'variance'
        if value ~= 0.0,
            errmsg = 'Property ''variance'' is immutable.';
            stk_error (errmsg, 'SettingImmutableProperty');
        end

    case 'varfun'
        errmsg = 'Property ''varfun'' is immutable.';
        stk_error (errmsg, 'SettingReadOnlyProperty');

    otherwise % name
        cov.stk_homnoisecov = set (cov.stk_homnoisecov, propname, value);
        
end % switch

end % function set
