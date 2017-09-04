% STK_SAMPCRIT_AKG_EVAL computes the Approximate KG criterion
%
% CALL: AKG = stk_sampcrit_akg_eval (ZC_MEAN, ZC_STD, ZR_MEAN, ZR_STD, ZCR_COV)
%
%    computes the value AKG of the Approximate KG criterion for a set of
%    candidates points, with respect to a certain reference grid.  The
%    predictive distributions of the objective function (to be minimized) at
%    the candidates and reference points is assumed to be jointly Gaussian,
%    with mean ZC_MEAN and standard deviation ZC_STD for the candidate points,
%    mean ZR_MEAN and satandard deviation ZR_STD on the reference points, and
%    covariance matrix ZCR_COV between the candidate and reference points.
%    The input argument must have the following sizes:
%
%       * ZC_MEAN    M x 1,
%       * ZC_STD     M x 1,
%       * ZR_MEAN    L x 1,
%       * ZR_STD     L x 1,
%       * ZCR_COV    M x L,
%
%    where M is the number of candidate points and L the number of reference
%    points.  The output has size M x 1.
%
% NOTE ABOUT THE "KNOWLEDGE GRADIENT" CRITERION
%
%    The "Knowlegde Gradient" (KG) criterion is the one-step look-ahead (a.k.a
%    myopic) sampling criterion associated to the problem of estimating the
%    minimizer of the objective function under the L^1 loss (equivalently,
%    under the linear loss/utility).
%
%    This sampling strategy was proposed for the first time in the work of
%    Mockus and co-authors in the 70's (see [1] and refs therein), for the case
%    of noiseless evaluations, but only applied to particular Brownian-like
%    processes for which the minimum of the posterior mean coincides with the
%    best evaluations so far (in which case the KG criterion coincides with the
%    EI criterion introduced later by Jones et al [2]).
%
%    It was later discussed for the case of a finite space with independent
%    Gaussian priors first by Gupta and Miescke [3] and then by Frazier et al
%    [4] who named it "knowledge gradient".  It was extended to the case of
%    correlated priors by Frazier et al [5].
%
% NOTE ABOUT THE REFERENCE SET
%
%    For the case of continuous input spaces, there is no exact expression of
%    the KG criterion.  The approximate KG criterion proposed in this function
%    is an approximation of the KG criterion where the continuous 'min' in the
%    expression of the criterion at the i^th candidate point are replaced by
%    discrete mins over some reference grid *augmented* with the i^th candidate
%    point.
%
%    This type of approximation has been proposed by Scott et al [6] under the
%    name "knowledge gradient for continuous parameters" (KGCP).  In [6], the
%    reference grid is composed of the current set of evaluation points.  The
%    implementation proposed in STK leaves this choice to the user.
%
%    Note that, with the reference grid proposed in [6], the complexity of one
%    evaluation of the AKG (KGCP) criterion increases as O(N log N), where N
%    denotes the number of evaluation points.
%
% NOTE ABOUT THE NOISELESS CASE
%
%    Simplified formulas are available for the noiseless case (see [7]) but not
%    currenly implemented in STK.
%
% REFERENCES
%
%   [1] J. Mockus, V. Tiesis and A. Zilinskas. The application of Bayesian
%       methods for seeking the extremum. In L.C.W. Dixon and G.P. Szego, eds,
%       Towards Global Optimization, 2:117-129, North Holland NY, 1978.
%
%   [2] D. R. Jones, M. Schonlau and William J. Welch. Efficient global
%       optimization of expensive black-box functions.  Journal of Global
%       Optimization, 13(4):455-492, 1998.
%
%   [3] S. Gupta and K. Miescke,  Bayesian look ahead one-stage sampling
%       allocations for selection of the best population,  J. Statist. Plann.
%       Inference, 54:229-244, 1996.
%
%   [4] P. I. Frazier, W. B. Powell, S. Dayanik,  A knowledge gradient policy
%       for sequential information collection,  SIAM J. Control Optim.,
%       47(5):2410-2439, 2008.
%
%   [5] P. I. Frazier, W. B. Powell, and S. Dayanik.  The Knowledge-Gradient
%       Policy for Correlated Normal Beliefs.  INFORMS Journal on Computing
%       21(4):599-613, 2009.
%
%   [6] W. Scott, P. I. Frazier and W. B. Powell.  The correlated knowledge
%       gradient for simulation optimization of continuous parameters using
%       Gaussian process regression.  SIAM J. Optim, 21(3):996-1026, 2011.
%
%   [7] J. van der Herten, I. Couckuyt, D. Deschrijver, T. Dhaene,  Fast
%       Calculation of the Knowledge Gradient for Optimization of Deterministic
%       Engineering Simulations,  arXiv preprint arXiv:1608.04550
%
% See also: STK_SAMPCRIT_EI_EVAL

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function AKG = stk_sampcrit_akg_eval (zc_mean, zc_std, zr_mean, zr_std, zcr_cov)

