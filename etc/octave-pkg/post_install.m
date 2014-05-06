function post_install (desc)

  root = desc.dir;
  config = fullfile (root, "config");
  
  addpath (config);
  stk_config_mole (root, false, true);
  rmpath (config);

  movefile (fullfile (root, "PKG_ADD.m"), ...
	    fullfile (root, "PKG_ADD"));

  movefile (fullfile (root, "PKG_DEL.m"), ...
	    fullfile (root, "PKG_DEL"));

endfunction
