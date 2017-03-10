% ISEQUAL [overload base function]

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2013, 2014 SUPELEC
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

% INTERNAL NOTE: overloaded for Octave 3.2.x compat / see CODING_GUIDELINES

function b = isequal (x, y, varargin)

if nargin < 2
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
end

% First, make sure that x and y belong to the same class
% (either stk_dataframe or some derived class)
b = isa (x, 'stk_lm_constant') && strcmp (class (y), class (x));

if b && (nargin > 2)
    b = isequal (x, varargin{:});
end

end % function
