% STK_POSTERIOR_MATCOV ...

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@supelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function Kpost = stk_posterior_matcov(kreq, idx1, idx2, pairwise)

if nargin < 4,
    pairwise = false;
end

xt1 = kreq.xt(idx1, :);

if ~isempty(idx2)
    xt2 = kreq.xt(idx2, :);
end

if isempty(idx2) % Compute K(xt1, xt1)
    
    % WARNING: this form adds the variance of the noise on the diagonal
    
    if pairwise    
        % Compute a vector of posterior variances
        % (this is the variance of future noisy observations)        
        Kpost = stk_make_matcov(kreq.model, xt1, [], true) ...
            - dot(kreq.lambda_mu, kreq.RS)';
    else
        % Compute a posterior covariance matrix
        K0 = stk_make_matcov(kreq.model, xt1, [], false);
        Ka = kreq.lambda_mu(:, idx1)' * kreq.RS(:, idx1);
        Kpost = K0 - .5 * (Ka + Ka');
    end
    
else % Compute K(xt1, xt2)
    
    % WARNING: this form does NOT add the variance of the noise even if xt1 and
    % xt2 are equal (or have some elements in common)

    K0 = stk_make_matcov(kreq.model, xt1, xt2, pairwise);

    if pairwise % Compute a vector of posterior covariances
        
        K1 = dot(kreq.lambda_mu(:, idx1), kreq.RS(:, idx2))';
        
        if ~isequal(idx1, idx2)
            K1 = .5 * (K1 + dot(kreq.lambda_mu(:, idx2), kreq.RS(:, idx1))');
        end       
        
    else % Compute a posterior covariance matrix
        
        K1 = kreq.lambda_mu(:, idx1)' * kreq.RS(:, idx2);
        
        if isequal(idx1, idx2)
            K1 = .5 * (K1 + K1');
        else
            K1 = .5 * (K1 + kreq.RS(:, idx1)' * kreq.lambda_mu(:, idx2));
        end

    end
    
    Kpost = K0 - K1;
    
end

end % function stk_posterior_matcov
