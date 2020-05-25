#!/bin/bash
touch rootfs-corepure64/dev/urandom
mount --bind /dev/urandom rootfs-corepure64/dev/urandom
chroot rootfs-corepure64 /bin/ash
