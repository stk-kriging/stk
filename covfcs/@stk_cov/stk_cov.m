% classdef stk_cov
% properties
%    dim
%    param_
% methods
%    get_default_bounds
%    get_cparam
%    set_cparam
%    get_param
%    set_cparam

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

if mod(nargin, 2) ~= 1,
    stk_error('Incorrect number of arguments.', 'InvalidArguments');
end

opt = analyze_options(varargin{:});
if ~isfield(opt, 'dim'), opt.dim = 1; end

% initialize a structure with a "fun" field containing a function_handle
[cov, covname] = analyze_first_arg(arg1);

% set field "param"
if isfield(opt, 'param'),
    cov.param_ = opt.param;
else
    init_name = sprintf('%s_defaultparam', covname);
    try
        cov.param_ = feval(init_name, opt.dim);
    catch  %#ok<*CTCH>
        disp(lasterr()); %#ok<LERR>
        stk_error('Cannot initialize covariance parameters', 'CovInitFailed');
    end
end

% set function handles
cov = set_handle_(cov, opt, covname, 'get_default_bounds', '_defaultbounds');
cov = set_handle_(cov, opt, covname, 'get_cparam', '_getcparam');
cov = set_handle_(cov, opt, covname, 'get_param', '_getparam');
cov = set_handle_(cov, opt, covname, 'set_cparam', '_setcparam');
cov = set_handle_(cov, opt, covname, 'set_param', '_setparam');

cov = class(cov, 'stk_cov');

end % function stk_cov


function opt = analyze_options(varargin)

L = length(varargin) / 2;
opt = struct();

for i = 1:L,
    optname = varargin{1 + (i-1) * 2};
    if ischar(optname)
        opt.(optname) = varargin{2 + (i-1) * 2};
    else
        stk_error(['Incorrect list of parameter names/values ' ...
            'passed to stk_cov().'], 'InvalidArgument');
    end
end

end % function analyze_options


function [cov, covname] = analyze_first_arg(arg1)

switch class(arg1)
    
    case 'char'
        try
            cov.fun = str2func(arg1);
        catch
            errmsg = sprintf('Failed to create a function handle for %s.', arg1);
            stk_error(errmsg, 'InvalidArgument');
        end
        covname = arg1;
        
    case 'function_handle'
        cov.fun = arg1;
        covname = func2str(arg1);
        
    otherwise
        stk_error('Invalid argument', 'InvalidArgument');
        
end

cov.name = covname;

end % function analyze_first_arg


function cov = set_handle_(cov, opt, covname, propname, suffix)

if isfield(opt, propname)
    cov.(propname) = opt.(propname);
else
    fct_name = sprintf('%s%s', covname, suffix);
    if exist([fct_name '.m'], 'file')
        cov.(propname) = str2func(fct_name);
    else
        % not a big deal
        cov.(propname) = [];
    end
end

end