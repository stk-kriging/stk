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
%       'estimparams', true           estimate parameters of model
%                                     after each evaluation?
%       'simulatenoise', false
%       'estimnoise', false           estimate noise variance?
%       'noisevariance', 0.0          noise variance
%       'showprogress', true          display progress
%       'pause', 0                    pause at each iteration
%       'disp', false                 show plots
%       'gnuplot', false
%       'disp_xvals', []              optional x values for display
%       'disp_zvals', []              optional z values for display
%       'show1dsamplepaths', false    show sample paths?
%       'show1dmaximizerdens', 2      show estimated density of the maximize
%       'searchgrid_xvals', []        optional search points
%       'searchgrid_unique', true
%       'searchgrid_adapt', false     adapt search points
%       'searchgrid_size', 200        number of search points
%       'nsamplepaths', 800           number of sample paths for IAGO
%       'quadtype', []                type of quadrature
%       'quadorder', nan              order of the quadrature
%       'ComputeCurrentOptimum', true
%       'stoprule', true              stop rule

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Ivana Aleksovska  <ivanaaleksovska@gmail.com>
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

function [varargout] = stk_optim(f, dim, box, xi, N, varargin)

init = @stk_optim_init;
[algo_obj, xi, zi] = init (f, dim, box, xi, varargin);
crit = algo_obj.samplingcrit;

if algo_obj.ComputeCurrentOptimum
    xstarn  = stk_dataframe(zeros(N, dim));
    Mn      = stk_dataframe(inf(N, 1));
end

crit_reg = nan(N, 1);
for i = 1:N
    progress_disp('* iteration', i, N);

    %% ESTIMATE MODEL PARAMETERS
    if algo_obj.estimparams
        fprintf('parameter estimation ..');
        if algo_obj.estimnoise
            [algo_obj.model.param, algo_obj.model.lognoisevariance] = stk_param_estim (...
                algo_obj.model, xi, zi, algo_obj.model.param, algo_obj.model.lognoisevariance);
            xi = stk_setnoisevariance(xi, exp(algo_obj.model.lognoisevariance));
        else
            algo_obj.model.param = stk_param_estim (algo_obj.model, xi, zi, algo_obj.model.param);
        end
        fprintf('done\n');
    end
    
    %% SEARCH GRID
    [xg, xi_ind, algo_obj] = stk_searchgrid(algo_obj, xi);
    ng = stk_length(xg);
    
    % CHOOSE NEW EVALUATION POINT
    [xinew, xg, zp, algo_obj, crit_xg] = crit (algo_obj, xg, xi_ind, zi);
    
    % COMPUTE CURRENT OPTIMIZER
    if algo_obj.ComputeCurrentOptimum
        switch(algo_obj.type)
            case 'usemaxobs'
                [Mn(i, 1), xstarn_ind] = max(zi.data);
                xstarn(i,:) = xi(xstarn_ind, :);
            case 'usemaxpred'
                [~, xstarn_ind] = max(zp.mean);
                xstarn(i,:) = xg(xstarn_ind, :);
                Mn(i, 1) = stk_feval(algo_obj.f, xstarn(i,:));
        end
    end
    
    % CARRY OUT NEW EVALUATION
    switch algo_obj.noise
        case 'noisefree'
            zinew = stk_feval(f, xinew);
        case 'known'
            zinew = stk_feval_noise(f, xinew);
            xinew = stk_ndf(xinew, zinew.noisevariance);
        case 'simulatenoise'
            xinew = stk_ndf(xinew, algo_obj.noisevariance);
            zinew = stk_feval (f, xinew);
            noise = sqrt (algo_obj.noisevariance) * randn (1);
            zinew = zinew + noise;
        case 'unknown'
            xinew = stk_ndf(xinew, algo_obj.noisevariance); % noisevariance will be estimated
            zinew = stk_feval(f, xinew);
    end
    
    xi = [xi; xinew]; %#ok<AGROW>
    zi = [zi; zinew]; %#ok<AGROW>

    if ~strcmp(algo_obj.noise, 'noisefree')
        algo_obj.model.lognoisevariance = log(xi.noisevariance);
    end

    
    % PAUSE?
    if algo_obj.pause > 0
        disp('pause'); pause;
    end
    
    % STOP?
    if algo_obj.stoprule && algo_obj.ComputeCurrentOptimum,
        switch algo_obj.samplingcritname
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
    if algo_obj.ComputeCurrentOptimum
        res.xstarn  = xstarn;
        res.Mn      = Mn;
    end
    varargout{1} = res;
elseif nargout > 1
    varargout{1} = xi;
    varargout{2} = zi;
elseif nargout > 2 && algo_obj.ComputeCurrentOptimum
    varargout{3} = Mn;
    varargout{4} = xstarn;
end

end %%END stk_optim

function progress_disp(msg, n, N)
msg = sprintf('%s .. %d/%d\n', msg, n, N);
fprintf(msg);
end
