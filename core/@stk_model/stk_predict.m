% STK_PREDICT performs a kriging prediction from data
%
% CALL: ZP = stk_predict(MODEL, XP)
%
%    performs a kriging prediction at the points XP, using the kriging model
%    MODEL. The input argument XP can be either a numerical array or a
%    dataframe. On a factor space of dimension DIM, XP must have size NP x DIM,
%    where NP is the number of prediction points. The output ZP is a dataframe
%    of size NP x 2, with:
%
%     * the kriging predictor in the first column (ZP.mean), and
%     * the kriging variance in the second column (ZP.var).
%
% CALL: [ZP, LAMBDA, MU] = stk_predict(MODEL, XP)
%
%    also returns the matrix of kriging weights LAMBDA and the matrix of
%    Lagrange multipliers MU.
%
% CALL: [ZP, LAMBDA, MU, K] = stk_predict(MODEL, XP)
%
%    also returns the posterior covariance matrix K at the locations XP (this is
%    an NP x NP covariance matrix). From a frequentist point of view, K can be
%    seen as the covariance matrix of the prediction errors.
%
% SPECIAL CASE #1
%
%    If MODEL.domain.type is discrete, MODEL.observations.x and XP are expected
%    to be vectors of integer indices. This feature is not fully documented
%    as of today... If XP is empty, it is assumed that predictions must be
%    computed at all points of the underlying discrete space.
%
% SPECIAL CASE #2
%
%    If MODEL.observations.z is empty, everything but ZP.mean is computed.
%    Indeed, neither the kriging variance ZP.var nor the matrices LAMBDA and
%    MU actually depend on the observed values.
%
% EXAMPLE: see examples/example01.m

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
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

function [zp, lambda, mu, K] = stk_predict (model, xt)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% TODO: these should become options
display_waitbar = false;
block_size = [];

%--- Prepare the lefthand side of the KRiging EQuation -------------------------

xi = double (model.observations.x);

if iscell (xi)
    % WARNING: experimental HIDDEN feature, use at your own risk !!!
    kreq = xi{2}; % already computed, I hope you known what you're doing ;-)
    xi = xi{1};
else
    kreq = stk_kreq_qr (model, xi);
end

%--- Convert and check input arguments: zi, xt ---------------------------------

zi = double (model.observations.z);
ni = kreq.n;

if ~ (isempty (zi) || isequal (size (zi), [ni 1]))
    stk_error ('zi must have size ni x 1.', 'IncorrectSize');
end

xt = double (xt);

switch model.domain.type
    
    case 'discrete',
        
        if isempty (xt)
            % default: predict the response at all possible locations
            m = size (model.domain.nt, 1);
            xt = (1:m)';
        elseif ~iscolumn (xt)
            warning ('STK:stk_predict:IncorrectSize', 'xt should be a column.');
            xt = xt(:);
        end
        
    case 'continuous',
        
        assert (~isempty (xt));
        
    otherwise
        
        error ('model.domain.type should be either "continuous" or "discrete"');
        
end

nt = size (xt, 1);

%--- Prepare the output arguments ----------------------------------------------

zp_v = zeros (nt, 1);
compute_prediction = ~ isempty (zi);

% compute the kriging prediction, or just the variances ?
if compute_prediction,
    zp_a = zeros (nt, 1);
else
    zp_a = nan (nt, 1);
end

%--- Choose nb_blocks & block_size ---------------------------------------------

if isempty (block_size)
    MAX_RS_SIZE = 5e6; SIZE_OF_DOUBLE = 8; % in bytes
    block_size = ceil( MAX_RS_SIZE / (ni * SIZE_OF_DOUBLE));
end

% blocks of size approx. block_size
nb_blocks = max (1, ceil(nt / block_size));

block_size = ceil (nt / nb_blocks);

% if we want to return a full kreq object in the case where several blocks are
% used, we need to recompose full lambda_mu and RS matrices.
if nargin > 1
    lambda_mu = zeros (ni + kreq.r, nt);
    RS = zeros (size (lambda_mu));
end

%--- MAIN LOOP (over blocks) ---------------------------------------------------

% TODO: this loop should be parallelized !!!

for block_num = 1:nb_blocks
    
    % compute the indices for the current block
    idx_beg = 1 + block_size * (block_num - 1);
    idx_end = min(nt, idx_beg + block_size - 1);
    idx = idx_beg:idx_end;
    
    % solve the kriging equation for the current block
    [Kti, Pt] = stk_make_matcov (model, xt, xi);
    kreq = stk_set_righthandside (kreq, Kti, Pt);
    
    % compute the kriging mean
    if compute_prediction,
        zp_a(idx) = kreq.lambda' * zi;
    end
    
    if nargin > 1
        lambda_mu(:, idx) = kreq.lambda_mu;
        RS(:, idx) = kreq.RS;
    end
    
    % compute kriging variances (this does NOT include the noise variance)
    zp_v(idx) = stk_make_matcov (model, xt, xt, true) - kreq.delta_var;
    
    % note: the following modification computes prediction variances for noisy
    % variance, i.e., including the noise variance also
    % zp_v(idx) = stk_make_matcov (model, xt, [], true) ...
    %     - dot (kreq.lambda_mu, kreq.RS);
    
    b = (zp_v < 0);
    if any (b),
        zp_v(b) = 0.0;
        warning('STK:stk_predict:NegativeVariancesSetToZero', sprintf ( ...
            ['Correcting numerical inaccuracies in kriging variance.\n' ...
            '(%d negative variances have been set to zero)'], sum (b)));
    end
    
    if display_waitbar,
        waitbar (idx_end/nt, hwb, sprintf ( ...
            'In stk\\_predict(): %d/%d predictions completed',idx_end,nt));
    end
end

if display_waitbar,
    close (hwb);
end

%--- Prepare outputs -----------------------------------------------------------

zp = stk_dataframe ([zp_a zp_v], {'mean' 'var'});
zp.info = 'Created by stk_predict';

if nargout > 1 % lambda requested
    lambda = lambda_mu(1:ni, :);
end

if nargout > 2 % mu requested
    mu = lambda_mu((ni+1):end, :);
end

if nargout > 3,
    K0 = stk_make_matcov (model, xt, xt);
    deltaK = lambda_mu' * RS;
    K = K0 - 0.5 * (deltaK + deltaK');
end

end % function stk_predict -----------------------------------------------------


%!shared n, m, model, x0, x_obs, z_obs, x_prd, y_prd1, idx_obs, idx_prd
%!
%! n = 10;     % number of observations
%! m = n + 1;  % number of predictions
%! d = 1;      % dimension of the input space
%!
%! x0 = stk_sampling_regulargrid(n+m, d, [0; pi]);
%!
%! idx_obs = (2:2:(n+m-1))';
%! idx_prd = (1:2:(n+m))';
%!
%! x_obs = x0(idx_obs);
%! z_obs = sin (double (x_obs));
%! x_prd = x0(idx_prd);
%!
%! model = stk_model('stk_materncov32_iso');
%! model = stk_setobs(model, x_obs, z_obs);
%! model.randomprocess.priormean = stk_lm('constant');
%! % this is currently the default, but better safe than sorry

%!error y_prd1 = stk_predict();
%!error y_prd1 = stk_predict(model);
%!test  y_prd1 = stk_predict(model, x_prd);
%!error y_prd1 = stk_predict(model, x_prd, 0);

%!test
%! [y_prd1, lambda, mu, K] = stk_predict(model, x_prd);
%! assert(isequal(size(lambda), [n m]));
%! assert(isequal(size(mu), [1 m]));  % ordinary kriging
%! assert(isequal(size(K), [m m]));
