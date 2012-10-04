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

if nargin == 0,
    arg1 = 'stk_nullcov';
    opt = struct();
elseif mod(nargin, 2) ~= 1,
    stk_error('Incorrect number of arguments.', 'InvalidArguments');
else
    opt = analyze_options(varargin{:});
end

% initialize a structure with fields "fun" and "name"
cov = analyze_first_arg(arg1);

% dimension of factor space
if ~isfield(opt, 'dim'), 
    dim = 1; 
else
    dim = opt.dim;
    opt = rmfield(opt, 'dim');
end
    
% set field "param"
if isfield(opt, 'param'),
    cov.param_ = opt.param;
    opt = rmfield(opt, 'param');
else
    init_name = sprintf('%s_defaultparam', cov.name);
    try
        cov.param_ = feval(init_name, dim);
    catch  %#ok<*CTCH>
        disp(lasterr()); %#ok<LERR>
        stk_error('Cannot initialize covariance parameters', 'CovInitFailed');
    end
end
    
% set function handles
[cov, opt] = set_handle_(cov, opt, cov.name, 'get_default_bounds', '_defaultbounds');
[cov, opt] = set_handle_(cov, opt, cov.name, 'get_cparam', '_getcparam');
[cov, opt] = set_handle_(cov, opt, cov.name, 'get_param', '_getparam');
[cov, opt] = set_handle_(cov, opt, cov.name, 'set_cparam', '_setcparam');
[cov, opt] = set_handle_(cov, opt, cov.name, 'set_param', '_setparam');

% unused options ?
optnames = fieldnames(opt);
if ~isempty(optnames),
    for i = 1:length(optnames),
        warning('Unused option: %s.', optnames{i});
    end
end

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


function cov = analyze_first_arg(arg1)

switch class(arg1)
    
    case 'char'
        try
            if strcmp(arg1, 'NULL')
                cov.fun = [];
            else
                cov.fun = str2func(arg1);
            end
        catch
            errmsg = sprintf('Failed to create a function handle for %s.', arg1);
            stk_error(errmsg, 'InvalidArgument');
        end
        cov.name = arg1;
        
    case 'function_handle'
        cov.fun = arg1;
        cov.name = func2str(arg1);
        
    otherwise
        stk_error('Invalid argument', 'InvalidArgument');
        
end

end % function analyze_first_arg


function [cov, opt] = set_handle_(cov, opt, covname, propname, suffix)

if isfield(opt, propname)
    cov.(propname) = opt.(propname);
    opt = rmfield(opt, propname);
else
    fct_name = sprintf('%s%s', covname, suffix);
    if exist([fct_name '.m'], 'file')
        cov.(propname) = str2func(fct_name);
    else
        % not a big deal
        cov.(propname) = [];
    end
end

end % function set_handle_
