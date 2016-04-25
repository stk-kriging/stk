function [K, calc] = stk_covariance(covparam, xi, yi, diff, pairwise, calc)
% K = stk_covariance(covparam, xi, yi, diff, pairwise)
% [K, calc] = stk_covariance(covparam, xi, yi, diff, pairwise, calc)
%
% Compute the covariance matrix.
%
% - covparam : the covariance parameter;
% - xi, yi : 2 sets of point, where covariance must be evaluated;
% - diff : if -1, return the value of the covariance.
% If diff >= 1, return the derivative of the covariance, by
% the diff-th parameter.
% L(covparam, xi, diff) = d( L(covparam, xi, -1) )/d( covparam(diff) )
% Default value : -1 (no derivative);
% - pairwise : a boolean, indicating if L must be a vector (pairwise =
% true), or a square matrix (pairwise = false).
% stk_covariance (noiseparam, xi, yi, diff, true) = diag( stk_covariance
% (noiseparam, xi, yi, diff, false) ).
% If pairwise is true, then xi and yi must have the same size.
% - calc : previous furnish by the function. Allow to compute faster the
% covariance.
%
% K is the value of the covariance (of its derivative, if diff >= 1).
% If pairwise is false, size(K) = [n, m], where n = size(xi, 1)
% and m = size(yi, 1). If pairwise is true, size(L) = [n, 1],
% where n = size(xi, 1) = size(yi, 1) (xi and yi must have the same size).
%
% calc is the intermediar calculation effected during the compution of the
% noise covariance. If provided during the next call, the computation will
% be faster.

warning('STK:stk_covariance:weakImplementation',...
    'You should implement a function ''stk_covariance'' for your own class.');

% Check number of inputs
if nargin > 6,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

% Default values
if nargin < 6 || isempty(calc)
    calc = [];  %no previous calculation
end

if nargin < 5 || isempty(pairwise)
    pairwise = false; % default: matrix
end

if nargin < 4 || isempty(diff)
    diff = -1; % default: compute the value (not a derivative)
end

% Check diff parameters
if diff ~= -1
    [~, ~, lenParam] = optimizable_fields(noiseparam);
    if diff < 1 || diff > lenParam
        stk_error ('Incorrect value for the ''diff'' parameter.', ...
            'InvalidArgument');
    end
end

% Check size
dim = size(xi, 2);
if size(yi, 2) ~= dim
    stk_error ('xi and yi have incompatible sizes.', 'InvalidArgument');
end

if pairwise
    if size(xi, 1) ~= size(yi, 1)
        stk_error ('xi and yi have incompatible sizes.', 'InvalidArgument');
    end
end

% Implement the noise variance... theoretically
stk_error(['You cannot use the default function ''stk_covariance''.',...
    'Implement it for your own class.'], 'NoImplementation');


end

