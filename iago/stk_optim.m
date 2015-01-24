% STK_OPTIM optimization algorithm
%
% CALL: stk_optim(F, DIM, BOX, XI, N, OPTIONS)
%
%   STK_OPTIM maximizes function F using initial design XI and a
%   budget of N evaluations. OPTIONS contains the parameters of the
%   algorithm
%
%    * F    handle on the objective function
%    * DIM  dimension of the search space
%    * BOX  2 x DIM matrix where BOX(1, j) and BOX(2, j) are the lower-
%           and upper-bound of the interval on the j^th coordinate.
%    * XI   stk_dataframe of initial evaluation points
%    * N    evaluation budget
%    * OPTIONS cellarray of parameters of the algorithm
%
%       parameter, default value      comment
%       ---------  -------------      -------
%       'samplingcritname', 'EI',     'EI'/'IAGO'
%       'model', model                optional stk_model
%                                     after each evaluation?
%       'estimnoise', false           estimate noise variance?
%       'noisevariance', 0.0          noise variance
%       'showprogress', true          display progress
%       'pause', 0                    pause at each iteration
%       'disp', false                 show plots
%       'disp_xvals', []              optional x values for display
%       'disp_zvals', []              optional z values for display
%       'show1dsamplepaths', false    show sample paths?
%       'show1dmaximizerdens', 2      show estimated density of the maximize
%       'searchgrid_xvals', []        optional search points
%       'searchgrid_unique', true
%       'searchgrid_adapt', false     adapt search points (not implemented yet)
%       'searchgrid_size', 200        number of search points
%       'nsamplepaths', 800           number of sample paths for IAGO
%       'quadtype', []                type of quadrature
%       'quadorder', nan              order of the quadrature
%       'ComputeCurrentOptimum', true
%       'stoprule', true              stop rule

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec & Ivana Aleksovska
%
%    Authors:  Ivana Aleksovska  <ivanaaleksovska@gmail.com>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%              Julien Bect       <julien.bect@supelec.fr>

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

function [varargout] = stk_optim(f, dim, box, xi, N, varargin)

[algo, xi, zi] = stk_optim_init (f, dim, box, xi, varargin);

xstarn  = stk_dataframe(zeros(N, dim));
Mn      = stk_dataframe(inf(N, 1));

crit_reg = nan(N, 1);
for i = 1:N
    fprintf ('* iteration .. %d/%d\n', i, N);
    
    % ESTIMATE MODEL PARAMETERS
    if algo.estimparams
        fprintf('parameter estimation ..');
        
        if isa (algo.xg0, 'stk_ndf')  % noisy heteroscedatic case
            known_var = algo.noisevariance{1};
            % If known_var is true (known variance) then model.lognoisevariance
            % should *already* contain the vector of log-variances. Otherwise,
            % we call an appropriate estimation procedure.
            if known_var
                % Nothing to do. Just a safety net.
                ni = stk_length (xi);  lnv = algo.model.lognoisevariance;
                assert ((isnumeric (lnv)) && (isvector (lnv)) ...
                    && (length (lnv) == ni));
            else
                var_fun = algo.noisevariance{2};
                algo.model.lognoisevariance = var_fun (algo, xi, zi);
                % Preliminary attempt / other parameters could be useful ?
            end
        end
        
        % All other cases should be dealt with transparently by STK
        [algo.model.param, algo.model.lognoisevariance] = ...
            stk_param_estim (algo.model, xi, zi);
        
        fprintf('done\n');
    end
    
    % Pick a new evaluation point (from algo.xg0)
    [xinew, zp, crit_xg] = algo.samplingcrit (algo, xi, zi);
    
    % COMPUTE CURRENT OPTIMIZER AND OPTIMUM
    switch(algo.type)
        case 'usemaxobs'
            [Mn(i, 1), xstarn_ind] = max(zi.data);
            xstarn(i,:) = xi(xstarn_ind, :);
        case 'usemaxpred'
            [~, xstarn_ind] = max(zp.mean);
            xstarn(i,:) = algo.xg0(xstarn_ind, :);
            Mn(i, 1) = stk_feval(algo.f, xstarn(i,:));
    end
    
    % CARRY OUT NEW EVALUATION
    [xi, zi, algo] = stk_optim_addevals(algo, xi, zi, xinew);
    
    % PAUSE?
    if algo.pause > 0
        disp('pause'); pause;
    end
    
    % STOP?
    if algo.stoprule,
        switch algo.samplingcritname
            case 'EEI',
                crit_reg(i) = max(crit_xg);
                if i>1 && crit_reg(i) < 1e-7*crit_reg(1) ...
                        && crit_reg(i) > 0.9*crit_reg(i-1),
                    disp('Criterion is not improving: early stopping');
                    break
                end
            case 'EI',
                crit_reg(i) = max(crit_xg) - min(crit_xg);
                if i>1 && crit_reg(i) < 1e-8*(Mn(i) - mean(zi.data)),
                    disp('Criterion is not improving: early stopping');
                    break
                end
            case 'IAGO',
                crit_reg(i) = min(crit_xg);
                if i>1 && crit_reg(i) < 1e-14,
                    disp('Criterion is ill-conditioned: early stopping');
                    break
                end
        end
    end
