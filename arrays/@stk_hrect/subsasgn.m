% SUBSASGN [overload base function]

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function x = subsasgn (x, idx, value)

if isa (x, 'stk_hrect')
    
    x.stk_dataframe = subsasgn (x.stk_dataframe, idx, value);
    
    data = double (x);
    if any (data(1, :) > data(2, :))
        stk_error ('Lower bounds cannot be larger than upperbounds', ...
            'IllegalAssigment');
    end
    
else % value must be an stk_hrect object
    
    x = subsasgn (x, idx, x.stk_dataframe);
    
end

end % function
