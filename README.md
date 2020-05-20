# Building snaps in a qemu-static chroot

This repo contains a couple of scripts to set-up a qemu-static chroot
in which you can run snapcraft. With this, it is possible to
cross-build snaps without needing real HW for it.  This is **not** the
recommended way, because it is slow and not as reliable as using the
real devices. In most cases, you can just link your github project to
[snapcraft.io](https://snapcraft.io/) and get the snaps built for
different architectures, or use a real device with Ubuntu classic, or
with Ubuntu Core with the lxd snap.

However, some times it is convenient to do things in your local
machine: you do not have the hardware readily available or you are
still bringing up a UC image for it. These scripts will help you in
that scenario.

`build-snapcraft-chroot.sh` creates a qemu-static chroot for
focal/armhf.  You can build snaps for the core20 base using it. It is
inspired on the [docker
files](https://github.com/snapcore/snapcraft/tree/master/docker) used
to create docker containers capable of running snapcraft. By changing
the `series`/`arch` variables, and adding the right coreXX snap to the
snaps list, you can create chroots able to build for different base
snaps and architectures. Note that it is important that the Ubuntu
release matches the base core snap of the snap to build.

`snapcraft-chroot.sh` starts the chroot. The only additional thing it
does is mounting proc and sysfs so programs inside the chroot do not
complain too much. Once you are in the chroot, the `snapcraft` command
will be available and run as usual.
