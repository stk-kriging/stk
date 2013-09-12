% STK_KRIGING_EQUATION...

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

function posterior = stk_posterior_model (model, xi, xt)

posterior = struct ( 'model',     model,  ...
    'xi',   [], 'xt',        [],     ...
    'LS_Q', [],  'LS_R',     [],     ...
    'RS',   [], 'lambda_mu', []      );

posterior = class (posterior, 'stk_posterior_model');

if nargin > 1,

    % this triggers a first set of partial computations...
    posterior = set (posterior, 'xi', xi);
    
    if nargin > 2,
        % ...and this triggers the remaining computation
        % (if xt is not provided, we end up with an incomplete kreq)
        posterior = set (posterior, 'xt', xt);
    end
    
end % if

end % function stk_kriging_equation
