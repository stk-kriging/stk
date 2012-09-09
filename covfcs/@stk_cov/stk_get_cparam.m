% Copyright Notice
%
%    Copyright (C) 2011, 2012 SUPELEC
%
%    Authors:   Julien Bect       <julien.bect@supelec.fr>
%               Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>
%
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

function t = stk_get_cparam(cov, varargin)

switch length(varargin)
    case 0,
        idx = [];
    case 1,
        idx = varargin{1};
    otherwise
        stk_error('Incorrect number of arguments', 'IncorrectNumberOfArgs');
end

F = cov.get_cparam;

if isempty(F), % no getter available, can we assume that cparam = param ?
    
    if isa(get(cov, 'param'), 'double'), % yes, we can
        t = stk_get_param(cov, idx);
    else
        errmsg = 'cparam does not exist for this covariance.';
        stk_error(errmsg, 'CParamMissing');
    end
    
else
    
    t = F(get(cov, 'param'), idx);
    % using get() instead of cov.param_ make derived classes easier to
    % write -> no need to overload stk_get_cparam
    
end % if

end % function stk_get_param
