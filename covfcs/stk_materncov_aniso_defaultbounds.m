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

function [lb, ub] = stk_materncov_aniso_defaultbounds(param0, z)

if nargin > 2,
   stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

if nargin < 2,
    log_empirical_variance = 0.0;
else
    log_empirical_variance = log (var (double (z)));
end

% constants
opts = stk_options_get ('stk_param_getdefaultbounds');
TOLVAR = opts.tolvar;
TOLSCALE = opts.tolscale;

% bounds for the variance parameter
if log_empirical_variance == - Inf
    lbv = param0(1) - TOLVAR;
    ubv = param0(1) + TOLVAR;
else
    lbv = min (log_empirical_variance, param0(1)) - TOLVAR;
    ubv = max (log_empirical_variance, param0(1)) + TOLVAR;
end

dim = length(param0) - 2;

lbnu = min(log(0.5), param0(2));
ubnu = max(log(10 * dim), param0(2));

scale = param0(3:end);
lba = scale(:) - TOLSCALE;
uba = scale(:) + TOLSCALE;

lb = [lbv; lbnu; lba];
ub = [ubv; ubnu; uba];

end % function stk_materncov_aniso_defaultbounds
