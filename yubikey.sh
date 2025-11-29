#!/bin/bash
set -e

# YubiKey FIDO2 LUKS Setup for Arch Linux

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[*]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[!]${NC} $1"; exit 1; }

confirm() {
    local description="$1"
    local command="$2"
    echo ""
    echo "----------------------------------------"
    info "NEXT STEP: $description"
    warn "COMMAND: $command"
    echo "----------------------------------------"
    read -p "Proceed? [y/N]: " -n 1 -r
    echo ""
    [[ $REPLY =~ ^[Yy]$ ]] || { warn "Skipped."; return 1; }
    return 0
}

echo "========================================"
echo " YubiKey FIDO2 LUKS Setup for Arch Linux"
echo "========================================"
echo ""
warn "This script modifies critical boot configuration."
warn "Ensure you have your LUKS passphrase as backup."
echo ""
read -p "Continue? [y/N]: " -n 1 -r
echo ""
[[ $REPLY =~ ^[Yy]$ ]] || exit 0

# Check root
[[ $EUID -ne 0 ]] && error "Run as root"

# Check for YubiKey
info "Checking for YubiKey..."
ykman info &>/dev/null || error "YubiKey not detected. Install ykman and insert your key."

# Check for FIDO2 support
ykman fido info &>/dev/null || error "YubiKey does not support FIDO2"
info "YubiKey with FIDO2 detected."

# Find LUKS device
LUKS_DEVICE=$(lsblk -rno NAME,FSTYPE | awk '$2 == "crypto_LUKS" {print "/dev/"$1; exit}')
[[ -z "$LUKS_DEVICE" ]] && error "No LUKS device found"

LUKS_UUID=$(blkid -s UUID -o value "$LUKS_DEVICE")
[[ -z "$LUKS_UUID" ]] && error "Could not get UUID for $LUKS_DEVICE"

info "Found LUKS device: $LUKS_DEVICE"
info "UUID: $LUKS_UUID"

# Check FIDO2 PIN
if ! ykman fido info 2>/dev/null | grep -q "PIN.*remaining"; then
    warn "No FIDO2 PIN set."
    if confirm "Set a FIDO2 PIN on your YubiKey. This PIN protects the FIDO2 credentials and will be required at boot." "ykman fido access change-pin"; then
        ykman fido access change-pin
    fi
fi

# Install libfido2 if needed
if ! pacman -Q libfido2 &>/dev/null; then
    if confirm "Install libfido2 package. Required for FIDO2 support in systemd-cryptenroll." "pacman -S libfido2"; then
        pacman -S libfido2
    fi
fi

# Enroll YubiKey
if confirm "Enroll your YubiKey as a LUKS decryption key. You will need to enter your existing LUKS passphrase, then touch your YubiKey. This adds the YubiKey to a new keyslot without removing your passphrase." "systemd-cryptenroll --fido2-device=auto --fido2-with-client-pin=yes --fido2-with-user-presence=yes --fido2-with-user-verification=yes $LUKS_DEVICE"; then
    info "Touch your YubiKey when prompted..."
    systemd-cryptenroll \
        --fido2-device=auto \
        --fido2-with-client-pin=yes \
        --fido2-with-user-presence=yes \
        --fido2-with-user-verification=yes \
        "$LUKS_DEVICE"
fi

# Backup configs
if confirm "Backup current mkinitcpio.conf and GRUB config. Saves copies to .bak files in case you need to restore." "cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak && cp /etc/default/grub /etc/default/grub.bak"; then
    cp /etc/mkinitcpio.conf /etc/mkinitcpio.conf.bak
    cp /etc/default/grub /etc/default/grub.bak
    info "Configs backed up."
fi

# Update mkinitcpio.conf
NEW_HOOKS="HOOKS=(base systemd autodetect microcode modconf kms keyboard sd-vconsole block sd-encrypt filesystems fsck)"
echo ""
info "Current HOOKS:"
grep "^HOOKS=" /etc/mkinitcpio.conf
info "New HOOKS:"
echo "    $NEW_HOOKS"
if confirm "Update mkinitcpio.conf HOOKS. Changes from traditional 'encrypt' hook to systemd-based 'sd-encrypt' hook, which supports FIDO2 authentication." "sed -i 's/^HOOKS=.*/$NEW_HOOKS/' /etc/mkinitcpio.conf"; then
    sed -i "s/^HOOKS=.*/$NEW_HOOKS/" /etc/mkinitcpio.conf
    info "mkinitcpio.conf updated."
fi

# Update GRUB
NEW_CMDLINE="GRUB_CMDLINE_LINUX=\"rd.luks.name=$LUKS_UUID=root rd.luks.options=fido2-device=auto root=/dev/mapper/root\""
echo ""
info "Current GRUB_CMDLINE_LINUX:"
grep "^GRUB_CMDLINE_LINUX=" /etc/default/grub
info "New GRUB_CMDLINE_LINUX:"
echo "    $NEW_CMDLINE"
if confirm "Update GRUB kernel parameters. Changes from 'cryptdevice=' syntax to 'rd.luks.name=' syntax with FIDO2 option. This tells the initramfs to use your YubiKey for decryption." "sed -i 's|^GRUB_CMDLINE_LINUX=.*|$NEW_CMDLINE|' /etc/default/grub"; then
    sed -i "s|^GRUB_CMDLINE_LINUX=.*|$NEW_CMDLINE|" /etc/default/grub
    info "GRUB config updated."
fi

# Regenerate initramfs
if confirm "Regenerate initramfs with new hooks. This rebuilds the initial ramdisk to include FIDO2 support. Required for changes to take effect." "mkinitcpio -P"; then
    mkinitcpio -P
fi

# Regenerate GRUB
if confirm "Regenerate GRUB configuration. Applies the new kernel parameters to your bootloader." "grub-mkconfig -o /boot/grub/grub.cfg"; then
    grub-mkconfig -o /boot/grub/grub.cfg
fi

# Verify
echo ""
info "Enrollment status:"
systemd-cryptenroll "$LUKS_DEVICE"

echo ""
info "Setup complete. Reboot and enter your YubiKey PIN + touch to unlock."
warn "Keep your passphrase as backup (slot 0)."
