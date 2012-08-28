function q = quantile(X, alpha)

n = size(X,1);
k = ceil(alpha*n);
X = sort(X);
q = X(k,:);