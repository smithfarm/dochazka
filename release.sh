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
    ( \
      echo "Removing old checkout" ; \
      rm -rf $OBS_DIR ; \
      cd $HOME/obs ; \
      echo "Branching $OBS_PROJECT/$OBS_NAME" ; \
      osc -A https://api.opensuse.org/ branch $OBS_PROJECT/$OBS_NAME ; \
      echo "Checking out branch" ; \
      osc co home:smithfarm:branches:$OBS_PROJECT/$OBS_NAME ; \
      cd home:smithfarm:branches:$OBS_PROJECT/$OBS_NAME ; \
      echo "Removing old tarball(s)" ; \
      osc rm -f $CPAN_NAME-*.tar.gz \
    )
fi

echo "Copying new tarball into $OBS_DIR"
cp $CPAN_NAME-*.tar.gz $OBS_DIR
./Build distclean

if [ 'x'$obs'x' = 'xyx' ]
then
    ( cd $OBS_DIR ; \
      echo "Running cpanspec" ; \
      cpanspec -f *.tar.gz ; \
      echo "Adding new tarball" ; \
      osc add $CPAN_NAME-*.tar.gz ; \
      echo "Committing" ; \
      osc -A https://api.opensuse.org/ commit -v -m $VERSION --noservice ; \
      echo "Waiting 10 seconds" ; \
      sleep 10 ; \
      echo "Submitting" ; \
      osc -A https://api.opensuse.org/ sr -m $VERSION --no-cleanup \
    )
fi

( cd $OBS_DIR ; cpan-upload -u SMITHFARM $CPAN_NAME-*.tar.gz )
