% STK_OPTIONS_GET returns the value of one or all STK options
%
% See also: stk_options_set

% Copyright Notice
%
%    Copyright (C) 2016, 2023 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

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

function argout = stk_options_get (varargin)

opts = stk_options_set ();

switch nargin

    case 0  % Nothing to do, just return the output
        argout = opts;

    case 1
        argout = opts.(varargin{1});

    case 2
        switch varargin{1}

            case 'stk_param_estim'
                if strcmp (varargin{2}, 'optim_display_level')
                    % TODO: Remove this error in STK 3.x
                    error (sprintf ([ ...
                        'Options stk_param_estim.optim_display_level has ' ...
                        'been removed.\n\nDisplay options for optimization ' ...
                        'algorithms can be set through the properties of ' ...
                        'the algorithm objects instead.\n']));
                else
                    argout = opts.stk_param_estim.(varargin{2});
                end

            otherwise
                argout = opts.(varargin{1}).(varargin{2});
        end

    otherwise
        stk_error ('Too many input arguments.', 'TooManyInputArgs');

end

end % function

%#ok<*SPWRN,*SPERR>
