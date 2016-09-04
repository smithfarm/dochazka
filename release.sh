#!/bin/bash
# generic release script
# meant to be run from the distro directory
if [ ! -e VERSION_MODULE ]
then
    echo "Must be run in git checkout"
    exit 1
fi

echo -n "Update OBS? (y/N) "
read obs

CPAN_NAME=$(cat CPAN_NAME)
OBS_NAME="perl-$CPAN_NAME"
OBS_PROJECT=$(cat OBS_PROJECT)
OBS_DIR="$HOME/obs/home:smithfarm:branches:$OBS_PROJECT/$OBS_NAME/"
VERSION=$(grep -P 'Version \d\.*\d+' $(cat VERSION_MODULE) | cut -d' ' -f2)
perl Build.PL
./Build distmeta
./Build dist

if [ 'x'$obs'x' = 'xyx' ]
then
    ( cd $OBS_DIR ; \
      osc -A https://api.opensuse.org/ up ; \
      osc rm -f $CPAN_NAME-*.tar.gz \
    )
fi

cp $CPAN_NAME-*.tar.gz $OBS_DIR
./Build distclean

if [ 'x'$obs'x' = 'xyx' ]
then
    ( cd $OBS_DIR ; \
      sed -i -r \
          -e "s/${CPAN_NAME}-[[:digit:]]\.[[:digit:]]+\.tar\.gz/${CPAN_NAME}-${VERSION}.tar.gz/" \
          ${OBS_NAME}.spec ; \
      echo "Running local source services" ; \
      osc service dr ; \
      echo "Adding new tarball" ; \
      osc add $CPAN_NAME-*.tar.gz ; \
      echo "Updating changes file" ; \
      osc vc -m "updated to ${VERSION}\n   see /usr/share/doc/packages/$OBS_NAME/Changes" ; \
      echo "Committing" ; \
      osc -A https://api.opensuse.org/ commit -v -m $VERSION ; \
      echo "Waiting 10 seconds" ; \
      sleep 10 ; \
      echo "Submitting" ; \
      osc -A https://api.opensuse.org/ sr -m $VERSION \
    )
fi

( cd $OBS_DIR ; cpan-upload -u SMITHFARM $CPAN_NAME-*.tar.gz )
