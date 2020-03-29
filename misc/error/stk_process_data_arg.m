% ...

% Copyright Notice
%
%    Copyright (C) 2020 CentraleSupelec
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

function [data, varargin] = stk_process_data_arg (nargin_extra, arg1, varargin)

if nargin < 2
    stk_error ('Not enough input arguments.', 'NotEnoughInputArgs');
end

if isa (arg1, 'stk_iodata')
    
    if nargin > 2 + nargin_extra
        stk_error ('Too many input arguments.', 'TooManyInputArgs');
    end
    
    data = arg1;
    
else
    
    if nargin > 3 + nargin_extra
        stk_error ('Too many input arguments.', 'TooManyInputArgs');
    end
    
    data = stk_iodata (arg1, varargin{1});
    varargin(1) = [];
    
end

n_missing = nargin_extra - length (varargin);
varargin = [varargin cell(1, n_missing)];
        
end % function