end % for i=1:N

%% PREPARE OUTPUT
if nargout == 1
    res.xi      = xi;
    res.zi      = zi;
    res.xstarn  = xstarn;
    res.Mn      = Mn;
    varargout{1} = res;
elseif nargout > 1
    varargout{1} = xi;
    varargout{2} = zi;
elseif nargout > 2
    varargout{3} = Mn;
    varargout{4} = xstarn;
end

end % function stk_optim


%!shared f0, f, DIM, BOX, xi, MAX_ITER, options, xt, zt, xg, NOISEVARIANCE
%!
%! DIM = 1; BOX = [-1.0; 1.0];
%! 
%! f0 = @(x) ((0.8*x-0.2).^2 + exp(-0.5*(abs(x+0.1)/0.1).^1.95) ...
%!     + exp(-1/2*(2*x-0.6).^2/0.1) - 0.02);
%! 
%! NT = 400;  xt = stk_sampling_regulargrid (NT, DIM, BOX);
%! zt = stk_feval (f0, xt); % Ground truth
%! 
%! xi_ind = [90 230 290 350];  xi = xt(xi_ind, :);
%! 
%! % f = f0;  NOISEVARIANCE = 0.0;  % NOISELESS
%!
%! NOISEVARIANCE = 0.1 ^ 2;
%! f = @(x)(f0(x) + sqrt (NOISEVARIANCE) * randn (size (x)));  % NOISY
%! 
%! MAX_ITER = 2;
%!
%! xg = stk_sampling_regulargrid (5, DIM, BOX);
%!
%! options = {'samplingcritname', 'IAGO',  ...
%!     'noisevariance', NOISEVARIANCE, ...
%!     'disp', true, 'show1dsamplepaths', true, ...
%!     'quadorder', 3, 'nsamplepaths', 5};

%!test
%! options = [options {'disp_xvals', xt, 'disp_zvals', zt}];
%! options = [options {'searchgrid_xvals', xg}];
%! res = stk_optim (f, DIM, BOX, xi, MAX_ITER, options);  close all;

%!test  % xt, zt -> numeric
%! options = [options {'disp_xvals', double(xt), 'disp_zvals', double(zt)}];
%! options = [options {'searchgrid_xvals', xg}]
%! res = stk_optim (f, DIM, BOX, xi, MAX_ITER, options);  close all;

%!test  % xg -> numeric
%! options = [options {'disp_xvals', xt, 'disp_zvals', zt}];
%! options = [options {'searchgrid_xvals', double(xg)}];
%! res = stk_optim (f, DIM, BOX, xi, MAX_ITER, options);  close all;

%!test  % xg -> numeric
%! options = [options {'disp_xvals', xt, 'disp_zvals', zt}];
%! options = [options {'searchgrid_xvals', xg}];
%! xi = xi.data;
%! res = stk_optim (f, DIM, BOX, xi, MAX_ITER, options);  close all;
