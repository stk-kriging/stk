% STK_REMLQRG computes restricted likelihood 
%
% CALL: [rl,drl_param] = stk_remlqrg(param, xi, yi, model, options)
%
% STK_REMLQRG computes the restricted likelihood given data and its
% gradient with respect to the parameters of the covariance
%
% FIXME: documentation incomplete


%                   Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%    Version:   1.0.2
%    Authors:   Julien Bect        <julien.bect@supelec.fr>
%               Emmanuel Vazquez   <emmanuel.vazquez@supelec.fr>
%    URL:       http://sourceforge.net/projects/kriging/
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%
function [rl,drl_param,drl_lnv] = stk_remlqrg(xi, yi, model)

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

[K,P] = stk_make_matcov( xi, model );
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
        V = feval(model.covariance_type, xi, xi, model.param, paramdiff);
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