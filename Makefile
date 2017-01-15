## Copyright Notice
##
##    Copyright (C) 2015, 2017 CentraleSupelec
##
##    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

## Copying Permission Statement
##
##    This file is part of
##
##            STK: a Small (Matlab/Octave) Toolbox for Kriging
##               (http://sourceforge.net/projects/kriging)
##
##    STK is free software: you can redistribute it and/or modify it under
##    the terms of the GNU General Public License as published by the Free
##    Software Foundation,  either version 3  of the License, or  (at your
##    option) any later version.
##
##    STK is distributed  in the hope that it will  be useful, but WITHOUT
##    ANY WARRANTY;  without even the implied  warranty of MERCHANTABILITY
##    or FITNESS  FOR A  PARTICULAR PURPOSE.  See  the GNU  General Public
##    License for more details.
##
##    You should  have received a copy  of the GNU  General Public License
##    along with STK.  If not, see <http://www.gnu.org/licenses/>.

VERNUM=$(shell cat stk_version.m | grep -o "v = '.*'" \
 | cut -d \' -f 2 | sed s/-dev/.0/)

.PHONY: all release \
  octaveforge-release octaveforge-package octaveforge-htmldoc \
  sourceforge-release sourceforge-allpurpose sourceforge-octpkg \
  forgedoc-inspect check_hg_clean clean

all: release forgedoc-inspect

release: octaveforge-release sourceforge-release

# "dist rule" expected by OF admins
# (build packages only, not OF html doc or forgedoc-inspect)
dist: octaveforge-package sourceforge-release


## Directories
BUILD_DIR=${CURDIR}/build
SF_DIR=${BUILD_DIR}/sourceforge
OF_DIR=${BUILD_DIR}/octaveforge

## Programs
OCT_EVAL=octave --no-gui --eval
OFWGET=wget --quiet http://octave.sourceforge.net

## File names for the OF release
OF_MD5SUM=${OF_DIR}/stk-${VERNUM}.md5sum
OF_OCTPKG_UNPACKED=${OF_DIR}/stk
OF_OCTPKG_TIMESTAMP=${OF_OCTPKG_UNPACKED}.dir.timestamp
OF_OCTPKG_TARBALL=${OF_DIR}/stk-${VERNUM}.tar.gz
OF_DOC_UNPACKED=${OF_DIR}/stk-html
OF_DOC_TIMESTAMP=${OF_DOC_UNPACKED}.dir.timestamp
OF_DOC_TARBALL=${OF_DIR}/stk-${VERNUM}-html.tar.gz
OF_DOC_INSPECT=${OF_DOC_UNPACKED}-inspect

## File names for the SF release
SF_ALLPURP_UNPACKED=${SF_DIR}/stk
SF_ALLPURP_TIMESTAMP=${SF_ALLPURP_UNPACKED}.dir.timestamp
SF_ALLPURP_TARBALL=${SF_DIR}/stk-${VERNUM}-allpurpose.tar.gz
SF_OCTPKG_TARBALL=${SF_DIR}/stk-${VERNUM}-octpkg.tar.gz

## Octave-Forge goodies
OFGOODIES=\
  ${OF_DOC_INSPECT}/octave-forge.css \
  ${OF_DOC_INSPECT}/download.png \
  ${OF_DOC_INSPECT}/doc.png \
  ${OF_DOC_INSPECT}/oct.png \
  ${OF_DOC_INSPECT}/news.png \
  ${OF_DOC_INSPECT}/homepage.png

# Extract date of hg changeset
HG_ID   := $(shell hg id --id | sed -e 's/+//')
HG_DATE := $(shell hg log --rev $(HG_ID) --template {date\|isodate})

# Follows the recommendations of https://reproducible-builds.org/docs/archives
REPRO_TAR = tar cf - --mtime="$(HG_DATE)" --sort=name --owner=root --group=root --numeric-owner


##### OCTPKG: Octave-Forge Release #####

octaveforge-release: ${OF_MD5SUM} \
 octaveforge-package octaveforge-htmldoc
	@echo
	ls -lh ${OF_DIR}
	@echo

octaveforge-package: ${OF_OCTPKG_TARBALL}

octaveforge-htmldoc: ${OF_DOC_TARBALL}

${OF_MD5SUM}: ${OF_OCTPKG_TARBALL} ${OF_DOC_TARBALL}
	md5sum ${OF_OCTPKG_TARBALL} > ${OF_MD5SUM}
	md5sum ${OF_DOC_TARBALL} >> ${OF_MD5SUM}

${OF_OCTPKG_TARBALL}: ${OF_OCTPKG_TIMESTAMP} | ${OF_DIR}
	@echo
	@echo Create octpkg tarball: $@
	$(REPRO_TAR) -C ${OF_DIR} $(notdir ${OF_OCTPKG_UNPACKED}) | gzip -9n > "$@"
	@echo

${OF_OCTPKG_TIMESTAMP}: | ${OF_DIR} check_hg_clean
	${OCT_EVAL} "cd admin; build octpkg ${OF_DIR}"
	touch ${OF_OCTPKG_TIMESTAMP}

# Create tar.gz archive (this should create a tarball
#    with the expected structure, according to
#    http://octave.sourceforge.net/developers.html)
${OF_DOC_TARBALL}: ${OF_DOC_TIMESTAMP}
	@echo
	@echo Create forgefoc tarball: $@
	$(REPRO_TAR) -C ${OF_DIR} $(notdir ${OF_DOC_UNPACKED}) | gzip -9n > "$@"
	@echo

${OF_DOC_TIMESTAMP}: ${OF_OCTPKG_TARBALL} | ${OF_DIR} check_hg_clean
	${OCT_EVAL} "cd admin; build forgedoc ${OF_DOC_UNPACKED} ${OF_OCTPKG_TARBALL}"
	touch ${OF_DOC_TIMESTAMP}

${OF_DIR}:
	mkdir -p ${OF_DIR}


##### ALLPURP: SourceForge Matlab/Octave Release #####

sourceforge-release: sourceforge-allpurpose sourceforge-octpkg
	@echo
	ls -lh ${SF_DIR}
	@echo

sourceforge-allpurpose: ${SF_ALLPURP_TARBALL}

sourceforge-octpkg: ${SF_OCTPKG_TARBALL}

${SF_ALLPURP_TARBALL}: ${SF_ALLPURP_TIMESTAMP} | ${SF_DIR}
	@echo
	@echo Create all-purpose tarball: $@
	$(REPRO_TAR) -C ${SF_DIR} $(notdir ${SF_ALLPURP_UNPACKED}) | gzip -9n > "$@"

${SF_ALLPURP_TIMESTAMP}: ${SF_OCTPKG_TARBALL} | ${SF_DIR} check_hg_clean
	${OCT_EVAL} "cd admin; build allpurpose ${SF_DIR} ${SF_OCTPKG_TARBALL}"
	touch ${SF_ALLPURP_TIMESTAMP}

${SF_OCTPKG_TARBALL}: ${OF_OCTPKG_TARBALL} | ${SF_DIR}
	cp ${OF_OCTPKG_TARBALL} ${SF_OCTPKG_TARBALL}

${SF_DIR}:
	mkdir -p ${SF_DIR}


##### forgedoc-inspect: a copy for visual inspection  #####

## Note: downloading the goodies directly in ${OF_DOC_UNPACKED}
##   is not a good idea -> the goodies would end up being packaged
##   with the Octave Forge documentation !

forgedoc-inspect: ${OF_DOC_INSPECT} ${OFGOODIES}

${OF_DOC_INSPECT}: ${OF_DOC_TIMESTAMP}
	@echo
	@echo Create of copy of ${OF_DOC_UNPACKED} for visual inspection
	cp -R ${OF_DOC_UNPACKED} ${OF_DOC_INSPECT}

${OFGOODIES}: | ${OF_DOC_INSPECT}
	@echo
	@echo Download OF goodie: $@
	cd ${OF_DOC_INSPECT} \
	   && ${OFWGET}/$(notdir $@)


##### Mercurial-related tricks #####

check_hg_clean:
ifneq ($(shell hg st),)
	$(error Your hg clone is not clean, stopping here.  Use 'hg status' to see what's going on..)
endif

##### Clean up #####

clean:
	rm -rf ${BUILD_DIR}

