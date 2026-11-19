# fedora-nvidia-kmod

Pre-compiled NVIDIA kernel module (`kmod-nvidia`) RPMs for Fedora 45 (`x86_64`).

Automated daily GitHub Actions build that pre-compiles NVIDIA out-of-tree kernel modules against the latest Fedora 45 kernels.

---

## Why

On Fedora, the standard `akmod-nvidia` package builds kernel modules locally on the client machine. This requires installing the full C build toolchain (`gcc`, `make`, `glibc-devel`, `kernel-devel`, `binutils`, etc.) totaling ~85 packages (~500 MB).

This repository offloads module compilation to GitHub Actions cloud runners:
- **Zero build dependencies:** Eliminates ~85 compiler packages from your workstation.
- **Fast updates:** Installs a ready-made binary `.rpm` directly.
- **Single-release policy:** Automatically retains only the single latest verified kernel release to keep the repository clean.

---

## Quick Install

Run the automated installer:

```bash
curl -fsSL https://raw.githubusercontent.com/musmandev092/fedora-nvidia-kmod/main/install.sh | sudo bash
```

Or download and install manually from the [latest release](https://github.com/musmandev092/fedora-nvidia-kmod/releases/latest):

```bash
# Enable RPM Fusion nonfree for userspace libraries
sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-45.noarch.rpm

# Install pre-built kmod RPM and userspace display libraries
sudo dnf install -y ./kmod-nvidia-*.rpm xorg-x11-drv-nvidia-libs xorg-x11-drv-nvidia-cuda-libs

# Regenerate initramfs
sudo dracut --regenerate-all --force
```

---

## Safe Kernel Update Practice

To avoid booting into a new kernel before a matching `kmod-nvidia` module is built, lock automatic kernel updates in `/etc/dnf/dnf.conf`:

```ini
excludepkgs=kernel,kernel-core,kernel-modules
```

When a new kernel release is available in this repository, run `install.sh` to update both the kernel and driver simultaneously.

---

## License

MIT
