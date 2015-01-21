% STK_OPTIM_INIT initializes the optimization algorithms
%
% CALL: stk_optim_init()
%
% STK_OPTIM_INIT sets parameters of the optimization algorithm

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

function [algo_obj, xi, zi] = stk_optim_init(f, dim, box, xi, varargin)

%% FUNCTION DEFINTION
algo_obj.f  = f;
algo_obj.dim = dim;
algo_obj.box = box;

%% DEFAULT MODEL SPECIFICATION
model = stk_model ('stk_materncov_aniso');
SIGMA2 = nan;  % variance parameter, will be set later
NU     = nan;  % regularity parameter, will be set later
RHO    = nan(dim, 1);  % scale (range) parameter, will be set later
param0 = log ([SIGMA2; NU; 1./RHO]);
model.param = param0;
model.lognoisevariance = nan; % will be set later

%% PROCESS OPTIONS
options = {
    'samplingcritname', 'EI'
    'model', model
    'estimparams', true
    'noise', 'noisefree'
    'estimnoise', false
    'noisevariance', 0.0
    'showprogress', true
    'pause', 0
    'disp', false
    'gnuplot', false
    'disp_xvals', []
    'disp_zvals', []
    'show1dsamplepaths', false
    'show1dmaximizerdens', 2
    'searchgrid_xvals', []
    'searchgrid_unique', true
    'searchgrid_adapt', false
    'searchgrid_size', 200
    'searchgrid_noise', []
    'nsamplepaths', 800
    'quadtype', []
    'quadorder', nan
    'stoprule', true
    };

if iscell(varargin{1}{1}),
    varargin=varargin{1}{1};
else
    varargin=varargin{1};
end
n = numel(varargin);
useropt = struct();
for i = 1 : 2 : n
    name = varargin{i};
    value = varargin{i+1};
    useropt.(name) = value;
end

% set MODEL_USER if model is provided by user
MODEL_USER = isfield(useropt, 'model');

% set NOISEVARIANCE_USER if noisevariance is provided by user
NOISEVARIANCE_USER = isfield(useropt, 'noisevariance');

% default values
for i = 1:size(options, 1)
    if isfield(useropt, options{i, 1})
        algo_obj.(options{i, 1}) = useropt.(options{i, 1});
		useropt = rmfield(useropt, options{i, 1});
    else
        algo_obj.(options{i, 1}) = options{i, 2};
    end
end
% warn for unknown options passed by the user
unknown_fields = fieldnames(useropt);
for i=1:numel(unknown_fields)
	warning('stk_optim_init: Unknown field %s\n', unknown_fields{i});
end

%% NOISE OPTIONS: SANITY CHECK
switch algo_obj.noise
    case 'noisefree'
        assert(algo_obj.estimnoise == false, 'STK:optim_init',...
            'Error: cannot estimate noise variance in the noisefree case');
        assert(algo_obj.noisevariance == 0.0,  'STK:optim_init',...
            'Error: noise variance must be zero in the noisefree case');
    case 'known'
        % NB: only this case makes it possible to deal with heteroscedastic noise
        assert(algo_obj.estimnoise == false, 'STK:optim_init',...
            'Error: cannot estimate noise variance if noise variance is known');
        assert(isa(f, 'cell'), 'STK:optim_init',...
            'Error: f must be a cellarray of function handles in noise variance is known');
    case 'unknown'
        assert(algo_obj.estimnoise == true, 'STK:optim_init',...
            'Error: if noise variance is unknown, must estimate noise variance');
end

if MODEL_USER && NOISEVARIANCE_USER
    assert(algo_obj.model.lognoisevariance == log (algo_obj.noisevariance), ...
        'STK:optim_init', ...
        'Error: noise variance in model not equal to noise variance in options');
end

%% INITIAL EVALUATIONS
[xi, zi, algo_obj] = stk_optim_addevals(algo_obj, [], [], xi);

%% SET DEFAULT MODEL PARAMETERS
if any(isnan(algo_obj.model.param))
    if stk_length(xi) > 1;  SIGMA2 = 4*var(zi.data); else SIGMA2 = 1.0; end
    NU     = 2*dim;
    for d = 1:dim
        RHO(d) = 1/4 * abs(box(2, d) - box(1, d));
    end
    param0 = log ([SIGMA2; NU; 1./RHO]);
    algo_obj.model.param = param0;
