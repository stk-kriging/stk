#!/bin/bash
ADMIN="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
BASEDIR=$(dirname $ADMIN)
SUBBASEDIR=$(dirname $BASEDIR)
VERSION=$(basename $BASEDIR)

echo "Making SVN export $VERSION in $SUBBASEDIR.."

cd  $SUBBASEDIR
svn export --force $VERSION stk-$VERSION

echo "Creating archive.."
rm -Rf stk-$VERSION/etc
rm -Rf stk-$VERSION/admin

tar czf stk-$VERSION.tar.gz stk-$VERSION
echo "stk-$VERSION.tar.gz created"
