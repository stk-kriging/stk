% STK_FUNCTION [experimental]
%
% EXPERIMENTAL CLASS WARNING:  This class is currently considered experimental.
%    STK users that wish to experiment with it are welcome to do so, but should
%    be aware that API-breaking changes are likely to happen in future releases.
%    We invite them to direct any questions, remarks or comments about this
%    experimental class to the STK mailing list.
%
% CALL: F = stk_function ()
%
%    creates a "pure" function object.  Pure function objects are useless by
%    themselves, and typically constructed as parent objects for derived
%    function object classes (e.g., sampling criterion objects).
%
% See also: stk_sampcrit_ei, stk_sampcrit_eqi

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

function F = stk_function ()

if nargin > 0
    
    % Catch syntax errors (Octave only)
    stk_error ('Too many input arguments.', 'TooManyInputArgs');
    
end % if

F = class (struct (), 'stk_function');

end % function


%!shared F

%!test F = stk_function ()  % ending ";" omitted on purpose, to test disp

%!error F = stk_function (1.234)  %  too many input arguments

%!error [F F];   % arrays of sampling criterion objects are not supported
%!error [F; F];  % idem

%!error get (F, 'toto');     % field does not exist
%!error y = feval (F, 1.0);  % not implemented for "pure" function objects

%!error dummy = F{2};        % illegal indexing
%!error dummy = F(1.0);      % feval not implemented
%!error dummy = F.toto;      % field does not exist

%!error F{2} = 1.234;        % illegal indexing
%!error F(5) = 1.234;        % illegal indexing
%!error F.toto = 1.234;      % field does not exist
