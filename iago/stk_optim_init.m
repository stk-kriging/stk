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

function [algo_obj, zi] = stk_optim_init(f, dim, box, xi, varargin)

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
model.lognoisevariance = log (nan); % will be set later

%% PROCESS OPTIONS
options = {
    'samplingcritname', 'EI'
    'model', model
    'estimparams', true
    'simulatenoise', false
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
    'nsamplepaths', 800
    'quadtype', []
    'quadorder', nan
    'ComputeCurrentOptimum', true
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
	fprintf('***Warning*** -- Unknown field %s\n', unknown_fields{i});
end

%% INITIAL EVALUATIONS
zi = stk_feval (f, xi);
if algo_obj.simulatenoise
    noise = sqrt (algo_obj.noisevariance) * randn (size (zi));
    zi = zi + noise;
end

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
if ~isfield(algo_obj.model, 'lognoisevariance') % when model is provided by user without lognoisevariance
	algo_obj.model.lognoisevariance = log (algo_obj.noisevariance);
end
if isnan(algo_obj.model.lognoisevariance)
    algo_obj.model.lognoisevariance = log (algo_obj.noisevariance);
end

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

%% SELECT SAMPLING CRITERION
switch (algo_obj.samplingcritname)
	case 'EI',
		algo_obj.samplingcrit = @(algo, xi, zi)(stk_optim_crit_EI (algo, xi, zi));
		algo_obj.type = 'usemaxobs';
		NEED_QUAD = false;
	case 'EI_v2',
		algo_obj.samplingcrit = @(algo, xi, zi)(stk_optim_crit_SUR (algo, xi, zi, 1));
		algo_obj.type = 'usemaxobs';
		NEED_QUAD = true;
		if isempty(algo_obj.quadtype), algo_obj.quadtype = 'GH'; end
		if isnan(algo_obj.quadorder),  algo_obj.quadorder = 15;  end
	case 'EI_v3',
		algo_obj.samplingcrit = @(algo, xi, zi)(stk_optim_crit_SUR (algo, xi, zi, 2));
		algo_obj.type = 'usemaxpred';
		NEED_QUAD = true;
		if isempty(algo_obj.quadtype), algo_obj.quadtype = 'GH'; end
		if isnan(algo_obj.quadorder),  algo_obj.quadorder = 15;  end
	case 'EEI',
		algo_obj.samplingcrit = @(algo, xi, zi)(stk_optim_crit_SUR (algo, xi, zi, 3));
		algo_obj.type = 'usemaxobs';
		NEED_QUAD = true;
		if isempty(algo_obj.quadtype), algo_obj.quadtype = 'GH'; end
		if isnan(algo_obj.quadorder),  algo_obj.quadorder = 15;  end
	case 'EEI_v2',
		algo_obj.samplingcrit = @(algo, xi, zi)(stk_optim_crit_SUR (algo, xi, zi, 4));
		algo_obj.type = 'usemaxpred';
		NEED_QUAD = true;
		if isempty(algo_obj.quadtype), algo_obj.quadtype = 'GH'; end
		if isnan(algo_obj.quadorder),  algo_obj.quadorder = 15;  end
	case 'IAGO',
		algo_obj.samplingcrit = @(algo, xi, zi)(stk_optim_crit_iago (algo, xi, zi));
		algo_obj.type = 'usemaxobs';
		NEED_QUAD = true;
		if isempty(algo_obj.quadtype), algo_obj.quadtype = 'GH'; end
		if isnan(algo_obj.quadorder),  algo_obj.quadorder = 15;  end
end

%% QUADRATURE
if NEED_QUAD
	algo_obj.Q = algo_obj.quadorder;
	[algo_obj.zQ, algo_obj.wQ] = stk_quadrature(algo_obj.quadtype, algo_obj.quadorder);
end

%% MISC
if algo_obj.showprogress
	addpath(fullfile(pwd(), 'misc'));
end
if algo_obj.disp
	addpath(fullfile(pwd(), 'viewfcs'));
end

end %%END stk_optim_init