#!/bin/sh -ex

if [ $# -ne 1 ]; then
    printf "Usage: %s <chroot_folder>\n" "$0"
    exit 1
fi

chroot_dir=$1

finish() {
    set +e
    umount "$chroot_dir"/sys
    umount "$chroot_dir"/proc
}
trap finish EXIT

# "Simulate" docker so snapcraft does not try to talk to snapd
touch "$chroot_dir"/.dockerenv

mount -t proc none "$chroot_dir"/proc
mount -t sysfs none "$chroot_dir"/sys
chroot "$chroot_dir"
