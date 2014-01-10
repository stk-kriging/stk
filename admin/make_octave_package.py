#!/usr/bin/python

import os, re, shutil, datetime
from os.path import join, relpath, normpath, isdir, dirname, basename


def mkdir (d):
    
    d = os.path.abspath (d)
    
    if not os.path.isdir (d):
        d0 = dirname (d)
        if not os.path.isdir (d0):
            mkdir (d0)
        if not os.path.isdir (d):
            os.mkdir (d)


def make_octave_package (baseDir, buildDir):

    # FIXME: get versionNumber from README
    versionNumber = "4.8.1"    
    pkgName = "stk-" + versionNumber

    # Use baseDir as current directory
    # and work with relative paths from now on
    here = os.getcwd ();   os.chdir (baseDir)
    buildDir = relpath (buildDir, baseDir)
    
    # Directory that will contain the unpacked octave package
    pkgDir = join (buildDir, pkgName);  mkdir (pkgDir)
    
    # Standard directories in Octave's package structure
    instDir = join (pkgDir, "inst")
    srcDir = join (pkgDir, "src")
    
    # List of files or directories that must be ignored
    ignoreList = ("admin", "etc", "admin", "misc/mole/matlab", buildDir)
    
    # Prepare regular expressions
    regex_copy_inst = re.compile ("\.m$")
    regex_copy_src = re.compile ("\.[ch]$")
    regex_ignore = re.compile ("(~|\.(mexglx|mex|o|tmp))$")

    def copy_to_dir (f, dstDir):
        mkdir (dstDir)
        shutil.copy (f, dstDir)
                    
    def process_file (f):

        if f not in ignoreList:
            
            if re.search (regex_copy_inst, f):
                copy_to_dir (f, dirname (join (instDir, f)))

            elif re.search (regex_copy_src, f):
                copy_to_dir (f, dirname (join (srcDir, f)))
            
            # DESCRIPTION, COPYING, ChangeLog & NEWS will be available
            # in "packinfo" after installation
            elif f == "ChangeLog":
                shutil.copy (f, pkgDir)
            elif f == "LICENSE":
                shutil.copy (f, join (pkgDir, "COPYING"))
            elif f == "WHATSNEW":
                shutil.copy (f, join (pkgDir, "NEWS"))
            
            # README & AUTHORS: these two are placed at the root of the
            # package directory and will be moved to inst during install
            # (see pre_install.m)            
            elif f in ("README", "AUTHORS"):
                shutil.copy (f, pkgDir)
                
            # other README files: copy directly to inst
            elif basename (f) == "README":                
                copy_to_dir (f, dirname (join (instDir, f)))
                
            elif not re.search (regex_ignore, f):
                print "Ignoring file %s" % f

    def process_directory (r):
        if r not in ignoreList:
            for name in os.listdir (r):
                s = normpath (join (r, name))
                if isdir (s):
                    process_directory (s)
                else:
                    process_file (s)
                
    process_directory ('.')  # process STK directories recursively
    
    # add mandatory file : DESCRIPTION
    F = open (join (pkgDir, "DESCRIPTION"), "w")
    F.write ("Name: STK\n")
    F.write ("#\n")
    F.write ("Version: " + versionNumber + "\n")
    F.write ("#\n")
    F.write ("Date: " + str (datetime.date.today ()) + "\n")
    F.write ("#\n")
    F.write ("Title: STK: A Small Toolbox for Kriging\n")
    F.write ("#\n")
    F.write ("Author: Julien BECT <julien.bect@supelec.fr>,\n")
    F.write (" Emmanuel VAZQUEZ <emmanuel.vazquez@supelec.fr>\n")
    F.write (" and many others (see AUTHORS)\n")
    F.write ("#\n")
    F.write ("Maintainer: Julien BECT <julien.bect@supelec.fr>\n")
    F.write (" and Emmanuel VAZQUEZ <emmanuel.vazquez@supelec.fr>\n")
    F.write ("#\n")
    F.write ("Description: blah blah blah\n")
    F.write ("#\n")
    F.write ("Categories: Kriging\n")  # optional if an INDEX file is provided
    F.close ()
    
    # pre_install: a function that is run prior to the installation
    shutil.copy (join ("etc", "octave-pkg", "pre_install.m"), pkgDir)

    # PKG_ADD: commands that are run when the package is added to the path
    shutil.copy (join ("etc", "octave-pkg", "PKG_ADD.m"),
                 join (pkgDir, "PKG_ADD"))

    # PKG_DEL: commands that are run when the package is removed from the path
    shutil.copy (join ("etc", "octave-pkg", "PKG_DEL.m"),
                 join (pkgDir, "PKG_DEL"))
    
    import tarfile
    tgzName = pkgName + ".tar.gz"
    tar = tarfile.open (join (buildDir, tgzName), "w:gz")
    tar.add (pkgDir, arcname = pkgName)
    tar.close ()

    os.chdir (here)


baseDir = dirname (dirname (os.path.realpath (__file__)))
buildDir = join (baseDir, "octave-build")
make_octave_package (baseDir, buildDir)