end
algo_obj.model.prior.mean = param0;
algo_obj.model.prior.invcov = 0.5*eye(length(param0));

%% CANDIDATE POINTS
if ~isempty(algo_obj.searchgrid_xvals)
    algo_obj.xg0 = algo_obj.searchgrid_xvals;
	algo_obj.searchgrid_size = stk_length(algo_obj.xg0);
else
    algo_obj.xg0 = stk_sampling_maximinlhs(algo_obj.searchgrid_size, algo_obj.dim, algo_obj.box, 100);
    if dim == 1
        algo_obj.xg0.data = sort(algo_obj.xg0.data);
    end
end

if ~strcmp(algo_obj.noise, 'noisefree') && ~isa(algo_obj.xg0, 'stk_ndf')
    algo_obj.xg0 = stk_ndf(algo_obj.xg0, algo_obj.noisevariance);
end

%% SELECT SAMPLING CRITERION
switch (algo_obj.samplingcritname)
	case 'EI',
        assert(strcmp(algo_obj.noise, 'noisefree'), 'STK:optim_init',...
            'Error: cannot use noisy evaluations with crit=''EI''');
		algo_obj.samplingcrit = @(algo, xg, xi_ind, zi)(stk_optim_crit_EI (algo, xg, xi_ind, zi));
		algo_obj.type = 'usemaxobs';
		NEED_QUAD = false;
	case 'EI_v2',
        assert(strcmp(algo_obj.noise, 'noisefree'), 'STK:optim_init',...
            'Error: cannot use noisy evaluations with crit=''EI_v2''');
		algo_obj.samplingcrit = @(algo, xg, xi_ind, zi)(stk_optim_crit_SUR (algo, xg, xi_ind, zi, 1));
		algo_obj.type = 'usemaxobs';
		NEED_QUAD = true;
		if isempty(algo_obj.quadtype), algo_obj.quadtype = 'GH'; end
		if isnan(algo_obj.quadorder),  algo_obj.quadorder = 15;  end
	case 'EI_v3',
		algo_obj.samplingcrit = @(algo, xg, xi_ind, zi)(stk_optim_crit_SUR (algo, xg, xi_ind, zi, 2));
		algo_obj.type = 'usemaxpred';
		NEED_QUAD = true;
		if isempty(algo_obj.quadtype), algo_obj.quadtype = 'GH'; end
		if isnan(algo_obj.quadorder),  algo_obj.quadorder = 15;  end
	case 'EEI',
        assert(strcmp(algo_obj.noise, 'noisefree'), 'STK:optim_init',...
            'Error: cannot use noisy evaluations with crit=''EEI''');
		algo_obj.samplingcrit = @(algo, xg, xi_ind, zi)(stk_optim_crit_SUR (algo, xg, xi_ind, zi, 3));
		algo_obj.type = 'usemaxobs';
		NEED_QUAD = true;
		if isempty(algo_obj.quadtype), algo_obj.quadtype = 'GH'; end
		if isnan(algo_obj.quadorder),  algo_obj.quadorder = 15;  end
	case 'EEI_v2',
		algo_obj.samplingcrit = @(algo, xg, xi_ind, zi)(stk_optim_crit_SUR (algo, xg, xi_ind, zi, 4));
		algo_obj.type = 'usemaxpred';
		NEED_QUAD = true;
		if isempty(algo_obj.quadtype), algo_obj.quadtype = 'GH'; end
		if isnan(algo_obj.quadorder),  algo_obj.quadorder = 15;  end
	case 'IAGO',
		algo_obj.samplingcrit = @(algo, xg, xi_ind, zi)(stk_optim_crit_iago (algo, xg, xi_ind, zi));
		algo_obj.type = 'usemaxobs';
		NEED_QUAD = true;
		if isempty(algo_obj.quadtype), algo_obj.quadtype = 'GH'; end
		if isnan(algo_obj.quadorder),  algo_obj.quadorder = 15;  end
end

%% QUADRATURE
if NEED_QUAD
	algo_obj.Q = algo_obj.quadorder;
	algo_obj = stk_quadrature(0, algo_obj, algo_obj.quadtype, algo_obj.quadorder);
end

end %%END stk_optim_init