% zc_mean:   M x 1  where M is the number of (C)andidate points
% zc_std:    M x 1
% zr_mean:   L x 1  where L is the number of (R)eference points
% zr_std:    L x 1
% zcr_cov    M x L  covariance between (C)andidate points and (R)eference points

% note: Scott et al.'s "KGCP" corresponds to refs points X_1, ..., X_n

if nargin > 5
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

M = size (zc_mean, 1);
if ~ isequal (size (zc_mean), [M 1])
    stk_error (['zc_mean should have size M x 1, where M is the number of ' ...
        'candidate points.'], 'IncorrectSize');
end
if ~ isequal (size (zc_std), [M 1])
    stk_error (['zc_std should have size M x 1, where M is the number of ' ...
        'candidate points.'], 'IncorrectSize');
end

L = size (zr_mean, 1);
if ~ isequal (size (zr_mean), [L 1])
    stk_error (['zr_mean should have size L x 1, where L is the number of ' ...
        'reference points.'], 'IncorrectSize');
end
if ~ isequal (size (zr_std), [L 1])
    stk_error (['zr_std should have size L x 1, where L is the number of ' ...
        'reference points.'], 'IncorrectSize');
end

if ~ isequal (size (zcr_cov), [M L])
    stk_error (['zcr_cov should have size L x 1, where M is the number of ' ...
        'candidate points and L the number of reference points.'], ...
        'IncorrectSize');
end

AKG = zeros (M, 1);

% Minimum over the reference grid
if isempty (zr_mean)
    zr_min = +inf;
else
    zr_min = min (zr_mean);
end

for i = 1:M
    
    if zc_std(i) == 0,  continue;  end
    
    % Mitigate the effect of small inaccurate covariance values
    a0 = zcr_cov(i,:)' / zc_std(i);
    a0 = max (-zr_std, min (zr_std, a0));
    
    a = [a0; zc_std(i)];        % slopes
    b = [zr_mean; zc_mean(i)];  % intercepts
    
    % Intersection of lower half-planes
    % (algorithm similar to the one in Scott et al, 2011, Table 4.1,
    %  except that cases of equal slopes are dealt with inside the loop)
    [a, b, z] = stk_halfpintl (a, b);
    
    % Compute normal cdfs and pdfs
    F = [0; stk_distrib_normal_cdf(z); 1];
    p = [0; stk_distrib_normal_pdf(z); 0];
    
    % Compute the expected min  (Equation 4.11 in Scott et al, 2011)
    expected_min = sum (b .* diff (F)) - sum (a .* diff (p));
    
    % Finally, compute the value of the AKG criterion
    AKG(i) = max (0, min (zr_min, zc_mean(i)) - expected_min);
    
end % for

end % function


%!shared zc_mean, zc_std, zr_mean, zr_std, zcr_cov, AKG, nc
%! xi = [0; 0.2; 0.7; 0.9];
%! zi = [1; 0.9; 0.6; 0.1] - 10;
%! ni = 4;
%!
%! M_prior = stk_model('stk_materncov32_iso');
%! M_prior.param = log ([1.0; 2.1]);
%! M_prior.lognoisevariance = 0.678;
%!
%! nc = 20;
%! xc = stk_sampling_regulargrid (nc, 1, [0; 1]);
%! [zp, ignd1, ignd2, K] = stk_predict (M_prior, xi, zi, [xi; xc]);  % See CG#07
%!
%! ir = 1:ni;  ic = ni + (1:nc);
%!
%! zc_mean = zp.mean(ic);
%! zc_std = sqrt (zp.var(ic));
%!
%! % reference grid: current evaluation points ("KGCP")
%! zr_mean = zp.mean(ir);
%! zr_std = sqrt (zp.var(ir));
%!
%! zcr_cov = K(ic, ir);

%!test AKG = stk_sampcrit_akg_eval (zc_mean, zc_std, zr_mean, zr_std, zcr_cov);
%!assert (isequal (size (AKG), [nc 1]))
%!assert (all (AKG >= 0))

% not enough or too many input args
%!error AKG = stk_sampcrit_akg_eval (zc_mean, zc_std, zr_mean, zr_std);
%!error AKG = stk_sampcrit_akg_eval (zc_mean, zc_std, zr_mean, zr_std, zcr_cov, 1.234);
