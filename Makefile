## Copyright Notice
##
##    Copyright (C) 2015 CentraleSupelec
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


all: release forgedoc-inspect

release: octaveforge-release sourceforge-release


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
OF_OCTPKG_TARBALL=${OF_DIR}/stk-${VERNUM}.tar.gz
OF_DOC_UNPACKED=${OF_DIR}/stk-html
OF_DOC_TARBALL=${OF_DIR}/stk-${VERNUM}-html.tar.gz
OF_DOC_INSPECT=${OF_DOC_UNPACKED}-inspect

## File names for the SF release
SF_ALLPURP_UNPACKED=${SF_DIR}/stk
SF_ALLPURP_TARBALL=${SF_DIR}/stk-${VERNUM}-allpurpose.tar.gz
SF_OCTPKG_TARBALL=${SF_DIR}/stk-${VERNUM}-octpkg.tar.gz

## Octave-Forge goodies
OFGOODIES=\
  ${OF_DOC_INSPECT}/octave-forge.css \
  ${OF_DOC_INSPECT}/download.png \
  ${OF_DOC_INSPECT}/doc.png \
  ${OF_DOC_INSPECT}/oct.png


##### OCTPKG: Octave-Forge Release #####

octaveforge-release: ${OF_MD5SUM} \
 octaveforge-package octaveforge-htmldoc

${OF_MD5SUM}: ${OF_OCTPKG_TARBALL} ${OF_DOC_TARBALL}
	md5sum ${OF_OCTPKG_TARBALL} > ${OF_MD5SUM}
	md5sum ${OF_DOC_TARBALL} >> ${OF_MD5SUM}

octaveforge-package: ${OF_OCTPKG_TARBALL}

${OF_OCTPKG_TARBALL}: ${OF_OCTPKG_UNPACKED} | ${OF_DIR}
	@echo
	@echo Create octpkg tarball: $@
	tar czf ${OF_OCTPKG_TARBALL} -C ${OF_DIR} $(notdir ${OF_OCTPKG_UNPACKED})
	@echo

${OF_OCTPKG_UNPACKED}: | ${OF_DIR}
	${OCT_EVAL} "cd admin; build octpkg ${OF_DIR}"

octaveforge-htmldoc: ${OF_DOC_TARBALL}

# Create tar.gz archive (this should create a tarball
#    with the expected structure, according to
#    http://octave.sourceforge.net/developers.html)
${OF_DOC_TARBALL}: ${OF_DOC_UNPACKED}
	@echo
	@echo Create forgefoc tarball: $@
	tar czf ${OF_DOC_TARBALL} -C ${OF_DIR} $(notdir ${OF_DOC_UNPACKED})
	@echo

${OF_DOC_UNPACKED}: ${OF_OCTPKG_TARBALL} | ${OF_DIR}
	${OCT_EVAL} "cd admin; build forgedoc ${OF_DOC_UNPACKED} ${OF_OCTPKG_TARBALL}"

${OF_DIR}:
	mkdir -p ${OF_DIR}


##### ALLPURP: SourceForge Matlab/Octave Release #####

sourceforge-release: sourceforge-allpurpose sourceforge-octpkg

sourceforge-allpurpose: ${SF_ALLPURP_TARBALL}

${SF_ALLPURP_TARBALL}: ${SF_ALLPURP_UNPACKED} | ${SF_DIR}
	@echo
	@echo Create all-purpose tarball: $@
	tar czf ${SF_ALLPURP_TARBALL} -C ${SF_DIR} $(notdir ${SF_ALLPURP_UNPACKED})

${SF_ALLPURP_UNPACKED}: ${SF_OCTPKG_TARBALL} | ${SF_DIR}
	${OCT_EVAL} "cd admin; build allpurpose ${SF_DIR} ${SF_OCTPKG_TARBALL}"

sourceforge-octpkg: ${SF_OCTPKG_TARBALL}

${SF_OCTPKG_TARBALL}: ${OF_OCTPKG_TARBALL} | ${SF_DIR}
	cp ${OF_OCTPKG_TARBALL} ${SF_OCTPKG_TARBALL}

${SF_DIR}:
	mkdir -p ${SF_DIR}


##### forgedoc-inspect: a copy for visual inspection  #####

## Note: downloading the goodies directly in ${OF_DOC_UNPACKED}
##   is not a good idea -> the goodies would end up being packaged
##   with the Octave Forge documentation !

forgedoc-inspect: ${OF_DOC_INSPECT} ${OFGOODIES}

${OF_DOC_INSPECT}: ${OF_DOC_UNPACKED}
	@echo
	@echo Create of copy of ${OF_DOC_UNPACKED} for visual inspection
	cp -R ${OF_DOC_UNPACKED} ${OF_DOC_INSPECT}

${OFGOODIES}: | ${OF_DOC_INSPECT}
	@echo
	@echo Download OF goodie: $@
	cd ${OF_DOC_INSPECT} \
	   && ${OFWGET}/$(notdir $@)


##### Clean up #####

clean:
	rm -rf ${BUILD_DIR}
