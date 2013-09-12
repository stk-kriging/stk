% GET...

% Copyright Notice
%
%    Copyright (C) 2013 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function value = get (posterior, propname)

switch propname
    
    case 'log_abs_det_kriging_matrix'
        % LS_Q has +/- 1 determinant, so we only need to care about LS_R
        value = sum (log (abs (diag (posterior.LS_R))));
                 
    case 'log_det_covariance_matrix_a'
        n = size (posterior.xi, 1);
        Q11 = posterior.LS_Q(1:n, 1:n);
        R11 = posterior.LS_R(1:n, 1:n);
        value = log (det (Q11 * R11)); % K = Q11 * R11
        % note: this method seems much less accurate than the others,
        %       we strongly recommend to avoid using it
        
    case 'log_det_covariance_matrix_b'
        n = size (posterior.xi, 1);
        Q11 = posterior.LS_Q(1:n, 1:n);
        R11 = posterior.LS_R(1:n, 1:n);
        Kchol = chol (Q11 * R11); % K = Q11 * R11
        value = 2 * sum (log (diag (Kchol)));
        
    case 'log_det_covariance_matrix_c'
        % note: very efficient (but not the best) and quite simple to understand
        n = size(posterior.xi, 1);
        Q11 = posterior.LS_Q(1:n, 1:n);
        diag_R  = diag (posterior.LS_R);
        logdet1 = log (abs (det (Q11)));
        logdet2 = sum (log (abs (diag_R(1:n))));
        value = logdet1 + logdet2;
        
    case {'log_det_covariance_matrix', 'log_det_covariance_matrix_d'}
        % note: this is the fastest of all five solutions for large matrices
        %       (for small matrices, the difference is negligible)... but also
        %       the trickiest !
        n = size (posterior.xi, 1);
        QL = posterior.LS_Q((n + 1):end, :); % lowerpart of LS_Q
        diag_R = diag (posterior.LS_R);
        logdet1 = sum (log (abs (diag_R)));
        T = posterior.LS_R \ (QL');
        logdet2 = log (abs (det (T((n + 1):end, :))));
        value = logdet1 + logdet2;
        
    case 'log_det_covariance_matrix_e'
        % note: the most time consuming of all five solutions (blame qrdelete),
        %       we strongly recommend to avoid using it
        n = size (posterior.xi, 1);
        Q = posterior.LS_Q;
        R = posterior.LS_R;
        r = size (Q, 1) - n;
        for i = 0:(r - 1),
            [Q, R] = qrdelete (Q, R, n + r - i, 'row');
            [Q, R] = qrdelete (Q, R, n + r - i, 'col');
        end
        value = sum (log (abs (diag (R))));
        
    otherwise
        try
            value = posterior.(propname);
        catch
            error ('There is no property called ''%s''.', propname);
        end
        
end % switch

end % function get
