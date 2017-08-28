#!/usr/bin/env bash
#
# Author: Soonho Kong <soonhok@cs.cmu.edu>
#

usage() {
cat <<EOF
Usage: '$0' <repo_name> <datetime> <ubuntu_distro>

It returns a corresponding version string. For example, 
 
    $0 lean 20141115015200 precise

returns 

    lean-0.2.0.20141115015200.git0d982cceedc2479ffc3cc68d2a1291c711770028~12.04

EOF
}

REPO=$1
DATE=$2
DIST=$3

if [[ ! $# == 3 ]] ; then
    usage;
    exit 1;
fi

if [[ ! -d ${REPO}/.git ]] ; then
    usage;
    echo "${REPO}/.git is not a directory."
    exit 1;
fi

if   [[ ${DIST} == trusty ]] ; then
    DIST_VER=14.04
elif [[ ${DIST} == xenial ]] ; then
    DIST_VER=16.04
elif [[ ${DIST} == zesty ]] ; then
    DIST_VER=17.04
else 
    usage;
    echo "Wrong distro name ${DIST}: we support 'precise', 'trusty', 'wily' and 'xenial'"
    exit 1
fi

VERSION_MAJOR=2
VERSION_MINOR=5
VERSION_PATCH=1

cd ${REPO}
GIT_HASH=`git log --pretty=format:%H -n 1`

echo ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}.${DATE}.git${GIT_HASH}~${DIST_VER}