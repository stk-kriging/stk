## Copyright Notice
##
##    Copyright (C) 2015, 2017, 2019, 2020, 2022, 2023 CentraleSupelec
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

.PHONY: all release allpurpose-release octpkg-release check_git_clean clean

all: release


## Build directory
BUILD_DIR=${CURDIR}/build

## Programs
OCTAVE ?= octave
OCT_EVAL=${OCTAVE} --no-gui --silent --norc --eval

## File names for the octpkg release
OCTPKG_UNPACKED=${BUILD_DIR}/stk-octpkg
OCTPKG_UNPACKED_TIMESTAMP=${OCTPKG_UNPACKED}.dir.timestamp
OCTPKG_TARBALL=stk-${VERNUM}-octpkg.tar.gz

## File names for the allpurpose release
ALLPURPOSE_UNPACKED=${BUILD_DIR}/stk-allpurpose
ALLPURPOSE_UNPACKED_TIMESTAMP=${ALLPURPOSE_UNPACKED}.dir.timestamp
ALLPURPOSE_TARBALL=stk-${VERNUM}-allpurpose.tar.gz

# File containing the git SHA-1 of the revision being built
GIT_TIMESTAMP=${BUILD_DIR}/git.stamp

# Extract git info
GIT_OLD_SHA := $(shell test -e $(GIT_TIMESTAMP) && cat $(GIT_TIMESTAMP))
GIT_SHA     := $(shell git rev-parse HEAD)
GIT_DATE    := $(shell git log -1 --pretty=format:%cd --date=iso)

# Update git stamp file if the revision has changed
DUMMY := $(shell \
  test "$(GIT_OLD_SHA)" != "$(GIT_SHA)" \
  && mkdir -p $(BUILD_DIR) \
  && echo "$(GIT_SHA)" > "$(GIT_TIMESTAMP)")

# Follows the recommendations of https://reproducible-builds.org/docs/archives
define create_tarball
$(shell cd $(dir $(1)) \
    && find $(notdir $(1)) -print0 \
    | LC_ALL=C sort -z \
    | tar c --mtime="$(GIT_DATE)" --mode=a+rX,u+w,go-w,ug-s \
            --owner=root --group=root --numeric-owner \
            --no-recursion --null -T - -f - \
    | gzip -9n > "$(2)")
endef


release: allpurpose-release octpkg-release
	@echo
	@echo === Release tarballs ===
	@ls -lh ${BUILD_DIR}/*.tar.gz
	@echo


##### OCTPKG: Octave package #####

octpkg-release: ${OCTPKG_TARBALL}

${OCTPKG_TARBALL}: ${OCTPKG_UNPACKED_TIMESTAMP}
	@echo
	@echo Create octpkg tarball: $@
	@echo $(OCTPKG_UNPACKED)
	$(call create_tarball,$(OCTPKG_UNPACKED),$@)
	@echo

${OCTPKG_UNPACKED_TIMESTAMP}: ${GIT_TIMESTAMP} | check_git_clean
	@${OCT_EVAL} "cd admin; build octpkg '${BUILD_DIR}' '${GIT_DATE}'"
	@touch ${OCTPKG_UNPACKED_TIMESTAMP}


##### ALLPURP: Github Matlab/Octave Release #####

allpurpose-release: ${ALLPURPOSE_TARBALL}

${ALLPURPOSE_TARBALL}: ${ALLPURPOSE_UNPACKED_TIMESTAMP}
	@echo
	@echo Create all-purpose tarball: $@
	$(call create_tarball,$(ALLPURPOSE_UNPACKED),$@)

${ALLPURPOSE_UNPACKED_TIMESTAMP}: ${OCTPKG_TARBALL} ${GIT_TIMESTAMP} | check_git_clean
	@${OCT_EVAL} "cd admin; build allpurpose '${BUILD_DIR}' '${OCTPKG_TARBALL}' '${GIT_DATE}'"
	@touch ${ALLPURPOSE_UNPACKED_TIMESTAMP}


##### Check git status #####

check_git_clean:
ifneq ($(shell git status --porcelain),)
	$(error Your git clone is not clean, stopping here.  Use 'git status' to see what is going on..)
endif


##### Clean up #####

clean:
	rm -rf ${BUILD_DIR}

