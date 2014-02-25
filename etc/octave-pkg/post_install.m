function post_install (desc)

  MOLE_DO_ADDPATH = false;
  MOLE_PRUNE_UNUSED = true;
  run (fullfile (desc.dir, "misc", "mole", "init.m"));

  movefile (fullfile (desc.dir, "PKG_ADD.m"), ...
	    fullfile (desc.dir, "PKG_ADD"));

  movefile (fullfile (desc.dir, "PKG_DEL.m"), ...
	    fullfile (desc.dir, "PKG_DEL"));

endfunction
