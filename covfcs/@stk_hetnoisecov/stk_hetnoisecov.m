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

function cov = stk_hetnoisecov (arg)

prop = struct ();

if nargin == 0, % default constructor
    
    prop.varfun = @(x)(1.0);
    prop.x = [];
    prop.v = [];
    
else
    
    if isstruct (arg),
        prop.varfun = [];
        prop.x = arg.x;
        prop.v = arg.v;
    elseif isa (arg, 'function_handle')
        prop.varfun = arg;
        prop.x = [];
        prop.v = [];
    else
        stk_error ('Incorrect variance argument.', 'IncorrectArgument');
    end
    
end

cov = struct ('prop', prop, 'aux', []);
cov = class (cov, 'stk_hetnoisecov', stk_cov ());
cov = set (cov, 'name', 'stk_hetnoisecov');

end % function stk_hetnoisecov
