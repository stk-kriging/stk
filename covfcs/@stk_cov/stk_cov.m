% Constructor
%   stk_cov
%
% Generic methods (it is usually not necessary to overload them)
%   get
%   set
%   subsasgn
%   subsref
%
% Default methods (it is usually recommended to overload them)
%   stk_get_defaultbounds
%
% Virtual methods (it is mandatory to overload them)
%   feval
%   stk_get_param
%   stk_set_param
%   stk_get_cparam
%   stk_set_cparam

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

function cov = stk_cov(arg1, varargin)

if nargin == 0, % default constructor
    
    cov = struct('name', 'NULL');
    cov = class(cov, 'stk_cov');
    
else
    
    switch class(arg1)
        
        case 'char'
            if strcmp(arg1, 'NULL')                
                cov = stk_cov(); % use default constructor
                return
            else
                try
                    h = str2func(arg1);
                catch
                    errmsg = sprintf('Failed to create a function handle for %s.', arg1);
                    stk_error(errmsg, 'InvalidArgument');
                end
            end
            
        case 'function_handle'
            h = arg1;
            
        otherwise
            stk_error('Invalid argument', 'InvalidArgument');
            
    end
    
    % now we have a function handle... is it a constructor for a derived class
    % or a direct handle to a covariance function ?
    try
        % pretend that it's a class constructor
        cov = h(varargin{:});
        assert(isa(cov, 'stk_cov'));
    catch
        % apparently not... let's try to build an object of class stk_generalcov
        cov = stk_generalcov(h, varargin{:});
    end
    
end

end % function stk_cov
