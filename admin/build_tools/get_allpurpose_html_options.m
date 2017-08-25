% GET_ALLPURPOSE_HTML_OPTIONS

% Copyright Notice
%
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

function options = get_allpurpose_html_options ()

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

options.header = @ (opts, pars, vpars) sprintf ("\
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
 content=\"%s\"/>\n\
\n\
<meta name=\"author\"\n\
 content=\"Julien Bect and Emmanuel Vazquez\" />\n\
\n\
<meta name=\"description\"\n\
 content=\"Function reference for STK:\
 a Small (Matlab/Octave) Toolbox for Kriging.\" />\n\
\n\
<meta name=\"keywords\" lang=\"en\"\n\
 content=\"kriging, Gaussian processes, Matérn covariance,\
 design and analysis of computer experiments\" />\n\
\n\
<title>STK: a Small (Matlab/Octave) Toolbox for Kriging</title>\n\
\n\
<link rel=\"stylesheet\" type=\"text/css\" href=\"%scss/%s\" />\n\
\n\
</head>\n\
\n\
<body>\n\
\n\
<div class=\"header\">\n\
  <table><tr>\n\
    <td id=\"logo\">\n\
      <a class=\"linkToIndex\" href =\"%sindex.html\">\n\
        <img src=\"%simages/stk_logo.png\" alt=\"Octave logo\" />\n\
      </a>\n\
    </td>\n\
    <td id=\"title\">\n\
      <a class=\"linkToIndex\" href =\"%sindex.html\">\n\
        <b>STK</b>: a <b>S</b>mall (Matlab/Octave)\n\
        <b>T</b>oolbox for <b>K</b>riging\n\
      </a>\n\
    </td>\n\
  </tr></table>\n\
</div>\n\
\n\
<div id=\"doccontent\">\n", date (), vpars.pkgroot, opts.css, ...
vpars.root, vpars.pkgroot, vpars.pkgroot, vpars.pkgroot);

%%--- Footer -------------------------------------------------------------------

options.footer = ["</div>\n</body>\n</html>\n"];

end % function
