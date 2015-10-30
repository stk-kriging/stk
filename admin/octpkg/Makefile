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
 __stk_distrib_bivnorm0_cdf__.mex \
 __stk_dominatedhv_mex__.mex

__%__.mex: stk_mex.h

__stk_sampling_vdc_rr2__.mex: primes.h
__stk_paretofind_mex__.mex: pareto.h
__stk_isdominated_mex__.mex: pareto.h
__stk_dominatedhv_mex__.mex: wfg.h

MKOCTFILE ?= mkoctfile

__%__.mex: %.c
	$(MKOCTFILE) --mex --output $@ $<

__stk_dominatedhv_mex__.mex: stk_dominatedhv_mex.c wfg.c
	$(MKOCTFILE) --mex --output $@ $< wfg.c
	
.PHONY: clean

clean:
        rm -f *.o *.mex
