% STK_TEST_CRITGRAD [STK internal]
%
% INTERNAL FUNCTION WARNING:
%    This function is considered as internal: API-breaking changes are
%    likely to happen in future releases.  Please don't rely on it.

% Copyright Notice
%
%    Copyright (C) 2021 CentraleSupelec
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

function ok = stk_test_critgrad (criterion, model, x, z, diff, delta0)

% Tolerances
TOL_CRIT_VAL = 1e-12;
TOL_CRIT_DERIV = 1e-5;
TOL_RSQUARED = 1e-4;

% Number evaluation points in the parameter space
q = 4;  grid_size = 2 * q + 1;

% Current vector of model parameters
v = stk_get_optimizable_model_parameters (model);

% Current value of the parameter of interest
p0 = v(diff);

% Evaluation grid
p = linspace (p0 - delta0, p0 + delta0, grid_size);

% Evaluate the criterion on the grid
crit_val = zeros (grid_size, 1);
for k = 1:grid_size
    v(diff) = p(k);
    m = stk_set_optimizable_model_parameters (model, v);
    if k == q + 1
        [crit_val(k), crit_deriv] = criterion (m, x, z);
    else
        crit_val(k) = criterion (m, x, z);
    end
end

% Regressors for a quadratic model
H1 = ones (2 * q + 1, 1);
H2 = (p - p0)';
H3 = (p - p0)' .^ 2;
H  = [H1 H2 H3];

% Ordinary least squares
beta = H \ crit_val;

% Root-mean-square error
mse = mean ((crit_val - H * beta) .^ 2);
rmse = sqrt (mse);

% Coefficient of determination
rsquared = 1 - mse / (mean ((crit_val - mean (crit_val)) .^ 2));

% Function values
crit_val1 = crit_val(q+1);
crit_val2 = beta(1);
crit_vald = crit_val1 - crit_val2;

% Relative error on function value
if crit_vald == 0
    crit_val_err = 0.0;
else
    crit_val_err = crit_vald / (max (abs (crit_val1), abs (crit_val2)));
end

% Relative error on the partial derivative
crit_deriv1 = crit_deriv(diff);
crit_deriv2 = beta(2);
crit_derivd = crit_deriv1 - crit_deriv2;

% Relative error on function value
if crit_derivd == 0
    crit_deriv_err = 0.0;
else
    crit_deriv_err = crit_derivd / (max (abs (crit_deriv1), abs (crit_deriv2)));
end

ok0 = rsquared > (1 - TOL_RSQUARED);
ok1 = (abs (crit_val_err) < TOL_CRIT_VAL);
ok2 = (abs (crit_deriv_err) < TOL_CRIT_DERIV);

if nargout == 0  % Display outputs
    
    pp = linspace (min (p), max (p), 50);
    ff = beta(1) + beta(2) * (pp - p0) + beta(3) * (pp - p0) .^ 2;
    
    figure;
    plot (p, crit_val, 'dk--');  hold on;
    plot (p0, crit_val(q + 1), 'ro', ...
        'MarkerFaceColor', 'y', 'MarkerSize', 10);
    plot (pp, ff, 'r--');
    stk_labels (sprintf ('param(%d)', diff), 'ALL');
    set (gcf, 'Name', sprintf ('Check %s gradient wrt #%d', ...
        func2str (criterion), diff));
    
    fprintf ('~~~ Checking gradient for parameter #%d of %s ~~~\n', ...
        diff, func2str (criterion));
    if stk_disp_isloose (),  fprintf ('|\n');  end
    
    % Function values
    fprintf ('| * function value:\n');
    fprintf ('|    o computed:        %+.6e\n', crit_val1);
    fprintf ('|    o regression:      %+.6e\n', crit_val2);
    fprintf ('|    o difference:      %+.6e\n', crit_vald);
    fprintf ('|    o relative error:  %+.6e  [TOL = %.1e, %s]\n', ...
        crit_val_err, TOL_CRIT_VAL, ok_str (ok1));
    if stk_disp_isloose (),  fprintf ('|\n');  end
    
    % Partial derivative
    fprintf ('| * partial derivative:\n');
    fprintf ('|    o computed:        %+.6e\n', crit_deriv1);
    fprintf ('|    o regression:      %+.6e\n', crit_deriv2);
    fprintf ('|    o difference:      %+.6e\n', crit_derivd);
    fprintf ('|    o relative error:  %+.6e  [TOL = %.1e, %s]\n', ...
        crit_deriv_err, TOL_CRIT_DERIV, ok_str (ok2));
    if stk_disp_isloose (),  fprintf ('|\n');  end
    
    % Numerical noise
    fprintf ('| * error (numerical noise or deviation from quadratic model ?)\n');
    fprintf ('|    o RMSE:           %.5e\n', rmse);
    fprintf ('|    o R^2:            %.5f  [TOL = %.1e, %s]\n', ...
        rsquared, TOL_RSQUARED, ok_str (ok0));
    
    if stk_disp_isloose ()
        fprintf ('|\n\n');
    end
    
else
    
    ok = ok1 & ok2;
    
end

end % function


function s = ok_str (b)

if b
    s = 'OK';
else
    s = 'NOT OK';
end

end
