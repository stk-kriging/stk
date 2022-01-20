% STK_DISTRIB_BIVNORM_CDF [STK internal]

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function [p, q] = stk_distrib_bivnorm_cdf (z, mu1, mu2, sigma1, sigma2, rho)

%--- Split z into [z1, z2] -----------------------------------------------------

s = size (z);
if s(end) ~= 2
    stk_error (['Incorrect size: expecting an array with length 2 ' ...
        'on its last dimension.'], 'IncorrectSize');
end

S = struct ('type', '()', 'subs', {repmat({':'}, size(s))});

S.subs{end} = 1;  z1 = subsref (z, S);
S.subs{end} = 2;  z2 = subsref (z, S);

%--- Substract the means -------------------------------------------------------

if ~ isequal (mu1, 0)
    z1 = bsxfun (@minus, z1, mu1);
end

if ~ isequal (mu2, 0)
    z2 = bsxfun (@minus, z2, mu2);
end

%--- Bring everything to a common size -----------------------------------------

if ~ isequal (size (z1), size (z2), size (sigma1), size (sigma2), size (rho))
    [z1, z2, sigma1, sigma2, rho] = stk_commonsize ...
        (z1, z2, sigma1, sigma2, rho);
end

p = nan (size (z1));
q = nan (size (z1));

%--- Deal with special cases ---------------------------------------------------

b1 = (sigma1 == 0.0);
if any (b1)  % First component is zero a.s.
    [p(b1) q(b1)] = handle_singular_case (b1, z1, z2, sigma2);
end

b2 = (~ b1) & (sigma2 == 0.0);
if any (b2)  % Second component is zero a.s.
    [p(b2) q(b2)] = handle_singular_case (b2, z2, z1, sigma1);
end

%--- Deal with the general case ------------------------------------------------

b0 = ~ (b1 | b2);
if any (b0)
    z1 = z1(b0) ./ sigma1(b0);
    z2 = z2(b0) ./ sigma2(b0);
    [p(b0), q(b0)] = stk_distrib_bivnorm0_cdf ([z1 z2], rho(b0));
end

end % function


function [p q] = handle_singular_case (b1, z1, z2, sigma2)

z1_ = z1(b1);
z2_ = z2(b1);
sigma2_ = sigma2(b1);

% Values for the case z1 < 0
s = size (z1_);
p = zeros (s);
q = ones (s);

b1p = (z1_ >= 0);
if any (b1p)
    [p(b1p) q(b1p)] = stk_distrib_normal_cdf (z2_(b1p), 0, sigma2_(b1p));
end

end % function

%!test
%!
%! z1 = [0 1; -1  2];
%! z2 = [0 1;  1 -2];
%!
%! z  = cat (3, z1, z2);   % 2 x 2 x 2
%!
%! mu1 = 0;                % 1 x 1 x 1
%! mu2 = [0 1];            % 1 x 2 x 1
%!
%! sigma1 = [1  3];        % 1 x 2 x 1
%! sigma2 = [1; 2];        % 2 x 1 x 1
%!
%! rho = [0; 0.5];         % 2 x 1 x 1
%!
%! %% BROADCASTING => the result will be a 2 x 2 matrix
%!
%! p = stk_distrib_bivnorm_cdf (z, mu1, mu2, sigma1, sigma2, rho);
%!
%! p11 = 0.25;               % mvncdf ([ 0  0], [0 0], [1 0; 0 1]);
%! p12 = 0.315279329909118;  % mvncdf ([ 1  1], [0 1], [9 0; 0 1]);
%! p21 = 0.146208349559646;  % mvncdf ([-1  1], [0 0], [1 1; 1 4]);
%! p22 = 0.064656239880040;  % mvncdf ([ 2 -2], [0 1], [9 3; 3 4]);
%!
%! assert (stk_isequal_tolabs (p, [p11 p12; p21 p22], 1e-14))


%%% [p, q] = stk_distrib_bivnorm_cdf ([inf z], 0, 0, 1, 1, 0) with various z's

%!test
%! [p, q] = stk_distrib_bivnorm_cdf ([inf -inf], 0, 0, 1, 1, 0);
%! assert ((p == 0.0) && (q == 1.0))

%!test
%! [p, q] = stk_distrib_bivnorm_cdf ([inf -10], 0, 0, 1, 1, 0);
%! assert (stk_isequal_tolrel (p, 7.619853024160489e-24, 1e-12))
%! assert (q == 1.0)

%!test
%! [p, q] = stk_distrib_bivnorm_cdf ([inf 0], 0, 0, 1, 1, 0);
%! assert (stk_isequal_tolrel (p, 0.5, 1e-12))
%! assert (stk_isequal_tolrel (q, 0.5, 1e-12))

%!test
%! [p, q] = stk_distrib_bivnorm_cdf ([inf 10], 0, 0, 1, 1, 0);
%! assert (p == 1.0);
%! assert (stk_isequal_tolrel (q, 7.619853024160489e-24, 1e-12))

%!test
%! [p, q] = stk_distrib_bivnorm_cdf ([inf inf], 0, 0, 1, 1, 0);
%! assert ((p == 1.0) && (q == 0.0))


%%% [p, q] = stk_distrib_bivnorm_cdf ([z inf], 0, 0, 1, 1, 0) with various z's

%!test
%! [p, q] = stk_distrib_bivnorm_cdf ([-inf inf], 0, 0, 1, 1, 0);
%! assert ((p == 0.0) && (q == 1.0))

%!test
%! [p, q] = stk_distrib_bivnorm_cdf ([-10 inf], 0, 0, 1, 1, 0);
%! assert (stk_isequal_tolrel (p, 7.619853024160489e-24, 1e-12))
%! assert (q == 1.0)

%!test
%! [p, q] = stk_distrib_bivnorm_cdf ([0 inf], 0, 0, 1, 1, 0);
%! assert (stk_isequal_tolrel (p, 0.5, 1e-12))
%! assert (stk_isequal_tolrel (q, 0.5, 1e-12))

%!test
%! [p, q] = stk_distrib_bivnorm_cdf ([10 inf], 0, 0, 1, 1, 0);
%! assert (p == 1.0);
%! assert (stk_isequal_tolrel (q, 7.619853024160489e-24, 1e-12))

%!test
%! [p, q] = stk_distrib_bivnorm_cdf ([inf inf], 0, 0, 1, 1, 0);
%! assert ((p == 1.0) && (q == 0.0))

%!test  % A mixture of singular and non-singular cases
%! p = stk_distrib_bivnorm_cdf ([0 0], 0, 0, [1; 0], 1, 0);
%! assert (isequal (p, [0.25; 0.5]));
