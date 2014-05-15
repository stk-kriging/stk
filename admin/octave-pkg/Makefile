all: \
 __stk_dist_pairwise__.mex \
 __get_column_number__.mex \
 __stk_dist_matrixy__.mex \
 __stk_filldist_discr_mex__.mex \
 __stk_gpquadform_matrixy__.mex \
 __stk_mindist_mex__.mex \
 __stk_dist_matrixx__.mex \
 __stk_dist_pairwise__.mex \
 __stk_gpquadform_matrixx__.mex \
 __stk_gpquadform_pairwise__.mex \
 __stk_sampling_vdc_rr2__.mex

__stk_sampling_vdc_rr2__.mex: primes.h

__%__.mex: %.c stk_mex.h
	mkoctfile --mex --output $@ $<

