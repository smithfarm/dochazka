dochazka
========

For Dochazka documentation, see
``https://metacpan.org/pod/App::Dochazka::REST#DOCUMENTATION``.

This repo contains release automation scripts and other boilerplate used by all
Perl modules in the Dochazka project. It does not contain any Dochazka source code.

This repo also serves as a central place for filing issues against the Dochazka
repos:

* https://github.com/smithfarm/dochazka-common
* https://github.com/smithfarm/dochazka-rest
* https://github.com/smithfarm/dochazka-cli
* https://github.com/smithfarm/dochazka-www

Running Dochazka from source
============================

Before Dochazka can be run from source, dependencies (both build and runtime)
must be satisfied. Common dependencies can be installed by running the
:code:`bootstrap.sh` script provided in this git repo. Other Dochazka repos
contain their own :code:`bootstrap.sh` scripts for installing dependencies
specific to those projects.


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
