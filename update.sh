#!/usr/bin/env bash
#
# Author: Soonho Kong
#
set -e  # Abort if any command fails
UPDT_PATH="`dirname \"$0\"`"
UPDT_PATH="`( cd \"$UPDT_PATH\" && pwd )`"
cd $UPDT_PATH
#          14.04  16.04  17.04
DIST_LIST="trusty xenial zesty"
ORG=dreal-deps
REPO=ibex-lib
SHA=5f6731a3d20072d02478c806d05724f5f306f15d  # ibex-2.6.1 + custom patches
PPA_NAME=dreal
PKG_NAME=libibex-dev
URGENCY=medium
AUTHOR_NAME="Soonho Kong"
AUTHOR_EMAIL="soonho.kong@gmail.com"

# Check out the project if it's not here and update PREVIOUS_HASH
if [ ! -d ./${REPO} ] ; then
    git clone https://github.com/${ORG}/${REPO}
    DOIT=TRUE
    cd ${REPO}
    git rev-parse HEAD > PREVIOUS_HASH
    cd ..
fi

# Update CURRENT_HASH
cd ${REPO}
git fetch --all --quiet
git reset --hard $SHA --quiet
git rev-parse HEAD > CURRENT_HASH
cd ..

# Only run the script if there is an update
if ! cmp ${REPO}/PREVIOUS_HASH ${REPO}/CURRENT_HASH >/dev/null 2>&1
then
    DOIT=TRUE
fi

# '-f' option enforce update
if [[ $1 == "-f" ]] ; then
    DOIT=TRUE
fi

if [[ $DOIT == TRUE ]] ; then

    DATETIME=`date +"%Y%m%d%H%M%S"`
    DATE_STRING=`date -R`

    for DIST in ${DIST_LIST}
    do
        echo "=== 1. Create debian/changelog file"
        VERSION=`./get_version.sh ${REPO} ${DATETIME} ${DIST}`
        cp debian/changelog.template                               debian/changelog
        sed -i "s/##PKG_NAME##/${PKG_NAME}/g"                      debian/changelog
        sed -i "s/##VERSION##/${VERSION}/g"                        debian/changelog
        sed -i "s/##DIST##/${DIST}/g"                              debian/changelog
        sed -i "s/##URGENCY##/${URGENCY}/g"                        debian/changelog
        sed -i "s/##COMMIT_MESSAGE##/bump to version ${VERSION}/g" debian/changelog
        sed -i "s/##AUTHOR_NAME##/${AUTHOR_NAME}/g"                debian/changelog
        sed -i "s/##AUTHOR_EMAIL##/${AUTHOR_EMAIL}/g"              debian/changelog
        sed -i "s/##DATE_STRING##/${DATE_STRING}/g"                debian/changelog
        rm -rf ${REPO}/debian
        cp -r debian ${REPO}/debian

        echo "=== 2. ${PKG_NAME}_${VERSION}.orig.tar.gz"
        tar -acf ${PKG_NAME}_${VERSION}.orig.tar.gz --exclude ${REPO}/.git ${REPO}
        cd ${REPO}
        debuild -S -sa
        cd ..

        echo "=== 3. Upload: ${PKG_NAME}_${VERSION}_source.changes"
        dput -f ppa:dreal/dreal ${PKG_NAME}_${VERSION}_source.changes
        # rm -- ${PKG_NAME}_*
        # rm -rf -- ${REPO}/debian debian/changelog
        # rm ${REPO}/bin/bmc
    done
else
    echo "Nothing to do."
fi
mv ${REPO}/CURRENT_HASH ${REPO}/PREVIOUS_HASH
