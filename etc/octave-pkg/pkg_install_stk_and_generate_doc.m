#!octave

build_dir = fileparts (mfilename ('fullpath'));

pkg_list = pkg ('list');
pkg_names = cellfun (@(x)(x.name), pkg_list, 'UniformOutput', false);

if ismember ('stk', pkg_names)
   pkg uninstall stk;
end

pkg ('install', fullfile (build_dir, 'stk-XX.YY.ZZ.tar.gz'))

pkg load generate_html
generate_package_html ('stk', fullfile (build_dir, 'html'), 'octave-forge')

system (sprintf ('wget -P %s %s', fullfile (build_dir, 'html'), ...
   'http://octave.sourceforge.net/octave-forge.css'))

system (sprintf ('firefox %s/html/stk/index.html', build_dir))
