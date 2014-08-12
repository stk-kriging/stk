# Instructions for building the STK Octave package

## Creation of the tarball

The process of creating a tarball for Octave is currently handled by an Octave
function named `make_octave_package` and located in /admin.

Let's assume that STK's source tree is located at ~/source/stk. Then, the
following shell commands create the tarball:

	cd ~/source/stk
	octave --eval "cd admin; make_octave_package"

As a result, you should get in ~/source/stk/octave-build:

 * stk-X.Y.Z.tar.gz: ready to be installed using `pkg`,
 * stk: unpacked tarball, available for inspection,
 * test_package.m: test script, see below.

## Testing installation and documentation

The script `test_package` provided in the build directory allows to test that

 1. The generated tarball can actually be installed using `pkg`,
 2. The documentation that will be auto-generated for the Octave-Forge website
    is OK.

The script should be directly executable (if not, check file
permissions). Therefore, assuming that you're stll at the root of STK's source
tree, a simple

	octave-build/test_package.m

from the shell should get you through the whole process, ending with Firefox
opened on the auto-generated documentation, ready for inspection.
