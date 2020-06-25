#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color
INSPECTION_DESC="$(find %system.teamcity.build.tempDir% -maxdepth 2 -name '.descriptions.xml' -print -quit)"

if test -n "${INSPECTION_DESC}"
then
    INSPECTION_DIR="$(dirname  ${INSPECTION_DESC})"

    mkdir -p "%system.teamcity.build.tempDir%/authada-inspections"
    cp -r "${INSPECTION_DIR}"/. "%system.teamcity.build.tempDir%/authada-inspections/."
    echo "##teamcity[importData type='intellij-inspections' path='%system.teamcity.build.tempDir%/authada-inspections']"

	echo ""
    echo ""
    ls -lah "%system.teamcity.build.tempDir%/authada-inspections"
    echo ""
    echo ""

	ls -lah "${INSPECTION_DIR}"

   	INSPECTION_FILE="$(find ${INSPECTION_DIR} -maxdepth 1 -name '*.xml' -not -name ".descriptions.xml" -print -quit)"
    if test -n "${INSPECTION_DESC}"
	then
	    declare -i ERROR_COUNT=0
        declare -i WARN_COUNT=0

    	for f in $(find ${INSPECTION_DIR} -maxdepth 1 -name '*.xml' -not -name ".descriptions.xml")
        do
        	declare -ri EC=$(xmllint --xpath "count(//problem/problem_class[@ severity='ERROR'])" ${f})
        	declare -ri WC=$(xmllint --xpath "count(//problem/problem_class[@ severity='WARNING'])" ${f})

            ERROR_COUNT=$(( ${ERROR_COUNT} + ${EC} ))
            WARN_COUNT=$(( ${WARN_COUNT} + ${WC} ))
        done

        echo -e "${RED}\u2718${NC} Some inspections failed #$(( ${ERROR_COUNT} + ${WARN_COUNT} ))"
    	echo "##teamcity[buildStatisticValue key='A:InspectionStatsE' value='${ERROR_COUNT}']"
        echo "##teamcity[buildStatisticValue key='A:InspectionStatsW' value='${WARN_COUNT}']"
   fi
fi
