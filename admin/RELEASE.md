Assume, say, that we want to release STK version 4.5 (hum... not yet...).


## Preliminaries on the default branch

 * Check that only unix-style EOL characters are used and that only "standard"
   extended ASCII characters are used.
   
        ./admin/find_nonstandard_characters.sh
        ./admin/fix_eol.sh

 * Check that all mlock-ed files and all files containing persistent variables
   are listed in `config/stk_config_clearpersistents.m`.

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
 
        make clean  ## safer (our Makefile is far from perfect)
        make
        
 * As a result, directory `./build` should contain:
 
   * `sourceforge/stk-4.5.0-allpurpose.tar.gz`: "all purpose" (Matlab/Octave)
      release, to be uploaded in the SourceForge FRS.
   * `sourceforge/stk-4.5.0-octpkg.tar.gz`: Octave package, to be uploaded
      in the SourceForge FRS as well.

   * `sourceforge/stk/`: unpacked tarball corresponding to the "all purpose"
      release, available for inspection.

   * `octaveforge/stk-4.5.0.tar.gz`: "Octave package" release. This is a regular
     Octave package tarball, identical to the `stk-4.5.0-octpkg.tar.gz`, ready
     to be installed using `pkg`.
   * `octaveforge/stk-4.5.0-html.tar.gz`: Octave-Forge HTML documentation.
   * `octaveforge/stk-4.5.0.md5sum`: MD5 sums for the Octave package and its HTML
     documentation. All three files are ready to be upload on the OF package
     release tracker (http://sourceforge.net/p/octave/package-releases).

   * `octaveforge/stk/`: unpacked Octave package tarball, available for inspection.
   * `octaveforge/stk-html/`: unpacked HTML doc tarball (prefer the next one for
     visual inspection)
   * `octaveforge/stk-html-inspect/`: unpacked HTML doc tarball, together with some
     OF goodies (images, CSS stylesheet), ready for visual inspection.

## Check build outputs

 * Inspect HTML documentations
   * `sourceforge/stk/doc/html`: HTML doc for the "all purpose" release,
      that will also be uploaded to <http://kriging.sourceforge.net/htmldoc/>
   * `octaveforge/stk-html-inspect`: HTML doc for the Octave-Forge web site.
   
 * Run test suite
   * Check that all unit tests and all example scripts run on all available test
     platforms (Linux/Windows, Octave/Matlab...).
   * For Octave: don't forget to test both the "all purpose" release and the
     Octave package.
 
 * In case problems are found
   * Fix them on the release/maintenance branch
   * Graft them back to the default branch (if appropriate)
   * Go back to "Build tarballs" to create a new release candidate
 

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
   * Upload the Octave package, the HTML documentation and the MD5 sums to the OF
     package release tracker.

## Spread the news

 * Post a message to announce the release in the 'news' section on Sourceforge.
     <http://sourceforge.net/p/kriging/news/>

 * Send a message to the STK mailing list (kriging-help@lists.sourceforge.net)
 
 * What else ?

