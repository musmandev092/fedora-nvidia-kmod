#!/usr/bin/env bash
set -euo pipefail

REPO="musmandev092/fedora-nvidia-kmod"
CURRENT_KERNEL=$(uname -r)

echo "==> Current running kernel: ${CURRENT_KERNEL}"

RELEASE_INFO=$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest")
RELEASE_TAG=$(echo "${RELEASE_INFO}" | grep -o '"tag_name": *"[^"]*"' | head -n 1 | cut -d'"' -f4)
TARGET_KERNEL="${RELEASE_TAG#kmod-}"

echo "==> Latest available kmod release is for kernel: ${TARGET_KERNEL}"

DOWNLOAD_URL=$(echo "${RELEASE_INFO}" | grep -o '"browser_download_url": *"[^"]*kmod-nvidia[^"]*\.rpm"' | head -n 1 | cut -d'"' -f4)

if [ -z "${DOWNLOAD_URL}" ]; then
  echo "ERROR: No kmod-nvidia RPM found in latest release"
  exit 1
fi

RPM_NAME=$(basename "${DOWNLOAD_URL}")
TMP_DIR=$(mktemp -d)
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "==> Downloading ${RPM_NAME}..."
curl -fsSL -o "${TMP_DIR}/${RPM_NAME}" "${DOWNLOAD_URL}"

if ! rpm -q rpmfusion-nonfree-release >/dev/null 2>&1; then
  echo "==> Enabling RPM Fusion nonfree repository..."
  sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-45.noarch.rpm
fi

echo "==> Installing pre-compiled NVIDIA driver package..."
sudo dnf install -y "${TMP_DIR}/${RPM_NAME}" xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-cuda-libs

echo "==> Regenerating initramfs..."
sudo dracut --regenerate-all --force

echo "==> Installation complete"
