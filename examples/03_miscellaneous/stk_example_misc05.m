% STK_EXAMPLE_MISC05  Parameter estimation for heteroscedastic noise variance
%
% DESCRIPTION
%
%    We consider a 1d prediction problem with noisy data, where the variance of
%    the noise depends on the input location.
%
%    A simple heteroscedastic model is used, where the only parameter to be
%    estimated is a dispersion parameter (the square of a scale parameter).
%    More preciesely, the variance of the noise is assumed to be of the form
%
%       tau^2(x) = phi * (x + 1) ^ 2,
%
%    and the dispersion parameter phi is estimated together with the parameters
%    of the covariance function.
%
% EXPERIMENTAL FEATURE WARNING
%
%    This script demonstrates an experimental feature of STK (namely, gaussian
%    noise model objects).  STK users that wish to experiment with it are
%    welcome to do so, but should be aware that API-breaking changes are likely
%    to happen in future releases.  We invite them to direct any questions,
%    remarks or comments about this experimental feature to the STK mailing
%    list.
%
% See also: stk_example_kb09

% Copyright Notice
%
%    Copyright (C) 2018, 2023 CentraleSupelec
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

stk_disp_examplewelcome;  stk_figure ('stk_example_misc05');

% Load a 1D noisy dataset (heteroscedastic Gaussian noise)
[xi, zi, ref] = stk_dataset_twobumps ('noisy2');  xt = ref.xt;  zt = ref.zt;


%% Gaussian process model

model = stk_model (@stk_materncov52_iso);

% Variance of the heteroscedastic noise:  tau^2(x) = exp(param) * (x + 1) ^ 2
% (note that the true variance function for this dataset is not exactly of this form...)
model.lognoisevariance = stk_gaussiannoise_het0 (@(x) (x + 1) .^ 2, 1.0);

% NOTE: yes, it feels a little weird to store a "noise model" in a field
% called "lognoisevariance"... but please keep in mind that this is just an
% experimental feature of STK for now ;-)


%% Parameter estimation

% Currently stk_param_init does not support this noise variance model,
% and therefore we have to provide an explicit starting point for the
% estimation procedure
covparam0 = [0 0];
gn0 = stk_gaussiannoise_het0 (@(x) (x + 1) .^ 2, 1.0);

% ReML parameter estimation: here, we estimate jointly the parameters of the
% covariance function (log-variance, log-range) and the parameter of the
% variance function
model = stk_param_estim (model, xi, zi, covparam0, gn0);

% Display models
model,  gn = model.lognoisevariance


%% Prediction

zp = stk_predict (model, xi, zi, xt);

% Display the result
stk_plot1d (xi, zi, xt, zt, zp);
h = stk_legend ();  set (h, 'Location', 'NorthWest');
stk_title ('Prediction and credible intervals');
stk_labels ('input variable x', 'response z');


%#ok<*NOPTS>

%!test
%! stk_example_misc05;  close all;
%! assert (isa (model.lognoisevariance, 'stk_gaussiannoise_het0'));
