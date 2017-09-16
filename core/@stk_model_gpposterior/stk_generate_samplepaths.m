% STK_GENERATE_SAMPLEPATHS [overload STK function]

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
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

function zsim = stk_generate_samplepaths (model, varargin)
    
switch nargin
    
    case {0, 1}
        stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
        
    case 2
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XT)
        xt = varargin{1};
        nb_paths = 1;
        conditional = false;
        
    case 3
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XT, NB_PATHS)
        xt = varargin{1};
        nb_paths = varargin{2};
        conditional = false;
        
    case 4
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT)
        xi = varargin{1};
        zi = varargin{2};
        xt = varargin{3};
        nb_paths = 1;
        conditional = true;
        
    case 5
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT, NB_PATHS)
        xi = varargin{1};
        zi = varargin{2};
        xt = varargin{3};
        nb_paths = varargin{4};
        conditional = true;
        
    otherwise
        stk_error ('Too many input arguments.', 'TooManyInputArgs');
        
end

if ~ isa (model, 'stk_model_gpposterior')
    stk_error ('Syntax error.', 'SyntaxError');
end

if conditional
    model = stk_model_update (model, xi, zi);
end

xi = get_input_data (model);
zi = get_output_data (model);
model = get_prior_model (model);

zsim = stk_generate_samplepaths (model, xi, zi, xt, nb_paths);

end % function
