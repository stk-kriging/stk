# Contributing to STK

## Fork and pull request

In order to contribute to the STK project, please follow the standard
[GitHub flow](https://docs.github.com/en/get-started/quickstart/github-flow):

  1. fork the [STK repository](https://github.com/stk-kriging/stk),
  2. clone the forked repository,
  3. create a topic branch,
  4. make changes & push them to the topic branch,
  5. make a pull request (PR).

When creating the PR, please consider checking the "Allow edits from
maintainers" box, to allow STK maintainers to make changes directly to
your topic branch.

Thank you for taking the time to contribute! :+1:

## Requirements for acceptable contributions

In order to be acceptable, a contribution must:

1. follow as much as possible existing coding practices in the STK
   code base.  See also [admin/CODING_GUIDELINES](../admin/CODING_GUIDELINES).

2. pass all unit tests on recent versions of Matlab and Octave.  This
   is checked by the [Github actions](workflows/), which are run
   automatically for all pushes and pull requests.

3. document the changes exhaustively in the [ChangeLog](../ChangeLog)
   file and in the commit message.  For any non-trivial commit, the
   commit message is actually a copy (with minor reformatting) of the
   corresponding entry in the [ChangeLog](../ChangeLog).  See past
   commits for examples.
