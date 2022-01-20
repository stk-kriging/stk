% STK_PREDICT_ [STK internal]
%
% See also: stk_predict

% Copyright Notice
%
%    Copyright (C) 2020 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function [zp, lambda, mu, K] = stk_predict_ (gn, xt)

nt = stk_get_sample_size (xt);

zp_mean = zeros (nt, 1);
zp_var = stk_variance_eval (gn, xt);
zp = stk_dataframe ([zp_mean zp_var], {'mean' 'var'});

if nargout > 1
    lambda = zeros (0, nt);
    
    if nargout > 2
        mu = zeros (0, nt);
        
        if nargout > 3
            K = diag (zp_var);
        end
    end
end

end % function
