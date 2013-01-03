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

function param = stk_materncov_iso_setparam(param, idx, value)

switch class(idx),
    
    case 'double' % idx is an index
        param(idx) = value;
        
    case 'char'
        switch idx,
            case 'sigma2'
                param(1) = log(value);
            case 'nu'
                param(2) = log(value);
            case 'rho'
                param(3) = -log(value);
            case 'alpha'
                param(3) = log(value);
            otherwise
                stk_error('Invalid paramer name', 'InvalidArgument');
        end
        
    otherwise
        stk_error('Invalid type of parameter idx.', 'InvalidArgument');
        
end

end % function stk_materncov_iso_getparam
