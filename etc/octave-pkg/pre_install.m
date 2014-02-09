function pre_install (desc)

  ## compile all MEX-files
  pkg_dir = pwd;
  src_dir = fullfile (pkg_dir, "src");
  inst_dir = fullfile (pkg_dir, "inst");
  cd (inst_dir);
  stk_build (true, src_dir, inst_dir);
  
  ## copy AUTHORS and README to inst (this makes them available
  ## in the installation directory for future reference)
  cd (pkg_dir);
  copyfile (fullfile (pkg_dir, "AUTHORS"), inst_dir);
  copyfile (fullfile (pkg_dir, "README"), inst_dir);
  
endfunction


