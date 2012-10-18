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

function [lb, ub] = stk_get_defaultbounds(cov, cparam0, z)
stk_narginchk(1, 3);

if nargin > 1 && ~isempty(cparam0)
    cov = set(cov, 'cparam', cparam0); % raise an error
end

if nargin < 3 || isempty(z)
    empirical_variance = 1.0;
else
    if isstruct(z), z = z.a; end
    empirical_variance = var(z);
end

TOLVAR = 5.0;

% bounds for the logvariance parameter
lnv0 = log(cov.prop.variance);
lb = min(log(empirical_variance), lnv0) - TOLVAR;
ub = max(log(empirical_variance), lnv0) + TOLVAR;

end % function stk_get_defaultbounds
