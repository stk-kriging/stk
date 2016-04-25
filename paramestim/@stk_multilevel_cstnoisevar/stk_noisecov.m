function [L, calc] = stk_noisecov (ml_nv, xi, diff, pairwise, calc)
% L = stk_noisecov (ml_nv, xi, diff, pairwise)
% [L, calc] = stk_noisecov (ml_nv, xi, diff, pairwise, calc)
%
% Compute the noise variance matrix, i.d. the exponential of the log-noise
% variance, for a multi-level noise variance parameter.
%
% - ml_nv : the multi-level noise variance parameter;
% - xi : a set of point, where noise must be evaluated;
% - diff : if -1, return the value of the noise variance.
% If diff >= 1, return the derivative of the noise variance parameter, by
% the diff-th parameter.
% L(ml_nv, xi, diff) = d( L(ml_nv, xi, -1) )/d( ml_nv(diff) )
% Default value : -1 (no derivative).
% Diff must be lower than the number of levels.
% - pairwise : a boolean, indicating if L must be a vector (pairwise =
% true), or a square matrix (pairwise = false).
% stk_noisecov (ml_nv, xi, diff, true) = diag( stk_noisecov
% (ml_nv, xi, diff, false) ).
% - calc : previous furnish by the function. Allow to compute faster the
% covariance.
%
% L is the value of the noise variance (of its derivative, if diff >= 1).
% If pairwise is false, size(L) = [n, n], where n = size(xi, 1). If
% pairwise is true, size(L) = [n, 1], where n = size(xi, 1).
%
% calc is the intermediar calculation effected during the compution of the
% noise covariance. If provided during the next call, the computation will
% be faster.

%% Check number of inputs
if nargin > 5,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

%% Default values
if nargin < 5 || isempty(calc)
    calc = [];  %no previous calculation
end

if nargin < 4 || isempty(pairwise)
    pairwise = false; % default: matrix
end

if nargin < 3 || isempty(diff)
    diff = -1; % default: compute the value (not a derivative)
end

if nargin < 2
    stk_error('Too few input arguments.', 'TooFewInputArgs');
end

%% Check diff parameters
lnv = ml_nv.lognoisevar;
lev = ml_nv.levels;

nbLev = length(ml_nv.levels);
if nbLev ~= length(lnv)
    stk_error('There is a mistake in the multi-fidelity noise variance parameter.',...
        'InvalidArgument');
end

if diff ~= -1 && (diff < 1 || diff > nbLev)
    stk_error ('Incorrect value for the ''diff'' parameter.', ...
        'InvalidArgument');
end

%% Implement the noise variance... theoretically
xl = double( xi(:, size(xi, 2)) );    % column of levels


if isempty(calc) || ~isequal(calc.xl, xl) ||...
        ~isequal([calc.lnv; calc.lev], [lnv; lev])
    %% If no previous calculation
    ni = size(xi, 1);
    tolEps = 1e-6*range(lev);
    xind = zeros(ni, 1);    % index of levels
    for l = 1:nbLev
        ind = abs(xl(:, 1) - lev(l)) < tolEps;
        xind(ind, 1) = l;
    end

    lnv = [mean(lnv), lnv];
    
    %if diff = -1
    L = exp (lnv(xind + 1)');
    
    calc = struct('xl', xl,...
        'lnv', lnv(2:(nbLev + 1)),...
        'lev', lev,...
        'xind', xind,...
        'l', L);
    
    if diff > 0
        L = zeros(ni, 1);% 0 otherwise
        L(xind == diff) = exp(lnv(diff + 1));
        L(xind == 0)    = (1/nbLev)*exp(lnv(1));
    end
    
else
    %% else, return previous result
    if diff == -1
        L = calc.l;
    else
        L = zeros(size(calc.xind));
        L(calc.xind == diff) = exp(calc.lnv(diff));
        L(calc.xind == 0)    = (1/nbLev)*exp( mean(calc.lnv) );
    end
end

if ~pairwise
    L = diag(L);
end
end