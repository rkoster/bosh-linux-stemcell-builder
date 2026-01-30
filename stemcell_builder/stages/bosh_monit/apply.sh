#!/usr/bin/env bash

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash
source $base_dir/lib/prelude_bosh.bash

monit_basename=monit-5.2.5
monit_archive=$monit_basename.tar.gz

mkdir -p $chroot/$bosh_dir/src
cp -r $dir/assets/$monit_archive $chroot/$bosh_dir/src

pkg_mgr install "zlib1g-dev"

run_in_bosh_chroot $chroot "
cd src
tar zxvf $monit_archive
cd $monit_basename
./configure --prefix=$bosh_dir --without-ssl CFLAGS="-fcommon"
make -j4 && make install
"

mkdir -p $chroot/$bosh_dir/etc
cp $dir/assets/monitrc $chroot/$bosh_dir/etc/monitrc
chmod 0700 $chroot/$bosh_dir/etc/monitrc

# monit refuses to start without an include file present
mkdir -p $chroot/$bosh_app_dir/monit
touch $chroot/$bosh_app_dir/monit/empty.monitrc

# Monit wrapper script (uses bosh-agent firewall-allow for access control):
mv $chroot/$bosh_dir/bin/monit $chroot/$bosh_dir/bin/monit-actual

# Helper script provides permit_monit_access function that BOSH jobs can source
# to gain firewall access to the monit API for controlled failover scenarios
cp $dir/assets/monit-access-helper.sh $chroot/$bosh_dir/etc/
chmod +x $chroot/$bosh_dir/etc/monit-access-helper.sh

cp $dir/assets/monit $chroot/$bosh_dir/bin/monit
chmod +x $chroot/$bosh_dir/bin/monit
