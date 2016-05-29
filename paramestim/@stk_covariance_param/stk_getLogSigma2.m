function logsigma2 = stk_getLogSigma2(covparam)
% logsigma2 = stk_getLogSigma2(covparam)
%
% This function should return a value of log(s^2), where s^2 is the
% variance at 0 of the covariance.
% If the covariance k is stationnary (k(x, y) = c(x -y)), then s^2 = c(0).
% Otherwise, s^2 is a kind of "mean value" of k(x, x).

if isfield(covparam, 'logsig2')
    logsigma2 = covparam.logsig2;
elseif isfield(covparam, 'sig2')
    logsigma2 = log(covparam.sig2);
else
    logsigma2 = 0;  %default value : sig2 = 1.0;
end

end

