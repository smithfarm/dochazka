#!/bin/bash
#
# prerelease.sh
#
# Bumps version number, commits all outstanding modifications,
# adds a git tag and appends draft Changes file entry
#
if [ ! -e VERSION_MODULE ]
then
    echo "Must be run in git checkout"
    exit 1
fi
perl-reversion -bump
perl Build.PL
./Build distmeta
perl-reversion | tail -n1
VERSION=$(grep -P 'Version \d\.*\d+' $(cat VERSION_MODULE) | cut -d' ' -f2)
echo "$VERSION $(date +'%Y-%m-%d %H:%M %Z')" >>Changes
git --no-pager log \
    --no-merges \
    --oneline \
    --no-color \
    --reverse \
    $(git describe --tags --abbrev=0)..HEAD >>Changes
echo >>Changes
vi Changes
git commit -as -m $VERSION
git tag -m $VERSION $VERSION
