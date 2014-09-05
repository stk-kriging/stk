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
copyfile (fullfile (htmldocparts_dir, '*.png'), image_dir);

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
    '<div class="package_box_contents">.*?</div>', 'match');
s_package_box = tmp{1};

% Reconstruct table

s_table = sprintf ("\
<table>\n\
<tr><td rowspan=\"2\" class=\"box_table\">\n\
<div class=\"package_box\">\n\
  <div class=\"package_box_header\"></div>\n\
  %s\n\
</div>\n\
</td>\n\
<td>\n\
  <div class=\"smallLinkBox\" id=\"DownloadBox\">\n\
  <table><tr>\n\
    <td class=\"icon\">\n\
      <img src=\"images/download.png\"/>\n\
    </td>\n\
    <td class=\"download_link\">\n\
      <a href=\"http://sourceforge.net/projects/kriging/files/stk/\" class=\"download_link\">\n\
      Download STK</a>\n\
    </td>\n\
  </tr></table>\n\
</div>\n\
</td></tr>\n\
<tr><td>\n\
<div class=\"smallLinkBox\" id=\"NewsBox\">\n\
  <table><tr>\n\
    <td class=\"icon\"><img src=\"images/news.png\"/></td>\n\
    <td><a href=\"NEWS.html\" class=\"news_file\">\n\
      What's new ?\n\
    </a></td>\n\
  </tr></table>\n\
</div>\n\
</td></tr>\n\
</table>", s_package_box);

% Modify overview.html

fid = fopen_ (fn_overview, 'rt');
s = (char (fread (fid)))';
fclose (fid);

s = regexprep (s, "<h2.*?stk.*?</h2>\S*\n(\S*\n)?", s_table);

fid = fopen_ (fn_index, 'wt');
fprintf (fid, "%s", s);
fclose (fid);

delete (fn_overview);

end % function merge_index_overview
