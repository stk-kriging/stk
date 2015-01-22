% STK_OPTIM_INIT initializes the optimization algorithms
%
% CALL: stk_optim_init()
%
% STK_OPTIM_INIT sets parameters of the optimization algorithm

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
    'noisevariance', 0.0
    'showprogress', true
    'pause', 0
    'disp', false
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
MODEL_USER = isfield (useropt, 'model');

% set NOISEVARIANCE_USER if noisevariance is provided by user
NOISEVARIANCE_USER = isfield (useropt, 'noisevariance');

% default values
for i = 1:size(options, 1)
    if isfield(useropt, options{i, 1})
        algo_obj.(options{i, 1}) = useropt.(options{i, 1});
        useropt = rmfield(useropt, options{i, 1});
    else
        algo_obj.(options{i, 1}) = options{i, 2};
    end
end

% Warn for unknown options passed by the user
unknown_fields = fieldnames (useropt);
for i = 1:(numel (unknown_fields))
    warning ('Unknown option: %s\n', unknown_fields{i});  %#ok<WNTAG>
end

% Safety net: stop if there are unknown options
if ~ isempty (unknown_fields)
    stk_error ('Unknown option', 'InvalidArgument');
end


%% Noise options: check consistency

v1 = algo_obj.noisevariance;  lnv2 = algo_obj.model.lognoisevariance;

if MODEL_USER
    if NOISEVARIANCE_USER
        if isnumeric (v1)
            % Noiseless or noisy/homoscedastic case
            assert ((isscalar (v1)) && (isscalar (lnv2)));
            if ~ isnan (v1)
                % Known noise variance: should be the same
                assert (((v1 == 0) && (lnv2 == -inf)) ...
                    || (stk_isequal_tolrel (v1, exp (lnv2), 1e-12)));
            end
        else
            % Heteroscedastic case: v1 = {known_var, var_fun}
            assert ((iscell (v1)) && (numel (v1) == 2));
            assert ((isempty (v2)) || (isequal (v1, lnv2)));
            algo_obj.model.lognoisevariance = [];
        end
    else
        % Set options.noisevariance based on model.lognoisevariance
        if isnumeric (lnv2)
            % Noiseless of noisy/homoscedastic case
            assert (isscalar (lnv2));
            options.noisevariance = exp (lnv2);
        else
            % Heteroscedastic case: lnv2 = {known_var, var_fun}
            assert ((iscell (lnv2)) && (numel (lnv2) == 2));
            options.noisevariance = lnv;
        end
    end
else
    % No model has been provided by the user.
    %  => set model.lognoisevariance based on options.noisevariance
    if isnumeric (v1)
        % Noiseless of noisy/homoscedastic case
        assert (isscalar (v1));
        algo_obj.model.lognoisevariance = log (v1);
    else
        % Heteroscedastic case:
        assert ((iscell (v1)) && (numel (v1) == 2));
        algo_obj.model.lognoisevariance = [];
    end
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

% Turn algo_obj.xg0 into an stk_ndf object *in the heteroscedastic case only*
v = algo_obj.noisevariance;
if isa (algo_obj.xg0, 'stk_ndf')
    % The user has provided an stk_ndf object => heteroscedastic case
    if NOISEVARIANCE_USER
        assert (isequal (algo_obj.xg0.noisevariance, v));
    else
        algo_obj.noisevariance = algo_obj.xg0.noisevariance;
    end
else
    if ischar (v)
        % Heteroscedastic case with known noise variance
        algo_obj.xg0 = stk_ndf (algo_obj.xg0, nan (size (algo_obj.xg0, 1), 1));
    elseif (isnumeric (v)) && (~ isscalar (v))
        % Heteroscedastic case with known noise variance
        algo_obj.xg0 = stk_ndf (algo_obj.xg0, v(:));
    else
        % Homoscedastic case with known noise variance (safety net)
        assert ((isnumeric (v)) && (isscalar (v)));
    end
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


%% SELECT SAMPLING CRITERION

noisy_eval = ~ isequal (algo_obj.noisevariance, 0);

switch (algo_obj.samplingcritname)
    case 'EI',
        assert (noisy_eval, 'STK:optim_init',...
            'Error: cannot use noisy evaluations with crit=''EI''');
        algo_obj.samplingcrit = @(algo, xi, zi)(stk_optim_crit_EI (algo, xi, zi));
        algo_obj.type = 'usemaxobs';
        NEED_QUAD = false;
    case 'EI_v2',
        assert (noisy_eval, 'STK:optim_init',...
            'Error: cannot use noisy evaluations with crit=''EI_v2''');
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
        assert (noisy_eval, 'STK:optim_init',...
            'Error: cannot use noisy evaluations with crit=''EEI''');
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
        algo_obj.samplingcrit = @stk_optim_crit_iago;
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

end % function stk_optim_init
