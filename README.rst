dochazka
========

This repo contains the release automation scripts used by all Perl modules in
the Dochazka project.

This repo also serves as a central place for filing issues against the Dochazka
repos:

* https://github.com/smithfarm/dochazka-common
* https://github.com/smithfarm/dochazka-rest
* https://github.com/smithfarm/dochazka-cli
* https://github.com/smithfarm/dochazka-www

Release management
==================

Make sure you have :code:`perl-reversion` and :code:`cpan-uploader` installed.
In openSUSE, this means installing the :code:`perl-Perl-Version` and
:code:`perl-CPAN-Uploader` packages.

Make sure you have properly branched the OBS package. For example, if
``OBS_PROJECT`` contains "devel:langages:perl", you need to do::

    cd ~/obs
    oosc branch devel:languages:perl $PKG_NAME
    oosc checkout home:$USER:devel:languages:perl/$PKG_NAME

Run ``sh install.sh`` to install the ``prerelease.sh`` and ``release.sh``
scripts in ``/usr/bin``.

Change directory to the local git clone where you have prepared a new release.

Run the :code:`prerelease.sh` script to bump the version number,
commit all outstanding modifications, add a git tag, append draft
Changes file entry, etc.

Optionally run the :code:`release.sh` script to push the release to OBS and
CPAN.

Once the above steps have been completed successfully once, further releases
can be accomplished by simply running ``prerelease.sh`` and ``release.sh`` in
succession.
