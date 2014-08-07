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
    
    case 'cparam' % FIXME: check
        cov.prop.variance = exp (value);
        
    case 'variance',
        cov.prop.variance = value;
        
    case 'varfun'
        errmsg = 'Property varfun cannot be set directly.';
        stk_error (errmsg, 'SettingReadOnlyProperty');
        
    case {'x', 'v'}
        if ~ isempty (value)
            errmsg = sprintf ('Property ''%s'' is immutable.', propname);
            stk_error (errmsg, 'SettingImmutableProperty');
        end
        
    otherwise, % name
        cov.stk_hetnoisecov = set (cov.stk_hetnoisecov, propname, value);
        
end % switch

end % function set
