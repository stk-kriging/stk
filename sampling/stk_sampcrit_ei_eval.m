% STK_SAMPCRIT_EI_EVAL ...

% Copyright Notice
%
%    Copyright (C) 2016, 2017 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function crit_val = stk_sampcrit_ei_eval (arg1, arg2, arg3)

if isa (arg2, 'stk_model_gpposterior')

    % The syntax
    %
    %    crit_val = stk_sampcrit_ei_eval (xt, M_post, goal)
    %
    % was introduced by mistake in STK 2.4.0 (without documentation).  It
    % will be removed from future releases.  We keep it for STK 2.4.x to
    % avoid breaking things in a minor release.
    
    if nargin > 3
        stk_error ('Too many input arguments.', 'TooManyInputArgs');
    end
    
    xt = arg1;
    M_post = arg2;
    
    if nargin < 3
        goal = 'minimize';
    else
        goal = arg3;
    end
    
    zi = M_post.output_data;  assert (size (zi, 2) == 1);
    zp = stk_predict (M_post, xt);
    
    zp_mean = zp.mean;
    zp_std = sqrt (zp.var);
    
elseif (isa (arg2, 'stk_dataframe')) ...
        && (isequal (arg2.colnames, {'mean', 'var'}))
    
    % The syntax
    %
    %    crit_val = stk_sampcrit_ei_eval (xt, zp, goal)
    %
    % was introduced by mistake in STK 2.4.0 (without documentation).  It
    % will be removed from future releases.  We keep it for STK 2.4.x to
    % avoid breaking things in a minor release.
    
    if nargin > 3
        stk_error ('Too many input arguments.', 'TooManyInputArgs');
    end
    
    % Remark: With this syntax, xt is ignored.  Beurk.
    zp = arg2;
    
    if nargin < 3
        goal = 'minimize';
    else
        goal = arg3;
    end
    
    zp_mean = zp.mean;
    zp_std = sqrt (zp.var);
    
    % TODO: warning !!!
    
    % WARNING: The threshold used here is *not* the usual one (maximum of the
    % posterior mean instead of maximum of the observations).
    zi = zp_mean;
    
else
    
    % The syntax
    %
    %    crit_val = stk_sampcrit_ei_eval (zp_mean, zp_std, zi)
    %
    % is the one that will be kept for future releases.
    
    if nargin > 4
        stk_error ('Too many input arguments.', 'TooManyInputArgs');
    end
    
    zp_mean = arg1;
    zp_std = arg2;
    zi = arg3;
    
    goal = 'minimize';
    
end

% Minimize or maximize?
switch goal
    case 'minimize'
        minimize = true;
        threshold = min (zi);
    case 'maximize'
        minimize = false;
        threshold = max (zi);
    otherwise
        stk_error (['Incorrect value for argument ''goal'': should be ' ...
            'either ''minimize'' or ''maximize''.'], 'InvalidArgument');
end

% Evaluate the sampling criterion
crit_val = stk_distrib_normal_ei (threshold, zp_mean, zp_std, minimize);

end % function


%!error crit_val = stk_sampcrit_ei_eval ()                % not enough args
%!error crit_val = stk_sampcrit_ei_eval (0)               % not enough args
%!error crit_val = stk_sampcrit_ei_eval (0, 0, 0, 0, 0)   % too many args

%%
% Compare various ways to compute the EI

%!shared xi, zi, M_prior, xt, zp, EIref, EI1, EI2, EI3
%! xi = [0; 0.2; 0.7; 0.9];
%! zi = [1; 0.9; 0.6; 0.1];
%! M_prior = stk_model('stk_materncov32_iso');
%! M_prior.param = log ([1.0; 2.1]);
%! xt = stk_sampling_regulargrid (20, 1, [0; 1]);
%! zp = stk_predict (M_prior, xi, zi, xt);
%! EIref = stk_distrib_normal_ei (min (zi), zp.mean, sqrt (zp.var), true);

%!test % Current syntax (STK 2.4.1 and later)
%! EI1 = stk_sampcrit_ei_eval (zp.mean, sqrt (zp.var), min (zi));

%!assert (isequal (EI1, EIref))

%!test % Deprecated syntax #1 (STK 2.4.0 only, never documented)
%! M_post = stk_model_gpposterior (M_prior, xi, zi);
%! EI2 = stk_sampcrit_ei_eval (xt, M_post);
%! EI2b = stk_sampcrit_ei_eval (xt, M_post, 'minimize');
%! assert (isequal (EI2, EI2b));  % 'minimize' is the default

%!assert (isequal (EI2, EIref))

%!test % Deprecated syntax #2 (STK 2.4.0 only, never documented)
%! EI3 = stk_sampcrit_ei_eval ([], zp);
%! EI3b = stk_sampcrit_ei_eval ([], zp, 'minimize');
%! assert (isequal (EI3, EI3b));  % 'minimize' is the default

%!assert (~ isequal (EI3, EIref)); % we *know* that result will be different !!!
