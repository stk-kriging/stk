% STK_SMPCRIT_EHVI_MSFEVAL ... [FIXME: missing documentation]
%
% Note: minimization wrt to all objectives is assumed (for now)
%
% Note: *_eval function should be provided for all pointwise sampling
%       (makes them easy to use when means and std are already computed)

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
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

function EHVI = stk_sampcrit_ehvi_eval (zp_mean, zp_std, zi, zr)

if nargin > 4,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% EHVI with respect to the reference
EIr = stk_distrib_normal_ei (zr, zp_mean, zp_std, 1);  % m x p
EHVI = prod (EIr, 2);                                  % m x 1

% Compute signed decomposition wrt to the reference zr
S = stk_dominatedhv (zi, zr, 1);

if ~ isempty (S.sign)
    
    % Shift rectangle number to third dimension
    Rs = shiftdim (S.sign,  -2);
    Ra = shiftdim (S.xmin', -1);
    Rb = shiftdim (S.xmax', -1);    
    
    EIa = stk_distrib_normal_ei (Ra, zp_mean, zp_std, 1);  % m x p x R
    EIb = stk_distrib_normal_ei (Rb, zp_mean, zp_std, 1);  % m x p x R
    
    EHVI = EHVI - sum (bsxfun (@times, Rs, prod (EIb - EIa, 2)), 3);
    
end % if

end % function


%!shared zr, zi
%! zr = [1 1];
%! zi = [0.25 0.75; 0.5 0.5; 0.75 0.25];

%!test  % no improvement (1 computation)
%! zp_mean = [0.6 0.6];  zp_std = [0 0];
%! EHVI = stk_sampcrit_ehvi_eval (zp_mean, zp_std, zi, zr);
%! assert (stk_isequal_tolabs (EHVI, 0, 1e-12));

%!test  % guaranteed improvement (1 computation)
%! zp_mean = [0 0];  zp_std = [0 0];
%! EHVI = stk_sampcrit_ehvi_eval (zp_mean, zp_std, zi, zr);
%! assert (stk_isequal_tolabs (EHVI, 10 * 0.25 ^ 2));

%!test  % no improvement again (2 computations)
%! zp_mean = [0.5 0.5; 0.6 0.6];  zp_std = [0 0; 0 0];
%! EHVI = stk_sampcrit_ehvi_eval (zp_mean, zp_std, zi, zr);
%! assert (stk_isequal_tolabs (EHVI, [0; 0], 1e-12));

%!test  % no observation -> EHVI wrt zr
%! zp_mean = [0.6 0.6];  zp_std = 0.01 * [1 1];  zi = [];
%! EHVI = stk_sampcrit_ehvi_eval (zp_mean, zp_std, zi, zr);
%! assert (stk_isequal_tolabs (EHVI, (1 - 0.6)^2, 1e-12));

%!test  % no observation below zr -> EHVI wrt zr
%! zp_mean = [0.6 0.6];  zp_std = 0.01 * [1 1];  zi = [2 2];
%! EHVI = stk_sampcrit_ehvi_eval (zp_mean, zp_std, zi, zr);
%! assert (stk_isequal_tolabs (EHVI, (1 - 0.6)^2, 1e-12));

% FIXME: add MORE unit tests
