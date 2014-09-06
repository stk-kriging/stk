Assume, say, that we want to release STK version 4.5 (hum... not yet...).


## Preliminaries on the default branch

 * Check that only unix-style EOL characters are used and that only "standard"
   extended ASCII characters are used.
   
        ./admin/find_nonstandard_characters.sh
        ./admin/fix_eol.sh

 * Check that AUTHORS is up-to-date. Check copyright years on all files modified
   since the previous release.
 
 * Check that the NEWS file has been updated, and contains a clean description 
   of all changes since the previous release.


## Create release branch and build tarballs

 * Create release/maintenance branch

        hg branch 4.5.x

        # In stk_version.m, update version number to "4.5.0"
        # and modify copyright years if appropriate.

        hg commit -m "Create release branch 4.5.x"

 * Build tarballs
 
        octave --eval "cd admin; build all"
        
 * As a result, directory `./build` should contain the following files:
 
   * `stk-2.2-allpurpose.tar.gz`: "all purpose" (Matlab/Octave) release.
   * `allpurpose/stk/`: unpacked tarball, available for inspection.

   * `stk-2.2-octpkg.tar.gz`: "Octave package" release. This is a regular
     Octave package tarball, ready to be installed using `pkg`.
   * `octpkg/stk/`: unpacked tarball, available for inspection.
   
   * `stk-2.2-forgedoc.tar.gz`: Octave-Forge HTML documention.
   * `octpkg/stk/`: unpacked tarball, available for inspection.
   

## Check build outputs

 * Inspect HTML documentations
   * `build/allpurpose/stk/doc/html`: HTML doc for the "all purpose" release,
      that will also be uploaded to <http://kriging.sourceforge.net/htmldoc/>
   * `build/octpkg/html`: HTML doc for the Octave-Forge web site.
   
 * Run test suite
   * Check that all unit tests and all example scripts run on all available test
     platforms (Linux/Windows, Octave/Matlab...).
   * For Octave: don't forget to test both the "all purpose" release and the
     Octave package.
 
 * In case problems are found
   * Fix them on the default branch
   * Merge into the release/maintenance branch...
   * ...and go back to "Build tarballs" to create a new release candidate :)
 

## Release

 * Create a release tag
 
        hg update 4.5.x
        hg tag 4.5.0 -m "Tag release 4.5.0"
        
 * Update version number on default branch

        hg update default
                
        # In stk_version.m, update version number to "4.6-dev" (or "5.0-dev")
        # and modify copyright years if appropriate.
        hg commit -m "Update version number to 4.6-dev"

 * Release tarballs
   * Upload "allpurpose" and "octpkg" tarballs to Sourceforge's FRS.
       <http://sourceforge.net/projects/kriging/files/>
   * Upload a copy of the "allpurpose" HTML doc to 
       <http://kriging.sourceforge.net/htmldoc/>
   * Send the Octave package + Octave-Forge HTML doc to Octave-Forge maintainers
   

## Spread the news

 * Post a message to announce the release in the 'news' section on Sourceforge.
     <http://sourceforge.net/p/kriging/news/>

 * Send a message to the STK mailing list (kriging-help@lists.sourceforge.net)
 
 * What else ?

