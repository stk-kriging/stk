% VERTCAT [overload base function]

% Copyright Notice
%
%    Copyright (C) 2013, 2015 SUPELEC
%
%    Author: Emmanuel Vazquez  <emmanuel.vazquez@supelec.fr>

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

function z = vertcat (x, y, varargin)


%--- Get data -------------------------------------------------------------

x_df = x.stk_dataframe;
x_noisevariance = x.noisevariance;

if nargin < 2,
    y_df = stk_dataframe([]);
    y_noisevariance = [];
else
    assert(isa(y, 'stk_ndf'), 'STK:vertcat:IncompatibleObjects', ...
        'Error: trying to vertcat incompatible objects');
    y_df = y.stk_dataframe;
    y_noisevariance = y.noisevariance;
end

z_df = [x_df; y_df];
z_noisevariance = [x_noisevariance; y_noisevariance];

z = stk_ndf(z_df, z_noisevariance);
end % function vertcat

