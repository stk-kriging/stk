function post_install (desc)

  root = desc.dir;
  config = fullfile (root, "config");

  # Prune unused functions from the MOLE
  addpath (config);
  stk_config_mole (root, false, true);
  rmpath (config);

endfunction
