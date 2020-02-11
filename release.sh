#!/bin/bash
# generic release script
# meant to be run from the distro directory
SCRIPTNAME=$(basename ${0})

function usage {
    echo "$SCRIPTNAME - script for cutting Dochazka releases"
    echo
    echo "Usage:"
    echo "  $SCRIPTNAME [-h,--help] [--obs]"
    echo
    echo "Options:"
    echo "    --help         Display this usage message"
    echo "    --obs          Update OBS"
    echo
    exit 1
}

# sanity checks
if [ ! -e VERSION_MODULE ] ; then
    echo "VERSION_MODULE file not found -- are you in a local git clone?"
    exit 1
fi
HEAD=$(git rev-parse --abbrev-ref HEAD)
if [ "$HEAD" = "master" ] ; then
    true
else
    echo "Must be on master branch"
    exit 1
fi

set -e
TEMP=$(getopt -o h --long "help,obs" -n 'release.sh' -- "$@")
set +e
eval set -- "$TEMP"

OBS=""
while true ; do
    case "$1" in
        --obs) OBS="$1" ; shift ;;
        --) shift ; break ;;
        *) echo "Internal error" ; exit 1 ;;
    esac
done

CPAN_NAME=$(cat CPAN_NAME)
VERSION=$(grep -P 'Version \d\.*\d+' $(cat VERSION_MODULE) | cut -d' ' -f2)
perl Build.PL
./Build distmeta
./Build dist
TARBALL_DIR=$(pwd)

if [ "$OBS" ] ; then
    OBS_NAME="perl-$CPAN_NAME"
    OBS_PROJECT=$(cat OBS_PROJECT)
    OBS_DIR="home:smithfarm:branches:$OBS_PROJECT/$OBS_NAME/"
    if [ -d "$HOME/obs" ] ; then
        true
    else
        echo "No ~/obs directory: creating one"
        mkdir -p "$HOME/obs"
    fi
    set -ex
    pushd "$HOME/obs"
    rm -rf $OBS_DIR ; \
    osc -A https://api.opensuse.org/ branch $OBS_PROJECT/$OBS_NAME 2>/dev/null || true
    osc -A https://api.opensuse.org/ co $OBS_DIR
    pushd $OBS_DIR
    osc rm -f $CPAN_NAME-*.tar.gz
    cp $TARBALL_DIR/$CPAN_NAME-*.tar.gz .
    cpanspec -f *.tar.gz
    osc add $CPAN_NAME-*.tar.gz
    osc -A https://api.opensuse.org/ commit -v -m $VERSION --noservice
    sleep 10
    osc -A https://api.opensuse.org/ sr -m $VERSION --no-cleanup
    popd
    popd
fi

cpan-upload -u SMITHFARM $CPAN_NAME-$VERSION.tar.gz
./Build distclean
