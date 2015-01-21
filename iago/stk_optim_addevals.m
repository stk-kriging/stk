% STK_OPTIM_ADDEVALS add evaluations for optimization
%
% CALL: stk_optim_addevals()
%
% STK_OPTIM_INIT sets parameters of the optimization algorithm

% Copyright Notice
%
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:   Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function [xi, zi, algo_obj] = stk_optim_addevals(algo_obj, xi, zi, xinew)

switch algo_obj.noise
    case 'noisefree'
        zinew = stk_feval(algo_obj.f, xinew);
    case 'known'
        zinew_ = stk_feval(algo_obj.f, xinew);
        zinew  = zinew_(:, 1);
        xinew  = stk_ndf(xinew, zinew_.data(:, 2));
    case 'unknown'
        xinew = stk_ndf(xinew, algo_obj.noisevariance); % noisevariance will be estimated
        zinew = stk_feval(algo_obj.f, xinew);
end

if isempty(xi)
    xi = xinew;
    zi = zinew;
else
    xi = [xi; xinew];
    zi = [zi; zinew];
end

if ~strcmp(algo_obj.noise, 'noisefree')
    algo_obj.model.lognoisevariance = log(xi.noisevariance);
end

end %%END stk_optim_addevals
