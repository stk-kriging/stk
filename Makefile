## Copyright Notice
##
##    Copyright (C) 2015, 2017, 2019, 2020, 2022 CentraleSupelec
##
##    Author:  Julien Bect  <julien.bect@centralesupelec.fr>

## Copying Permission Statement
##
##    This file is part of
##
##            STK: a Small (Matlab/Octave) Toolbox for Kriging
##               (https://github.com/stk-kriging/stk/)
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
  github-release github-allpurpose github-octpkg \
  forgedoc-inspect check_git_clean clean

all: release forgedoc-inspect

release: octaveforge-release github-release

# "dist rule" expected by OF admins
# (build packages only, not OF html doc or forgedoc-inspect)
dist: octaveforge-package github-release


## Directories
BUILD_DIR=${CURDIR}/build
SF_DIR=${BUILD_DIR}/github
OF_DIR=${BUILD_DIR}/octaveforge

## Programs
OCTAVE ?= octave
OCT_EVAL=${OCTAVE} --no-gui --silent --norc --eval
OFWGET=wget --quiet http://octave.sourceforge.net

## File names for the OF release
OF_MD5SUM=${OF_DIR}/stk-${VERNUM}.md5sum
OF_OCTPKG_UNPACKED=${OF_DIR}/stk
OF_OCTPKG_TIMESTAMP=${OF_OCTPKG_UNPACKED}.dir.timestamp
OF_OCTPKG_TARBALL=${OF_DIR}/stk-${VERNUM}.tar.gz
OF_DOC_UNPACKED=${OF_DIR}/stk-html
OF_DOC_TIMESTAMP=${OF_DOC_UNPACKED}.dir.timestamp
OF_DOC_TARBALL=${OF_DIR}/stk-html.tar.gz
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

# File containing the git SHA-1 of the revision being built
GIT_STAMP=${BUILD_DIR}/git.stamp

# Extract git info
GIT_OLD_SHA := $(shell test -e $(GIT_STAMP) && cat $(GIT_STAMP))
GIT_SHA     := $(shell git rev-parse HEAD)
GIT_DATE    := $(shell git log -1 --pretty=format:%cd --date=iso)

# Update git stamp file if the revision has changed
DUMMY := $(shell                        \
  test "$(GIT_OLD_SHA)" != "$(GIT_SHA)"     \
  && mkdir -p $(BUILD_DIR)              \
  && echo "$(GIT_SHA)" > "$(GIT_STAMP)")

# Follows the recommendations of https://reproducible-builds.org/docs/archives
define create_tarball
$(shell cd $(dir $(1))                                     \
    && find $(notdir $(1)) -print0                         \
    | LC_ALL=C sort -z                                     \
    | tar c --mtime="$(GIT_DATE)" --mode=a+rX,u+w,go-w,ug-s \
            --owner=root --group=root --numeric-owner      \
            --no-recursion --null -T - -f -                \
    | gzip -9n > "$(2)")
endef


##### OCTPKG: Octave-Forge Release #####

octaveforge-release: ${OF_MD5SUM} \
 octaveforge-package octaveforge-htmldoc
	@echo
	@echo === tarballs for the *Octave Forge* FRS ===
	@ls -lh ${OF_DIR}/*.tar.gz
	@echo 
	@cat ${OF_MD5SUM}
	@echo

octaveforge-package: ${OF_OCTPKG_TARBALL}

octaveforge-htmldoc: ${OF_DOC_TARBALL}

${OF_MD5SUM}: ${OF_OCTPKG_TARBALL} ${OF_DOC_TARBALL}
	@echo Compute checksums...
	@cd ${OF_DIR} && md5sum $(notdir ${OF_OCTPKG_TARBALL}) \
	   $(notdir ${OF_DOC_TARBALL}) > ${OF_MD5SUM}

${OF_OCTPKG_TARBALL}: ${OF_OCTPKG_TIMESTAMP} | ${OF_DIR}
	@echo
	@echo Create octpkg tarball: $@
	$(call create_tarball,$(OF_OCTPKG_UNPACKED),$@)
	@echo

${OF_OCTPKG_TIMESTAMP}: ${GIT_STAMP} | check_git_clean ${OF_DIR}
	@${OCT_EVAL} "cd admin; build octpkg ${OF_DIR} ${GIT_DATE}"
	@touch ${OF_OCTPKG_TIMESTAMP}

# Create tar.gz archive (this should create a tarball
#    with the expected structure, according to
#    http://octave.sourceforge.net/developers.html)
${OF_DOC_TARBALL}: ${OF_DOC_TIMESTAMP}
	@echo
	@echo Create forgefoc tarball: $@
	$(call create_tarball,$(OF_DOC_UNPACKED),$@)
	@echo

${OF_DOC_TIMESTAMP}: ${OF_OCTPKG_TARBALL} ${GIT_STAMP} | check_git_clean ${OF_DIR}
	@${OCT_EVAL} "cd admin; build forgedoc ${OF_DOC_UNPACKED} ${OF_OCTPKG_TARBALL}"
	@touch ${OF_DOC_TIMESTAMP}

${OF_DIR}:
	@mkdir -p ${OF_DIR}


##### ALLPURP: Github Matlab/Octave Release #####

github-release: github-allpurpose github-octpkg
	@echo
	@echo === tarballs for the *stk project* FRS ===
	@ls -lh ${SF_DIR}/*.tar.gz
	@echo

github-allpurpose: ${SF_ALLPURP_TARBALL}

github-octpkg: ${SF_OCTPKG_TARBALL}

${SF_ALLPURP_TARBALL}: ${SF_ALLPURP_TIMESTAMP} | ${SF_DIR}
	@echo
	@echo Create all-purpose tarball: $@
	$(call create_tarball,$(SF_ALLPURP_UNPACKED),$@)

${SF_ALLPURP_TIMESTAMP}: ${SF_OCTPKG_TARBALL} ${GIT_STAMP} | check_git_clean ${SF_DIR}
	@${OCT_EVAL} "cd admin; build allpurpose ${SF_DIR} ${SF_OCTPKG_TARBALL} ${GIT_DATE}"
	@touch ${SF_ALLPURP_TIMESTAMP}

${SF_OCTPKG_TARBALL}: ${OF_OCTPKG_TARBALL} | ${SF_DIR}
	@cp ${OF_OCTPKG_TARBALL} ${SF_OCTPKG_TARBALL}

${SF_DIR}:
	@mkdir -p ${SF_DIR}


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


##### Check git status #####

check_git_clean:
ifneq ($(shell git status --porcelain),)
	$(error Your git clone is not clean, stopping here.  Use 'git status' to see what is going on..)
endif


##### Clean up #####

clean:
	rm -rf ${BUILD_DIR}

