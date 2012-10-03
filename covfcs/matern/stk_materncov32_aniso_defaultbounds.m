% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
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

function [lb, ub] = stk_materncov32_aniso_defaultbounds(param0, z)

stk_narginchk(1, 2);

if nargin < 2,
    empirical_variance = 1.0;
else
    if isstruct(z), z = z.a; end
    empirical_variance = var(z);
end

% constants
TOLVAR = 5.0;
TOLSCALE = 5.0;

% bounds for the variance parameter
lbv = min(log(empirical_variance) - TOLVAR, param0(1));
ubv = max(log(empirical_variance) + TOLVAR, param0(1));

scale = param0(2:end);
lba = scale(:) - TOLSCALE;
uba = scale(:) + TOLSCALE;

lb = [lbv; lba];
ub = [ubv; uba];

end % function stk_materncov32_aniso_defaultbounds
