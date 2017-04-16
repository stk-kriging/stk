% STK_CONDITIONING [overload STK function]

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function zsimc = stk_conditioning (lambda, zi, zsim, xi_ind, noise_sim)

if nargin > 5,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

df_out = false;  % stk_dataframe output ?

% Read 'lambda' argument
if isa (lambda, 'stk_dataframe')
    lambda_ = lambda.data;
    rownames = lambda.colnames;
    df_out = true;
else
    lambda_ = lambda;
    rownames = {};
end

% Read 'zi' argument
if isa (zi, 'stk_dataframe')
    zi_ = zi.data;
else
    zi_ = zi;
end

% Read 'zsim' argument
if isa (zsim, 'stk_dataframe')
    zsim_ = zsim.data;
    colnames = zsim.colnames;
    if isempty (rownames),
        rownames = zsim.rownames;
    elseif ~ isequal (zsim.rownames, rownames)
        rownames = {};
    end
    df_out = true;
else
    zsim_ = zsim;
    colnames = {};
end

if nargin < 4,
    
    zsimc = stk_conditioning (lambda_, zi_, zsim_);
    
else % nargin >= 4
    
    % Read 'xi_ind' argument
    if isa (xi_ind, 'stk_dataframe')
        xi_ind_ = xi_ind.data;
    else
        xi_ind_ = xi_ind;
    end
    
    if nargin < 5,
        
        zsimc = stk_conditioning (lambda_, zi_, zsim_, xi_ind_);
        
    else % nargin >= 5
        
        % Read 'noise_sim' argument
        if isa (noise_sim, 'stk_dataframe'),
            noise_sim_ = noise_sim.data;
        else
            noise_sim_ = noise_sim;
        end
        
        zsimc = stk_conditioning (lambda_, zi_, zsim_, xi_ind_, noise_sim_);
    end
end

if df_out,
    zsimc = stk_dataframe (zsimc, colnames, rownames);
end

end % function
