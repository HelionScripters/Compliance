#!/bin/bash

# Elevate to root if not already
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (use sudo)"
  exit 1
fi

echo "Installing XRDP..."
apt-get update -y
apt-get install xrdp -y

echo "Stopping XRDP service..."
systemctl stop xrdp

echo "Updating /etc/xrdp/xrdp.ini..."

# Backup existing config
cp /etc/xrdp/xrdp.ini /etc/xrdp/xrdp.ini.bak

# Apply required changes
sed -i 's/^port=3389/port=vsock:\/\/-1:3389/' /etc/xrdp/xrdp.ini
sed -i 's/^security_layer=negotiate/security_layer=rdp/' /etc/xrdp/xrdp.ini
sed -i 's/^bitmap_compression=true/bitmap_compression=false/' /etc/xrdp/xrdp.ini

echo "Updating /etc/xrdp/startwm.sh..."

# Backup existing file
cp /etc/xrdp/startwm.sh /etc/xrdp/startwm.sh.bak

# Add required environment variables under comments section
sed -i '/# locale and the user environment properly\./a\
export GNOME_SHELL_SESSION_MODE=ubuntu\
export XDG_CURRENT_DESKTOP=ubuntu:GNOME
' /etc/xrdp/startwm.sh


echo "Reloading systemd daemon..."
systemctl daemon-reload

#Hyper‑V Integration Services (Enlightenments)
echo "Settting up Hyper‑V Integration Services (Enlightenments)"

apt install linux-tools-generic linux-cloud-tools-generic linux-tools-$(uname -r) linux-cloud-tools-$(uname -r) -y

systemctl enable hv-kvp-daemon

echo "Creating monthly maintenance cron jobs..."

cat << 'EOF' | crontab -
# Monthly maintenance - 2:00 AM on the 28th
0 2 28 * * apt-get update && apt-get dist-upgrade -y

# Monthly reboot - 4:00 AM on the 28th
0 4 28 * * reboot
EOF

echo "Setup complete. Poweroff System."