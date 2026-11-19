#!/usr/bin/env bash
set -euo pipefail

TARGET_KERNEL="${1:-}"

if [ -z "${TARGET_KERNEL}" ]; then
  echo "Usage: $0 <target-kernel-version>"
  exit 1
fi

echo "==> Setting up RPM Fusion repositories..."
dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-45.noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-45.noarch.rpm

echo "==> Installing build dependencies for kernel ${TARGET_KERNEL}..."
dnf install -y \
  "kernel-core-${TARGET_KERNEL}" \
  "kernel-devel-${TARGET_KERNEL}" \
  akmod-nvidia \
  gcc \
  make

echo "==> Building kernel module for ${TARGET_KERNEL}..."
akmods --force --kernels "${TARGET_KERNEL}"

echo "==> Collecting built RPMs..."
mkdir -p /work/dist
find /var/cache/akmods/ -name "kmod-nvidia*.rpm" -exec cp -v {} /work/dist/ \;

if ! ls /work/dist/kmod-nvidia*.rpm >/dev/null 2>&1; then
  echo "ERROR: kmod-nvidia RPM was not generated"
  exit 1
fi

echo "==> Build complete for ${TARGET_KERNEL}"
