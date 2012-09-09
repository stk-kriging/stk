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

function cov = stk_set_cparam(cov, varargin)

switch(length(varargin))
    case 1
        idx = [];
        val = varargin{1};
    case 2
        idx = varargin{1};
        val = varargin{2};
    otherwise
        stk_error('Incorrect number of arguments', 'IncorrectNumberOfArgs');
end

F = cov.set_cparam;

% if F is empty, it is assumed that cparam = param
% (i.e., param is an ordinary double-precision vector of parameter)

if isempty(F), % no setter available, can we assume that cparam = param ?
    
    if isa(get(cov, 'param'), 'double'), % yes, we can
        cov = stk_set_param(cov, idx, val);
    else
        errmsg = 'cparam does not exist for this covariance.';
        stk_error(errmsg, 'CParamMissing');
    end
       
else % user user-provided setter
    
    cov.param_ = F(cov.param_, idx, val);
    
end

end