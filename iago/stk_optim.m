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
%       'samplingcritname', 'EI',     criterion name ('EI', 'IAGO', ...)
%       'samplingcrit', [],           criterion function handle
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
%       'nsamplepaths', 100           number of sample paths for IAGO
%       'quadtype', []                type of quadrature
%       'quadorder', nan              order of the quadrature
%       'stoprule', false             stop rule
%       'opt_estim', 'auto'           how do we estimate x_opt and f_opt ?

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

function [x_opt, f_opt, retcode, aux] = ...
    stk_optim (f, dim, box, xi, zi, N, varargin)

t0 = tic;  start_time = datestr (now);

algo = stk_optim_init (f, dim, box, varargin);

% Initial design
if isempty (zi) && (~ isempty (xi))
    [xi, zi, algo] = stk_optim_addevals (algo, [], [], xi);
else
    assert ((stk_length (xi)) == (stk_length (zi)));
end

iter_history = struct ('x_opt', {}, 'f_opt', {});

% crit_reg = nan(N, 1);
for i = 1:N
    fprintf ('* iteration .. %d/%d\n', i, N);
    
    % Estimate model parameters
    if algo.estimparams
        fprintf('parameter estimation ..');
        % Note: in the case of heteroscedastic noise, model.lognoisevariance
        % should *already* contain the vector of log-variances.
        [algo.model.param, algo.model.lognoisevariance] = ...
            stk_param_estim_withrep (algo.model, xi, zi);  fprintf('done\n');
    end
    
    % Compute sampling criterion
    [zp, crit_xg] = algo.samplingcrit (algo, xi, zi);
    assert ((stk_length (algo.xg0)) == (stk_length (crit_xg)));  %%%TEMP
    assert ((stk_length (algo.xg0)) == (stk_length (zp)));       %%%TEMP
    
    % Pick a new evaluation point
    min_crit = min (crit_xg);
    idx_min = find (crit_xg == min_crit);  % TODO: introduce numerical tol ?
    if (length (idx_min)) > 1
        idx_min = idx_min (randi (length (idx_min)));
    end
    xi_new = algo.xg0(idx_min, :);
    
    % Figure (optional): evaluations, predictions, criterion, etc.
    if algo.disp,  stk_optim_view_;  end
    
    % COMPUTE CURRENT OPTIMIZER AND OPTIMUM
    switch algo.opt_estim
        case 'usemaxobs'
            [f_opt, idx_opt] = max (zi(:, 1));
            x_opt = xi(idx_opt, :);
        case 'usemaxpred'
            [f_opt, idx_opt] = max (zp.mean);
            x_opt = algo.xg0(idx_opt, :);
    end
    
    % CARRY OUT NEW EVALUATION
    [xi, zi, algo, zi_new] = stk_optim_addevals (algo, xi, zi, xi_new);
    
    % PAUSE?
    if algo.pause > 0
        disp('pause'); pause;
    end
    
    % FIXME: the choice of a stopping rule should not be directly tied to the
    %   choice of a sampling criterion. It makes it impossible to use stopping
    %   rules in conjunction with user-defined criterions. Moreover, early
    %   stopping should be associated with specific return codes. Finally, each
    %   of these stopping rules involve one or two numerical constants that
    %   should be tunable as options.
    
    % % STOP?
    % if algo.stoprule,
    %    switch algo.samplingcritname
    %         case 'EEI',
    %             crit_reg(i) = max(crit_xg);
    %             if i>1 && crit_reg(i) < 1e-7*crit_reg(1) ...
    %                     && crit_reg(i) > 0.9*crit_reg(i-1),
    %                 disp('Criterion is not improving: early stopping');
    %                 break
    %             end
    %         case 'EI',
    %             crit_reg(i) = max(crit_xg) - min(crit_xg);
    %             if i>1 && crit_reg(i) < 1e-8*(f_opt - mean(zi.data)),
    %                 disp('Criterion is not improving: early stopping');
    %                 break
    %             end
    %         case 'IAGO',
    %             crit_reg(i) = min(crit_xg);
    %             if i>1 && crit_reg(i) < 1e-14,
    %                 disp('Criterion is ill-conditioned: early stopping');
    %                 break
    %             end
    %     end
    % end
    
    % HISTORY: Count current number of observations
    if size (zi, 2) == 1, % One-column representation
        nb_obs = stk_length (zi);
    elseif size (zi, 2) == 3,  % Three-columns representation
        nb_obs = sum (zi.nb_obs);
    else
        error ('Unsupported representation of evaluation results.');
    end
    
    % HISTORY: Fill iter_history structure
    iter_history(i).x_opt     = x_opt;
    iter_history(i).f_opt     = f_opt;
    iter_history(i).xi_new    = xi_new;
    iter_history(i).zi_new    = zi_new;
    iter_history(i).nb_obs    = nb_obs;
    iter_history(i).algo      = algo;
    iter_history(i).t_elapsed = toc (t0);
    
end % for i=1:N


%% PREPARE OUTPUT

% Return estimation of the optimizer
x_opt = iter_history(end).x_opt;

if nargout > 1,
    
    % Return estimation of the optimal value
    f_opt = iter_history(end).f_opt;
    
    if nargout > 2,
        
        % Exit code. Unused for now
        retcode = 0;
        
        if nargout > 3
            
            aux = struct (...
                'evaluations', struct ('xi', xi, 'zi', zi), ...
                'iter_history', iter_history, ...
                'start_time', start_time, ...
                'end_time', datestr (now));
            
        end
    end
end


end % function


%--- SUBFUNCTIONS --------------------------------------------------------------
% [we use evalin ('caller', ...) since Octave does not support nested functions]

function stk_optim_view_ ()

[algo, i, xi, zi, xi_new, crit_xg] = evalin ...
    ('caller', 'deal (algo, i, xi, zi, xi_new, crit_xg);');

if mod (i - 1, algo.disp_period) ~= 0
    return;
end

% Figure XX01: Ground truth + prediction mean/var on the same grid, in 1D
if algo.dim == 1
    stk_optim_fig01 (algo, xi, zi, xi_new);
end

% Figure XX02: Sampling criterion
stk_optim_fig02 (algo, crit_xg);

% Figure XX??: density of the maximizer
%   (useful for criterion that do not already display it)
%   TODO

end % function


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
%! res = stk_optim (f, DIM, BOX, xi, [], MAX_ITER, options);  close all;

%!test  % xt, zt -> numeric
%! options = [options {'disp_xvals', double(xt), 'disp_zvals', double(zt)}];
%! options = [options {'searchgrid_xvals', xg}]
%! res = stk_optim (f, DIM, BOX, xi, [], MAX_ITER, options);  close all;

%!test  % xg -> numeric
%! options = [options {'disp_xvals', xt, 'disp_zvals', zt}];
%! options = [options {'searchgrid_xvals', double(xg)}];
%! res = stk_optim (f, DIM, BOX, xi, [], MAX_ITER, options);  close all;

%!test  % xg -> numeric
%! options = [options {'disp_xvals', xt, 'disp_zvals', zt}];
%! options = [options {'searchgrid_xvals', xg}];
%! xi = xi.data;
%! res = stk_optim (f, DIM, BOX, xi, [], MAX_ITER, options);  close all;
