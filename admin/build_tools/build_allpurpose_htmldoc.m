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

function build_allpurpose_htmldoc (htmldoc_dir, htmldocparts_dir)

if (exist ('OCTAVE_VERSION', 'builtin') ~= 5)
    warning ('Cannot build forgedoc from Matlab.');
    return;
end

pkg load generate_html

options = struct ();

%--- Global options ------------------------------------------------------------

% Style sheet
options.css = "stk.css";

% Do not include alphabetical lists
options.include_alpha = false;

options.include_package_page = true;
options.include_overview = true;
options.include_package_license = true;
options.include_package_news = true;
options.include_demos = true;

%--- Header --------------------------------------------------------------------

hh = "\
<!DOCTYPE\
 html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n\
 \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n\
\n\
<html\
 xmlns=\"http://www.w3.org/1999/xhtml\"\
 lang=\"en\" xml:lang=\"en\">\n\
\n\
<head>\n\
\n\
<meta http-equiv=\"content-type\"\n\
 content=\"text/html; charset=utf-8\" />\n\
\n\
<meta name=\"date\"\n\
 content=\"%date\"/>\n\
\n\
<meta name=\"author\"\n\
 content=\"Julien Bect and Emmanuel Vazquez\" />\n\
\n\
<meta name=\"description\"\n\
 content=\"Function reference for STK:\
 a Small (Matlab/Octave) Toolbox for Kriging.\" />\n\
\n\
<meta name=\"keywords\" lang=\"en\"\n\
 content=\"kriging, Gaussian processes, Matérn covariance, \
 design and analysis of computer experiments\" />\n\
\n\
<title>STK: a Small (Matlab/Octave) Toolbox for Kriging</title>\n\
\n\
<link rel=\"stylesheet\" type=\"text/css\" href=\"%pkgrootcss/%css\" />\n\
<link rel=\"shortcut icon\" href=\"%rootfavicon.ico\" />\n\
\n\
</head>\n\
\n\
<body>\n\
\n\
<div class=\"header\">\n\
  <table><tr>\n\
    <td id=\"logo\">\n\
      <a class=\"linkToIndex\" href =\"%pkgrootindex.html\">\n\
        <img src=\"%pkgrootimages/stk_logo.png\" alt=\"Octave logo\" />\n\
      </a>\n\
    </td>\n\
    <td id=\"title\">\n\
      <a class=\"linkToIndex\" href =\"%pkgrootindex.html\">\n\
        <b>STK</b>: a <b>S</b>mall (Matlab/Octave)\n\
        <b>T</b>oolbox for <b>K</b>riging\n\
      </a>\n\
    </td>\n\
  </tr></table>\n\
</div>\n\
\n\
<div id=\"doccontent\">\n";

options.header = strrep (hh, "%date", date ());

%%--- Footer -------------------------------------------------------------------

options.footer = ["</div>\n</body>\n</html>\n"];

%--- Generate HTML doc ---------------------------------------------------------

[container_dir, dirname] = fileparts (htmldoc_dir);

generate_package_html ('stk', container_dir, options)
movefile (fullfile (container_dir, 'stk'), htmldoc_dir);

% Style sheet
css_dir = fullfile (htmldoc_dir, 'css');
mkdir (css_dir);
copyfile (fullfile (htmldocparts_dir, 'stk.css'), ...
    fullfile (css_dir, 'stk.css'));

% Merge index.html and overview.html
merge_index_overview (htmldoc_dir);

% Provide a nicely formatted GPLv3 licence
enhance_copying (htmldoc_dir, htmldocparts_dir);

% Copy the STK icon
image_dir = fullfile (htmldoc_dir, 'images');
mkdir (image_dir);
copyfile (fullfile (htmldocparts_dir, 'stk_logo.png'), ...
    fullfile (image_dir, 'stk_logo.png'));

end % function build_allpurpose_htmldoc


%--- merge_index_overview ------------------------------------------------------

function merge_index_overview (dir)

fn_index = fullfile (dir, 'index.html');
fn_overview = fullfile (dir, 'overview.html');

% Get package box from index.html

[fid, errmsg] = fopen (fn_index, "rt");
if fid == -1, error (errmsg); end
s = (char (fread (fid)))';
fclose (fid);

tmp = regexp (s, ...
  '<div class="package_box_contents">(?<content>.*?)</div>', 'names');

s_box = regexprep (tmp(1).content, 'Read license', 'GNU Public Licence v3');

% Modify overview.html

[fid, errmsg] = fopen (fn_overview, 'rt');
if fid == -1, error (errmsg); end
s = char (fread (fid));
fclose (fid);

s = regexprep (s', "<h2.*?stk.*?</h2>\S*\n(\S*\n)?", ...
  ["<div class=\"package_box\">\n" s_box "</div>\n\n\n"]);

[fid, errmsg] = fopen (fn_index, 'wt');
if fid == -1, error (errmsg); end
fprintf (fid, "%s", s);
fclose (fid);

delete (fn_overview);

end % function merge_index_overview


%--- enhance_copying -----------------------------------------------------------

function enhance_copying (htmldoc_dir, htmldocparts_dir)

% Get formatted GPLv3

[fid, errmsg] = fopen (fullfile (htmldocparts_dir, "GPLv3.html"), "rt");
if fid == -1, error (errmsg); end
s = (char (fread (fid)))';
fclose (fid);

tmp = regexp (s, ...
  '<body>(?<content>.*?)<p>END OF TERMS', 'names');

s_GPLv3 = tmp(1).content;

% Replace in COPYING.html

fn_copying = fullfile (htmldoc_dir, 'COPYING.html');

[fid, errmsg] = fopen (fn_copying, 'rt');
if fid == -1, error (errmsg); end
s = (char (fread (fid)))';
fclose (fid);

s = strrep (s, 'charset=iso-8859-1', 'charset=utf-8');
s = regexprep (s, '<pre>.*</pre>', ...
  ["<div id=\"GPLv3\">\n" s_GPLv3 "</div>\n"]);
s = regexprep (s, '<h2 class="tbdesc">.*?package</a></p>', '');

[fid, errmsg] = fopen (fn_copying, 'wt');
if fid == -1, error (errmsg); end
fprintf (fid, "%s", s);
fclose (fid);

end % function enhance_copying
