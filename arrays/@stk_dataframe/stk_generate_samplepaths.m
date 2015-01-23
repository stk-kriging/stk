% STK_GENERATE_SAMPLEPATHS [overload STK]
%
% See also: stk_generate_samplepaths

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2011-2014 SUPELEC
%
%    Authors:  Julien Bect       <julien.bect@supelec.fr>
%              Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

if isa (model, 'stk_dataframe')
    stk_error (['The first input argument (model) should not be an ' ...
        'stk_dataframe object'], TypeMismatch');
end

switch nargin,
    
    case {0, 1},
        stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
        
    case 2,
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XT)
        xt = varargin{1};
        nb_paths = 1;
        conditional = false;
        
        zsim = stk_generate_samplepaths (model, double (xt));
        
    case 3,
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XT, NB_PATHS)
        xt = varargin{1};
        nb_paths = varargin{2};
        conditional = false;
        
        if isa (nb_paths, 'stk_dataframe')
            nb_paths = double (nb_paths);
            assert (isscalar (nb_paths));
        end
        
        zsim = stk_generate_samplepaths (model, double (xt), nb_paths);
        
    case 4,
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT)
        xi = varargin{1};
        zi = varargin{2};
        xt = varargin{3};
        nb_paths = 1;
        conditional = true;
        
        zsim = stk_generate_samplepaths (model, double (xi), ...
            double (zi), double (xt));
        
    case 5,
        % CALL: ZSIM = stk_generate_samplepaths (MODEL, XI, ZI, XT, NB_PATHS)
        xi = varargin{1};
        zi = varargin{2};
        xt = varargin{3};
        nb_paths = varargin{4};
        conditional = true;
        
        if isa (nb_paths, 'stk_dataframe')
            nb_paths = double (nb_paths);
            assert (isscalar (nb_paths));
        end
        
        zsim = stk_generate_samplepaths (model, double (xi), ...
            double (zi), double (xt), nb_paths);
        
    otherwise
        stk_error ('Too many input arguments.', 'TooManyInputArgs');
        
end

%--- stk_dataframe output -----------------------------------------------------

if isa (zsim, 'stk_dataframe')
    % This case happens when model.response_name exists and contains a
    % non-empty string.
    
    if conditional && (isa (zi, 'stk_dataframe')) ...
            && (~ isempty (zi.colnames)) ...
            && (~ strcmp (model.response_name, zi.colnames))
        % colnames are different: don't use any
        zsim.colnames = {};
    end
    
    try
        zsim.rownames = xt.rownames;
    catch
        zsim.rownames = {};
    end
    
else % model.response name does not exist or is empty
    
    try
        rownames = xt.rownames;
    catch
        rownames = {};
    end
    
    try
        response_name = zi.colnames{1};
        assert (numel (zi.colnames) == 1);
        assert ((~ isempty (response_name)) && (ischar (response_name)));
        if nb_paths == 1,
            colnames = {response_name};
        else
            colnames = arrayfun ( ...
                @(i)(sprintf ('%s_%d', response_name, i)), ...
                1:nb_paths, 'UniformOutput', false);
        end
    catch
        colnames = {};
    end
    
    zsim = stk_dataframe (zsim, colnames, rownames);
    
end

end % function stk_generate_samplepaths

%#ok<*CTCH>
