# rpi_buildbot

Right now only the build_image.sh script is working. Usage : on a fresh install of Raspbian set the root password as yunohost, install git, then git clone https://github.com/YunoHost/install_script /tmp/install_script, chmod +x build_image.sh and execute the script.

# Overview:

-	When the farm is idle, the Raspberry is booted on a clean Raspbian image from usb

-	The build is called, we check if the latest raspbian lite downloaded is still the latest, we download the latest if needed
-	The image is burned to the sd card
-	We grab and copy the installation script to the sd card. The script (build_image.sh) will:

  o	Set root password as “yunohost”
  
  o	Proceed to Yunohost installation
  
  o	Update image
  
  o	Change hostname
  
  o	Allow SSH connection as root
  
  o	Delete the pi user
  
  o	Copy the first-boot script, make it executable and run at first boot. This script (yunohost-firstboot) will, at the first user boot:
  
    -	Expand the partition to fit the sd card
    
    -	Generate new SSH keys
    
    -	Delete itself once done
    
  o	Copy the boot_prompt script and make it run at boot 
  
•	We reboot the Raspberry Pi, this time on the usb

•	The image preparation script is executed

•	We reboot on the usb, create an img from the sd card

•	We shrink the image to the smallest size

•	The sd card is formatted 
