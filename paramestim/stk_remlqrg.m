% STK_REMLQRG computes the restricted likelihood of a model given data.
%
% CALL: [ARL, dARL_dtheta, dARL_dLNV] = stk_remlqrg(MODEL, XI, YI)
%
%   computes the opposite of the restricted likelihood (denoted by ARL for
%   Anti-Restricted Likelihood) of MODEL given the data (XI, YI). The function
%   also returns the gradient dARL_dtheta of ARL with respect to the parameters
%   of the covariance function and the derivative dARL_dLNV of ARL with respect
%   to the logarithm of the noise variance.
%
% EXAMPLE: see paramestim/stk_param_estim.m

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

function [rl, drl_param, drl_lnv] = stk_remlqrg(model, xi, yi)
stk_narginchk(3, 3);

PARAMPRIOR = isfield( model, 'prior' );
NOISYOBS   = isfield( model, 'lognoisevariance' );
NOISEPRIOR = isfield( model, 'noiseprior' );

if ~NOISYOBS,
    if NOISEPRIOR,
        error([...
            'Having a prior on the noise variance when there is' ...
            'no observation noise doesn''t make sense...']);
    else
        % log(eps) is harmless
        model.lognoisevariance = log(eps);
    end
end

n = size(xi.a,1);

%% compute rl

[K,P] = stk_make_matcov( model, xi );
q = size(P,2);

[Q,R_ignored] = qr(P); %#ok<NASGU> %the second argument *must* be here
W = Q(:,(q+1):n);
Wyi = W'*yi.a;

G = W'*(K*W);

Ginv = inv(G);
WKWinv_Wyi = Ginv*Wyi; %#ok<MINV>

[C,p]=chol(G); %#ok<NASGU>
ldetWKW= 2*sum(log(diag(C))); % log(det(G));

attache= Wyi'*WKWinv_Wyi;

if PARAMPRIOR
    prior = (model.param - model.prior.mean)'*model.prior.invcov*(model.param - model.prior.mean);
else
    prior = 0;
end

if NOISEPRIOR
    noiseprior = (model.lognoisevariance - model.noiseprior.mean)^2/model.noiseprior.var;
else
    noiseprior = 0;
end

rl = 1/2*((n-q)*log(2*pi) + ldetWKW + attache + prior + noiseprior);

%% compute gradient

if nargout >= 2
    
    nbparam = length(model.param);
    drl_param = zeros( nbparam, 1 );
    
    for paramdiff = 1:nbparam,
        V = feval(model.covariance_type, model.param, xi, xi, paramdiff);
        WVW = W'*V*W;
        drl_param(paramdiff) = 1/2*(sum(sum(Ginv.*WVW)) - WKWinv_Wyi'*WVW*WKWinv_Wyi);
    end
    
    if PARAMPRIOR
        drl_param = drl_param + model.prior.invcov*(model.param - model.prior.mean);
    end
    
    if nargout >= 3,
        if NOISYOBS,
            diff = 1;
            V = stk_noisecov(n, model.lognoisevariance, diff);
            WVW = W'*V*W;
            drl_lnv = 1/2*(sum(sum(Ginv.*WVW)) - WKWinv_Wyi'*WVW*WKWinv_Wyi);
            if NOISEPRIOR
                drl_lnv = drl_lnv + (model.lognoisevariance - model.noiseprior.mean)/model.noiseprior.var;
            end
        else
            % returns NaN for the derivative with respect to the noise
            % variance in the case of a model without observation noise
            drl_lnv = NaN;
        end
    end
    
end

end


%%%%%%%%%%%%%
%%% tests %%%
%%%%%%%%%%%%%

%!shared f, xi, zi, NI, model
%!
%! f = @(x)( -(0.8*x(1)+sin(5*x(2)+1)+0.1*sin(10*x(3))) );
%! DIM = 3; NI = 20; box = repmat([-1.0; 1.0], 1, DIM);
%! xi = stk_sampling_maximinlhs(NI, DIM, box, 1);
%! zi = stk_feval(f, xi);
%!
%! SIGMA2 = 1.0;  % variance parameter
%! NU     = 4.0;  % regularity parameter
%! RHO1   = 0.4;  % scale (range) parameter
%!
%! model = stk_model('stk_materncov_aniso');
%! model.param = log([SIGMA2; NU; 1/RHO1 * ones(DIM, 1)]);

%!error [J, dJ1, dJ2] = stk_remlqrg();
%!error [J, dJ1, dJ2] = stk_remlqrg(model);
%!error [J, dJ1, dJ2] = stk_remlqrg(model, xi);
%!test  [J, dJ1, dJ2] = stk_remlqrg(model, xi, zi);
%!error [J, dJ1, dJ2] = stk_remlqrg(model, xi, zi, pi);
