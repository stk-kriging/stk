# Notes on design choices (temp)

### Observations: `xi`, `xinew`

 * they do not carry the value of the noise variance
 * the noise variance is in `algo.model.lognoisevariance`

### Homoscedastic / heteroscedastic

 * Homoscedastic case
    * `algo.noisevariance` is a scalar (`nan` means 'unknown')
    * `algo.model.lognoisevariance` is a scalar also
 * Heteroscedastic case
    * `algo.noisevariance` a vector of length size (algo.xg0, 1)
    * `algo.model.lognoisevariance` is a vector of length `ni`

### Noiseless/noisy

 * `noiseless` iff `isequal (algo.noisevariance, 0.0)`
 * no need for an additional flag

### To declare that the variance of the noise is unknown

 * homoscedastic case: set `algo.noisevariance` to `nan`
 * heteroscedastic case: NOT SUPPORTED YET

### Search grid

 * the search grid is *exactly* `algo.xg0`
 * the evaluation point are not necessarily in the search grid

### Gather repetitions: `options.gather_repetitions = true|false`

 * default: `true`
 * If true: after each evaluation, or batch of evaluations, gather
   evaluations corresponding to a common `xi(j, :)`. In this case, `zi`
   has three columns: `z_mean`, `z_var`, `nb_obs`
 * If false: nothing special. In this case, `zi` has one column unless
   `f` itself already returns batch results in three-column format.
