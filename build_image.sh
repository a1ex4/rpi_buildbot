
#!/bin/bash
#
# After the image has been written, we mount the second partition of the sd card, place this script in /etc/init.d/
# and make it executable
#sudo passwd root

if ! [ -e /var/rpi_update ]; then

    # https://github.com/RPi-Distro/raspberrypi-sys-mods/issues/6#issuecomment-254902333
    sed -i 's/frontend=pager/frontend=text/' /etc/apt/listchanges.conf
    apt-get update ; apt-get dist-upgrade -y ; apt-get install rpi-update ; rpi-update
    sed -i 's/frontend=text/frontend=pager/' /etc/apt/listchanges.conf
    touch /var/rpi_update
    reboot
fi

# If we are on the Raspberry Pi Zero http://elinux.org/RPi_HardwareHistory
if [[ $( cat /proc/cpuinfo | grep 'Revision' | awk '{print $3}' | sed 's/^1000//') == *"9000"* ]]; then
    apt-get install -y ssl-cert lua-event lua-expat lua-socket lua-sec lua-filesystem
    cd /tmp/install_script
    dpkg -i metronome_3.7.9+33b7572-1_armhf.deb
    apt-mark hold metronome
fi

# Yunohost install
cd /tmp/install_script
chmod +x install_script
sudo ./install_yunohost -a

# Allow ssh as root
sed -i '0,/without-password/s/without-password/yes/g' /etc/ssh/sshd_config

# Delete pi user
deluser --remove-all-files pi

# Change hostname
sed -i 's/raspberrypi/YunoHost/g' /etc/hosts
sed -i 's/raspberrypi/YunoHost/g' /etc/hostname

# Setup scripts
chmod a+x yunohost-firstboot boot_prompt.sh
cp yunohost-firstboot /etc/init.d/
cp boot_prompt.sh /usr/bin/
insserv /etc/init.d/yunohost-firstboot
touch /var/firstboot
cp boot_prompt.service /etc/systemd/system/
systemctl enable boot_prompt.service

rm /var/rpi_update
# Delete me
rm $0
