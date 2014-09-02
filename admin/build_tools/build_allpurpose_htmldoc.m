% BUILD_ALLPURPOSE_HTMLDOC

% Copyright Notice
%
%    Copyright (C) 2014 SUPELEC
%
%    Author:  Julien Bect  <julien.bect@supelec.fr>

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

function build_allpurpose_htmldoc ...
    (root_dir, build_dir, htmldoc_dir, version_number)

% Generate the documentation
generate_htmldoc (root_dir, build_dir, ...
    htmldoc_dir, version_number, 'allpurpose');

% Directories
htmldocparts_dir = fullfile (root_dir, 'admin', 'htmldoc');
css_dir = fullfile (htmldoc_dir, 'css');
image_dir = fullfile (htmldoc_dir, 'images');

% Provide style sheet
mkdir (css_dir);
copyfile (fullfile (htmldocparts_dir, 'stk.css'), ...
    fullfile (css_dir, 'stk.css'));

% Merge index.html and overview.html
merge_index_overview (htmldoc_dir);

% Copy the STK icon
mkdir (image_dir);
copyfile (fullfile (htmldocparts_dir, 'stk_logo.png'), ...
    fullfile (image_dir, 'stk_logo.png'));

end % function build_allpurpose_htmldoc


%--- merge_index_overview ------------------------------------------------------

function merge_index_overview (dir)

fn_index = fullfile (dir, 'index.html');
fn_overview = fullfile (dir, 'overview.html');

% Get package box from index.html

fid = fopen_ (fn_index, 'rt');
s = (char (fread (fid)))';
fclose (fid);

tmp = regexp (s, ...
  '<div class="package_box_contents">(?<content>.*?)</div>', 'names');

s_box = tmp(1).content;

% Modify overview.html

fid = fopen_ (fn_overview, 'rt');
s = char (fread (fid));
fclose (fid);

s = regexprep (s', "<h2.*?stk.*?</h2>\S*\n(\S*\n)?", ...
  ["<div class=\"package_box\">\n" s_box "</div>\n\n\n"]);

fid = fopen_ (fn_index, 'wt');
fprintf (fid, "%s", s);
fclose (fid);

delete (fn_overview);

end % function merge_index_overview
