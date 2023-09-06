% STK_SIMULATE_NOISE simulates random draws of the observation noise
%
% CALL: Z = stk_simulate_noise (MODEL, X)
%
%    simulates one random draw of the observation noise in the MODEL at
%    observation points X.  The input argument X can be either a numerical
%    matrix or a dataframe.  The output Z has the same number of of rows as X.
%    More precisely, on a factor space of dimension DIM,
%
%     * X must have size NS x DIM,
%     * Z will have size NS x 1,
%
%    where NS is the number of simulation points.
%
% CALL: Z = stk_simulate_noise (MODEL, X, M)
%
%    generates M random draws at once.  In this case, the output argument Z has
%    size NS x M.
%
% FIXME: NOTE
%
%    Observation with reptitions / 'gather' mode / x can be iodata !
%
% See also: stk_generate_samplepaths

% Copyright Notice
%
%    Copyright (C) 2015, 2017, 2018, 2020 CentraleSupelec
%    Copyright (C) 2017 LNE
%
%    Authors:  Julien Bect  <julien.bect@centralesupelec.fr>
%              Remi Stroh   <remi.stroh@lne.fr>

% Copying Permission Statement
%
%    This file is part of
%
%            STK: a Small (Matlab/Octave) Toolbox for Kriging
%               (https://github.com/stk-kriging/stk/)
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

function noise_sim = stk_simulate_noise (model, x, nrep)

if nargin < 3
    nrep = 1;
end

m = stk_get_sample_size (x);

if ~ stk_isnoisy (model)  % Noiseless case
    
    noise_sim = zeros (m, nrep);
    
else  % Noisy case
    
    % Standard deviation of the observations
    s = sqrt (stk_covmat_noise (model, x, [], -1, true));
    
    % Simulate noise values
    s = reshape (s, m, 1);  % FIXME: Do we really need a reshape here?
    noise_sim = bsxfun (@times, s, randn (m, nrep));
    
end

end % function
