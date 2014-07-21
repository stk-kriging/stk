function post_install (desc)

  root = desc.dir;
  config = fullfile (root, "config");

  # Prune unused functions from the MOLE
  addpath (config);
  stk_config_mole (root, false, true);
  rmpath (config);

  # PKG_ADD/PKG_DEL (see design notes below)
  movefile (fullfile (root, "PKG_ADD.m"), ...
	    fullfile (root, "PKG_ADD"));
  movefile (fullfile (root, "PKG_DEL.m"), ...
	    fullfile (root, "PKG_DEL"));

endfunction


# ~~~~~ DESIGN NOTES ~~~~~
# 
#   The following approaches didn't work:
#
#   1) PKG_ADD/PKG_DEL (without .m) at the package root
#
#      The files are copied to the arch-dependent directory,
#      which is not where we want them to be.
#
#   2) PKG_ADD/PKG_DEL (without .m) in ./inst
#
#      The files are not copied at all. Pity.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~
