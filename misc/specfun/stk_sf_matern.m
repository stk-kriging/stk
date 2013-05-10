% STK_SF_MATERN computes the Matern correlation function.
%
% CALL: K = stk_sf_matern(NU, H)
%
%    computes the value of the Matern correlation function of order NU at
%    distance H. Note that the Matern correlation function is a valid
%    correlation function for all dimensions.
%
% CALL: K = stk_sf_matern(NU, H, DIFF)
%
%    computes the derivative of the Matern correlation function of order NU, at
%    distance H, with respect to the order NU if DIFF is equal to 1, or with
%    respect the distance H if DIFF is equal to 2. (If DIFF is equal to -1,
%    this is the same as K = stk_sf_matern(NU, H).)
%
% See also: stk_sf_matern32, stk_sf_matern52

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

function k = stk_sf_matern(Nu, h, diff)

stk_narginchk(2, 3);

% default: compute the value (not a derivative)
if (nargin<3), diff = -1; end

BIGNUM = 1e50;

% NOTE: direct calls to besselmx() are faster than besselk()...
% ...but they are not Octave-compliant !

[N,M]=size(h);
hp = abs(reshape(h,N*M,1));
t = 2 * sqrt (Nu) * hp;
z = 2^(Nu - 1) * gamma(Nu) * t.^(-Nu);
I = (z < BIGNUM);

if (diff==-1)
    
    k = ones(N*M,1);
    %k(I) = 1 ./ z(I) .* besselmx(double('K'),Nu,t(I),0);
    k(I) = 1 ./ z(I) .* besselk(Nu,t(I));
    
elseif (diff == 1) % numerical derivative wrt Nu
    
    itermax = 2;
    delta = 1e-4;
    dk = zeros(N*M,itermax);
    for l= 1:itermax
        Nu_p = Nu + 2^(l-1)*delta;
        Nu_m = Nu - 2^(l-1)*delta;
        t_p = 2 * sqrt (Nu_p) * hp;
        t_m = 2 * sqrt (Nu_m) * hp;
        k_p = 1 / (2^(Nu_p - 1) * gamma(Nu_p)) .* t_p(I).^Nu_p .* ...
            besselk( Nu_p, t_p(I) );
        % besselmx( double('K'), Nu_p, t_p(I), 0 );
        k_m = 1 / (2^(Nu_m - 1) * gamma(Nu_m)) .* t_m(I).^Nu_m .* ...
            besselk( Nu_m, t_m(I) );
        % besselmx( double('K'), Nu_m, t_m(I), 0 );
        dk(I,l) =  k_p - k_m;
    end
    k = 1/(12 * delta)* (- dk(:,2) + 8*dk(:,1));
    
elseif (diff == 2) % deriv. wrt h
    
    k = zeros(N*M,1);
    dtdh = 2 * sqrt(Nu);
    k(I)  = - dtdh ./ z(I) .* besselk( Nu-1, t(I) );
    % k(I)  = - dtdh ./ z(I) .* besselmx( double('K'), Nu-1, t(I), 0 );
    
end

k = reshape(k,N,M);


%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%!shared nu, h, diff
%! nu = 1.0; h = 1.0; diff = -1;

%!error stk_sf_matern();
%!error stk_sf_matern(nu);
%!test  stk_sf_matern(nu, h);
%!test  stk_sf_matern(nu, h, diff);
%!error stk_sf_matern(nu, h, diff, pi);

%!test %% h = 0.0 => correlation = 1.0
%! for nu = 0.1:0.2:5.0,
%!   x = stk_sf_matern(nu, 0.0);
%!   assert(stk_isequal_tolrel(x, 1.0, 1e-8));
%! end
