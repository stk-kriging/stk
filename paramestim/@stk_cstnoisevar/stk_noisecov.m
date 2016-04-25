function [L, calc] = stk_noisecov (cstnoisevar, xi, diff, pairwise, calc)
% L = stk_noisecov (cstnoisevar, xi, diff, pairwise)
% [L, calc] = stk_noisecov (cstnoisevar, xi, diff, pairwise, calc)
%
% Compute the noise variance matrix, i.d. the exponential of the log-noise
% variance.
% L = exp(cstnoisevar.lognoisevar)*size(xi)
%
% - cstnoisevar : the constant noise variance parameter;
% - xi : a set of point, where noise must be evaluated;
% - diff : if -1, return the value of the noise variance.
% If diff = 1, return the derivative of the noise variance parameter, by
% the parameter.
% L(cstnoisevar, xi, 1) = d( L(cstnoisevar, xi, -1) )/d(cstnoisevar)
% Default value : -1 (no derivative);
% - pairwise : a boolean, indicating if L must be a vector (pairwise =
% true), or a square matrix (pairwise = false).
% stk_noisecov (cstnoisevar, xi, diff, true) = diag( stk_noisecov
% (cstnoisevar, xi, diff, false) ).
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
if diff ~= -1 && diff ~= 1
    stk_error ('Incorrect value for the ''diff'' parameter.', ...
        'InvalidArgument');
end

%% Calculation of the noise variance
% Remark: the result does not depend on diff

lnv = cstnoisevar.lognoisevar;
ni = size(xi, 1);

if isempty(calc) || ~isequal([calc.ni; calc.lnv], [ni; lnv])
    %% If no previous calculation
    if pairwise
        if lnv == -inf
            L = zeros (ni, 1);
        else
            L = (exp (lnv)) * (ones (ni, 1));
        end
        l = L;
    else
        if lnv == -inf
            L = zeros (ni);
            l = zeros (ni, 1);
        else
            L = (exp (lnv)) * (eye (ni));
            l = (exp (lnv)) * (ones (ni, 1));
        end
        
    end
    calc = struct('ni', ni, 'lnv', lnv, 'l', l);
else
    %% else, return previous result
    if pairwise
        L = calc.l;
    else
        L = diag(calc.l);
    end
end

end

