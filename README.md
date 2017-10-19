This script creates an Ubuntu package for [ibex-lib][ibex-lib] and uploads it to
[launchpad.net](https://launchpad.net/~dreal/+archive/ubuntu/dreal/+packages).

Uploaded packages are available at https://launchpad.net/~dreal/+archive/ubuntu/dreal/+packages.

[ibex-lib]: https://http://ibex-lib.org/


Required packages
=================

We assume that you have Ubuntu 14.04 LTS system. You need the
following packages:

```bash
sudo apt-get install git pbuilder build-essential ubuntu-dev-tools
```

Also we assume that you have created your GPG/PGP key and published to
launchpad.


How to use script
=================

```bash
./update.sh
```


How to install libibex-dev using PPA
====================================

```bash
sudo add-apt-repository ppa:dreal/dreal
sudo apt-get update
sudo apt-get install libibex-dev
```

Once install ibex-lib via PPA, you can use the standard `apt-get upgrade`
to get the latest version of it.


Test Package Locally
====================

Have the following in `~/.pbuilderrc` to enable `universe` (since `coinor-clp-dev` is there).

```
COMPONENTS="main restricted universe multiverse"

if [ "$DIST" == "squeeze" ]; then
    echo "Using a Debian pbuilder environment because DIST is $DIST"
    COMPONENTS="main contrib non-free"
fi
```

To set up pbuilder, run:

```bash
sudo pbuilder --create                \
              --distribution trusty   \
              --architecture amd64    \
              --basetgz /var/cache/pbuilder/trusty-amd64-base.tgz  \
              --debootstrapopts --keyring=/etc/apt/trusted.gpg
```

To create a package, run:
```bash
sudo pbuilder --build
              --distribution trusty
              --architecture amd64
              --basetgz /var/cache/pbuilder/trusty-amd64-base.tgz \
              libibex-dev_2.5.1.<timedate>.git<gitsha>\~14.04.dsc
```

You can find the `.deb` file at `/var/cache/pbuilder/result/`.
