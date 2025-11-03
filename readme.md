# grain-alpine-qemu

alpine linux VM setup for grain network

## what is grain-alpine-qemu?

grain-alpine-qemu documents how to set up an alpine linux virtual machine
using QEMU on a fresh Ubuntu 24.04 LTS local host. this gives you a
minimal, secure linux environment for development work.

alpine linux is known for its small size and security focus. combined
with QEMU virtualization, you get a lightweight VM that's easy to
manage and mirrors your development environment.

## prerequisites

- Ubuntu 24.04 LTS (fresh install)
- QEMU and KVM support
- internet connection

## installation

### 1. install QEMU on Ubuntu host

```bash
sudo apt update
sudo apt install -y qemu-system-x86 qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
```

### 2. download alpine linux extended

visit https://alpinelinux.org/downloads/ and download the latest
extended ISO for x86_64. the extended version includes useful tools
for development work.

save it to `~/Downloads/alpine-extended-X.X.X-x86_64.iso` (replace
X.X.X with the actual version number).

### 3. create VM disk image

```bash
mkdir -p ~/VMs
cd ~/VMs
qemu-img create -f qcow2 alpine-vm.qcow2 10G
```

### 4. boot from ISO and install alpine

run the installation script to boot from the ISO:

```bash
./qemu-vm-install.sh
```

this will start QEMU with the alpine ISO mounted. when alpine boots:

1. login as `root` (no password initially)
2. run `setup-alpine`
3. follow the prompts:
   - select keyboard layout
   - select hostname (or press Enter for default)
   - configure networking (choose the interface, usually `eth0`)
   - choose `dhcp` for automatic IP configuration
   - set root password
   - when prompted for disk, select `sda` (the qcow2 disk)
   - choose `sys` installation type
   - confirm installation
4. after installation completes, run `poweroff`

### 5. boot installed alpine VM

after the VM powers off, run the boot script:

```bash
./qemu-vm-start.sh
```

this boots alpine from the installed disk (not the ISO). login as `root`
with the password you set during installation.

### 6. configure alpine VM

once logged in, configure the system:

#### create xy user

```bash
adduser xy
# follow prompts to set password and confirm
```

#### add xy to sudoers

```bash
# uncomment the community repository
sed -i 's|^#http://dl-cdn.alpinelinux.org/alpine/v3.22/community|http://dl-cdn.alpinelinux.org/alpine/v3.22/community|' /etc/apk/repositories

# update package index
apk update

# install sudo
doas apk install sudo
# or if doas isn't available:
apk add sudo

# add xy to wheel group
adduser xy wheel
```

alternatively, edit `/etc/sudoers` directly:

```bash
visudo
# add this line:
xy ALL=(ALL) NOPASSWD: ALL
```

#### configure networking (if needed)

if networking isn't working:

```bash
# start networking service
rc-service networking start
rc-update add networking

# configure DNS
cat > /etc/resolv.conf <<EOF
nameserver 8.8.8.8
nameserver 8.8.4.4
EOF
```

### 7. install zig

visit https://ziglang.org/download/ to find the latest stable version
(currently 0.15.2).

```bash
# as root or with sudo
ZIG_VERSION="0.15.2"  # update to latest stable
ZIG_ARCHIVE="zig-x86_64-linux-${ZIG_VERSION}.tar.xz"
ZIG_URL="https://ziglang.org/download/${ZIG_VERSION}/${ZIG_ARCHIVE}"

cd /tmp
curl -L -o "$ZIG_ARCHIVE" "$ZIG_URL"

mkdir -p /usr/local/zig
tar -xJf "$ZIG_ARCHIVE" -C /usr/local/zig --strip-components=1

# symlink to /usr/local/bin
ln -sf /usr/local/zig/zig /usr/local/bin/zig

# add to PATH (for all users)
echo 'export PATH="/usr/local/zig:$PATH"' >> /etc/profile

# verify installation
zig version
```

### 8. create directory structure

```bash
# as xy user
mkdir -p ~/kae3g ~/github ~/gitlab
```

## usage

### starting the VM

```bash
./qemu-vm-start.sh
```

this boots alpine from the installed disk with networking configured.

### SSH access

the VM is configured with port forwarding. from your host:

```bash
ssh -p 2222 xy@localhost
# or
ssh -p 2222 root@localhost
```

### stopping the VM

inside the VM:

```bash
poweroff
```

or close the QEMU window.

## scripts

this repository includes:

- `qemu-vm-install.sh` - boots from ISO for installation
- `qemu-vm-start.sh` - boots from installed disk

both scripts configure networking with user-mode NAT (slirp), which
provides automatic NAT and works out of the box on Ubuntu.

## networking

the default configuration uses QEMU's user-mode networking:

- NAT networking (VM can reach internet, host can reach VM)
- automatic DHCP for the VM
- port forwarding: host port 2222 → VM port 22 (SSH)

if you need bridge networking instead, edit the scripts and use the
commented bridge networking configuration.

## directory structure

after setup, your alpine VM has:

```
/home/xy/
  ├── kae3g/    # local projects
  ├── github/   # GitHub repositories
  └── gitlab/   # GitLab repositories
```

this mirrors your Ubuntu host setup for consistency.

## troubleshooting

### VM won't boot

- make sure KVM is enabled in BIOS
- check that `qemu-system-x86_64` is installed
- verify disk image exists at `~/VMs/alpine-vm.qcow2`

### networking not working

- check that networking service is running: `rc-service networking status`
- verify DNS: `ping 8.8.8.8` and `ping google.com`
- check `/etc/resolv.conf` has nameservers

### can't SSH to VM

- make sure VM is running
- check port forwarding: `ssh -p 2222 xy@localhost`
- verify SSH service: `rc-service sshd status`

### sudo not working

- verify xy is in wheel group: `groups xy`
- check sudoers: `visudo -c`
- ensure sudo package is installed: `apk list sudo`

## team

**teamquest09** (Sagittarius ♐ / VI. The Lovers)

the explorers who seek truth, connection, and understanding. sagittarius's
questing spirit meets the lovers' harmony. we build environments that
support discovery and growth.

## license

triple licensed: MIT / Apache 2.0 / CC BY 4.0

choose whichever license suits your needs.
