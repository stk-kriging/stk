% STK_OPTIM_INIT initializes the optimization algorithms
%
% CALL: stk_optim_init()
%
% STK_OPTIM_INIT sets parameters of the optimization algorithm

% Copyright Notice
%
%    Copyright (C) 2015, 2020 CentraleSupelec
%    Copyright (C) Ivana Aleksovska
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

function algo = stk_optim_init (f, dim, box, varargin)

%% FUNCTION DEFINTION
algo.f  = f;
algo.dim = dim;
algo.box = box;

%% DEFAULT MODEL SPECIFICATION
model = stk_model ('stk_materncov_aniso', dim);
model.param = nan (dim + 2, 1);

%% PROCESS OPTIONS
options = {
    'samplingcritname', 'EI'
    'samplingcrit', []
    'model', model
    'estimparams', true
    'noisevariance', 0.0
    'gather_repetitions', []
    'showprogress', true
    'pause', 0
    'disp', false
    'disp_xvals', []
    'disp_zvals', []
    'disp_period', 1
    'disp_fignum_base', 3000
    'disp_fignum_critshift', 200
    'show1dsamplepaths', false
    'show1dmaximizerdens', 2
    'searchgrid_xvals', []
    'searchgrid_unique', true
    'searchgrid_adapt', false
    'searchgrid_size', 200
    'searchgrid_noise', []
    'nsamplepaths', 100
    'quadtype', []
    'quadorder', nan
    'stoprule', false
    'opt_estim', 'auto'
    'futurebatchsize', 1
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
        algo.(options{i, 1}) = useropt.(options{i, 1});
        useropt = rmfield(useropt, options{i, 1});
    else
        algo.(options{i, 1}) = options{i, 2};
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

v1 = algo.noisevariance;  lnv2 = algo.model.lognoisevariance;

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
            algo.model.lognoisevariance = [];
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
        algo.model.lognoisevariance = log (v1);
    else
        % Heteroscedastic case:
        assert ((iscell (v1)) && (numel (v1) == 2));
        algo.model.lognoisevariance = [];
    end
end

% Default: Enable repetition gathering, unless we're in the noiseless case
if isempty (algo.gather_repetitions)
    algo.gather_repetitions = ~ all (algo.model.lognoisevariance == -inf);
end

% Some criterions cannot deal with noisy evaluations
if (~ isequal (algo.noisevariance, 0)) ...
        && (ismember (algo.samplingcritname, {'EI', 'EI_v2', 'EEI'}))
    stk_error (sprintf (['Criterion ''%s'' cannot be used with noisy ' ...
        'evaluations'], algo.samplingcritname), 'InvalidArgument');
end


%% Convert logical options

algo.estimparams            = logical (algo.estimparams);
algo.gather_repetitions     = logical (algo.gather_repetitions);
algo.showprogress           = logical (algo.showprogress);
algo.disp                   = logical (algo.disp);
algo.show1dsamplepaths      = logical (algo.show1dsamplepaths);
algo.searchgrid_unique      = logical (algo.searchgrid_unique);
algo.searchgrid_adapt       = logical (algo.searchgrid_adapt);
algo.stoprule               = logical (algo.stoprule);


%% CANDIDATE POINTS
if ~isempty(algo.searchgrid_xvals)
    algo.xg0 = algo.searchgrid_xvals;
    algo.searchgrid_size = stk_get_sample_size (algo.xg0);
else
    algo.xg0 = stk_sampling_maximinlhs(algo.searchgrid_size, algo.dim, algo.box, 100);
    if dim == 1
        algo.xg0.data = sort(algo.xg0.data);
    end
end

% Turn algo.xg0 into an stk_ndf object *in the heteroscedastic case only*
v = algo.noisevariance;
if isa (algo.xg0, 'stk_ndf')
    % The user has provided an stk_ndf object => heteroscedastic case
    if NOISEVARIANCE_USER
        assert (isequal (algo.xg0.noisevariance, v));
    else
        algo.noisevariance = algo.xg0.noisevariance;
    end
else
    if ischar (v)
        % Heteroscedastic case with known noise variance
        algo.xg0 = stk_ndf (algo.xg0, nan (size (algo.xg0, 1), 1));
    elseif (isnumeric (v)) && (~ isscalar (v))
        % Heteroscedastic case with known noise variance
        algo.xg0 = stk_ndf (algo.xg0, v(:));
    else
        % Homoscedastic case with known noise variance (safety net)
        assert ((isnumeric (v)) && (isscalar (v)));
    end
end


%% Set prior for covariance parameters

% FIXME: only works for stk_materncov_aniso !

% Prior mean (rule of thumb)
LOGSIGMA2_PRIORMEAN = 0;  % don't care, since we use an infinite variance
LOGNU_PRIORMEAN = log (2 + 0.5 * dim);
LOGINVRHO_PRIORMEAN = - log (1/4 * (diff (box))');

algo.model.prior.mean = [LOGSIGMA2_PRIORMEAN; ...
    LOGNU_PRIORMEAN; LOGINVRHO_PRIORMEAN];

LOGNU_VAR = 0.3 ^ 2;
LOGINVRHO_VAR = 0.5 ^ 2;
algo.model.prior.invcov = diag ([0 1/LOGNU_VAR ...
    1/LOGINVRHO_VAR*ones(1,dim)]);


%% Sampling criterion

if isempty (algo.samplingcrit)
    
    switch (algo.samplingcritname)
        case 'EI',
            % Expected improvement criterion
            algo.samplingcrit = @stk_optim_crit_EI;
        case {'CEM', 'IAGO'},
            % Conditional entropy of the maximizer
            algo.samplingcrit = @stk_optim_crit_iago;
        otherwise
            % Try to create a function handle automatically
            algo.samplingcrit = str2func (algo.samplingcritname);
    end
    
else  % Make sure algo.samplingcritname is a char
    
    algo.samplingcritname = 'UnnamedCriterion';
    
end

% Experimental (a.k.a user-defined) sampling criteria can be used by providing
% directly a function handle in algo.samplingcrit. For instance
%
%    algo.samplingcritname = 'EEI';
%    algo.samplingcrit = @(A, xi, zi)(stk_optim_crit_SUR (A, xi, zi, 3));

assert (ischar (algo.samplingcritname));
assert (isa (algo.samplingcrit, 'function_handle'));


%% Method used to estimate x_opt and f_opt

if strcmp (algo.opt_estim, 'auto')
    if algo.noisevariance == 0
        % Noiseless case: use the best evaluation so far
        algo.opt_estim = 'usemaxobs';
    else
        % Othewise, use the best predicted value
        algo.opt_estim = 'usemaxpred';
    end
end

% FIXME: Another option would be worth including, namely, using the MAP
%    estimate for the optimal location in the set of candidate points

if ~ ismember (algo.opt_estim, {'usemaxobs', 'usemaxpred'})
    stk_error (['Option opt_estim should be equal to ''usemaxobs'' or ' ...
        '''usemaxpred''.'], 'InvalidArgument');
end

        
%% Quadrature rule(s)
%
% Currently, this section only deals with the choice of the "vertical"
% integration scheme, i.e., integration with respect to the unknown value of
% future observation(s).
%
% FIXME: in the case of integral criteria, there is another ("horizontal")
% integration rule. We should provide some control over this one too.
%

% Detect automatically some sampling criterion names for which we know
% that a quadrature is performed. For user-defined criterions, the user
% must specify algo.quadtype and algo.quadorder.
NEED_QUAD = ismember (algo.samplingcritname, ...
    {'EI_v2', 'EI_v3', 'EEI', 'EEI_v2', 'CEM', 'IAGO'});

if NEED_QUAD,
    % Default: Gauss-Hermite quadrature with 15 quadrature points
    if isempty (algo.quadtype),  algo.quadtype = 'GH';  end
    if isnan (algo.quadorder),   algo.quadorder = 15;   end
end

if ~ isempty (algo.quadtype)
    % Compute quadrature points and weights
    algo = stk_quadrature (0, algo, algo.quadtype, algo.quadorder);
end


%% Future batch size

fbs = algo.futurebatchsize;
if ~ ((isscalar (fbs)) && (fbs > 0) && ...
        ((floor (fbs) == fbs) || (isinf (fbs))))
    stk_error ('futurebatchsize should be a positive integer of +inf', ...
        'InvalidArgument');
end

end % function
