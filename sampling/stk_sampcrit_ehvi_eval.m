% STK_SAMPCRIT_EHVI_EVAL computes the EHVI criterion
%
% CALL: EHVI = stk_sampcrit_ehvi_eval (ZP_MEAN, ZP_STD, ZI, ZR)
%
%    computes the value EHVI of the Expected HyperVolume Improvement (EHVI) for
%    a multi-objective minimization problem, with respect to the observed values
%    ZI and the reference point ZR, assuming Gaussian predictive distributions
%    with means ZP_MEAN and standard deviations ZP_STD.  The input arguments
%    must have the following sizes:
%
%       * ZP_MEAN    M x P,
%       * ZP_STD     M x P,
%       * ZI         N x P,
%       * ZR         1 x P,
%
%    where M is the number of points where the EHVI must be computed, P the
%    number of objective functions to be minimized, and N the current number of
%    Pareto optimal solutions.  The output has size M x 1.
%
% NOTE
%
% 1) The result depends only on the non-dominated rows of ZI.
%
% 2) Multi-objective maximization problems, or mixed minimization/maximization
%    problems, can be handled by changing the sign of the corresponding
%    components of ZP_MEAN and ZI.
%
% REFERENCES
%
%  [1] Emmerich, M. T., Giannakoglou, K. C., & Naujoks, B.  Single- and
%      multiobjective evolutionary optimization assisted by gaussian random
%      field metamodels. IEEE Transactions on Evolutionary Computation,
%      10(4), 421-439, 2006.
%
% See also: stk_sampcrit_emmi_eval, stk_sampcrit_ei_eval

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
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

if nargin > 4
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% EHVI with respect to the reference
EIr = stk_distrib_normal_ei (zr, zp_mean, zp_std, 1);  % m x p
EHVI = prod (EIr, 2);                                  % m x 1

% Compute signed decomposition wrt to the reference zr
% (note: stk_dominatedhv removes non-dominated points and duplicates from zi)
S = stk_dominatedhv (zi, zr, 1);

if ~ isempty (S.sign)
    
    % Shift rectangle number to third dimension
    Rs = shiftdim (S.sign,  -2);
    Ra = shiftdim (S.xmin', -1);
    Rb = shiftdim (S.xmax', -1);
    
    % Number of rectangles
    R = size (Ra, 3);
    
    % Deal with BLOCK_SIZE rectangles at a time to avoid OOM
    BLOCK_SIZE = ceil (1e7 / (numel (EIr)));
    nb_blocks = ceil (R / BLOCK_SIZE);
    r2 = 0;
    for b = 1:nb_blocks
        
        r1 = r2 + 1;
        r2 = min (r1 + BLOCK_SIZE - 1, R);
        
        % Both EIa and EIb will have size m x p x BLOCK_SIZE
        EIa = stk_distrib_normal_ei (Ra(:, :, r1:r2), zp_mean, zp_std, 1);
        EIb = stk_distrib_normal_ei (Rb(:, :, r1:r2), zp_mean, zp_std, 1);
        
        EHVI = EHVI - sum (bsxfun (@times, ...
            Rs(:, :, r1:r2), prod (EIb - EIa, 2)), 3);
        
    end % if
    
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
