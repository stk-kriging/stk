% COPY_README

% Copyright Notice
%
%    Copyright (C) 2017 CentraleSupelec
%    Copyright (C) 2014 SUPELEC
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

function copy_readme (src_filename, unpacked_dir, release_date)

fid = fopen_ (src_filename, 'rt');
s = (char (fread (fid)))';
fclose (fid);

s = strrep (s, 'See stk_version.m', ...
    sprintf ('%s (%s)', get_version_number (), release_date(1:10)));

fid = fopen_ (fullfile (unpacked_dir, 'README.md'), 'wt');
fwrite (fid, s);
fclose (fid);

end % function
