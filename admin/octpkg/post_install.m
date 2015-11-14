# POST_INSTALL is run after the installation of the package

# Copyright Notice
#
#    Copyright (C) 2014 SUPELEC
#    Copyright (C) 2015 CentraleSupelec
#
#    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

# Copying Permission Statement
#
#    This file is part of
#
#            STK: a Small (Matlab/Octave) Toolbox for Kriging
#               (http://sourceforge.net/projects/kriging)
#
#    STK is free software: you can redistribute it and/or modify it under
#    the terms of the GNU General Public License as published by the Free
#    Software Foundation,  either version 3  of the License, or  (at your
#    option) any later version.
#
#    STK is distributed  in the hope that it will  be useful, but WITHOUT
#    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
#    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
#    License for more details.
#
#    You should  have received a copy  of the GNU  General Public License
#    along with STK.  If not, see <http://www.gnu.org/licenses/>.

function post_install (desc)

  here = pwd ();

  # Prune unused functions from the MOLE
  unwind_protect          
    cd (desc.dir);
    stk_init prune_mole
  unwind_protect_cleanup
    cd (here);
  end_unwind_protect

endfunction
