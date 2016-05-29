function [L, calc] = stk_noisecov (noiseparam, xi, diff, pairwise, calc)
% L = stk_noisecov (noiseparam, xi, diff, pairwise)
% [L, calc] = stk_noisecov (noiseparam, xi, diff, pairwise, calc)
%
% Compute the noise variance matrix, i.d. the exponential of the log-noise
% variance.
%
% - noiseparam : the noise variance parameter;
% - xi : a set of point, where noise must be evaluated;
% - diff : if -1, return the value of the noise variance.
% If diff >= 1, return the derivative of the noise variance parameter, by
% the diff-th parameter.
% L(noiseparam, xi, diff) = d( L(noiseparam, xi, -1) )/d( noiseparam(diff) )
% Default value : -1 (no derivative);
% - pairwise : a boolean, indicating if L must be a vector (pairwise =
% true), or a square matrix (pairwise = false).
% stk_noisecov (noiseparam, xi, diff, true) = diag( stk_noisecov
% (noiseparam, xi, diff, false) ).
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


warning('STK:stk_noisecov:weakImplementation',...
    'You should implement a function ''stk_noisecov'' for your own class.');

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
if diff ~= -1
    [~, ~, lenParam] = optimizable_fields(noiseparam);
    if diff < 1 || diff > lenParam
        stk_error ('Incorrect value for the ''diff'' parameter.', ...
            'InvalidArgument');
    end
end

%% Implement the noise variance... theoretically
stk_error(['You cannot use the default function ''stk_noisecov''.',...
    'Implement it for your own class.'], 'NoImplementation');

end

