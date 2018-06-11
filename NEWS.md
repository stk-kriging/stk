# Changes in version 2.5.1

## Bug fixes

* `stk_dominatedhv`: Workaround for Octave 4.4 issue
  ([ticket #89](https://sourceforge.net/p/kriging/tickets/89/))

## Miscellaneous

* Documentation fixes.

* `stk_option_set`: Return option struct only if `nargout > 0`.


# Changes in version 2.5.0

## Required Octave version

* Required Octave version number has been raised to 3.6.0.

## Sequential design of experiments

* `stk_sampcrit_akg_eval`: New function.  Computes the Approximate
  Knowledge Gradient (AKG) sampling criterion.

* `stk_example_doe05`: Example script that demonstrates the use of the AKG
  and EQI sampling criteria for noisy optimization.

* New (experimental) classes to represent sampling criterion objects:
  `stk_sampcrit_ei`, `stk_sampcrit_akg`, `stk_sampcrit_eqi`.

* `stk_sampcrit_ei_eval`: Remove deprecated calling forms.

## Design of experiments

* `stk_factorialdesign`: Accept one-variable `stk_dataframe` objects as
  factors and preserve column names in this case.

* `stk_sampling_nesteddesign`: New function to create nested designs.

* `stk_sampling_nestedlhs`: New function to create nested LHS (NLHS).

* `stk_sampling_sobol`: Fix help text.

## Validation of models

* `stk_distrib_normal_crps`: New function to compare observations and
  predictive (Gaussian) density.

* Calling `stk_predict_leaveoneout` with no output arguments now
  automatically creates two cross-validation diagnostics in two subplots:
  prediction VS observations (left panel) and normalized residuals (right
  panel).

* `stk_predict_leaveoneout` uses now the virtual LOO formula.

## `stk_dataframe` and related classes

* `stk_hrect`: Preserve column names for `stk_dataframe` inputs.

* `@stk_dataframe/find`: Overload base function to support calling find
  with an stk_dataframe as first input argument.

* `@stk_dataframe/plotmatrix`: Overload base function to enrich
  `plotmatrix` graphics with variable names when possible.

* Logical functions

   + Operations that normally return logical (`lt`, `eq`, `and`...) now
     return logical values for `stk_dataframe` arguments.

   + New overloaded functions for `stk_dataframe` objects: `isinf`,
     `isnan`, `isfinite`.

* Testing array membership

   + `@stk_dataframe/ismember`: No longer assumes `rows` flag for
     consistency with the base `ismember` function.

   + `stk_factorialdesign/ismember`: New function.  Tests membership
     for factorial designs much more efficiently than for plain arrays
     or data frames.

* `stk_generate_samplepaths` now returns a plain numerical array instead of
  a data frame.

## Miscellaneous

* `stk_plot_probdom2d`: New function to represent the uncertainty about a
  2D Pareto front.  This function is currently considered experimental and
  should not be expected to produce a reliable representation of the
  uncertainty for difficult or high-dimensional optimization problems.

* New test case: "truss3" (Koski, 1985; Das, 1997).

* Many functions have been optimized for speed.

* `stk_plot1d`: Handle the case where `xt` is not sorted.

* Support old-style STK structures (with a `.a` field) has been removed.

-----


# Changes in version 2.4.2

## Bug fixes

* Fix display problem of `stk_model_gpposterior` objects in Octave 4.2
  (ticket #73).


# Changes in version 2.4.1

## Bug fixes

* `stk_pmisclass`: Handle properly the case where `K22` is negative or
  null.

* `stk_get_optimizable_parameters`, `stk_get_optimizable_parameters`: Fix
  syntax errors.

* `stk_param_estim`: Issue a better error message when `LNV0` (the starting
  point for the estimation of the lognoisevariance parameter) is either
  `NaN` of infinite (ticket #72).

## Sampling criteria

* `stk_sampcrit_ei_eval`: The function now has a new syntax. The other
  syntaxes, introduced (accidentally) in STK 2.4.0, will remain supported
  in 2.4.x, but are deprecated and will be removed in a future release.

* Unlike the older `stk_distrib_normal_ei` function, `stk_sampcrit_ei_eval`
  is written for a *minimization* problem, following the usual convention
  in optimization software.

* From now on, it is recommended to use `stk_sampcrit_ei_eval` instead of
  `stk_distrib_normal_ei`.

* `stk_sampcrit_emmi_eval`: Now accepts for the input argument `ZI` a set
  of observations that contains dominated solutions (rows).  Dominated rows
  and duplicates are removed automatically, as in `stk_sampcrit_ehvi_eval`.

## Documentation

* `stk_pmisclass`, `stk_sampcrit_ei_eval`, `stk_sampcrit_ehvi_eval`: Help
  text has been added for all these functions.


# Changes in version 2.4.0

## Choosing the optimizer used in `stk_param_estim`

* The choice of the optimization algorithm used in `stk_param_estim` is now
  much more flexible, thanks to a new interface based on "optimizer object"
  classes.

* The following classes are currently available: `@stk_optim_octavesqp`,
  `@stk_optim_fmincon`, `@stk_optim_fminsearch`.

* `stk_optim_octavesqp` works both in Octave and in Matlab, with two
  possible choices for the QP solver: `qp` (available in Octave only, this
  is Octave's core `qp` function) and `quadprog` (available in Matlab from
  the Optimization toolbox or from MOSEK; should be available in Octave's
  optim package soon).

* Automatic detection of available optimizers.

* `stk_minimize_boxconstrained` (new function): Perform box-constrained
  minimization of a function.  This function is overloaded for each
  optimizer object class that supports box-constrained optimization.

* `stk_minimize_unconstrained` (new function): Perform unconstrained
  minimization of a function.  This function is overloaded for each
  optimizer object class that supports unconstrained optimization.

## Covariance functions

* It is now possible to specify default bounds for the estimation of the
  parameters in a user-defined covariance function. See the documentation
  of `stk_param_getdefaultbounds` for more information.

* Experimental/undocumented feature: it is possible to provide a
  specialized `stk_param_init` function for user-defined covariance
  functions.  Read `stk_param_init` if you need to do this.  (This feature
  might be removed or modified in future releases.)

* Radial basis functions (old and new):

   + `stk_rbf_matern`, `stk_rbf_matern32`, `stk_rbf_matern52` and
     `stk_rbf_gauss` (previously available internally as `stk_sf_*`
     functions).
   + New: `stk_rbf_exponential`, `st_rbf_spherical`.
   + Bugfix: `stk_rbf_matern32`, `stk_rbf_matern52` return 0 for very large
     `h`, where `stk_sf_matern32` and `stk_sf_matern52` returned NaN.

* New covariance functions

   + Exponential (aka Matérn 1/2): `stk_expcov_iso`, `stk_expcov_aniso`
   + Spherical: `stk_sphcov_iso`, `stk_sphcov_aniso`

## Linear models

* `model.lm` and linear model objects (`stk_lm_*` classes), introduced as
  an experimental feature in STK 2.2.0, are now the recommended way of
  setting the linear part of Gaussian process models.

* `model.order` is deprecated (but still supported).

* As an example, the following define a Gaussian process with a Matérn 5/2
  covariance function and a quadratic trend:

        model = stk_model ('stk_materncov52_aniso');
        model.lm = stk_lm_quadratic;

* `stk_lm_polynomial` (new function): Create a polynomial model of given
  degree, up to cubic models.

## `stk_model_gpposterior` objects

* A new `stk_model_gpposterior` class is introduced to represent a Gaussian
  process conditioned by observations (which is again Gaussian process).

* Internally, an `stk_model_gpposterior` object currently stores the QR
  factorization of the associated kriging matrix (other representations
  will be implemented in the future).

* `stk_predict` is overloaded for `stk_model_gpposterior` objects.

* `stk_model_update` (new function): Update a model with new observations.

## Space-filling designs

* `stk_sampling_sobol`: New function to generate points from a Sobol
  sequence using the algorithm of Bratley and Fox (1988), as modified by
  Joe and Kuo (2003).  The C implementation under the hood is due to Steven
  G. Johnson, and was borrowed from the NLopt toolbox (version 2.4.2).

## Sampling criterions for sequential designs

* `stk_sampcrit_ei_eval` (new function): Compute the expected improvement
  (EI) criterion for single-objective noiseless optimization.

* `stk_sampcrit_ehvi_eval` (new function): Compute the expect hyper-volume
  improvement (EHVI) criterion (Emmerich, Giannakoglou & Naujoks, 2006) for
  multi-objective noiseless optimization.  This function implements an
  exact computation of the EHVI criterion, using a decomposition of the
  dominated region into hyper-rectangles.

* `stk_sampcrit_emmi_eval` (new function): Compute the expected maximin
  improvement (EMMI) criterion for multi-objective noiseless optimization
  (Svenson & Santner, 2010).

## Miscellaneous

* `stk_pmisclass` (new function): Compute either the current probability of
  misclassification or the expectation of the future probability of
  misclassification, with respect to a given threshold.

* `stk_dominatedhv` (new function): Compute Pareto-dominated hypervolumes,
  which relies internally on the "Walking Fish Group" (WFG 1.10)
  algorithm. The function can also return the underlying
  inclusion-exclusion representation of the dominated region, i.e., its
  representation as a collection of signed overlapping hyper-rectangles.

* `stk_predict_leaveoneout`: New function that computes leave-one-out
  predictions and residuals.

* `stk_isnoisy` (new function): Returns false for a noiseless model and
  true otherwise.

## Graphics

* All STK functions related to graphics now accept a handle to existing
  axes as optional first input argument, and return a handle (or a vector
  of handles when appropriate) to the graphical object created by the
  function.

* STK is now compatible with Matlab >= R2014b, where handles to graphical
  objects are not numbers any more.

* `stk_plot1d`: A nice default legend can now be created painlessly using
  legend ('show'), and a struct of handles to the graphical objects
  composing the plot is returned to facilitate further customization. See,
  e.g., examples 1 and 2 in the "kriging basics" series.

* `stk_plot2d`: Removed (had been deprecated for a while).

* `stk_plot_predvsobs` (new function): Plot predictions against observations.

* `stk_plot_histnormres` (new function): Plot histogram of normalized
  residuals, together with the N(0, 1) pdf as a reference.

## Examples

* `stk_example_doe04`: Example script that demonstrates the use of
  `stk_pmisclass`.

* `stk_example_kb10`: Example script that demonstrates the use of
  leave-one-out cross-validation to produce goodness-of-fit graphical
  diagnostics.

* `stk_testfun_borehole` (new function): New test function (the "borehole
  model" response function, from Harper & Gupta 1983).

* `stk_testfun_twobumps` (new function): A simple 1D test function.

* `stk_dataset_twobumps` (new function): Define three datasets based on the
  TwoBumps test function.

## stk_dataframe class

* New overloaded functions for stk_dataframe objects: `acos`, `acosd`,
  `acosh`, `asin`, `asind`, `asinh`, `atan`, `atand`, `atanh`, `cos`,
  `cosd`, `cosh`, `exp`, `expm1`, `log`, `log10`, `log1p`, `log2`,
  `logical`, `sin`, `sind`, `sinh`, `sqrt`, `tan`, `tand`, `tanh`.

* `@stk_dataframe/bsxfun`: Now preserve row names if possible.

* `@stk_dataframe/openvar` (new function): Convert `stk_dataframe` object
  to table or double array before opening it the variable editor.

* `stk_dataframe` arrays now accept characters indices (row/column names)
  and cell array indices (list of row/column names).

* The `info` field is deprecated.

## Other minor changes

* `stk_plot_shadedci`: Delete invisible area object.

* `@stk_hrect/ismember`: Optimize for speed.

* `stk_predict`: In the case of discrete models, row input vectors are no
  longer accepted.

* `stk_runtests`: Now also available in the Octave package release, to
  provide a convenient wrapper around __run_test_suite__ ().

* `stk_maxabscorr`: No longer relies on corr ().

* `stk_kreq_qr`: Now has a default constructor, which allows to load saved
  `stk_kreq_qr` objects properly.

-----


# Changes in version 2.3.4

## Bug fixes

* `@stk_hrect/ismember`: Fix

   + a bug that prevented `ismember` from working on more than one point at
     a time, and
   + another bug in the case where `B` is not an `stk_hrect` object (it was
     incorrectly assumed to be an `stk_dataframe` in this case).

* `@stk_hrect/subsref`: Make sure that the returned value is still an
  `stk_hrect` object when the number of rows (which is two) is unchanged.

## Minor changes

* Add a `clean` target to the Octave package Makefile.

* Decrease unit test verbosity.


# Changes in version 2.3.3

## Bug fixes

* `stk_dist`, `stk_filldist`, `stk_gpquadform`, `stk_mindist`: Fix segmentation
  faults occurring with very large matrices (related to signed
  integer-based index computation in the underlying MEX-files).

* `stk_example_doe03`: Use the appropriate flag for maximization.

* `mole/matlab/file_in_path.m`: Fix two bugs (Matlab only)

## Minor changes

* `stk_example_doe03`: Display pointwise credible intervals in the upper
  panel.


# Changes in version 2.3.2

## Bug fixes

* `stk_param_estim`: Fix a bug related to parameter objects. More
  precisely, use `(:)` indexing systematically to access the vector of
  numerical parameters corresponding to a given parameter object.

* `@stk_kreq_qr/get`: Fix a call to `dot` to make it work when there is
  only one observation.

* Add missing field "Depends" to the `DESCRIPTION` file in the Octave
  package.

## Minor changes

* `stk_param_getdefaultbounds`: Return empty lower and upper bounds for
  parameter classes that do not implement the `stk_param_getdefaultbounds`
  (instead of calling `error`).

* Add optional field "Autoload" to the `DESCRIPTION` file in the Octave
  package.


# Changes in version 2.3.1

## Bug fixes

* `stk_optim_hasfmincon`: Detect `fmincon` by trying to use it, instead of
  relying on the result of the `exist` function (ticket #30 closed).

* `stk_param_estim`: Make sure that the bounds that we use for the `lnv`
  parameter contain the starting point `lnv0` when it is provided.

* `@stk_dataframe/set`: Fix `stk_error` calls (missing mnemonic).

* `stk_distrib_bivnorm_cdf`: Fix a bug in the case of mixtures of singular
  and non-singular cases.

* `@stk_dataframe/subsasgn`: Preserve column names when deleting rows, even
  if the resulting array is empty.

## Minor changes

* `stk_init`: Clear persistent variables. As a consequence, `stk_init` can
  now be used to restart STK completely.

* `stk_commonsize`: Accept empty dimensions, under the condition that all
  input arguments have the same empty dimensions (in which case the result
  is empty).

* `stk_commonsize`: is now faster when some arguments already have the
  proper size (unnecessary calls to `repmat` are avoided).

* `stk_distrib_normal_cdf`, `stk_distrib_bivnorm_cdf`: are now slightly
  faster (unnecessary calls to `stk_commonsize` are avoided).


# Changes in version 2.3.0

## Model structures

* `lognoisevariance` is now considered a mandatory field. For backward
  compatibility, a missing or empty lognoisevariance field is interpreted
  as `-inf`. A NaN value in the lognoisevariance field is now interpreted
  as meaning that the variance of the noise must be estimated.

* `model.param` is set to NaN by `stk_model`. This special value indicates
  that the parameters must be estimated from the data before any prediction
  can be done.

* Improved documentation for `stk_model`.

## Parameter estimation

* `stk_param_init` defaults to using the input value of
  `model.lognoisevariance` if it is not NaN, and estimating the variance if
  it is NaN. The meaning of the fifth argument, now called `DO_ESTIM_LNV`,
  has thus slightly changed: it is used to force or prevent the estimation
  of the variance of the noise, regardless of the value of
  `model.lognoisevariance`.

* `stk_param_init` also supports the heteroscedastic noisy case, but only
  when the variance of the noise is assumed to be known.

* `stk_param_init_lnv` is a new function that provides a rough estimate of
  the variance of the noise (in the spirit of `stk_param_init`).

* `stk_param_estim` estimates the variance of the noise if either

   + `param0lnv` is provided and is not empty (as in STK <= 2.2.0), or
   + `model.lognoisevariance` is NaN (new behaviour).

  If `param0lnv` is not provided, a starting point is obtained using the
  new `stk_param_init_lnv` function. In all cases (whether `lnv` is
  estimated or not) a meaningful value is returned for `lnv` (equal to
  `model.lognoisevariance` when `lnv` is not estimated).

* `stk_param_estim` can provide a value for `param0` when it is missing
  from the list of input arguments.

* `stk_param_relik`: Compute `G = W' * K * W` in such a way that the result
  is always (?) symmetric.

## Prediction

* `stk_predict` computes `lambda_mu` and `RS` only when necessary, depending on
  the number of output arguments.

## Covariance functions

* `stk_noisecov` now has a `pairwise` argument, like the others.

## Sampling

* `stk_sampling_randunif` accepts empty dim argument when `box` is provided

## Simulation of Gaussian process sample paths

* `stk_generate_samplepaths`: Do not add observation noise to the generated
  sample paths. This is consistent with `stk_predict`, which returns
  posterior variances for the unknown function, not for future noisy
  observations.

* `stk_conditioning`: Simulate sample paths conditioned on noisy
  observations when the additional `NOISE_SIM` argument is provided.

* `stk_generate_samplepaths`: Fix conditioning on noisy observations, which
  was not implemented properly until now.

* `stk_generate_samplepaths`: The output is an `stk_dataframe` object if
  either `MODEL.response_name` exists and is a non-empty string, or one of
  the input arguments (`XI`, `ZI`, `XT`) is an `stk_dataframe` object.

* `stk_conditioning`: The output is an `stk_dataframe` object if either
  `LAMBDA` or `ZSIM` is an `stk_dataframe` object.

## Objects representing sets

* `stk_hrect`: new class to describe hyper-rectangle objects.

* `stk_boundingbox`: constructs the bounding box for a set of points.

## Examples

* `stk_example_kb04` demonstrates how it is possible to estimate the
  variance of the noise without providing a initial guess for it.

* `stk_example_kb09` demonstrates how to simulate conditional sample paths
  in the case of noisy observations, both in the homoscedastic and in the
  heteroscedastic cases.

## Miscellaneous

* `stk_distrib_bivnorm_cdf` computes bivariate normal probabilities.

* `stk_disp_progress`: New function that displays a textual progress
  indicator.

* `stk_feval` handles cell-arrays of functions (ticket #19 closed),
  multivariate outputs (ticket #20 closed), and uses vectorized calls by
  default (unless a progress indicator is displayed).

* `sort`, `mtimes`, `uplus` and `uminus` are now overloaded for
  `stk_dataframe` objects

* `min`, `max` are now able to return a second output argument (index of
  mininizer or maximizer) for `stk_dataframe` arguments.

* Now the output of `stk_dataframe` is always an `stk_dataframe` object.
  Previously, this wasn't true if the first input argument was, e.g., an
  `stk_factorialdesign` object.

* `stk_distrib_normal_ei`, `stk_distrib_student_ei`: bugfix (the optional
  input argument "minimize" was not taken into account).

* `stk_distrib_normal_cdf`: Fix the zero-variance case.

-----


# Changes in version 2.2.1

## Octave 4.0 compliance

* Fix unit tests

## Octave package

* Do not ship `stk_test` and `stk_runtests` with the Octave package


# Changes in version 2.2.0

## Octave package

* The STK is now available both as an "all-purpose" Matlab/Octave toolbox
  (as usual) and as a full-fledged Octave package that can be installed
  using `pkg install`.

## Core

* `stk_model` now also accepts function handles for `covariance_type`.

* `stk_ortho_func` is deprecated and will be completely replaced, in the
  3.x series, by linear model objects. In the meantime, `stk_ortho_func`
  has been kept as a gateway to `stk_lm_*` functions and now supports the
  case of cubic polynomial models.

* `stk_cholcov`: new function that adaptively adds a little bit of noise on
  the diagonal of a covariance matrix to help `chol` succeed, when the
  first factorization returned by `chol` is not complete (a warning is
  emitted when doing so). Used in `stk_param_init`, `@stk_kreq_qr/get`,
  `stk_param_relik`...

* `@stk_kreq_qr`: heuristic improvement of numerical conditioning
  (implemented in the new private function `compute_P_scaling`).

## Covariance functions

* Accept `invRho = 0` in anisotropic covariance functions.

* `stk_sf_matern`: Handle special cases (3/2, 5/2, infinity) explicitly,
  and handle large values of the smoothness parameter `nu` better.

* Handle the case of Gaussian isotropic and anisotropic covariance
  functions in `stk_param_init` and `stk_param_getdefaultbounds`.

## Linear models

* Introduce linear models objects. Currently, the following linear model
  object classes are available: `stk_lm_null`, `stk_lm_constant`,
  `stk_lm_affine`, `stk_lm_quadratic`, `stk_lm_cubic` and `stk_lm_matrix`.

* Linear model objects are still considered an experimental feature. They
  can be accessed by setting `model.order` to NaN, in which case `model.lm`
  is expected to contain a linear model object.

* `stk_example_misc03`: New example script that demonstrates the use of
  linear model objects.

## Sample path simulation (`stk_generate_samplepaths`)

* The simulation of conditioned sample paths has been made easier (see
  ticket #3 on SF). This is demonstrated by `stk_example_kb08`.

* Now uses `model.response_name` (if available) to create column names for
  the output array, and `xt.rownames` (if available) to create row names.

* `stk_generate_samplepaths` can deal with replicated rows in `xt`.

## Parameter estimation

* `stk_param_estim`

   * Warn about constant-response data.
   * Return an additional `info` structure, which currently contains the
     criterion that has been used, the criterion value at the optimum, and
     the bounds.
   * Add a new (optional) input argument that will make it possible,
     in the future, to select which estimation criterion to use.

* `stk_param_relik`

   * Check symmetry of `G = W' * K * W` and apply a naive fix if it is not
     (emit a warning when doing so).
   * Improved implementation, which seems to reduce the number of warnings
     related to bad conditioning, and also improve the performance for
     large `n` (about 1000, say).

* New optimization options (can bet set through `stk_options_set`)

   * Add global options to control upper/lower bounds for `stk_param_estim`.
   * (Matlab) Add a `optim_display_level` option to control the verbosity
     `fmincon`/`fminsearch`. Its default value is `'off'`.

* `stk_param_gls`: new function that computes the GLS estimator.

## Array objects (`stk_dataframe`, `stk_factorialdesign`)

* `stk_length`: New function that returns the "length" of an array,
  currently defined as its number of rows.

* Improved display for both `stk_dataframe` and `stk_factorial` objects

* Fix and improve accessors (`subsasgn`, `subsref`, `set`, `get`,
  `fieldnames`)

* Minimalist support for linear indexing on `stk_dataframe` objects

* New overloaded methods: `@stk_dataframe/abs`, `@stk_dataframe/reshape`

* `@stk_dataframe/plot`: Full rewrite to improve compatibility with the
  base plot function. The case where `x` is an `stk_dataframe` objects with
  two or more columns is now handled in a way that is consistent with the
  base plot function (i.e., if `x` has two columns, then we get two 1D
  plots).

* `@stk_dataframe/horzcat`, `@stk_dataframe/vertcat`: Now the result is
  always an `stk_dataframe` object, and has row names iff either one of the
  two arguments doesn't have row names, or the row names of both arguments
  agree.

* `@stk_dataframe/bsxfun`: Modify the behaviour of `bsxfun` for
  `stk_dataframe` objects. The result is always an `stk_dataframe` object,
  and has column names iff either one of the two arguments doesn't have
  columns names or the columns names of both arguments agree.

## Graphics

* `stk_plot2d` is deprecated and will be removed in the 3.x series. Use
  `contour`, `mesh`, `surf`... directly instead (they are now overloaded
  for `stk_factorialdesign` objects).

* `stk_plot1d`: Improved flexibility in the way input arguments are
  handled.

* `stk_figure` does not set the axis title any more.

## Pareto domination

* `stk_isdominated`: New function that returns true for dominated rows.

* `stk_paretofind`: New function that finds non-dominated points.

* `stk_example_misc04`: New example script illustrating random Pareto fronts.

## Faster and less verbose startup

* Stop bothering users at startup with information that they can find in
  the `README` file anyway.

* Don't display selected optimizers at startup.

* In Matlab, don't bother checking if the PCT is installed.

## Documentation

* New HTML documentation, available in the "all-purpose" Matlab/Octave
  release (doc/html directory) and online on Source-Forge at
  <http://kriging.sourceforge.net/htmldoc>.

* Lots of fixes and improvements in help texts.

* Add a `CITATION` file, which explains how to cite STK in publications.

* `stk_testfun_braninhoo`: Fix domain bounds in the documentation.

## Miscellaneous

* Options set/get

   * `stk_options_set`: Add a reset feature.
   * `stk_options_set`: Prevent persistent from being cleared (bugfix)

* Remove `page_screen_output` (not needed anymore).

* Restore the `stk_` prefix for `distrib_*` functions (`distrib_normal_cdf`
  is renamed to `stk_distrib_normal_cdf`, `distrib_student_ei` to
  `stk_distrib_student_ei`, etc.)

* Lots of internal changes, minor changes, etc. not worth mentioning here.

-----


# Changes in version 2.1.1

## Bug fix

* Fix a bug in `stk_param_init`.

## Minor changes

* Add size checks to several functions.

* Warn Octave users about the problem with MEX-files in privates folders:
  Octave must be restarted when `stk_init` is run for the first time.


# Changes in version 2.1.0

## How to get help

* Several ways to get help, report bugs or ask for new features on
  Sourceforge are now proposed to the user (both in `README` or
  `stk_init.m`)

## Examples

* Existing examples have been improved: descriptions rewritten; graphical
  options controlled globally thanks to dedicated plotting functions
  (`stk_figure`; `stk_subplot`, `stk_axes`, `stk_title`...); + lots of
  minor changes

* New examples

   * kb06: ordinary kriging VS linear trend
   * kb07: simulations of Matérn sample paths with different various `nu`
   * doe03: one-dimensional Bayesian optimization (expected improvement)

## Covariance functions

* New function: `stk_gausscov_iso` (isotropic Gaussian covariance model)

* New function: `stk_gausscov_aniso` (anisotropic Gaussian covariance model)

## Special functions

* The precision of `stk_sf_matern` has been improved around 0 for high `nu`

* New function: `stk_sf_gausscorr` (Gaussian correlation function in 1D)

## Design of experiments

* New function: `stk_phipcrit` (phi_p criterion for space-filling designs)

* New function: `stk_maxabscorr` (maximal pairwise absolute correlation)

## Probability distributions

* A new 'probability distributions' module has been initiated (read
  `misc/distrib/README` to understand the reasons why)

* Currently provides: pdf, cdf and expected improvement (EI) for the
  Gaussian and Student t distributions

## Matlab/Octave compatibility

* Matlab/Octave compatibility throughout all supported releases has been
  strengthened, thanks to the creation of a Matlab/Octave Language
  Extension (MOLE) module

* octave_quantile removed; instead, a replacement for `quantile` is
  provided by the MOLE when needed.

* new function `graphicstoolkit`, providing a kind of replacement for
  `graphics_toolkit`, that also work in Matlab and old Octave releases

* ...

## Miscellaneous

* `stk_plot1dsim` has been removed (use `stk_plot1d` instead)

* plotting functions now work directly on the current axes

* An optional `box` argument has been added to `stk_sampling_halton_rr2`

* `stk_feval` now uses input row names for its output

## Bugfixes

* `@stk_kreq_qr/stk_update` is now (inefficient but) working

* `isequal` is now working for `stk_dataframe` and `stk_kreq_qr` objects in
  Octave 3.2.x (explicit overloading was required for these old releases)

* and many other tiny little things

-----


# Changes in version 2.0.3

## Bug fix

* Fix a bug `core/stk_predict.m` (related to blockwise computations)


# Changes in version 2.0.2

## Bug fixes

* Fix a bug in `@stk_dataframe/subsref` (handle colnames properly when
  ()-indexing is used to extract a subset of rows).

* Fix a bug in `@stk_dataframe/stk_dataframe` (make sure that `.data`
  contains numerical data) and add a copy constructor.


# Changes in version 2.0.1

## Bug fixes

* Fix a bug in `stk_predict` (don't compute the optional outputs `lambda`
  and `mu` when they are not requested by the caller).

* Fix a bug in `stk_sampling_olhs` (fail neatly when called with n = 2).


# Changes in version 2.0.0

## Required Octave version number

* Required Octave version number has been raised to 3.2.2.

## Important changes to the public API

* New R-like data structures: `@stk_dataframe`, `@stk_factorial_design`.

* The structures previously used everywhere in STK (with a `.a` field) are
  still supported but should be considered as deprecated (and will probably
  be completely removed in the next major release).

* As a result, `stk_predict` does not return a `.a`/`.v` structure any
  more. Instead, it returns an stk_dataframe object with two variables
  called `mean` and `var`.

* The function that computes (the opposite of the log of) the restricted
  likelihood is now called `stk_param_relik` instead of `stk_remlqrg`.

## Internal structure

* Many improvements in the internal structure of STK, for the sake of
  clarity (for those who happen to read the code) and efficiency:

* `@stk_kreq_qr`: new class for encapsulating basic computations related to
  a Gaussian process (kriging) model.

* The old `Kx_cache`/`Px_cache` mechanism, for working efficiently on
  finite spaces, has been replaced by a new covariance function:
  `stk_discretecov`.

* A new framework to encapsulate various approaches to parallel
  computations. Currently only supporting `'none'` or `'parfor'`
  (Mathworks' PCT toolbox parfor loops) engines, more to come later.

## Experimental support for parameter objects.

* `model.param` is now allowed to be an object from a user-defined
  class. This feature is experimental, and not really used currently in the
  toolbox.

* A new function `stk_param_getdefaultbounds` has appeared in `./param`,
  that was previously hidden in `stk_predict`. It can be overridden in the
  case where `model.param` is an object from a user-defined class.

## New sampling algorithms and related functions

* Fill-distance computation: exact (using Pronzato & Müller, Statistics &
  Computing, 2011) or approximate (using a space-filling reference set).

* Van Der Corput and Halton RR2-scrambled sequences (quasi-MC)

* NOLHS designs (Cioppa & Lucs, Technometrics, 2007)

## Miscellaneous

* `misc/options`: a new system for managing options

* `octave_quantile`: replacement for the missing `quantile` function in
  base Matlab (Mathworks' Statistics toolbox is not a requirement of STK).

* Add MEX-files for computing "Gibbs-Paciorek quadratic forms" to support
  future work on non-stationary covariance functions.

* `AUTHORS`: a list of maintainers and contributors can now be found at the
  root of the source tree.

* `stk_compile_all`: now recompiles MEX-files automatically if the source code
  has changed.

* Various new utility functions, tiny or not-so-tiny improvements,
  bugfixes here and there...

-----


# Changes in version 1.2

## `stk_predict`

* Now offers the possibility to compute the posterior covariance matrix (it
  is returned as a fourth optional argument).

* Has been modified to work with non-stationary covariance functions.

## Covariance functions

* Added a new `"pairwise"` option to all covariance functions and also to
  `stk_dist` (formerly `stk_distance_matrix`). This options allows to
  compute only the diagonal of the full distance/covariance matrix).

## Space-filling designs

* New function (`stk_filldist`) to compute the (discretized) fill distance.

* New function (`stk_sampling_olhs`) to generate Orthogonal Latin Hypercube
  (OLH) samples using the algorithm of Ye (1998).

## Parameter estimation

* New (experimental) function to choose automatically the starting point
  for a parameter estimation optimization procedure (`stk_param_init`).

## New functions to work with boxes

* `stk_rescale`,

* `stk_normalize`.

## More flexible representation of data

* Improved the flexibility most functions (`stk_predict`,
  `stk_param_estim`, ...), which are now accepting both matrices and "data
  structures" (with an `.a` field) as input arguments.

* New function: `stk_datastruct`

## Regular grids

* New function `stk_plot2d` that serves has a wrapper around
  {`surf`|`contour`|`mesh`|`pcolor`}-type functions, to plot data defined
  over a two-dimensional regular grid.

* `stk_sampling_regulargrid` now also returns 'ndgrid-style' coordinate
  matrices stored in new `.coord` field.

## Examples

* Reorganized the example folder and renamed all example scripts.

* New example (`stk_example_misc03`) to demonstrate the effect of adding a
  prior on the covariance parameters.

* Improved graphical outputs in `stk_example_kb03`.

* New test function: `stk_testfun_braninhoo` (Branin-Hoo).

## Miscellaneous

* Renamed `stk_distancematrix` to `stk_dist`.

* Various new utility functions: `stk_runexamples`, `stk_disp_framedtext`,
  `stk_disp_examplewelcome`, `stk_plot_shadedci`, `stk_octave_config`.

* Improved Octave-specific configuration.

* Lots of bugfixes and improvements.

-----


# Changes in version 1.1

* New special functions for the Matérn 3/2 and 5/2 correlation functions
  (`stk_sf_matern32`, `stk_sf_matern52`). New covariance functions
  (`stk_materncov32_iso`, `stk_materncov32_aniso`, ...).

* New MEX-file to compute the separation distance (`stk_mindist`).

* New function to generate random Latin Hypercube Samples
  (`stk_sampling_randomlhs`).  Renamed `stk_sampling_cartesiangrid` to
  `stk_sampling_regulargrid`, and changed the meaning of the first argument
  for consistency with other `stk_sampling_*` functions.

* Improved `stk_model` function. Now provides default parameters for several
  families of covariance functions.

* Renamed fields in model structures (`covariance_cache` to `Kx_cache` and `P0`
  to `Px_cache`). A new field `dim` has been added to the model structure.

* Changed the order of the arguments of the functions that use the
  structure `model`. Now, `model` is always the first argument.

* Changed `stk_param_estim` to make it possible to estimate noise variance.

* Fixed issues in `stk_param_estim` related to the definition of the search
  domain and the selection of (constrained/unconstrained) optimizer.

* Renamed `stk_conditionning` to `stk_conditioning`.

* New functions for a more flexible and efficient management of STK's
  configuration in `stk_init` (path, compilation of MEX-file, checking for
  optional packages, selection of the default optimizer, ...).

* New functions for unit testing, based on Octave's testing system
  (`stk_test`, `stk_runtests`). Tests have been added to most functions in
  the toolbox.

* Improved documentation & new examples.

* Improved argument checking and error messages.

* Improved compatibility with older versions of Octave and Matlab.

* Lots of minor changes and bug fixes.

* Complete reorganization of the code (better directory structure).
