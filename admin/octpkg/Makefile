all: \
 __stk_dist_pairwise__.mex \
 __get_column_number__.mex \
 __stk_dist_matrixy__.mex \
 __stk_filldist_discr_mex__.mex \
 __stk_gpquadform_matrixy__.mex \
 __stk_isdominated_mex__.mex \
 __stk_mindist_mex__.mex \
 __stk_dist_matrixx__.mex \
 __stk_dist_pairwise__.mex \
 __stk_gpquadform_matrixx__.mex \
 __stk_gpquadform_pairwise__.mex \
 __stk_paretofind_mex__.mex \
 __stk_sampling_vdc_rr2__.mex \
 __stk_distrib_bivnorm0_cdf__.mex

__stk_sampling_vdc_rr2__.mex: primes.h

__stk_paretofind_mex__.mex: pareto.h
__stk_isdominated_mex__.mex: pareto.h

MKOCTFILE ?= mkoctfile

__%__.mex: %.c stk_mex.h
	$(MKOCTFILE) --mex --output $@ $<

.PHONY: clean

clean:
	rm -f *.o *.mex
