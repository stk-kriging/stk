% STK_SET_OPTIMIZABLE_PARAMETERS [STK internal]
%
% INTERNAL FUNCTION WARNING:
%
%    This function is currently considered as internal.  STK users that wish to
%    experiment with parameter classes can already overload it, but should be
%    aware that API-breaking changes are likely to happen in future releases.
%
% See also: stk_set_optimizable_parameters

% Copyright Notice
%
%    Copyright (C) 2017, 2018 CentraleSupelec
%    Copyright (C) 2017 LNE
%
%    Authors:  Remi Stroh   <remi.stroh@lne.fr>
%              Julien Bect  <julien.bect@centralesupelec.fr>

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

function model = stk_set_optimizable_model_parameters (model, value, select)

% Just a quick check
if ~ (isstruct (model) && isfield (model, 'param'))
    stk_error (['The first input argument does not look like a ' ...
        'valid STK model structure.'], 'InvalidArgument');
end

% Covariance parameters
covparam = stk_get_optimizable_parameters (model.param);
covparam_size = length (covparam);

% Noise parameters
noiseparam = stk_get_optimizable_noise_parameters (model);
noiseparam_size = length (noiseparam);

total_size = covparam_size + noiseparam_size;

if nargin >= 3
    
    % 'select' must be a logical vector of appropriate length
    % FIXME: support other types of selectors (such as indices) ?
    if (~ islogical (select)) && (numel (select) ~= total_size)
        stk_error (['Argument ''select'' must be a logical vector whose length is ' ...
            'equal to the number of parameters.'], 'InvalidArgument');
    end
    
    % Split selector
    covparam_select = select(1:covparam_size);
    noiseparam_select = select(covparam_size + (1:noiseparam_size));
    
    % Recompute block sizes
    covparam_size = sum (covparam_select);
    noiseparam_size = sum (noiseparam_select);
    total_size = covparam_size + noiseparam_size;
    
end

% Check length of value
if numel (value) ~= total_size
    stk_error (['The length of ''value'' must be equal to ' ...
        'the number of parameters.'], 'IncorrectSize');
end
   
% Change covariance parameter
if covparam_size > 0
    covparam = value(1:covparam_size);
    if nargin < 3
        model.param = stk_set_optimizable_parameters ...
            (model.param, covparam);
    else
        model.param = stk_set_optimizable_parameters ...
            (model.param, covparam, covparam_select);
    end
end

% Change noise variance parameter
if noiseparam_size > 0
    noiseparam = value(covparam_size + (1:noiseparam_size));
    if nargin < 3
        model.lognoisevariance = stk_set_optimizable_parameters ...
            (model.lognoisevariance, noiseparam);
    else
        model.lognoisevariance = stk_set_optimizable_parameters ...
            (model.lognoisevariance, noiseparam, noiseparam_select);
    end
end

end % function
