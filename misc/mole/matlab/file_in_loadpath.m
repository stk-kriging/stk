% FILE_IN_LOADPATH searches for a given filename in the the path.
%
% This functions is provided as a replacement for Octave's file_in_loadpath()
% function when using STK with Matlab.

% Copyright Notice
%
%    Copyright (C) 2018 CentraleSupelec
%    Copyright (C) 2012 SUPELEC
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

function name = file_in_loadpath(filename, flag)

if nargin < 2, flag = ''; end

searchpath = [pwd pathsep() path()];
name = file_in_path(searchpath, filename, flag);

if isempty(name),
    % maybe an absolute path ?
    fid = fopen(filename);
    if fid ~= -1,
        name = {filename};
        fclose(fid);
    end
end

end % function
