function pre_install (desc)

  pkg_dir = fileparts (mfilename ('fullpath'));
  src_dir = fullfile (pkg_dir, "src");
  inst_dir = fullfile (pkg_dir, "inst");

  run (fullfile (inst_dir, 'misc', 'mole', 'PKG_ADD.m'));
  
  ## compile all MEX-files
  cd (inst_dir);  
  stk_build (true, src_dir, inst_dir);
  
  run (fullfile (inst_dir, 'misc', 'mole', 'PKG_DEL.m'));

endfunction


