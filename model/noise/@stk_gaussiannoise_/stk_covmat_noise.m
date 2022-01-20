% STK_COVMAT_NOISE [STK internal]

% Copyright Notice
%
%    Copyright (C) 2019 CentraleSupelec
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

function [K, P1, P2] = stk_covmat_noise (model, varargin)

if nargout <= 1
    
    K = stk_covmat (model, varargin{:});
    
elseif nargout == 2
    
    [K, P1] = stk_covmat (model, varargin{:});
    
else
    
    [K, P1, P2] = stk_covmat (model, varargin{:});
    
end

end % function

%#ok<*INUSD,*STOUT>
