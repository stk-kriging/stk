function pre_install (desc)

  pkg_dir = pwd;
  src_dir = fullfile (pkg_dir, "src");
  inst_dir = fullfile (pkg_dir, "inst");

  run (fullfile (inst_dir, 'misc', 'mole', 'PKG_ADD.m'));
  
  ## compile all MEX-files
  cd (inst_dir);  
  stk_build (true, src_dir, inst_dir);
  
  ## copy AUTHORS and README to inst (this makes them available
  ## in the installation directory for future reference)
  cd (pkg_dir);
  copyfile (fullfile (pkg_dir, "AUTHORS"), inst_dir);
  copyfile (fullfile (pkg_dir, "README"), inst_dir);

  run (fullfile (inst_dir, 'misc', 'mole', 'PKG_DEL.m'));

endfunction


