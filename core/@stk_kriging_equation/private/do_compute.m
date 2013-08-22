% DO_COMPUTE [STK internal function]

% Copyright Notice
%
%    Copyright (C) 2011-2013 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function kreq = do_compute (kreq)

if  ~ isempty (kreq.xi)

    %--- step #1: QR factorization of the kriging equation LHS -----------------
    
    if isempty (kreq.LS_Q)
        
        [Kii, Pi] = stk_make_matcov(kreq.model, kreq.xi);
        
        LS =                              ...
            [[ Kii, Pi                 ]; ...
            [  Pi', zeros(size(Pi, 2)) ]];
        
        % orthogonal-triangular decomposition
        [kreq.LS_Q, kreq.LS_R] = qr (LS);

    end
    
    %--- step #2: compute kriging weights --------------------------------------
    
    if (~ isempty (kreq.xt)) && (isempty (kreq.RS))
        
        % prepare the right-hand side of the kriging equation
        [Kti, Pt] = stk_make_matcov (kreq.model, kreq.xt, kreq.xi);
        kreq.RS = [Kti Pt]';
        
        % Solve the kriging equation to get the extended
        % kriging weights vector (weights + Lagrange multipliers)
        kreq.lambda_mu = linsolve (kreq, kreq.RS);
        
    end
    
end

end % function do_compute
