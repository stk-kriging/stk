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
 * ...
 
