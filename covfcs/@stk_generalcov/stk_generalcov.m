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

function cov = stk_generalcov(arg1, varargin)

if nargin == 0,
    arg1 = 'stk_materncov_aniso';
    opt = struct();
elseif mod(nargin, 2) ~= 1,
    stk_error('Incorrect number of arguments.', 'InvalidArguments');
else
    opt = analyze_options(varargin{:});
end

% initialize a structure with fields "fun" and "name"
[cov, covname] = analyze_first_arg(arg1);

% dimension of factor space
if ~isfield(opt, 'dim'), 
    dim = 1; 
else
    dim = opt.dim;
    opt = rmfield(opt, 'dim');
end
    
% set field "param"
if isfield(opt, 'param'),
    cov.prop.param = opt.param;
    opt = rmfield(opt, 'param');
else
    init_name = sprintf('%s_defaultparam', covname);
    try
        cov.prop.param = feval(init_name, dim);
    catch  %#ok<*CTCH>
        disp(lasterr()); %#ok<LERR>
        stk_error('Cannot initialize covariance parameters', 'CovInitFailed');
    end
end

% set function handles
[cov, opt] = set_handle_(cov, opt, covname, 'get_defaultbounds', '_defaultbounds');
[cov, opt] = set_handle_(cov, opt, covname, 'get_cparam', '_getcparam');
[cov, opt] = set_handle_(cov, opt, covname, 'get_param', '_getparam');
[cov, opt] = set_handle_(cov, opt, covname, 'set_cparam', '_setcparam');
[cov, opt] = set_handle_(cov, opt, covname, 'set_param', '_setparam');

% unused options ?
optnames = fieldnames(opt);
if ~isempty(optnames),
    for i = 1:length(optnames),
        warning('Unused option: %s.', optnames{i});
    end
end

cov = class(cov, 'stk_generalcov', stk_cov());
cov = set(cov, 'name', covname);

end % function stk_generalcov


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
            if strcmp(arg1, 'NULL')
                fun = [];
            else
                fun = str2func(arg1);
            end
        catch
            errmsg = sprintf('Failed to create a function handle for %s.', arg1);
            stk_error(errmsg, 'InvalidArgument');
        end
        covname = arg1;
        
    case 'function_handle'
        fun = arg1;
        covname = func2str(arg1);
        
    otherwise
        stk_error('Invalid argument', 'InvalidArgument');
        
end

handlers = struct('fun', fun);
cov = struct('prop', struct('name', [], 'handlers', handlers), 'aux', []);

end % function analyze_first_arg


function [cov, opt] = set_handle_(cov, opt, covname, propname, suffix)

h = cov.prop.handlers;

if isfield(opt, propname)
    h.(propname) = opt.(propname);
    opt = rmfield(opt, propname);
else
    fct_name = sprintf('%s%s', covname, suffix);
    if exist([fct_name '.m'], 'file')
        h.(propname) = str2func(fct_name);
    else
        % not a big deal
        h.(propname) = [];
    end
end

cov.prop.handlers = h;

end % function set_handle_
