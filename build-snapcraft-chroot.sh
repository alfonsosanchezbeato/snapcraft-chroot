#!/bin/bash -ex
# To install the script requirements:
# apt install qemu qemu-user-static binfmt-support debootstrap

if [ "$(id -u)" -ne 0 ]; then
    printf "You need to run the script as root user\n"
    exit 1
fi

arch=armhf
series=focal
chroot_d=$arch-$series-rootfs
# List of snaps to be included in the image. We want snapcraft and
# core18, which is the base for the snapcraft snap. We also might want
# anoter coreXX snap matching the series (16 if xenial, 20 if focal,
# etc.). We also need snapd as snapcraft runs 'snap pack'.
snaps=(snapcraft snapd core18 core20)

# Create chroot, this can take a while...
qemu-debootstrap --arch $arch $series $chroot_d

# Download snaps that we will "install" in the chroot
for snap in "${snaps[@]}"; do
    UBUNTU_STORE_ARCH=$arch snap download --basename="$snap" "$snap"
    mkdir -p "$chroot_d/snap/$snap"
    unsquashfs -d "$chroot_d/snap/$snap/current" "$snap".snap
    rm "$snap".snap "$snap".assert
done

# Let snapcraft think it is in a docker container
touch $chroot_d/.dockerenv

# Script to invoke snapcraft in the chroot
cat > $chroot_d/usr/bin/snapcraft << EOF
#!/bin/sh -e
export LANG="en_US.UTF-8" LANGUAGE="en_US:en" LC_ALL="en_US.UTF-8" PATH="/snap/bin:\$PATH" SNAP="/snap/snapcraft/current" SNAP_NAME="snapcraft" SNAP_ARCH="$arch"
export SNAP_VERSION=\$(awk '/^version:/{print \$2}' /snap/snapcraft/current/meta/snap.yaml)
exec "/snap/snapcraft/current/usr/bin/python3" "/snap/snapcraft/current/bin/snapcraft" "\$@"
EOF

chmod +x $chroot_d/usr/bin/snapcraft

ln -s /snap/snapd/current/usr/bin/snap $chroot_d/usr/bin/snap

# Get proper locale
chroot $chroot_d locale-gen en_US.UTF-8
DEBIAN_FRONTEND=noninteractive chroot $chroot_d dpkg-reconfigure locales
