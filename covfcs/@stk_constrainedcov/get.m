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

function t = get (cov, propname)

switch propname
    
    case 'cparam'
        t = get (cov.prop.basecov, 'cparam');
        t = t(cov.aux.idxfree);
        
    case {'basecov', 'clist'}
        t = cov.prop.(propname);
        
    case 'name'
        t = get (cov.stk_cov, 'name');
        
    otherwise % perhaps a property of the base covariance ?
        try
            t = get (cov.prop.basecov, propname);
        catch
            errmsg = sprintf ('Property %s does not exist.', propname);
            stk_error (errmsg, 'IncorrectArgument');
        end
        
end % switch

end % function get
