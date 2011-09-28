% STK_PARAM_ESTIM estimates the parameters of the covariance from data 
%
% CALL: paramopt = stk_param_estim( param0, xi, yi, model,...)
%
% STK_PARAM_ESTIM helper function to estimate the parameters of a 
% covariance from data using rectricted maximum likelihood
%
% FIXME: documentation incomplete
% 
% EXAMPLE: see examples/example02.m

%                  Small (Matlab/Octave) Toolbox for Kriging
%
% Copyright Notice
%
%    Copyright (C) 2011 SUPELEC
%    Version: 1.0
%    Authors: Julien Bect <julien.bect@supelec.fr>
%             Emmanuel Vazquez <emmanuel.vazquez@supelec.fr>
%    URL:     http://sourceforge.net/projects/kriging/
%
% Copying Permission Statement
%
%    This  file is  part  of  STK: a  Small  (Matlab/Octave) Toolbox  for
%    Kriging.
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
%
function paramopt = stk_param_estim( param0, xi, yi, model, varargin )

% TODO: put 'param0' in the list of optional arguments and provide a
% default value for it !

% parser = inputParser;
% parser.addOptional( 'bounds', {}, @(x)(iscell(x)) );
% parser.addOptional( 'opt_options', [], @(x)(isstruct(x)) );
% parser.parse( varargin{:} );

% if ~isempty( parser.Results.bounds ),
%     lb = parser.Results.bounds{1};
%     ub = parser.Results.bounds{2};    
% else
    [lb,ub] = get_default_bounds( param0, xi, yi, model );
% end

assert( isempty(lb) || isempty(ub) || all( lb < ub ) );

if stk_is_octave_in_use() == false,
    % if ismember( 'opt_options', parser.UsingDefaults )
    options = optimset( 'Display', 'iter', 'Algorithm', 'interior-point', ...
        'GradObj', 'on', 'MaxFunEvals', 300, 'TolFun', 1e-5, 'TolX', 1e-6 );
    % end
    % options = optimset( options, 'PlotFcn', @optimplotfval );
else
    % use default options for 'fminsearch' in Octave
    options = [];
end

% FIXME: il peut se produire que param0 ne soit pas entre lb et ub, ce qui
% produit un warning inesthetique !

if stk_is_fmincon_available()
    % Use fmincon() from Matlab's optimization toolbox if available
    f = @(param)(f_(xi,yi,model,param));
    paramopt = fmincon(f,param0,[],[],[],[],lb,ub,[],options);
elseif stk_is_octave_in_use()
    % Use sqp() from Octave
    f      = @(param)(f_      (xi,yi,model,param));
    nablaf = @(param)(nablaf_ (xi,yi,model,param));
    paramopt = sqp(param0,{f,nablaf},[],[],lb,ub,[],1e-5);  
else
    f = @(param)(f_(xi,yi,model,param));
    disp('Warning: falling back on fminsearch. Expect wrong results.')
    paramopt = fminsearch(f,param0,options);
end

% NESTED FUNCTIONS ARE NOT OCTAVE-COMPLIANT !
%     function [l, dl] = f(param)
%         model.param = param;
%         [l, dl] = stk_remlqrg(xi, yi, model);
%     end

end


function [l,dl] = f_(xi,yi,model,param)
model.param = param;
[l, dl] = stk_remlqrg(xi, yi, model);
end

function dl = nablaf_(xi,yi,model,param)
model.param = param;
[l, dl] = stk_remlqrg(xi, yi, model); %#ok<ASGLU>
end

function [lb,ub] = get_default_bounds( param0, xi, yi, model )

% constants
TOLVAR = 5.0;
TOLSCALE = 5.0;

% bounds for the variance parameter
empirical_variance = var(yi.a);
lbv = log(empirical_variance) - TOLVAR;
ubv = log(empirical_variance) + TOLVAR;

% FIXME: write an function stk_get_dim() to do this
dim = size( xi.a, 2 );

switch model.covariance_type,
    
    case {'stk_materncov_aniso', 'stk_materncov_iso'}
               
        lbnu = log(0.5);
        ubnu = log(4*dim);
        
        scale = param0(3:end);
        lba = scale(:) - TOLSCALE;
        uba = scale(:) + TOLSCALE;
        
        lb = [lbv; lbnu; lba];
        ub = [ubv; ubnu; uba];
                
    otherwise
        
        lb = [];
        ub = [];
        
end

end