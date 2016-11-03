
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

apt-get install git -y
git clone https://github.com/YunoHost/install_script /tmp/install_script

# If we are on the Raspberry Pi Zero http://elinux.org/RPi_HardwareHistory
if [[ $( cat /proc/cpuinfo | grep 'Revision' | awk '{print $3}' | sed 's/^1000//') == *"9000"* ]]; then
    apt-get install -y ssl-cert lua-event lua-expat lua-socket lua-sec lua-filesystem
    cd /tmp/install_script && wget https://github.com/likeitneverwentaway/rpi_buildbot/raw/master/metronome_3.7.9%2B33b7572-1_armhf.deb
    dpkg -i metronome_3.7.9+33b7572-1_armhf.deb
    apt-mark hold metronome
fi


cd /tmp/install_script && sudo ./install_yunohost -a

sed -i '0,/without-password/s/without-password/yes/g' /etc/ssh/sshd_config
deluser --remove-all-files pi
sed -i 's/raspberrypi/YunoHost/g' /etc/hosts
sed -i 's/raspberrypi/YunoHost/g' /etc/hostname
wget https://raw.githubusercontent.com/likeitneverwentaway/rpi_buildbot/master/yunohost-firstboot https://raw.githubusercontent.com/YunoHost/packages_old/0a4a0bb49d3754a14aff579d8f8ca8a21507b280/yunohost-config-others/config/others/boot_prompt.sh -P /etc/init.d/
chmod a+x /etc/init.d/yunohost-firstboot /etc/init.d/boot_prompt.sh
insserv /etc/init.d/yunohost-firstboot
update-rc.d boot_prompt.sh defaults

rm /var/rpi_update
# Delete me
rm $0
