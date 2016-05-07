# Backward compatibility

This document gathers various notes about backward compatibility issues in STK.


## Missing lognoisevariance field

Starting with STK 2.3.0, the `lognoisevariance` field in model structure in
considered mandatory.

For backward compatiblity, all functions that explicitely manipulate this field
must consider that the model is noiseless (`lognoisevariance = -inf`) if the
`lognoisevariance` field is missing.
