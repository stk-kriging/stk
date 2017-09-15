% FAKE_NO_REP ...

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function [model, zi] = stk_fakenorep (model, zi)

if nargin > 2,
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
end

[n d] = size (zi);

lnv = model.lognoisevariance;

if d == 1  % Classical one-column representation of evaluation results
    
    % This makes things simpler: after a call to fake_no_rep, we *know* that
    % model.lognoisevariance is a vector of length size (zi, 1) in all cases
    if isscalar (lnv)
        model.lognoisevariance = repmat (lnv, n, 1);
    end
    
elseif d == 3  % Three-column representation of evaluation results
        
    if (isscalar (lnv)) && (lnv == -inf) && (~ all (zi.nb_obs == 1))
        
        stk_error (['Three-column representation of evaluations with ' ...
            'repetitions is not supported in the noiseless case.'], ...
            'IncompatibleArguments');
        
    elseif (any (isnan (lnv)))
        
        stk_error (['Three-column representation of evaluations with ' ...
            'repetitions is not supported yet when the variance of the ' ...
            'noise in unknown.'], 'IncompatibleArguments');
        
    else % This works in all remaining cases
        
        model.lognoisevariance = lnv - (log (zi.nb_obs));
        zi = zi.mean;
        
    end
    
else
    
    stk_error ('zi should have one or three columns', 'InvalidArgument');
    
end

% Safety net
assert (isequal (size (model.lognoisevariance), [n 1]));

end % function
