% GENERATE_HTMLDOC

% Copyright Notice
%
%    Copyright (C) 2015 CentraleSupelec
%    Copyright (C) 2014 SUPELEC
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

function success = generate_htmldoc ...
    (root_dir, htmldoc_dir, octpkg_tarball, flavour)

if (exist ('OCTAVE_VERSION', 'builtin') ~= 5)
    warning ('Cannot build forgedoc from Matlab.');
    success = false;
    return;
end

% Check that octpkg has been built
if (~ exist (octpkg_tarball, 'file'))
    error (sprintf ...
        ('%s does not exist: build octpkg first.', octpkg_tarball));
end

% Install package (even if it's already installed)
fprintf ('Installing %s (pkg install)...\n', octpkg_tarball);
pkg ('load', 'generate_html');
pkg ('install', octpkg_tarball);

% Options for generate_package_html
switch flavour
    case 'forgedoc'
        options = get_html_options ('octave-forge');
    case 'allpurpose'
        options = get_allpurpose_html_options ();
    otherwise
        error ('Unknown flavour');
end

% Generate HTML documentation
fprintf ('Generating HTML documentation for OF...\n');
pkg ('load', 'generate_html');
generate_package_html ('stk', htmldoc_dir, options);

% Enhance COPYING (license) file
htmldocparts_dir = fullfile (root_dir, 'admin', 'htmldoc');
enhance_copying (htmldoc_dir, htmldocparts_dir);

% Make a few changes to index.html
modify_index_html (htmldoc_dir);

success = true;

end % function


%--- enhance_copying -----------------------------------------------------------

function enhance_copying (htmldoc_dir, htmldocparts_dir)

% Get formatted GPLv3

fid = fopen_ (fullfile (htmldocparts_dir, 'GPLv3.html'), 'rt');
s = (char (fread (fid)))';
fclose (fid);

tmp = regexp (s, ...
  '<body>(?<content>.*?)<p>END OF TERMS', 'names');

s_GPLv3 = tmp(1).content;

% Replace in COPYING.html

fn_copying = fullfile (htmldoc_dir, 'stk', 'COPYING.html');

fid = fopen_ (fn_copying, 'rt');
s = (char (fread (fid)))';
fclose (fid);

s = regexprep (s, '<pre>.*</pre>', ...
  ["<div id=\"GPLv3\">\n" s_GPLv3 "</div>\n"]);
s = regexprep (s, '<h2 class="tbdesc">.*?package</a></p>', '');

fid = fopen_ (fn_copying, 'wt');
fprintf (fid, "%s", s);
fclose (fid);

end % function


%--- modify_index_html ----------------------------------------------------

function modify_index_html (htmldoc_dir)

fn_index = fullfile (htmldoc_dir, 'stk', 'index.html');

fid = fopen_ (fn_index, 'rt');
s = (char (fread (fid)))';
fclose (fid);

% Remove email addresses
s = regexprep (s, '&lt;.*?@.*?&gt;', '');

% Plural for authors and maintainers
s = regexprep (s, 'Package Author', 'Package Authors');
s = regexprep (s, 'Package Maintainer', 'Package Maintainers');

% Bold Letters in Description fieldnames
s = regexprep (s, 'Small Toolbox for Kriging', ...
    '<b>S</b>mall <b>T</b>oolbox for <b>K</b>riging');

% NEWS -> News
s = regexprep (s, '(\s+)NEWS', '$1News');

fid = fopen_ (fn_index, 'wt');
fprintf (fid, "%s", s);
fclose (fid);

end % function
