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

function K = feval (cov, varargin)

[x, y, diff, pairwise] = process_feval_inputs (cov, varargin{:});

% only cov(x, x) is supported for this class of covariance objects !
if ~ isempty(y) && ~ isequal (x, y)
    stk_error ('cov(x, y) is not implemented yet.', 'NotImplementedYet');
end

nx = size (x, 1);

switch diff,
    
    case {-1, 1}, % value or derivative wrt logvariance
        
        if pairwise,
            K = cov.prop.variance * ones (nx, 1);
        else
            K = cov.prop.variance * speye (nx, nx);
        end
        
    otherwise
        stk_error ('Incorrect diff argument.', 'IncorrectArgument');

end % switch diff

end % function feval