#!/usr/bin/env bash

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash

# Install nftables package
pkg_mgr install "nftables"

# Create nftables configuration directory
mkdir -p $chroot/etc/nftables

# Install base firewall rules
cp $dir/assets/base-firewall.nft $chroot/etc/nftables/bosh-base.nft
chmod 644 $chroot/etc/nftables/bosh-base.nft

# Create systemd service to load base firewall at boot
cat > $chroot/lib/systemd/system/bosh-base-firewall.service <<'EOF'
[Unit]
Description=BOSH Base Firewall Rules
DefaultDependencies=no
Before=network-pre.target
Wants=network-pre.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/nft -f /etc/nftables/bosh-base.nft
ExecStop=/usr/sbin/nft delete table inet bosh_firewall
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

run_in_chroot "${chroot}" "systemctl enable bosh-base-firewall.service"
