% FILE_IN_PATH searches for a given filename in a list of directories.
%
% This functions is provided as a replacement for Octave's file_in_path()
% function when using STK with Matlab.

% Copyright Notice
%
%    Copyright (C) 2015, 2018 CentraleSupelec
%    Copyright (C) 2012 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@centralesupelec.fr>
%
%    This file is based on the Oct2mat package, version 1.0.7. The
%    following information was provided in the DESCRIPTION of the
%    package:
%
%        Name: Oct2Mat
%        Version: 1.0.7
%        Date: 2008-08-23
%        Author: Paul Kienzle
%        Maintainer: Alois Schloegl
%        Title: Oct2Mat
%        Description: convert m-file into matlab-compatible coding style
%        Categories: graphics
%        Depends: octave (>= 2.9.7), io (>= 1.0.0)
%        License: GPL version 2 or later
%        Url: http://octave.sf.net

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

function loc = file_in_path(dirlist, filename, flag)

if nargin < 3, flag = ''; end

if iscell(filename),
    for i = 1:numel(filename),
        loc = file_in_path_(dirlist, filename{i}, flag);
        if ~isempty(loc), break; end
    end
else
    loc = file_in_path_(dirlist, filename, flag);
end

end % function

%%%%%%%%%%%%%%%%%
% file_in_path_ %
%%%%%%%%%%%%%%%%%

function loc = file_in_path_(dirlist, filename, flag)

idx = [0, strfind(dirlist, pathsep), length(dirlist) + 1];
% note: using strtok() is more elegant... but much slower !

get_all = strcmp(flag, 'all');
loc = {};

for i = 1:length(idx) - 1,
    pos1 = idx(i) + 1;
    pos2 = idx(i+1) - 1;
    dirname = dirlist(pos1:pos2);
    fullfn = fullfile(dirname, filename);
    try
        % note: fopen (fullfn, 'r') is much faster than exist (fullfn, 'file')
        fid = fopen (fullfn, 'r');
    catch
        fid = -1;
    end
    if fid ~= -1,
        fclose(fid);
        if get_all,
            loc = [loc; {fullfn}]; %#ok<AGROW>
        else
            loc = fullfn; break
        end
    end
end

end % function
