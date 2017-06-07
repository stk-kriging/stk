% GET  [STK internal]
%
% CALL: value = get (kreq, propname)
%
%    implements 'get' for stk_kreq_qr objects.

% Copyright Notice
%
%    Copyright (C) 2015, 2017 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Author:  Julien Bect       <julien.bect@centralesupelec.fr>
%             Emmanuel Vazquez  <emmanuel.vazquez@centralesupelec.fr>

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

function value = get (kreq, propname)

switch propname
    
    case {'n', 'r', 'P_scaling', 'LS_Q', 'LS_R', 'RS', 'lambda_mu'}
        value = kreq.(propname);
        
    case 'lambda'
        value = kreq.lambda_mu(1:kreq.n, :);
        
    case 'mu'
        value = kreq.lambda_mu((kreq.n + 1):end, :);
        
    case 'delta_var'
        value = dot (kreq.lambda_mu, kreq.RS, 1)';
        
    case 'log_abs_det_kriging_matrix'
        % LS_Q has +/- 1 determinant, so we only need to care about LS_R
        value = sum (log (abs (diag (kreq.LS_R))));
        
    case 'log_det_covariance_matrix_a'
        n = kreq.n;
        Q11 = kreq.LS_Q(1:n, 1:n);
        R11 = kreq.LS_R(1:n, 1:n);
        value = log (det (Q11 * R11)); % K = Q11 * R11
        % note: this method seems much less accurate than the others,
        %       we strongly recommend to avoid using it
        
    case 'log_det_covariance_matrix_b'
        n = kreq.n;
        Q11 = kreq.LS_Q(1:n, 1:n);
        R11 = kreq.LS_R(1:n, 1:n);
        Kchol = stk_cholcov (Q11 * R11); % K = Q11 * R11
        value = 2 * sum (log (diag (Kchol)));
        
    case 'log_det_covariance_matrix_c'
        % note: very efficient (but not the best) and quite simple to understand
        n = kreq.n;
        Q11 = kreq.LS_Q(1:n, 1:n);
        diag_R  = diag (kreq.LS_R);
        logdet1 = log (abs (det (Q11)));
        logdet2 = sum (log (abs (diag_R(1:n))));
        value = logdet1 + logdet2;
        
    case {'log_det_covariance_matrix', 'log_det_covariance_matrix_d'}
        % note: this is the fastest of all five solutions for large matrices
        %       (for small matrices, the difference is negligible)... but also
        %       the trickiest !
        n = kreq.n;
        QL = kreq.LS_Q((n + 1):end, :); % lowerpart of LS_Q
        diag_R = diag (kreq.LS_R);
        logdet1 = sum (log (abs (diag_R)));
        T = kreq.LS_R \ (QL');
        logdet2 = log (abs (det (T((n + 1):end, :))));
        value = logdet1 + logdet2;
        
    case 'log_det_covariance_matrix_e'
        % note: the most time consuming of all five solutions (blame qrdelete),
        %       we strongly recommend to avoid using it
        n = kreq.n;
        r = kreq.r;
        Q = kreq.LS_Q;
        R = kreq.LS_R;
        for i = 0:(r - 1)
            [Q, R] = qrdelete (Q, R, n + r - i, 'row');
            [Q, R] = qrdelete (Q, R, n + r - i, 'col');
        end
        value = sum (log (abs (diag (R))));
        
    otherwise
        error ('There is no property called ''%s''.', propname);
        
end % switch

end % function
