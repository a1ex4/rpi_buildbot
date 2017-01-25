#!/usr/bin/env bash

# screenFetch - a CLI Bash script to show system/theme info in screenshots

# Copyright (c) 2010-2016 Brett Bohnenkamper <kittykatt@kittykatt.us>

#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Yes, I do realize some of this is horribly ugly coding. Any ideas/suggestions would be
# appreciated by emailing me or by stopping by http://github.com/KittyKatt/screenFetch. You
# could also drop in on the IRC channel at irc://irc.rizon.net/screenFetch.
# to put forth suggestions/ideas. Thank you.

# Requires: bash 4.0+
# Optional dependencies: xorg-xdpyinfo (resoluton detection)
#                        scrot (screenshot taking)
#                        curl (screenshot uploading)


#LANG=C
#LANGUAGE=C
#LC_ALL=C


scriptVersion="3.7.0"

######################
# Settings for fetcher
######################

# This setting controls what ASCII logo is displayed.
# distro="Linux"

# This sets the information to be displayed. Available: distro, Kernel, DE, WM, Win_theme, Theme, Icons, Font, Background, ASCII. To get just the information, and not a text-art logo, you would take "ASCII" out of the below variable.
#display="distro host kernel uptime pkgs shell res de wm wmtheme gtk disk cpu gpu mem"
valid_display=( maindomain localip publicip ynhversion distro host kernel uptime pkgs shell res de wm wmtheme gtk disk cpu gpu mem )
display=( maindomain localip publicip ynhversion distro host kernel uptime res de wm wmtheme gtk disk cpu gpu mem )
# Display Type: ASCII or Text
display_type="ASCII"
# Plain logo
display_logo="no"

# Colors to use for the information found. These are set below according to distribution. If you would like to set your OWN color scheme for these, uncomment the lines below and edit them to your heart's content.
# textcolor="\e[0m"
# labelcolor="\e[1;34m"

# WM & DE process names
# Removed WM's: compiz
wmnames=( fluxbox openbox blackbox xfwm4 metacity kwin twin icewm pekwm flwm flwm_topside fvwm dwm awesome wmaker stumpwm musca xmonad.* i3 ratpoison scrotwm spectrwm wmfs wmii beryl subtle e16 enlightenment sawfish emerald monsterwm dminiwm compiz Finder herbstluftwm howm notion bspwm cinnamon 2bwm echinus swm budgie-wm dtwm 9wm chromeos-wm deepin-wm sway )
denames=( gnome-session xfce-mcs-manage xfce4-session xfconfd ksmserver lxsession lxqt-session gnome-settings-daemon mate-session mate-settings-daemon Finder deepin )



# Verbose Setting - Set to 1 for verbose output.
verbosity=


# The below function will allow you to add custom lines of text to the screenfetch output.
# It will automatically be executed at the right moment if use_customlines is set to 1.
use_customlines=
customlines () {
	# The following line can serve as an example.
	# feel free to let the computer generate the output: e. g. using $(cat /etc/motd) or $(upower -d | grep THISORTHAT)
	# In the example cutom0 line replace <YOUR LABEL> and <your text> with options specified by you.
	# Also make sure the $custom0 variable in out_array=... matches the one at the beginning of the line
	#
	custom0=$(echo -e "$labelcolor YOUR LABEL:$textcolor your text"); out_array=( "${out_array[@]}" "$custom0" ); ((display_index++));

	# Battery percentage and time to full/empty:
	# (uncomment lines below to use)
	#
	#custom1=$(echo -e "$labelcolor Battery:$textcolor $(upower -d | grep percentage | head -n1 | cut -d ' ' -f 15-)"); out_array=( "${out_array[@]}" "$custom1" ); ((display_index++));
	#if [ "$(upower -d | grep time)" ]; then
	#	battery_time="$(upower -d | grep time | head -n1 | cut -d ' ' -f 14-) $(upower -d | grep time | head -n1 | cut -d ' ' -f 6-7 | cut -d ':' -f1)"
	#else
	#	battery_time="power supply plugged in"
	#fi
	#custom2=$(echo -e "$labelcolor $(echo '  `->')$textcolor $battery_time"); out_array=( "${out_array[@]}" "$custom2" ); ((display_index++));

	# Display public IP:
	#custom3=$(echo -e "$labelcolor Public IP:$textcolor $(curl -s ipinfo.io/ip)"); out_array=( "${out_array[@]}" "$custom3" ); ((display_index++));

	###########################################
	##	MY CUSTOM LINES
	###########################################

	#custom4=...
}


#############################################
#### CODE No need to edit past here CODE ####
#############################################

#########################################
# Static Variables and Common Functions #
#########################################
c0="\033[0m" # Reset Text
bold="\033[1m" # Bold Text
underline="\033[4m" # Underline Text
display_index=0

# User options
gtk_2line="no"

# Static Color Definitions
colorize () {
	printf "\033[38;5;$1m"
}
getColor () {
	if [[ -n "$1" ]]; then
		if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
			if [[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -gt 1 ]] || [[ ${BASH_VERSINFO[0]} -gt 4 ]]; then
				tmp_color=${1,,}
			else
				tmp_color="$(tr '[:upper:]' '[:lower:]' <<< ${1})"
			fi
		else
			tmp_color="$(tr '[:upper:]' '[:lower:]' <<< ${1})"
		fi
		case "${tmp_color}" in
			'black')	color_ret='\033[0m\033[30m';;
			'red')		color_ret='\033[0m\033[31m';;
			'green')	color_ret='\033[0m\033[32m';;
			'brown')	color_ret='\033[0m\033[33m';;
			'blue')		color_ret='\033[0m\033[34m';;
			'purple')	color_ret='\033[0m\033[35m';;
			'cyan')		color_ret='\033[0m\033[36m';;
			'yellow')	color_ret='\033[0m\033[1;33m';;
			'white')	color_ret='\033[0m\033[1;37m';;

			'dark grey')	color_ret='\033[0m\033[1;30m';;
			'light red')	color_ret='\033[0m\033[1;31m';;
			'light green')	color_ret='\033[0m\033[1;32m';;
			'light blue')	color_ret='\033[0m\033[1;34m';;
			'light purple')	color_ret='\033[0m\033[1;35m';;
			'light cyan')	color_ret='\033[0m\033[1;36m';;
			'light grey')	color_ret='\033[0m\033[37m';;
			# Some 256 colors
			'orange') color_ret="$(colorize '202')";;
			# HaikuOS
			'black_haiku') color_ret="$(colorize '7')";;
			#ROSA color
			'rosa_blue') color_ret='\033[01;38;05;25m';;
		esac
		[[ -n "${color_ret}" ]] && echo "${color_ret}"
	else
		:
	fi
}

verboseOut () {
	if [[ "$verbosity" -eq "1" ]]; then
		printf "\033[1;31m:: \033[0m$1\n"
	fi
}

errorOut () {
	printf "\033[1;37m[[ \033[1;31m! \033[1;37m]] \033[0m$1\n"
}
stderrOut () {
	while IFS='' read -r line; do printf "\033[1;37m[[ \033[1;31m! \033[1;37m]] \033[0m${line}\n"; done
}


####################
#  Color Defines
####################

colorNumberToCode () {
	number="$1"
	if [[ "${number}" == "na" ]]; then
		unset code
	elif [[ $(tput colors) -eq "256" ]]; then
		code=$(colorize "${number}")
	else
		case "$number" in
			0|00) code=$(getColor 'black');;
			1|01) code=$(getColor 'red');;
			2|02) code=$(getColor 'green');;
			3|03) code=$(getColor 'brown');;
			4|04) code=$(getColor 'blue');;
			5|05) code=$(getColor 'purple');;
			6|06) code=$(getColor 'cyan');;
			7|07) code=$(getColor 'light grey');;
			8|08) code=$(getColor 'dark grey');;
			9|09) code=$(getColor 'light red');;
			  10) code=$(getColor 'light green');;
			  11) code=$(getColor 'yellow');;
			  12) code=$(getColor 'light blue');;
			  13) code=$(getColor 'light purple');;
			  14) code=$(getColor 'light cyan');;
			  15) code=$(getColor 'white');;
			*) unset code;;
		esac
	fi
	echo -n "${code}"
}


detectColors () {
	my_colors=$(sed 's/^,/na,/;s/,$/,na/;s/,/ /' <<< "${OPTARG}")
	my_lcolor=$(awk -F' ' '{print $1}' <<< "${my_colors}")
	my_lcolor=$(colorNumberToCode "${my_lcolor}")

	my_hcolor=$(awk -F' ' '{print $2}' <<< "${my_colors}")
	my_hcolor=$(colorNumberToCode "${my_hcolor}")
}

supported_distros="Alpine Linux, Antergos, Arch Linux (Old and Current Logos), BLAG, BunsenLabs, CentOS, Chakra, Chapeau, Chrome OS, Chromium OS, CrunchBang, CRUX, Debian, Deepin, Devuan, Dragora, elementary OS, Evolve OS, Exherbo, Fedora, Frugalware, Fuduntu, Funtoo, Fux, Gentoo, gNewSense, Jiyuu Linux, Kali Linux, KaOS, KDE neon, Kogaion, Korora, LinuxDeepin, Linux Mint, LMDE, Logos, Mageia, Mandriva/Mandrake, Manjaro, Mer, Netrunner, NixOS, openSUSE, Oracle Linux, Parabola GNU/Linux-libre, Pardus, Parrot Security, PCLinuxOS, PeppermintOS, Qubes OS, Raspbian, Red Hat Enterprise Linux, ROSA, Sabayon, SailfishOS, Scientific Linux, Slackware, Solus, SparkyLinux, SteamOS, SUSE Linux Enterprise, SwagArch, TinyCore, Trisquel, Ubuntu, Viperr and Void."
supported_other="Dragonfly/Free/Open/Net BSD, Haiku, Mac OS X, Windows+Cygwin and Windows+MSYS2."
supported_dms="KDE, GNOME, Unity, Xfce, LXDE, Cinnamon, MATE, Deepin, CDE, RazorQt and Trinity."
supported_wms="2bwm, 9wm, Awesome, Beryl, Blackbox, Cinnamon, chromeos-wm, Compiz, deepin-wm, dminiwm, dwm, dtwm, E16, E17, echinus, Emerald, FluxBox, FLWM, FVWM, herbstluftwm, howm, IceWM, KWin, Metacity, monsterwm, Musca, Gala, Mutter, Muffin, Notion, OpenBox, PekWM, Ratpoison, Sawfish, ScrotWM, SpectrWM, StumpWM, subtle, sway, TWin, WindowMaker, WMFS, wmii, Xfwm4, XMonad and i3."




############################
# Override Options/Display
############################

if [[ "$overrideOpts" ]]; then
	verboseOut "Found 'o' flag in syntax. Overriding some script variables..."
	OLD_IFS="$IFS"
	IFS=";"
	for overopt in "${overrideOpts}"; do
		eval "${overrideOpts}"
	done
	IFS="$OLD_IFS"
fi


#########################
# Begin Detection Phase
#########################

# Yunohost version
detectynhversion() {
	if [ -e /etc/yunohost/installed ]; then
		ynhversion=$(yunohost -v --output-as json| python -c 'import json,sys;obj=json.load(sys.stdin);print obj["yunohost"]')
		verboseOut "Finding YunoHost version...found as '${ynhversion}'"
	fi
	}

	
detectpublicip() {
	publicip=$(curl -s ipinfo.io/ip)
}


detectlocalip() {
	localip=$(/sbin/ifconfig | sed '/Bcast/!d' | awk '{print $2}' | sed 's/.*\://')
}


detectmaindomain() {
	if [ -e /etc/yunohost/installed ]; then
		maindomain=$(cat /etc/yunohost/current_host)
	fi}}


# Distro Detection - Begin
detectdistro () {
	if [[ -z "${distro}" ]]; then
		distro="Unknown"
		# LSB Release Check
		if type -p lsb_release >/dev/null 2>&1; then
			# read distro_detect distro_release distro_codename <<< $(lsb_release -sirc)
			distro_detect=( $(lsb_release -sirc) )
			if [[ ${#distro_detect[@]} -eq 3 ]]; then
				distro_codename=${distro_detect[2]}
				distro_release=${distro_detect[1]}
				distro_detect=${distro_detect[0]}
			else
				for ((i=0; i<${#distro_detect[@]}; i++)); do
					if [[ ${distro_detect[$i]} =~ ^[[:digit:]]+((.[[:digit:]]+|[[:digit:]]+|)+)$ ]]; then
						distro_release=${distro_detect[$i]}
						distro_codename=${distro_detect[@]:$(($i+1)):${#distro_detect[@]}+1}
						distro_detect=${distro_detect[@]:0:${i}}
						break 1
					elif [[ ${distro_detect[$i]} =~ [Nn]/[Aa] || ${distro_detect[$i]} == "rolling" ]]; then
						distro_release=${distro_detect[$i]}
						distro_codename=${distro_detect[@]:$(($i+1)):${#distro_detect[@]}+1}
						distro_detect=${distro_detect[@]:0:${i}}
						break 1
					fi
				done
			fi
			case "${distro_detect}" in
				"CentOS"|"Chapeau"|"Deepin"|"Devuan"|"Fedora"|"gNewSense"|"Jiyuu Linux"|"Kogaion"|"Korora"|"Mageia"|"Netrunner"|"NixOS"|"Pardus"|"Raspbian"|"Sabayon"|"Solus"|"SteamOS"|"Trisquel"|"Ubuntu"|"GrombyangOS")
					# no need to fix $distro/$distro_codename/$distro_release
					distro="${distro_detect}"
					;;
				"archlinux"|"Arch Linux"|"arch"|"Arch"|"archarm")
					distro="Arch Linux"
					distro_release="n/a"
					if grep -q 'antergos' /etc/os-release; then
						distro="Antergos"
						distro_release="n/a"
					fi
					if grep -q -i 'logos' /etc/os-release; then
						distro="Logos"
						distro_release="n/a"
					fi
					if grep -q -i 'swagarch' /etc/os-release; then
						distro="SwagArch"
						distro_release="n/a"
					fi
					;;
				"BLAG")
					distro="BLAG"
					distro_more="$(head -n1 /etc/fedora-release)"
					;;
				"Chakra")
					distro="Chakra"
					distro_release=""
					;;
				"BunsenLabs")
					distro=$(source /etc/lsb-release; echo "$DISTRIB_ID")
					distro_release=$(source /etc/lsb-release; echo "$DISTRIB_RELEASE")
					distro_codename=$(source /etc/lsb-release; echo "$DISTRIB_CODENAME")
					;;
				"Debian")
					if [[ -f /etc/crunchbang-lsb-release || -f /etc/lsb-release-crunchbang ]]; then
						distro="CrunchBang"
						distro_release=$(awk -F'=' '/^DISTRIB_RELEASE=/ {print $2}' /etc/lsb-release-crunchbang)
						distro_codename=$(awk -F'=' '/^DISTRIB_DESCRIPTION=/ {print $2}' /etc/lsb-release-crunchbang)
					elif [[ -f /etc/os-release ]]; then
						if [[ "$(cat /etc/os-release)" =~ "Raspbian" ]]; then
							distro="Raspbian"
							distro_release=$(awk -F'=' '/^PRETTY_NAME=/ {print $2}' /etc/os-release)
            fi
						if [[ "$(cat /etc/os-release)" =~ "BlankOn" ]]; then
							distro="BlankOn"
							distro_release=$(awk -F'=' '/^PRETTY_NAME=/ {print $2}' /etc/os-release)
						else
							distro="Debian"
						fi
					else
						distro="Debian"
					fi
					;;
				"elementary"|"elementary OS")
					distro="elementary OS"
					;;
				"EvolveOS")
					distro="Evolve OS"
					;;
				"KaOS"|"kaos")
					distro="KaOS"
					;;
				"frugalware")
					distro="Frugalware"
					distro_codename=null
					distro_release=null
					;;
				"Fuduntu")
					distro="Fuduntu"
					distro_codename=null
					;;
				"Fux")
					distro="Fux"
					distro_codename=null
					;;
				"Gentoo")
					if [[ "$(lsb_release -sd)" =~ "Funtoo" ]]; then
						distro="Funtoo"
					else
						distro="Gentoo"
					fi
					;;
				"LinuxDeepin")
					distro="LinuxDeepin"
					distro_codename=null
					;;
				"Kali"|"Debian Kali Linux")
					distro="Kali Linux"
					if [[ "${distro_codename}" =~ "kali-rolling" ]]; then
						distro_codename="n/a"
						distro_release="n/a"
					fi
					;;
				"Lunar Linux"|"lunar")
					distro="Lunar Linux"
					;;
				"MandrivaLinux")
					distro="Mandriva"
					case "${distro_codename}" in
						"turtle"|"Henry_Farman"|"Farman"|"Adelie"|"pauillac")
							distro="Mandriva-${distro_release}"
							distro_codename=null
							;;
					esac
					;;
				"ManjaroLinux")
					distro="Manjaro"
					;;
				"Mer")
					distro="Mer"
					if [[ -f /etc/os-release ]]; then
						if grep -q 'SailfishOS' /etc/os-release; then
							distro="SailfishOS"
							distro_codename="$(grep 'VERSION=' /etc/os-release | cut -d '(' -f2 | cut -d ')' -f1)"
							distro_release="$(awk -F'=' '/^VERSION=/ {print $2}' /etc/os-release)"
						fi
					fi
					;;
				"neon"|"KDE neon")
					distro="KDE neon"
					distro_codename="n/a"
					distro_release="n/a"
					if [[ -f /etc/issue ]]; then
						if grep -q "^KDE neon" /etc/issue ; then
							distro_release="$(grep '^KDE neon' /etc/issue | cut -d ' ' -f3)"
						fi
					fi
					;;
				"Ol"|"ol"|"Oracle Linux")
					distro="Oracle Linux"
					[ -f /etc/oracle-release ] && distro_release="$(sed 's/Oracle Linux //' /etc/oracle-release)"
					;;
				"LinuxMint")
					distro="Mint"
					if [[ "${distro_codename}" == "debian" ]]; then
						distro="LMDE"
						distro_codename="n/a"
						distro_release="n/a"
					fi
					;;
				"openSUSE"|"openSUSE project"|"SUSE LINUX")
					distro="openSUSE"
					if [ -f /etc/os-release ]; then
						if [[ "$(cat /etc/os-release)" =~ "SUSE Linux Enterprise" ]]; then
							distro="SUSE Linux Enterprise"
							distro_codename="n/a"
							distro_release=$(awk -F'=' '/^VERSION_ID=/ {print $2}' /etc/os-release | tr -d '"')
						fi
					fi
					if [[ "${distro_codename}" == "Tumbleweed" ]]; then
						distro_release="n/a"
					fi
					;;
				"Parabola GNU/Linux-libre"|"Parabola")
					distro="Parabola GNU/Linux-libre"
					distro_codename="n/a"
					distro_release="n/a"
					;;
				"Parrot"|"Parrot Security")
					distro="Parrot Security"
					;;
				"PCLinuxOS")
					distro="PCLinuxOS"
					distro_codename="n/a"
					distro_release="n/a"
					;;
				"Peppermint")
					distro="Peppermint"
					distro_codename=null
					;;
				"rhel")
					distro="Red Hat Enterprise Linux"
					;;
				"RosaDesktopFresh")
					distro="ROSA"
					distro_release=$(grep 'VERSION=' /etc/os-release | cut -d ' ' -f3 | cut -d "\"" -f1)
					distro_codename=$(grep 'PRETTY_NAME=' /etc/os-release | cut -d ' ' -f4,4)
					;;
				"SailfishOS")
					distro="SailfishOS"
					if [[ -f /etc/os-release ]]; then
						distro_codename="$(grep 'VERSION=' /etc/os-release | cut -d '(' -f2 | cut -d ')' -f1)"
						distro_release="$(awk -F'=' '/^VERSION=/ {print $2}' /etc/os-release)"
					fi
					;;
				"Sparky"|"SparkyLinux")
					distro="SparkyLinux"
					;;
				"Viperr")
					distro="Viperr"
					distro_codename=null
					;;
				*)
					if [ "x$(printf "${distro_detect}" | od -t x1 | sed -e 's/^\w*\ *//' | tr '\n' ' ' | grep 'eb b6 89 ec 9d 80 eb b3 84 ')" != "x" ]; then
						distro="Red Star OS"
						distro_codename="n/a"
						distro_release=$(printf "${distro_release}" | grep -o '[0-9.]' | tr -d '\n')
					fi
					;;
			esac
			if [[ "${distro_detect}" =~ "RedHatEnterprise" ]]; then distro="Red Hat Enterprise Linux"; fi
			if [[ "${distro_detect}" =~ "SUSELinuxEnterprise" ]]; then distro="SUSE Linux Enterprise"; fi
			if [[ -n ${distro_release} && ${distro_release} != "n/a" ]]; then distro_more="$distro_release"; fi
			if [[ -n ${distro_codename} && ${distro_codename} != "n/a" ]]; then distro_more="$distro_more $distro_codename"; fi
		fi

		# Existing File Check
		if [ "$distro" == "Unknown" ]; then
			if [ $(uname -o 2>/dev/null) ]; then
				os="$(uname -o)"
				case "$os" in
					"Cygwin"|"FreeBSD"|"OpenBSD"|"NetBSD")
						distro="$os"
						fake_distro="${distro}"
					;;
					"DragonFly")
						distro="DragonFlyBSD"
						fake_distro="${distro}"
					;;
					"Msys")
						distro="Msys"
						fake_distro="${distro}"
						distro_more="${distro} $(uname -r | head -c 1)"
					;;
					"Haiku")
						distro="Haiku"
						distro_more="$(uname -v | tr ' ' '\n' | grep 'hrev')"
					;;
					"GNU/Linux")
						if type -p crux >/dev/null 2>&1; then
							distro="CRUX"
							distro_more="$(crux | awk '{print $3}')"
						fi
						if type -p nixos-version >/dev/null 2>&1; then
							distro="NixOS"
							distro_more="$(nixos-version)"
						fi
					;;
				esac
			fi
			if [[ "${distro}" == "Cygwin" || "${distro}" == "Msys" ]]; then
				# https://msdn.microsoft.com/en-us/library/ms724832%28VS.85%29.aspx
				if [ "$(wmic os get version | grep -o '^\(6\.[23]\|10\)')" ]; then
					fake_distro="Windows - Modern"
				fi
			fi
			if [[ "${distro}" == "Unknown" ]]; then
				if [ -f /etc/os-release ]; then
					distrib_id=$(</etc/os-release);
					for l in $(echo $distrib_id); do
						if [[ ${l} =~ ^ID= ]]; then
							distrib_id=${l//*=}
							distrib_id=${distrib_id//\"/}
							break 1
						fi
					done
					if [[ -n ${distrib_id} ]]; then
						if [[ -n ${BASH_VERSINFO} && ${BASH_VERSINFO} -ge 4 ]]; then
							distrib_id=$(for i in ${distrib_id}; do echo -n "${i^} "; done)
							distro=${distrib_id% }
							unset distrib_id
						else
							distrib_id=$(for i in ${distrib_id}; do FIRST_LETTER=$(echo -n "${i:0:1}" | tr "[:lower:]" "[:upper:]"); echo -n "${FIRST_LETTER}${i:1} "; done)
							distro=${distrib_id% }
							unset distrib_id
						fi
					fi

					# Hotfixes
					[[ "${distro}" == "void" ]] && distro="Void"
					[[ "${distro}" == "evolveos" ]] && distro="Evolve OS"
					[[ "${distro}" == "antergos" ]] && distro="Antergos"
					[[ "${distro}" == "logos" ]] && distro="Logos"
					[[ "${distro}" == "Arch" || "${distro}" == "Archarm" || "${distro}" == "archarm" ]] && distro="Arch Linux"
					[[ "${distro}" == "elementary" ]] && distro="elementary OS"
					[[ "${distro}" == "Fedora" && -d /etc/qubes-rpc ]] && distro="qubes" # Inner VM
					[[ "${distro}" == "Ol" || "${distro}" == "ol" ]] && distro="Oracle Linux"
					if [[ "${distro}" == "Oracle Linux" ]] && [ -f /etc/oracle-release ]; then
						distro_more="$(sed 's/Oracle Linux //' /etc/oracle-release)"
					fi
					[[ "${distro}" == "rhel" ]] && distro="Red Hat Enterprise Linux"
					[[ "${distro}" == "Neon" ]] && distro="KDE neon"
					[[ "${distro}" == "SLED" || "${distro}" == "sled" || "${distro}" == "SLES" || "${distro}" == "sles" ]] && distro="SUSE Linux Enterprise"
					if [[ "${distro}" == "SUSE Linux Enterprise" ]] && [ -f /etc/os-release ]; then
						distro_more="$(awk -F'=' '/^VERSION_ID=/ {print $2}' /etc/os-release | tr -d '"')"
					fi
				fi
			fi

			if [[ "${distro}" == "Unknown" ]]; then
				if [[ "${OSTYPE}" == "linux-gnu" || "${OSTYPE}" == "linux" ]]; then
					if [ -f /etc/lsb-release ]; then
						LSB_RELEASE=$(</etc/lsb-release)
						distro=$(echo ${LSB_RELEASE} | awk 'BEGIN {
							distro = "Unknown"
						}
						{
							if ($0 ~ /[Uu][Bb][Uu][Nn][Tt][Uu]/) {
								distro = "Ubuntu"
								exit
							}
							else if ($0 ~ /[Mm][Ii][Nn][Tt]/ && $0 ~ /[Dd][Ee][Bb][Ii][Aa][Nn]/) {
								distro = "LMDE"
								exit
							}
							else if ($0 ~ /[Mm][Ii][Nn][Tt]/) {
								distro = "Mint"
								exit
							}
						} END {
							print distro
						}')
					fi
				fi
			fi

			if [[ "${distro}" == "Unknown" ]]; then
				if [[ "${OSTYPE}" == "linux-gnu" || "${OSTYPE}" == "linux" || "${OSTYPE}" == "gnu" ]]; then
					if [ -f /etc/arch-release ]; then distro="Arch Linux"
					elif [ -f /etc/chakra-release ]; then distro="Chakra"
					elif [ -f /etc/crunchbang-lsb-release ]; then distro="CrunchBang"
					elif [ -f /etc/debian_version ]; then
						if [ -f /etc/issue ]; then
							if grep -q "gNewSense" /etc/issue ; then
								distro="gNewSense"
							elif grep -q "^KDE neon" /etc/issue ; then
								distro="KDE neon"
								distro_more="$(cut -d ' ' -f3 /etc/issue)"
							else
								distro="Debian"
							fi
						fi
						if grep -q "Kali" /etc/debian_version ; then
							distro="Kali Linux"
						fi
					elif [ -f /etc/dragora-version ]; then distro="Dragora" && distro_more="$(cut -d, -f1 /etc/dragora-version)"
					elif [ -f /etc/evolveos-release ]; then distro="Evolve OS"
					elif [ -f /etc/exherbo-release ]; then distro="Exherbo"
					elif [ -f /etc/fedora-release ]; then
						if grep -q "Korora" /etc/fedora-release; then
							distro="Korora"
						elif grep -q "BLAG" /etc/fedora-release; then
							distro="BLAG"
							distro_more="$(head -n1 /etc/fedora-release)"
						else
							distro="Fedora"
						fi
					elif [ -f /etc/frugalware-release ]; then distro="Frugalware"
					elif [ -f /etc/fux-release ]; then distro="Fux"
					elif [ -f /etc/gentoo-release ]; then
						if grep -q "Funtoo" /etc/gentoo-release ; then
							distro="Funtoo"
						else
							distro="Gentoo"
						fi
					elif [ -f /etc/kogaion-release ]; then distro="Kogaion"
					elif [ -f /etc/mageia-release ]; then distro="Mageia"
					elif [ -f /etc/mandrake-release ]; then
						if grep -q "PCLinuxOS" /etc/mandrake-release ; then
							distro="PCLinuxOS"
						else
							distro="Mandrake"
						fi
					elif [ -f /etc/mandriva-release ]; then
						if grep -q "PCLinuxOS" /etc/mandriva-release ; then
							distro="PCLinuxOS"
						else
							distro="Mandriva"
						fi
					elif [ -f /etc/NIXOS ]; then distro="NixOS"
					elif [ -f /etc/obarun-release ]; then distro="Obarun"
					elif [ -f /etc/oracle-release ]; then
						distro="Oracle Linux"
						distro_more="$(sed 's/Oracle Linux //' /etc/oracle-release)"
					elif [ -f /etc/SuSE-release ]; then
						distro="openSUSE"
						if [ -f /etc/os-release ]; then
							if [[ "$(cat /etc/os-release)" =~ "SUSE Linux Enterprise" ]]; then
								distro="SUSE Linux Enterprise"
								distro_more=$(awk -F'=' '/^VERSION_ID=/ {print $2}' /etc/os-release | tr -d '"')
							fi
						fi
						if [[ "${distro_more}" =~ "Tumbleweed" ]]; then distro_more="Tumbleweed"; fi
					elif [ -f /etc/pardus-release ]; then distro="Pardus"
					elif [ -f /etc/pclinuxos-release ]; then distro="PCLinuxOS"
					elif [ -f /etc/redstar-release ]; then
						distro="Red Star OS"
						distro_more=$(grep -o '[0-9.]' /etc/redstar-release | tr -d '\n')
					elif [ -f /etc/redhat-release ]; then
						if grep -q "CentOS" /etc/redhat-release; then
							distro="CentOS"
						elif grep -q "PCLinuxOS" /etc/redhat-release; then
							distro="PCLinuxOS"
						elif [ "x$(od -t x1 /etc/redhat-release | sed -e 's/^\w*\ *//' | tr '\n' ' ' | grep 'eb b6 89 ec 9d 80 eb b3 84 ')" != "x" ]; then
							distro="Red Star OS"
							distro_more=$(grep -o '[0-9.]' /etc/redhat-release | tr -d '\n')
						else
							distro="Red Hat Enterprise Linux"
						fi
					elif [ -f /etc/rosa-release ]; then distro="ROSA"
					elif [ -f /etc/slackware-version ]; then distro="Slackware"
					elif [ -f /usr/share/doc/tc/release.txt ]; then
						distro="TinyCore"
						distro_more="$(cat /usr/share/doc/tc/release.txt)"
					elif [ -f /etc/sabayon-edition ]; then distro="Sabayon"; fi
				else
					if [[ -x /usr/bin/sw_vers ]] && /usr/bin/sw_vers | grep -i "Mac OS X" >/dev/null; then
						distro="Mac OS X"
					elif [[ -f /var/run/dmesg.boot ]]; then
						distro=$(awk 'BEGIN {
							distro = "Unknown"
						}
						{
							if ($0 ~ /DragonFly/) {
								distro = "DragonFlyBSD"
								exit
							}
							else if ($0 ~ /FreeBSD/) {
								distro = "FreeBSD"
								exit
							}
							else if ($0 ~ /NetBSD/) {
								distro = "NetBSD"
								exit
							}
							else if ($0 ~ /OpenBSD/) {
								distro = "OpenBSD"
								exit
							}
						} END {
							print distro
						}' /var/run/dmesg.boot)
					fi
				fi
			fi

			if [[ "${distro}" == "Unknown" ]] && [[ "${OSTYPE}" == "linux-gnu" || "${OSTYPE}" == "linux" || "${OSTYPE}" == "gnu" ]]; then
				if [[ -f /etc/issue ]]; then
					distro=$(awk 'BEGIN {
						distro = "Unknown"
					}
					{
						if ($0 ~ /"LinuxDeepin"/) {
							distro = "LinuxDeepin"
							exit
						}
						else if ($0 ~ /"Obarun"/) {
							distro = "Obarun"
							exit
						}
						else if ($0 ~ /"Parabola GNU\/Linux-libre"/) {
							distro = "Parabola GNU/Linux-libre"
							exit
						}
						else if ($0 ~ /"Solus"/) {
							distro = "Solus"
							exit
						}
					} END {
						print distro
					}' /etc/issue)
				fi
			fi

			if [[ "${distro}" == "Unknown" ]] && [[ "${OSTYPE}" == "linux-gnu" || "${OSTYPE}" == "linux" || "${OSTYPE}" == "gnu" ]]; then
				if [[ -f /etc/system-release ]]; then
					if grep -q "Scientific Linux" /etc/system-release; then
						distro="Scientific Linux"
					elif grep -q "Oracle Linux" /etc/system-release; then
						distro="Oracle Linux"
					fi
				elif [[ -f /etc/lsb-release ]]; then
					if grep -q "CHROMEOS_RELEASE_NAME" /etc/lsb-release; then
						distro="$(awk -F'=' '/^CHROMEOS_RELEASE_NAME=/ {print $2}' /etc/lsb-release)"
						distro_more="$(awk -F'=' '/^CHROMEOS_RELEASE_VERSION=/ {print $2}' /etc/lsb-release)"
					fi
				fi
			fi
		fi
	fi

	if [[ -n ${distro_more} ]]; then
		distro_more="${distro} ${distro_more}"
	fi

	if [[ "${distro}" != "Haiku" ]]; then
		if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
			if [[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -gt 1 ]] || [[ ${BASH_VERSINFO[0]} -gt 4 ]]; then
				distro=${distro,,}
			else
				distro="$(tr '[:upper:]' '[:lower:]' <<< ${distro})"
			fi
		else
			distro="$(tr '[:upper:]' '[:lower:]' <<< ${distro})"
		fi
	fi

	case $distro in
		alpine) distro="Alpine Linux" ;;
		antergos) distro="Antergos" ;;
		arch*linux*old) distro="Arch Linux - Old" ;;
		arch|arch*linux) distro="Arch Linux" ;;
		blag) distro="BLAG" ;;
		bunsenlabs) distro="BunsenLabs" ;;
		centos) distro="CentOS" ;;
		chakra) distro="Chakra" ;;
		chapeau) distro="Chapeau" ;;
		chrome*|chromium*) distro="Chrome OS" ;;
		crunchbang) distro="CrunchBang" ;;
		crux) distro="CRUX" ;;
		cygwin) distro="Cygwin" ;;
		debian) distro="Debian" ;;
		devuan) distro="Devuan" ;;
		deepin) distro="Deepin" ;;
		dragonflybsd) distro="DragonFlyBSD" ;;
		dragora) distro="Dragora" ;;
		elementary|'elementary os') distro="elementary OS";;
		evolveos) distro="Evolve OS" ;;
		exherbo|exherbo*linux) distro="Exherbo" ;;
		fedora) distro="Fedora" ;;
		freebsd) distro="FreeBSD" ;;
		freebsd*old) distro="FreeBSD - Old" ;;
		frugalware) distro="Frugalware" ;;
		fuduntu) distro="Fuduntu" ;;
		funtoo) distro="Funtoo" ;;
		fux) distro="Fux" ;;
		gentoo) distro="Gentoo" ;;
		gnewsense) distro="gNewSense" ;;
		haiku) distro="Haiku" ;;
		kali*linux) distro="Kali Linux" ;;
		kaos) distro="KaOS";;
		kde*neon|neon) distro="KDE neon" ;;
		kogaion) distro="Kogaion" ;;
		korora) distro="Korora" ;;
		linuxdeepin) distro="LinuxDeepin" ;;
		lmde) distro="LMDE" ;;
		logos) distro="Logos" ;;
		lunar|lunar*linux) distro="Lunar Linux";;
		mac*os*x|os*x) distro="Mac OS X" ;;
		manjaro) distro="Manjaro" ;;
		mageia) distro="Mageia" ;;
		mandrake) distro="Mandrake" ;;
		mandriva) distro="Mandriva" ;;
		mer) distro="Mer" ;;
		mint|linux*mint) distro="Mint" ;;
		msys|msys2) distro="Msys" ;;
		netbsd) distro="NetBSD" ;;
		netrunner) distro="Netrunner" ;;
		nix|nix*os) distro="NixOS" ;;
		obarun) distro="Obarun" ;;
		ol|oracle*linux) distro="Oracle Linux" ;;
		openbsd) distro="OpenBSD" ;;
		opensuse) distro="openSUSE" ;;
		parabolagnu|parabolagnu/linux-libre|'parabola gnu/linux-libre'|parabola) distro="Parabola GNU/Linux-libre" ;;
		pardus) distro="Pardus" ;;
		parrot|parrot*security) distro="Parrot Security" ;;
		pclinuxos|pclos) distro="PCLinuxOS" ;;
		peppermint) distro="Peppermint" ;;
		qubes) distro="Qubes OS" ;;
		raspbian) distro="Raspbian" ;;
		red*hat*|rhel) distro="Red Hat Enterprise Linux" ;;
		rosa) distro="ROSA" ;;
		red*star|red*star*os) distro="Red Star OS" ;;
		sabayon) distro="Sabayon" ;;
		sailfish|sailfish*os) distro="SailfishOS" ;;
		slackware) distro="Slackware" ;;
		solus) distro="Solus" ;;
		sparky|sparky*linux) distro="SparkyLinux" ;;
		steam|steam*os) distro="SteamOS" ;;
		suse*linux*enterprise) distro="SUSE Linux Enterprise" ;;
		swagarch) distro="SwagArch" ;;
		tinycore|tinycore*linux) distro="TinyCore" ;;
		trisquel) distro="Trisquel";;
		grombyangos) distro="GrombyangOS" ;;
		ubuntu)
			distro="Ubuntu"
			if grep -q 'Microsoft' /proc/version 2>/dev/null || \
			   grep -q 'Microsoft' /proc/sys/kernel/osrelease 2>/dev/null
			then
				uow=$(echo -e "$(getColor 'yellow') [Ubuntu on Windows 10]")
			fi
			;;
		viperr) distro="Viperr" ;;
		void) distro="Void" ;;
	esac
	verboseOut "Finding distro...found as '${distro} ${distro_release}'"
}
# Distro Detection - End


# Host and User detection - Begin
detecthost () {
	myUser=${USER}
	myHost=${HOSTNAME}
	if [[ -z "$USER" ]]; then myUser=$(whoami); fi
	if [[ "${distro}" == "Mac OS X" ]]; then myHost=${myHost/.local}; fi
	verboseOut "Finding hostname and user...found as '${myUser}@${myHost}'"
}

# Find Number of Running Processes
# processnum="$(( $( ps aux | wc -l ) - 1 ))"

# Kernel Version Detection - Begin
detectkernel () {
	# compatibility for older versions of OS X:
	kernel=$(uname -m && uname -sr)
	kernel=${kernel//$'\n'/ }
	#kernel=( $(uname -srm) )
	#kernel="${kernel[${#kernel[@]}-1]} ${kernel[@]:0:${#kernel[@]}-1}"
	verboseOut "Finding kernel version...found as '${kernel}'"
}
# Kernel Version Detection - End


# Uptime Detection - Begin
detectuptime () {
	unset uptime
	if [[ "${distro}" == "Mac OS X" || "${distro}" == "FreeBSD" || "${distro}" == "DragonFlyBSD" ]]; then
		boot=$(sysctl -n kern.boottime | cut -d "=" -f 2 | cut -d "," -f 1)
		now=$(date +%s)
		uptime=$(($now-$boot))
	elif [[ "${distro}" == "OpenBSD" ]]; then
		boot=$(sysctl -n kern.boottime)
		now=$(date +%s)
		uptime=$((${now} - ${boot}))
	elif [[ "${distro}" == "Haiku" ]]; then
		uptime=$(uptime | cut -d ',' -f2,3 | sed 's/ up //; s/ hour,/h/; s/ minutes/m/;')
	else
		if [[ -f /proc/uptime ]]; then
			uptime=$(</proc/uptime)
			uptime=${uptime//.*}
		fi
	fi

	if [[ -n ${uptime} ]] && [[ "${distro}" != "Haiku" ]]; then
		secs=$((${uptime}%60))
		mins=$((${uptime}/60%60))
		hours=$((${uptime}/3600%24))
		days=$((${uptime}/86400))
		uptime="${mins}m"
		if [ "${hours}" -ne "0" ]; then
			uptime="${hours}h ${uptime}"
		fi
		if [ "${days}" -ne "0" ]; then
			uptime="${days}d ${uptime}"
		fi
	else
		if [[ "$distro" =~ "NetBSD" ]]; then uptime=$(awk -F. '{print $1}' /proc/uptime); fi
		if [[ "$distro" =~ "BSD" ]]; then uptime=$(uptime | awk '{$1=$2=$(NF-6)=$(NF-5)=$(NF-4)=$(NF-3)=$(NF-2)=$(NF-1)=$NF=""; sub(" days","d");sub(",","");sub(":","h ");sub(",","m"); print}'); fi
	fi
	verboseOut "Finding current uptime...found as '${uptime}'"
}
# Uptime Detection - End


# Package Count - Begin
detectpkgs () {
	pkgs="Unknown"
	case "${distro}" in
		'Alpine Linux') pkgs=$(apk info | wc -l) ;;
		'Arch Linux'|'Parabola GNU/Linux-libre'|'Chakra'|'Manjaro'|'Antergos'|'Netrunner'|'KaOS'|'Obarun'|'SwagArch') pkgs=$(pacman -Qq | wc -l) ;;
		'Dragora') pkgs=$(ls -1 /var/db/pkg | wc -l) ;;
		'Frugalware') pkgs=$(pacman-g2 -Q | wc -l) ;;
		'Debian'|'Ubuntu'|'Mint'|'Fuduntu'|'KDE neon'|'Devuan'|'Raspbian'|'LMDE'|'CrunchBang'|'Peppermint'|'LinuxDeepin'|'Deepin'|'Kali Linux'|'Trisquel'|'elementary OS'|'gNewSense'|'BunsenLabs'|'SteamOS'|'Parrot Security'|'GrombyangOS') pkgs=$(dpkg -l | grep -c ^i) ;;
		'Slackware') pkgs=$(ls -1 /var/log/packages | wc -l) ;;
		'Gentoo'|'Sabayon'|'Funtoo'|'Chrome OS'|'Kogaion') pkgs=$(ls -d /var/db/pkg/*/* | wc -l) ;;
		'NixOS') pkgs=$(ls -d -1 /nix/store/*/ | wc -l) ;;
		'Fedora'|'Fux'|'Korora'|'BLAG'|'Chapeau'|'openSUSE'|'SUSE Linux Enterprise'|'Red Hat Enterprise Linux'|'ROSA'|'Oracle Linux'|'CentOS'|'Mandriva'|'Mandrake'|'Mageia'|'Mer'|'SailfishOS'|'PCLinuxOS'|'Viperr'|'Qubes OS'|'Red Star OS') pkgs=$(rpm -qa | wc -l) ;;
		'Void') pkgs=$(xbps-query -l | wc -l) ;;
		'Evolve OS'|'Solus') pkgs=$(pisi list-installed | wc -l) ;;
		'CRUX') pkgs=$(pkginfo -i | wc -l) ;;
		'Lunar Linux') pkgs=$(lvu installed | wc -l) ;;
		'TinyCore') pkgs=$(tce-status -i | wc -l) ;;
		'Exherbo')
			xpkgs=$(ls -d -1 /var/db/paludis/repositories/cross-installed/*/data/* | wc -l)
			pkgs=$(ls -d -1 /var/db/paludis/repositories/installed/data/* | wc -l)
			pkgs=$((${pkgs} + ${xpkgs}))
		;;
		'Mac OS X')
			if [ -d "/usr/local/bin" ]; then
				loc_pkgs=$(ls -l /usr/local/bin/ | grep -v "\(../Cellar/\|brew\)" | wc -l)
				pkgs=$((${loc_pkgs} -1));
			fi

			if type -p port >/dev/null 2>&1; then
				port_pkgs=$(port installed 2>/dev/null | wc -l)
				pkgs=$((${pkgs} + (${port_pkgs} -1)))
			fi

			if type -p brew >/dev/null 2>&1; then
				brew_pkgs=$(brew list -1 2>/dev/null | wc -l)
				pkgs=$((${pkgs} + ${brew_pkgs}))
			fi
			if type -p pkgin >/dev/null 2>&1; then
				pkgsrc_pkgs=$(pkgin list 2>/dev/null | wc -l)
				pkgs=$((${pkgs} + ${pkgsrc_pkgs}))
			fi
		;;
		'DragonFlyBSD')
			pkgs=$(if TMPDIR=/dev/null ASSUME_ALWAYS_YES=1 PACKAGESITE=file:///nonexistent pkg info pkg >/dev/null 2>&1; then
				pkg info | wc -l | awk '{print $1}'; else pkg_info | wc -l | tr -d ' '; fi)
		;;
		'OpenBSD')
			pkgs=$(pkg_info | wc -l | awk '{sub(" ", "");print $1}')
		;;
		'FreeBSD')
			pkgs=$(if TMPDIR=/dev/null ASSUME_ALWAYS_YES=1 PACKAGESITE=file:///nonexistent pkg info pkg >/dev/null 2>&1; then
				pkg info | wc -l | awk '{print $1}'; else pkg_info | wc -l | awk '{sub(" ", "");print $1}'; fi)
		;;
		'NetBSD')
			pkgs=$(pkg_info | wc -l | tr -d ' ')
		;;
		'Cygwin')
			cygfix=2
			pkgs=$(($(cygcheck -cd | wc -l) - ${cygfix}))
			if [ -d "/cygdrive/c/ProgramData/chocolatey/lib" ]; then
				chocopkgs=$(( $(ls -1 /cygdrive/c/ProgramData/chocolatey/lib | wc -l) ))
				pkgs=$((${pkgs} + ${chocopkgs}))
			fi
		;;
		'Msys')
			pkgs=$(pacman -Qq | wc -l)
			if [ -d "/c/ProgramData/chocolatey/lib" ]; then
				chocopkgs=$(( $(ls -1 /c/ProgramData/chocolatey/lib | wc -l) ))
				pkgs=$((${pkgs} + ${chocopkgs}))
			fi
		;;
		'Haiku')
			haikualpharelease="no"
			if [ -d /boot/system/package-links ]; then
				pkgs=$(ls /boot/system/package-links | wc -l)
			elif type -p installoptionalpackage >/dev/null 2>&1; then
				haikualpharelease="yes"
				pkgs=$(installoptionalpackage -l | sed -n '3p' | wc -w)
			fi
		;;
	esac
	verboseOut "Finding current package count...found as '$pkgs'"
}




# CPU Detection - Begin
detectcpu () {
	REGEXP="-r"
	if [ "$distro" == "Mac OS X" ]; then
		cpu=$(machine)
		if [[ $cpu == "ppc750" ]]; then
			cpu="IBM PowerPC G3"
		elif [[ $cpu == "ppc7400" || $cpu == "ppc7450" ]]; then
			cpu="IBM PowerPC G4"
		elif [[ $cpu == "ppc970" ]]; then
			cpu="IBM PowerPC G5"
		else
			cpu=$(sysctl -n machdep.cpu.brand_string)
		fi
		REGEXP="-E"
	elif [ "$OSTYPE" == "gnu" ]; then
		# no /proc/cpuinfo on GNU/Hurd
		if [ "$(uname -m | grep 'i.86')" ]; then
			cpu="Unknown x86"
		else
			cpu="Unknown"
		fi
	elif [ "$distro" == "FreeBSD" ]; then
		cpu=$(dmesg | grep 'CPU:' | head -n 1 | sed -r 's/CPU: //' | sed -e 's/([^()]*)//g')
	elif [ "$distro" == "DragonFlyBSD" ]; then
		cpu=$(sysctl -n hw.model)
	elif [ "$distro" == "OpenBSD" ]; then
		cpu=$(sysctl -n hw.model | sed 's/@.*//')
	elif [ "$distro" == "Haiku" ]; then
		cpu=$(sysinfo -cpu | grep 'CPU #0' | cut -d'"' -f2 | awk 'BEGIN{FS=" @"; OFS="\n"} { print $1; exit }')
		cpu_mhz=$(sysinfo -cpu | grep 'running at' | awk 'BEGIN{FS="running at "} { print $2; exit }' | cut -d'M' -f1)
		if [ $(echo $cpu_mhz) -gt 999 ]; then
			cpu_ghz=$(awk '{print $1/1000}' <<< "${cpu_mhz}")
			cpufreq="${cpu_ghz}GHz"
		else
			cpufreq="${cpu_mhz}MHz"
		fi
	else
		cpu=$(awk 'BEGIN{FS=":"} /model name/ { print $2; exit }' /proc/cpuinfo | awk 'BEGIN{FS=" @"; OFS="\n"} { print $1; exit }')
		cpun=$(grep -c '^processor' /proc/cpuinfo)
		if [ -z "$cpu" ]; then
			cpu=$(awk 'BEGIN{FS=":"} /Hardware/ { print $2; exit }' /proc/cpuinfo)
		fi
		if [ -z "$cpu" ]; then
			cpu=$(awk 'BEGIN{FS=":"} /^cpu/ { gsub(/  +/," ",$2); print $2; exit}' /proc/cpuinfo | sed 's/, altivec supported//;s/^ //')
			if [[ $cpu =~ ^(PPC)*9.+ ]]; then
				model="IBM PowerPC G5 "
			elif [[ $cpu =~ 740/750 ]]; then
				model="IBM PowerPC G3 "
			elif [[ $cpu =~ ^74.+ ]]; then
				model="Motorola PowerPC G4 "
			elif [[ "$(cat /proc/cpuinfo)" =~ "BCM2708" ]]; then
				model="Broadcom BCM2835 ARM1176JZF-S"
			else
				arch=$(uname -m)
				if [ "$arch" = "s390x" ] || [ "$arch" = "s390" ]; then
					cpu=""
					args=$(grep 'machine' /proc/cpuinfo | sed 's/^.*://g; s/ //g; s/,/\n/g' | grep '^machine=.*')
					eval $args
					case "$machine" in
						# information taken from https://github.com/SUSE/s390-tools/blob/master/cputype
						2064) model="IBM eServer zSeries 900" ;;
						2066) model="IBM eServer zSeries 800" ;;
						2084) model="IBM eServer zSeries 990" ;;
						2086) model="IBM eServer zSeries 890" ;;
						2094) model="IBM System z9 Enterprise Class" ;;
						2096) model="IBM System z9 Business Class" ;;
						2097) model="IBM System z10 Enterprise Class" ;;
						2098) model="IBM System z10 Business Class" ;;
						2817) model="IBM zEnterprise 196" ;;
						2818) model="IBM zEnterprise 114" ;;
						2827) model="IBM zEnterprise EC12" ;;
						2828) model="IBM zEnterprise BC12" ;;
						2964) model="IBM z13" ;;
						*) model="IBM S/390 machine type $machine" ;;
					esac
				else
					model="Unkown"
				fi
			fi
			cpu="${model}${cpu}"
		fi
		loc="/sys/devices/system/cpu/cpu0/cpufreq"
		bl="${loc}/bios_limit"
		smf="${loc}/scaling_max_freq"
		if [ -f "$bl" ] && [ -r "$bl" ]; then
			cpu_mhz=$(awk '{print $1/1000}' "$bl")
		elif [ -f "$smf" ] && [ -r "$smf" ]; then
			cpu_mhz=$(awk '{print $1/1000}' "$smf")
		else
			cpu_mhz=$(awk -F':' '/cpu MHz/{ print int($2+.5) }' /proc/cpuinfo | head -n 1)
		fi
		if [ -n "$cpu_mhz" ]; then
			if [ $(echo $cpu_mhz | cut -d. -f1) -gt 999 ]; then
				cpu_ghz=$(awk '{print $1/1000}' <<< "${cpu_mhz}")
				cpufreq="${cpu_ghz}GHz"
			else
				cpufreq="${cpu_mhz}MHz"
			fi
		fi
	fi
	if [[ "${cpun}" -gt "1" ]]; then
		cpun="${cpun}x "
	else
		cpun=""
	fi
	if [ -z "$cpufreq" ]; then
		cpu="${cpun}${cpu}"
	else
		cpu="$cpu @ ${cpun}${cpufreq}"
	fi
	thermal="/sys/class/hwmon/hwmon0/temp1_input"
	if [ -e $thermal ]; then
		temp=$(bc <<< "scale=1; $(cat $thermal)/1000")
	fi
	if [ -n "$temp" ]; then
		cpu="$cpu [${temp}°C]"
	fi
	cpu=$(sed $REGEXP 's/\([tT][mM]\)|\([Rr]\)|[pP]rocessor|CPU//g' <<< "${cpu}" | xargs)
	verboseOut "Finding current CPU...found as '$cpu'"
}
# CPU Detection - End


# GPU Detection - Begin (EXPERIMENTAL!)
detectgpu () {
	if [[ "${distro}" == "FreeBSD" || "${distro}" == "DragonFlyBSD" ]]; then
		nvisettexist=$(which nvidia-settings)
		if [ -x "$nvisettexist" ]; then
			gpu="$(nvidia-settings -t -q gpus | grep \( | sed 's/.*(\(.*\))/\1/')"
		else
			gpu_info=$(pciconf -lv 2> /dev/null | grep -B 4 VGA)
			gpu_info=$(grep -E 'device.*=.*' <<< "${gpu_info}")
			gpu="${gpu_info##*device*= }"
			gpu="${gpu//\'}"
			# gpu=$(sed 's/.*device.*= //' <<< "${gpu_info}" | sed "s/'//g")
		fi
	elif [[ "${distro}" == "OpenBSD" ]]; then
		gpu=$(glxinfo 2> /dev/null | grep 'OpenGL renderer string' | sed 's/OpenGL renderer string: //')
	elif [[ "${distro}" == "Mac OS X" ]]; then
		gpu=$(system_profiler SPDisplaysDataType | awk -F': ' '/^\ *Chipset Model:/ {print $2}' | awk '{ printf "%s / ", $0 }' | sed -e 's/\/ $//g')
	elif [[ "${distro}" == "Cygwin" || "${distro}" == "Msys" ]]; then
		gpu=$(wmic path Win32_VideoController get caption | sed -n '2p')
	elif [[ "${distro}" == "Haiku" ]]; then
		gpu="$(listdev | grep -A2 -e 'device Display controller' | tail -n1 | sed 's/  device ....: //')"
	else
		if [[ -n "$(PATH="/opt/bin:$PATH" type -p nvidia-smi)" ]]; then
			gpu=$($(PATH="/opt/bin:$PATH" type -p nvidia-smi | cut -f1) -q | awk -F':' '/Product Name/ {gsub(/: /,":"); print $2}' | sed ':a;N;$!ba;s/\n/, /g')
		elif [[ -n "$(PATH="/usr/sbin:$PATH" type -p glxinfo)" && -z "${gpu}" ]]; then
			gpu_info=$($(PATH="/usr/sbin:$PATH" type -p glxinfo | cut -f1) 2>/dev/null)
			gpu=$(grep "OpenGL renderer string" <<< "${gpu_info}" | cut -d ':' -f2 | sed -n '1h;2,$H;${g;s/\n/,/g;p}')
			gpu="${gpu:1}"
			gpu_info=$(grep "OpenGL vendor string" <<< "${gpu_info}")
		elif [[ -n "$(PATH="/usr/sbin:$PATH" type -p lspci)" && -z "$gpu" ]]; then
			gpu_info=$($(PATH="/usr/bin:$PATH" type -p lspci | cut -f1) 2> /dev/null | grep VGA)
			gpu=$(grep -oE '\[.*\]' <<< "${gpu_info}" | sed 's/\[//;s/\]//' | sed -n '1h;2,$H;${g;s/\n/, /g;p}')
		fi
	fi

	if [ -n "$gpu" ];then
		if [ $(grep -i nvidia <<< "${gpu_info}" | wc -l) -gt 0 ];then
			gpu_info="NVidia "
		elif [ $(grep -i intel <<< "${gpu_info}" | wc -l) -gt 0 ];then
			gpu_info="Intel "
		elif [ $(grep -i amd <<< "${gpu_info}" | wc -l) -gt 0 ];then
			gpu_info="AMD "
		elif [[ $(grep -i ati <<< "${gpu_info}" | wc -l) -gt 0  || $(grep -i radeon <<< "${gpu_info}" | wc -l) -gt 0 ]]; then
			gpu_info="ATI "
		else
			gpu_info=$(cut -d ':' -f2 <<< "${gpu_info}")
			gpu_info="${gpu_info:1} "
		fi
		gpu="${gpu}"
	else
		gpu="Not Found"
	fi

	verboseOut "Finding current GPU...found as '$gpu'"
}
# GPU Detection - End


# Disk Usage Detection - Begin
detectdisk () {
	diskusage="Unknown"
	if type -p df >/dev/null 2>&1; then
		if [[ "${distro}" =~ (Free|Net|Open|DragonFly)BSD ]]; then
			totaldisk=$(df -h -c 2>/dev/null | tail -1)
		elif [[ "${distro}" == "Mac OS X" ]]; then
			totaldisk=$(df -H / 2>/dev/null | tail -1)
		else
			totaldisk=$(df -h -x aufs -x tmpfs --total 2>/dev/null | tail -1)
		fi
		disktotal=$(awk '{print $2}' <<< "${totaldisk}")
		diskused=$(awk '{print $3}' <<< "${totaldisk}")
		diskusedper=$(awk '{print $5}' <<< "${totaldisk}")
		diskusage="${diskused} / ${disktotal} (${diskusedper})"
		diskusage_verbose=$(sed 's/%/%%/' <<< $diskusage)
	fi
	verboseOut "Finding current disk usage...found as '$diskusage_verbose'"
}
# Disk Usage Detection - End


# Memory Detection - Begin
detectmem () {
	if [ "$distro" == "Mac OS X" ]; then
		totalmem=$(echo "$(sysctl -n hw.memsize)" / 1024^2 | bc)
		wiredmem=$(vm_stat | grep wired | awk '{ print $4 }' | sed 's/\.//')
		activemem=$(vm_stat | grep ' active' | awk '{ print $3 }' | sed 's/\.//')
		compressedmem=$(vm_stat | grep occupied | awk '{ print $5 }' | sed 's/\.//')
		if [[ ! -z "$compressedmem | tr -d" ]]; then
			compressedmem=0
		fi
		usedmem=$(((${wiredmem} + ${activemem} + ${compressedmem}) * 4 / 1024))
	elif [[ "${distro}" == "Cygwin" || "${distro}" == "Msys" ]]; then
		total_mem=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)
		totalmem=$((${total_mem} / 1024))
		free_mem=$(awk '/MemFree/ { print $2 }' /proc/meminfo)
		used_mem=$((${total_mem} - ${free_mem}))
		usedmem=$((${used_mem} / 1024))
	elif [[ "$distro" == "FreeBSD"  || "$distro" == "DragonFlyBSD" ]]; then
		phys_mem=$(sysctl -n hw.physmem)
		size_mem=$phys_mem
		size_chip=1
		guess_chip=`echo "$size_mem / 8 - 1" | bc`
		while [ $guess_chip != 0 ]; do
			guess_chip=`echo "$guess_chip / 2" | bc`
			size_chip=`echo "$size_chip * 2" | bc`
		done
		round_mem=`echo "( $size_mem / $size_chip + 1 ) * $size_chip " | bc`
		totalmem=$(($round_mem / 1024^2 ))
		pagesize=$(sysctl -n hw.pagesize)
		inactive_count=$(sysctl -n vm.stats.vm.v_inactive_count)
		inactive_mem=$(($inactive_count * $pagesize))
		cache_count=$(sysctl -n vm.stats.vm.v_cache_count)
		cache_mem=$(($cache_count * $pagesize))
		free_count=$(sysctl -n vm.stats.vm.v_free_count)
		free_mem=$(($free_count * $pagesize))
		avail_mem=$(($inactive_mem + $cache_mem + $free_mem))
		used_mem=$(($round_mem - $avail_mem))
		usedmem=$(($used_mem / 1024^2 ))
	elif [ "$distro" == "OpenBSD" ]; then
		totalmem=$(($(sysctl -n hw.physmem) / 1024^2))
		usedmem=$(($(vmstat | sed -n 3p | awk '{ print $4 }') / 1024))
	elif [ "$distro" == "NetBSD" ]; then
		phys_mem=$(awk '/MemTotal/ { print $2 }' /proc/meminfo)
		totalmem=$((${phys_mem} / 1024))
		if grep -q 'Cached' /proc/meminfo; then
			cache=$(awk '/Cached/ {print $2}' /proc/meminfo)
			usedmem=$((${cache} / 1024))
		else
			free_mem=$(awk '/MemFree/ { print $2 }' /proc/meminfo)
			used_mem=$((${phys_mem} - ${free_mem}))
			usedmem=$((${used_mem} / 1024))
		fi
	elif [ "$distro" == "Haiku" ]; then
		totalmem=$(( $(sysinfo -mem | head -n1 | cut -d'/' -f3 | tr -d ' ' | tr -d ')') / 1024^2 ))
		usedmem=$(( $(sysinfo -mem | head -n1 | cut -d'/' -f2 | sed 's/max//; s/ //g') / 1024^2 ))
	else
		# MemUsed = Memtotal + Shmem - MemFree - Buffers - Cached - SReclaimable
		# Source: https://github.com/dylanaraps/neofetch/pull/391/files#diff-e863270127ca6116fd30e708cdc582fc
		mem_info=$(</proc/meminfo)
		mem_info=$(echo $(echo $(mem_info=${mem_info// /}; echo ${mem_info//kB/})))
		for m in $mem_info; do
			case ${m//:*} in
				"MemTotal") memused=$((memused+=${m//*:})); memtotal=${m//*:} ;;
				"ShMem") memused=$((memused+=${m//*:})) ;;
				"MemFree"|"Buffers"|"Cached"|"SReclaimable") memused=$((memused-=${m//*:})) ;;
			esac
		done
		memused=$((memused / 1024))
		memtotal=$((memtotal / 1024))
	fi
	mem="${memused}MiB / ${memtotal}MiB"
	verboseOut "Finding current RAM usage...found as '$mem'"
}
# Memory Detection - End


# Shell Detection - Begin
detectshell_ver () {
	local version_data='' version='' get_version='--version'

	case $1 in
		# ksh sends version to stderr. Weeeeeeird.
		ksh)
			version_data="$( $1 $get_version 2>&1 )"
			;;
		*)
			version_data="$( $1 $get_version 2>/dev/null )"
			;;
	esac

	if [[ -n $version_data ]];then
		version=$(awk '
		BEGIN {
			IGNORECASE=1
		}
		/'$2'/ {
			gsub(/(,|v|V)/, "",$'$3')
			if ($2 ~ /[Bb][Aa][Ss][Hh]/) {
				gsub(/\(.*|-release|-version\)/,"",$4)
			}
			print $'$3'
			exit # quit after first match prints
		}' <<< "$version_data")
	fi
	echo "$version"
}
detectshell () {
	if [[ ! "${shell_type}" ]]; then
		if [[ "${distro}" == "Cygwin" || "${distro}" == "Msys" || "${distro}" == "Haiku" || "${distro}" == "Alpine Linux" || "${OSTYPE}" == "gnu" || "${distro}" == "TinyCore" ]]; then
			shell_type=$(echo "$SHELL" | awk -F'/' '{print $NF}')
		elif readlink -f "$SHELL" | grep -q "busybox"; then
			shell_type="BusyBox"
		else
			if [[ "${OSTYPE}" == "linux-gnu" || "${OSTYPE}" == "linux" || "${OSTYPE}" == "linux-musl" ]]; then
				shell_type=$(cat /proc/$PPID/cmdline|tr '\0' '\n'|head -n 1)
			elif [[ "${distro}" == "Mac OS X" || "${distro}" == "DragonFlyBSD" || "${distro}" == "FreeBSD" || "${distro}" == "OpenBSD" || "${distro}" == "NetBSD" ]]; then
				shell_type=$(ps -p $PPID -o command | tail -1)
			else
				shell_type=$(ps -p $(ps -p $PPID | awk '$1 !~ /PID/ {print $1}') | awk 'FNR>1 {print $1}')
			fi
			shell_type=${shell_type/-}
			shell_type=${shell_type//*\/}
		fi
	fi

	case $shell_type in
		bash)
			shell_version_data=$( detectshell_ver "$shell_type" "^GNU.bash,.version" "4" )
			;;
		BusyBox)
			shell_version_data=$( busybox | head -n1 | cut -d ' ' -f2 )
			;;
		csh)
			shell_version_data=$( detectshell_ver "$shell_type" "$shell_type" "3" )
			;;
		dash)
			shell_version_data=$( detectshell_ver "$shell_type" "$shell_type" "3" )
			;;
		ksh)
			shell_version_data=$( detectshell_ver "$shell_type" "version" "5" )
			;;
		tcsh)
			shell_version_data=$( detectshell_ver "$shell_type" "^tcsh" "2" )
			;;
		zsh)
			shell_version_data=$( detectshell_ver "$shell_type" "^zsh" "2" )
			;;
		fish)
			shell_version_data=$( fish --version | awk '{print $3}' )
			;;
	esac

	if [[ -n $shell_version_data ]];then
		shell_type="$shell_type $shell_version_data"
	fi

	myShell=${shell_type}
	verboseOut "Finding current shell...found as '$myShell'"
}
# Shell Detection - End


# Resolution Detection - Begin
detectres () {
	if [[ ${distro} != "Mac OS X" && ${distro} != "Cygwin" && "${distro}" != "Msys" && ${distro} != "Haiku" ]]; then
		if [[ -n ${DISPLAY} ]]; then
			if type -p xdpyinfo >/dev/null 2>&1; then
				if [[ "$distro" =~ "BSD" ]]; then
					xResolution=$(xdpyinfo | sed -n 's/.*dim.* \([0-9]*x[0-9]*\) .*/\1/pg' | tr '\n' ' ')
				else
					xResolution=$(xdpyinfo | sed -n 's/.*dim.* \([0-9]*x[0-9]*\) .*/\1/pg' | sed ':a;N;$!ba;s/\n/ /g')
				fi
			fi
		fi
	elif [[ ${distro} == "Mac OS X" ]]; then
		xResolution=$(system_profiler SPDisplaysDataType | awk '/Resolution:/ {print $2"x"$4" "}')
		if [[ "$(echo $xResolution | wc -l)" -ge 1 ]]; then
			xResolution=$(echo $xResolution | tr "\\n" "," | sed 's/\(.*\),/\1/')
		fi
	elif [[ "${distro}" == "Cygwin" || "${distro}" == "Msys" ]]; then
		xResolution=$(wmic path Win32_VideoController get CurrentHorizontalResolution,CurrentVerticalResolution | awk 'NR==2 {print $1"x"$2}')
	elif [[ "${distro}" == "Haiku" ]]; then
		width=$(screenmode | cut -d ' ' -f2)
		height=$(screenmode | cut -d ' ' -f3 | tr -d ',')
		xResolution="$(echo ${width}x${height})"
	else
		xResolution="No X Server"
	fi
	verboseOut "Finding current resolution(s)...found as '$xResolution'"
}
# Resolution Detection - End


# DE Detection - Begin
detectde () {
	DE="Not Present"
	if [[ ${distro} != "Mac OS X" && ${distro} != "Cygwin" && "${distro}" != "Msys" ]]; then
		if [[ -n ${DISPLAY} ]]; then
			if type -p xprop >/dev/null 2>&1;then
				xprop_root="$(xprop -root 2>/dev/null)"
				if [[ -n ${xprop_root} ]]; then
					DE=$(echo "${xprop_root}" | awk 'BEGIN {
						de = "Not Present"
					}
					{
						if ($1 ~ /^_DT_SAVE_MODE/) {
							de = $NF
							gsub(/\"/,"",de)
							de = toupper(de)
							exit
						}
						else if ($1 ~/^KDE_SESSION_VERSION/) {
							de = "KDE"$NF
							exit
						}
						else if ($1 ~ /^_MUFFIN/) {
							de = "Cinnamon"
							exit
						}
						else if ($1 ~ /^TDE_FULL_SESSION/) {
							de = "Trinity"
							exit
						}
						else if ($0 ~ /"xfce4"/) {
							de = "XFCE4"
							exit
						}
						else if ($0 ~ /"xfce5"/) {
							de = "XFCE5"
							exit
						}
					} END {
						print de
					}')
				fi
			fi

			if [[ ${DE} == "Not Present" ]]; then
				# Let's use xdg-open code for GNOME/Enlightment/KDE/LXDE/MATE/XFCE detection
				# http://bazaar.launchpad.net/~vcs-imports/xdg-utils/master/view/head:/scripts/xdg-utils-common.in#L251
				if [ -n "${XDG_CURRENT_DESKTOP}" ]; then
					case "${XDG_CURRENT_DESKTOP}" in
						ENLIGHTENMENT)
							DE=Enlightenment;
							;;
						GNOME)
							DE=GNOME;
							;;
						KDE)
							DE=KDE;
							;;
						LUMINA|Lumina)
							DE=Lumina;
							;;
						LXDE)
							DE=LXDE;
							;;
						MATE)
							DE=MATE;
							;;
						XFCE)
							DE=XFCE
							;;
						'X-Cinnamon')
							DE=Cinnamon
							;;
						Unity)
							DE=Unity
							;;
						LXQt)
							DE=LXQt
							;;
					esac
				fi

				if [ -n "$DE" ]; then
					# classic fallbacks
					if [ -n "$KDE_FULL_SESSION" ]; then DE=KDE;
					elif [ -n "$TDE_FULL_SESSION" ]; then DE=Trinity;
					elif [ -n "$GNOME_DESKTOP_SESSION_ID" ]; then DE=GNOME;
					elif [ -n "$MATE_DESKTOP_SESSION_ID" ]; then DE=MATE;
					elif `dbus-send --print-reply --dest=org.freedesktop.DBus /org/freedesktop/DBus org.freedesktop.DBus.GetNameOwner string:org.gnome.SessionManager > /dev/null 2>&1` ; then DE=GNOME;
					elif xprop -root _DT_SAVE_MODE 2> /dev/null | grep ' = \"xfce4\"$' >/dev/null 2>&1; then DE=XFCE;
					elif xprop -root 2> /dev/null | grep -i '^xfce_desktop_window' >/dev/null 2>&1; then DE=XFCE
					elif echo $DESKTOP | grep -q '^Enlightenment'; then DE=Enlightenment;
					fi
				fi

				case "$DESKTOP_SESSION" in
					gnome|gnome-fallback|gnome-fallback-compiz )
						DE=GNOME
						;;
					deepin)
						DE=Deepin
						;;
				esac

				if [ -n "$DE" ]; then
					# fallback to checking $DESKTOP_SESSION
					case "$DESKTOP_SESSION" in
						gnome)
							DE=GNOME;
							;;
						LUMINA|Lumina)
							DE=Lumina;
							;;
						LXDE|Lubuntu)
							DE=LXDE;
							;;
						MATE)
							DE=MATE;
							;;
						xfce|xfce4|'Xfce Session')
							DE=XFCE;
							;;
						'budgie-desktop')
							DE=Budgie
							;;
						Cinnamon)
							DE=Cinnamon
							;;
						trinity)
							DE=Trinity
							;;
					esac
				fi

				if [ -n "$DE" ]; then
					# fallback to checking $GDMSESSION
					case "$GDMSESSION" in
						Lumina*|LUMINA*|lumina*)
							DE=Lumina
							;;
						MATE|mate)
							DE=MATE
							;;
					esac
				fi

				if [[ ${DE} == "GNOME" ]]; then
					if type -p xprop >/dev/null 2>&1; then
						if xprop -name "unity-launcher" >/dev/null 2>&1; then
							DE="Unity"
						elif xprop -name "launcher" >/dev/null 2>&1 &&
							xprop -name "panel" >/dev/null 2>&1; then

							DE="Unity"
						fi
					fi
				fi

				if [[ ${DE} == "KDE" ]]; then
					if [[ -n ${KDE_SESSION_VERSION} ]]; then
						if [[ ${KDE_SESSION_VERSION} == '5' ]]; then
							DE="KDE5"
						elif [[ ${KDE_SESSION_VERSION} == '4' ]]; then
							DE="KDE4"
						fi
					elif [[ "x${KDE_FULL_SESSION}" == "xtrue" ]]; then
						DE="KDE"
						DEver_data=$(kded --version 2>/dev/null)
						DEver=$(grep -si '^KDE:' <<< "$DEver_data" | awk '{print $2}')
					fi
				fi
			fi

			if [[ ${DE} != "Not Present" ]]; then
				if [[ ${DE} == "Cinnamon" ]]; then
					if type -p >/dev/null 2>&1; then
						DEver=$(cinnamon --version)
						DE="${DE} ${DEver//* }"
					fi
				elif [[ ${DE} == "GNOME" ]]; then
					if type -p gnome-session >/dev/null 2>&1; then
						DEver=$(gnome-session --version 2> /dev/null)
						DE="${DE} ${DEver//* }"
					elif type -p gnome-session-properties >/dev/null 2>&1; then
						DEver=$(gnome-session-properties --version 2> /dev/null)
						DE="${DE} ${DEver//* }"
					fi
				elif [[ ${DE} == "KDE4" || ${DE} == "KDE5" ]]; then
					if type -p kded${DE#KDE} >/dev/null 2>&1; then
						DEver=$(kded${DE#KDE} --version)
						if [[ $(( $(echo "$DEver" | wc -w) )) -eq 2 ]] && [[ "$(echo "$DEver" | cut -d ' ' -f1)" == "kded${DE#KDE}" ]]; then
							DEver=$(echo "$DEver" | cut -d ' ' -f2)
							DE="KDE ${DEver}"
						else
							for l in $(echo "${DEver// /_}"); do
								if [[ ${l//:*} == "KDE_Development_Platform" ]]; then
									DEver=${l//*:_}
									DE="KDE ${DEver//_*}"
								fi
							done
						fi
						if pgrep plasmashell >/dev/null 2>&1; then
							DEver=$(plasmashell --version | cut -d ' ' -f2)
							DE="$DE / Plasma $DEver"
						fi
					fi
				elif [[ ${DE} == "Lumina" ]]; then
					if type -p Lumina-DE.real >/dev/null 2>&1; then
						lumina="$(type -p Lumina-DE.real)"
					elif type -p Lumina-DE >/dev/null 2>&1; then
						lumina="$(type -p Lumina-DE)"
					fi
					if [ -n "$lumina" ]; then
						if grep -e '--version' "$lumina" >/dev/null; then
							DEver=$("$lumina" --version 2>&1 | tr -d \")
							DE="${DE} ${DEver}"
						fi
					fi
				elif [[ ${DE} == "MATE" ]]; then
					if type -p mate-session >/dev/null 2>&1; then
						DEver=$(mate-session --version)
						DE="${DE} ${DEver//* }"
					fi
				elif [[ ${DE} == "Unity" ]]; then
					if type -p unity >/dev/null 2>&1; then
						DEver=$(unity --version)
						DE="${DE} ${DEver//* }"
					fi
				elif [[ ${DE} == "Deepin" ]]; then
					if [[ -f /etc/deepin-version ]]; then
						DEver="$(awk -F '=' '/Version/ {print $2}' /etc/deepin-version)"
						DE="${DE} ${DEver//* }"
					fi
				elif [[ ${DE} == "Trinity" ]]; then
					if type -p tde-config >/dev/null 2>&1; then
						DEver="$(tde-config --version | awk -F ' ' '/TDE:/ {print $2}')"
						DE="${DE} ${DEver//* }"
					fi
				fi
			fi

			if [[ "${DE}" == "Not Present" ]]; then
				if pgrep -U ${UID} lxsession >/dev/null 2>&1; then
					DE="LXDE"
					if type -p lxpanel >/dev/null 2>&1; then
						DEver=$(lxpanel -v)
						DE="${DE} $DEver"
					fi
				elif pgrep -U ${UID} lxqt-session >/dev/null 2>&1; then
					DE="LXQt"
				elif pgrep -U ${UID} razor-session >/dev/null 2>&1; then
					DE="RazorQt"
				elif pgrep -U ${UID} dtsession >/dev/null 2>&1; then
					DE="CDE"
				fi
			fi
		fi
	elif [[ "${distro}" == "Mac OS X" ]]; then
		if ps -U ${USER} | grep [F]inder >/dev/null 2>&1; then
			DE="Aqua"
		fi
	elif [[ "${distro}" == "Cygwin" || "${distro}" == "Msys" ]]; then
		# https://msdn.microsoft.com/en-us/library/ms724832%28VS.85%29.aspx
		if [ "$(wmic os get version | grep -o '^\(6\.[01]\)')" ]; then
			DE='Aero'
		elif [ "$(wmic os get version | grep -o '^\(6\.[23]\|10\)')" ]; then
			DE='Modern UI/Metro'
		else
			DE='Luna'
		fi
	fi
	verboseOut "Finding desktop environment...found as '$DE'"
}
### DE Detection - End


# WM Detection - Begin
detectwm () {
	WM="Not Found"
	if [[ ${distro} != "Mac OS X" && ${distro} != "Cygwin" && "${distro}" != "Msys" ]]; then
		if [[ -n ${DISPLAY} ]]; then
			for each in "${wmnames[@]}"; do
				PID="$(pgrep -U ${UID} "^$each$")"
				if [ "$PID" ]; then
					case $each in
						'2bwm') WM="2bwm";;
						'9wm') WM="9wm";;
						'awesome') WM="Awesome";;
						'beryl') WM="Beryl";;
						'blackbox') WM="BlackBox";;
						'bspwm') WM="bspwm";;
						'budgie-wm') WM="BudgieWM";;
						'chromeos-wm') WM="chromeos-wm";;
						'cinnamon') WM="Muffin";;
						'compiz') WM="Compiz";;
						'deepin-wm') WM="deepin-wm";;
						'dminiwm') WM="dminiwm";;
						'dtwm') WM="dtwm";;
						'dwm') WM="dwm";;
						'e16') WM="E16";;
						'emerald') WM="Emerald";;
						'enlightenment') WM="E17";;
						'fluxbox') WM="FluxBox";;
						'flwm'|'flwm_topside') WM="FLWM";;
						'fvwm') WM="FVWM";;
						'herbstluftwm') WM="herbstluftwm";;
						'howm') WM="howm";;
						'i3') WM="i3";;
						'icewm') WM="IceWM";;
						'kwin') WM="KWin";;
						'metacity') WM="Metacity";;
						'monsterwm') WM="monsterwm";;
						'musca') WM="Musca";;
						'notion') WM="Notion";;
						'openbox') WM="OpenBox";;
						'pekwm') WM="PekWM";;
						'ratpoison') WM="Ratpoison";;
						'sawfish') WM="Sawfish";;
						'scrotwm') WM="ScrotWM";;
						'spectrwm') WM="SpectrWM";;
						'stumpwm') WM="StumpWM";;
						'subtle') WM="subtle";;
						'sway') WM="sway";;
						'swm') WM="swm";;
						'twin') WM="TWin";;
						'wmaker') WM="WindowMaker";;
						'wmfs') WM="WMFS";;
						'wmii') WM="wmii";;
						'xfwm4') WM="Xfwm4";;
						'xmonad.*') WM="XMonad";;
					esac
				fi

				if [[ ${WM} != "Not Found" ]]; then
					break 1
				fi
			done

			if [[ ${WM} == "Not Found" ]]; then
				if type -p xprop >/dev/null 2>&1; then
					WM=$(xprop -root _NET_SUPPORTING_WM_CHECK)
					if [[ "$WM" =~ 'not found' ]]; then
						WM="Not Found"
					elif [[ "$WM" =~ 'Not found' ]]; then
						WM="Not Found"
					elif [[ "$WM" =~ '[Ii]nvalid window id format' ]]; then
						WM="Not Found"
					elif [[ "$WM" =~ "no such" ]]; then
						WM="Not Found"
					else
						WM=${WM//* }
						WM=$(xprop -id ${WM} 8s _NET_WM_NAME)
						WM=$(echo $(WM=${WM//*= }; echo ${WM//\"}))
					fi
				fi
			else
				if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
					if [[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -gt 1 ]] || [[ ${BASH_VERSINFO[0]} -gt 4 ]]; then
						WM=${WM,,}
					else
						WM="$(tr '[:upper:]' '[:lower:]' <<< ${WM})"
					fi
				else
					WM="$(tr '[:upper:]' '[:lower:]' <<< ${WM})"
				fi
				case ${WM} in
					*'gala'*) WM="Gala";;
					'2bwm') WM="2bwm";;
					'awesome') WM="Awesome";;
					'beryl') WM="Beryl";;
					'blackbox') WM="BlackBox";;
					'budgiewm') WM="BudgieWM";;
					'chromeos-wm') WM="chromeos-wm";;
					'cinnamon') WM="Cinnamon";;
					'compiz') WM="Compiz";;
					'deepin-wm') WM="Deepin WM";;
					'dminiwm') WM="dminiwm";;
					'dwm') WM="dwm";;
					'e16') WM="E16";;
					'echinus') WM="echinus";;
					'emerald') WM="Emerald";;
					'enlightenment') WM="E17";;
					'fluxbox') WM="FluxBox";;
					'flwm'|'flwm_topside') WM="FLWM";;
					'fvwm') WM="FVWM";;
					'gnome shell'*) WM="Mutter";;
					'herbstluftwm') WM="herbstluftwm";;
					'howm') WM="howm";;
					'i3') WM="i3";;
					'icewm') WM="IceWM";;
					'kwin') WM="KWin";;
					'metacity') WM="Metacity";;
					'monsterwm') WM="monsterwm";;
					'muffin') WM="Muffin";;
					'musca') WM="Musca";;
					'mutter'*) WM="Mutter";;
					'notion') WM="Notion";;
					'openbox') WM="OpenBox";;
					'pekwm') WM="PekWM";;
					'ratpoison') WM="Ratpoison";;
					'sawfish') WM="Sawfish";;
					'scrotwm') WM="ScrotWM";;
					'spectrwm') WM="SpectrWM";;
					'stumpwm') WM="StumpWM";;
					'subtle') WM="subtle";;
					'sway') WM="sway";;
					'swm') WM="swm";;
					'twin') WM="TWin";;
					'wmaker') WM="WindowMaker";;
					'wmfs') WM="WMFS";;
					'wmii') WM="wmii";;
					'xfwm4') WM="Xfwm4";;
					'xmonad') WM="XMonad";;
				esac
			fi
		fi
	elif [[ ${distro} == "Mac OS X" && "${WM}" == "Not Found" ]]; then
		if ps -U ${USER} | grep Finder >/dev/null 2>&1; then
			WM="Quartz Compositor"
		fi
	elif [[ "${distro}" == "Cygwin" || "${distro}" == "Msys" ]]; then
		bugn=$(tasklist | grep -o 'bugn' | tr -d '\r \n')
		wind=$(tasklist | grep -o 'Windawesome' | tr -d '\r \n')
		blackbox=$(tasklist | grep -o 'blackbox' | tr -d '\r \n')
		if [ "$bugn" = "bugn" ]; then WM="bug.n"
		elif [ "$wind" = "Windawesome" ]; then WM="Windawesome"
		elif [ "$blackbox" = "blackbox" ]; then WM="Blackbox"
		else WM="DWM/Explorer"; fi
	fi
	verboseOut "Finding window manager...found as '$WM'"
}
# WM Detection - End


# WM Theme Detection - BEGIN
detectwmtheme () {
	Win_theme="Not Found"
	case $WM in
		'2bwm') Win_theme="Not Applicable";;
		'9wm') Win_theme="Not Applicable";;
		'Awesome') if [ -f ${XDG_CONFIG_HOME:-${HOME}/.config}/awesome/rc.lua ]; then Win_theme="$(grep -e '^[^-].*\(theme\|beautiful\).*lua' ${XDG_CONFIG_HOME:-${HOME}/.config}/awesome/rc.lua | grep '[a-zA-Z0-9]\+/[a-zA-Z0-9]\+.lua' -o | cut -d'/' -f1 | head -n1)"; fi;;
		'BlackBox') if [ -f $HOME/.blackboxrc ]; then Win_theme="$(awk -F"/" '/styleFile/ {print $NF}' $HOME/.blackboxrc)"; fi;;
		'Beryl') Win_theme="Not Applicable";;
		'bspwm') Win_theme="Not Applicable";;
		'BudgieWM')
			Win_theme="$(gsettings get org.gnome.desktop.wm.preferences theme)"
			Win_theme="${Win_theme//\'}"
		;;
		'Cinnamon'|'Muffin')
			de_theme="$(gsettings get org.cinnamon.theme name)"
			de_theme=${de_theme//"'"}
			win_theme="$(gsettings get org.cinnamon.desktop.wm.preferences theme)"
			win_theme=${win_theme//"'"}
			Win_theme="${de_theme} (${win_theme})"
		;;
		'Compiz'|'Mutter'*|'GNOME Shell'|'Gala')
			if type -p gsettings >/dev/null 2>&1; then
				Win_theme="$(gsettings get org.gnome.shell.extensions.user-theme name 2>/dev/null)"
				if [[ -z "$Win_theme" ]]; then
					Win_theme="$(gsettings get org.gnome.desktop.wm.preferences theme)"
				fi
				Win_theme=${Win_theme//"'"}
			elif type -p gconftool-2 >/dev/null 2>&1; then
				Win_theme=$(gconftool-2 -g /apps/metacity/general/theme)
			fi
		;;
		'Deepin WM')
			if type -p gsettings >/dev/null 2>&1; then
				Win_theme="$(gsettings get com.deepin.wrap.gnome.desktop.wm.preferences theme)"
				Win_theme=${Win_theme//"'"}
			fi
		;;
		'dminiwm') Win_theme="Not Applicable";;
		'dwm') Win_theme="Not Applicable";;
		'E16') Win_theme="$(awk -F"= " '/theme.name/ {print $2}' $HOME/.e16/e_config--0.0.cfg)";;
		'E17'|'Enlightenment')
			if [ "$(which eet 2>/dev/null)" ]; then
				econfig="$(eet -d $HOME/.e/e/config/standard/e.cfg config | awk '/value \"file\" string.*.edj/{ print $4 }')"
				econfigend="${econfig##*/}"
				Win_theme=${econfigend%.*}
			fi
		;;
		#E17 doesn't store cfg files in text format so for now get the profile as opposed to theme. atyoung
		#TODO: Find a way to extract and read E17 .cfg files ( google seems to have nothing ). atyoung
		'E17') Win_theme=${E_CONF_PROFILE};;
		'echinus') Win_theme="Not Applicable";;
		'Emerald') if [ -f $HOME/.emerald/theme/theme.ini ]; then Win_theme="$(for a in /usr/share/emerald/themes/* $HOME/.emerald/themes/*; do cmp "$HOME/.emerald/theme/theme.ini" "$a/theme.ini" &>/dev/null && basename "$a"; done)"; fi;;
		'Finder') Win_theme="Not Applicable";;
		'FluxBox'|'Fluxbox') if [ -f $HOME/.fluxbox/init ]; then Win_theme="$(awk -F"/" '/styleFile/ {print $NF}' $HOME/.fluxbox/init)"; fi;;
		'FVWM') Win_theme="Not Applicable";;
		'howm') Win_theme="Not Applicable";;
		'i3') Win_theme="Not Applicable";;
		'IceWM') if [ -f $HOME/.icewm/theme ]; then Win_theme="$(awk -F"[\",/]" '!/#/ {print $2}' $HOME/.icewm/theme)"; fi;;
		'KWin'*)
			if [[ -z $KDE_CONFIG_DIR ]]; then
				if type -p kde5-config >/dev/null 2>&1; then
					KDE_CONFIG_DIR=$(kde5-config --localprefix)
				elif type -p kde4-config >/dev/null 2>&1; then
					KDE_CONFIG_DIR=$(kde4-config --localprefix)
				elif type -p kde-config >/dev/null 2>&1; then
					KDE_CONFIG_DIR=$(kde-config --localprefix)
				fi
			fi

			if [[ -n $KDE_CONFIG_DIR ]]; then
				Win_theme="Not Applicable"
				KDE_CONFIG_DIR=${KDE_CONFIG_DIR%/}
				if [[ -f $KDE_CONFIG_DIR/share/config/kwinrc ]]; then
					Win_theme="$(awk '/PluginLib=kwin3_/{gsub(/PluginLib=kwin3_/,"",$0); print $0; exit}' $KDE_CONFIG_DIR/share/config/kwinrc)"
					if [[ -z "$Win_theme" ]]; then Win_theme="Not Applicable"; fi
				fi
				if [[ "$Win_theme" == "Not Applicable" ]]; then
					if [[ -f $KDE_CONFIG_DIR/share/config/kdebugrc ]]; then
						Win_theme="$(awk '/(decoration)/ {gsub(/\[/,"",$1); print $1; exit}' $KDE_CONFIG_DIR/share/config/kdebugrc)"
						if [[ -z "$Win_theme" ]]; then Win_theme="Not Applicable"; fi
					fi
				fi
				if [[ "$Win_theme" == "Not Applicable" ]]; then
					if [[ -f $KDE_CONFIG_DIR/share/config/kdeglobals ]]; then
						Win_theme="$(awk '/\[General\]/ {flag=1;next} /^$/{flag=0} flag {print}' $KDE_CONFIG_DIR/share/config/kdeglobals | grep -oP 'Name=\K.*')"
						if [[ -z "$Win_theme" ]]; then Win_theme="Not Applicable"; fi
					fi
				fi

				if [[ "$Win_theme" != "Not Applicable" ]]; then
					if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
						if [[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -gt 1 ]] || [[ ${BASH_VERSINFO[0]} -gt 4 ]]; then
							Win_theme="${Win_theme^}"
						else
							Win_theme="$(tr '[:lower:]' '[:upper:]' <<< ${Win_theme:0:1})${Win_theme:1}"
						fi
					else
						Win_theme="$(tr '[:lower:]' '[:upper:]' <<< ${Win_theme:0:1})${Win_theme:1}"
					fi
				fi
			fi
		;;
		'Marco')
			Win_theme="$(gsettings get org.mate.Marco.general theme)"
			Win_theme=${Win_theme//"'"}
		;;
		'Metacity') if [ "`gconftool-2 -g /apps/metacity/general/theme`" ]; then Win_theme="$(gconftool-2 -g /apps/metacity/general/theme)"; fi ;;
		'monsterwm') Win_theme="Not Applicable";;
		'Musca') Win_theme="Not Applicable";;
		'Notion') Win_theme="Not Applicable";;
		'OpenBox'|'Openbox')
			if [ -f ${XDG_CONFIG_HOME:-${HOME}/.config}/openbox/rc.xml ]; then
				Win_theme="$(awk -F"[<,>]" '/<theme/ { getline; print $3 }' ${XDG_CONFIG_HOME:-${HOME}/.config}/openbox/rc.xml)";
			elif [[ -f ${XDG_CONFIG_HOME:-${HOME}/.config}/openbox/lxde-rc.xml && $DE == "LXDE" ]]; then
				Win_theme="$(awk -F"[<,>]" '/<theme/ { getline; print $3 }' ${XDG_CONFIG_HOME:-${HOME}/.config}/openbox/lxde-rc.xml)";
			fi
		;;
		'PekWM') if [ -f $HOME/.pekwm/config ]; then Win_theme="$(awk -F"/" '/Theme/ {gsub(/\"/,""); print $NF}' $HOME/.pekwm/config)"; fi;;
		'Ratpoison') Win_theme="Not Applicable";;
		'Sawfish') Win_theme="$(awk -F")" '/\(quote default-frame-style/{print $2}' $HOME/.sawfish/custom | sed 's/ (quote //')";;
		'ScrotWM') Win_theme="Not Applicable";;
		'SpectrWM') Win_theme="Not Applicable";;
		'swm') Win_theme="Not Applicable";;
		'subtle') Win_theme="Not Applicable";;
		'TWin')
			if [[ -z $TDE_CONFIG_DIR ]]; then
				if type -p tde-config >/dev/null 2>&1; then
					TDE_CONFIG_DIR=$(tde-config --localprefix)
				fi
			fi
			if [[ -n $TDE_CONFIG_DIR ]]; then
				TDE_CONFIG_DIR=${TDE_CONFIG_DIR%/}
				if [[ -f $TDE_CONFIG_DIR/share/config/kcmthememanagerrc ]]; then
					Win_theme=$(awk '/CurrentTheme=/ {gsub(/CurrentTheme=/,"",$0); print $0; exit}' $TDE_CONFIG_DIR/share/config/kcmthememanagerrc)
				fi
				if [[ -z $Win_theme ]]; then
					Win_theme="Not Applicable"
				fi
			fi
		;;
		'WindowMaker') Win_theme="Not Applicable";;
		'WMFS') Win_theme="Not Applicable";;
		'wmii') Win_theme="Not Applicable";;
		'Xfwm4') if [ -f ${XDG_CONFIG_HOME:-${HOME}/.config}/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml ]; then Win_theme="$(xfconf-query -c xfwm4 -p /general/theme)"; fi;;
		'XMonad') Win_theme="Not Applicable";;
	esac
	if [[ "${distro}" == "Mac OS X" ]]; then
		themeNumber="$(defaults read NSGlobalDomain AppleAquaColorVariant 2>/dev/null)"
		if [ "${themeNumber}" == "1" ] || [ "${themeNumber}x" == "x" ]; then
			Win_theme="Blue"
		else
			Win_theme="Graphite"
		fi
	elif [[ "${distro}" == "Cygwin" || "${distro}" == "Msys" ]]; then
		if [ "${WM}" == "Blackbox" ]; then
			if [ "${distro}" == "Msys" ]; then
				Blackbox_loc=$(reg query 'HKLM\Software\Microsoft\Windows NT\CurrentVersion\WinLogon' //v 'Shell')
			else
				Blackbox_loc=$(reg query 'HKLM\Software\Microsoft\Windows NT\CurrentVersion\WinLogon' /v 'Shell')
			fi
			Blackbox_loc="$(echo ${Blackbox_loc} | sed 's/.*REG_SZ//' | sed -e 's/^[ \t]*//' | sed 's/.\{4\}$//')"
			Win_theme=$(cat "${Blackbox_loc}.rc" | grep "session.styleFile" | sed 's/ //g' | sed 's/session\.styleFile://g' | sed 's/.*\\//g')
		else
			if [[ "${distro}" == "Msys" ]]; then
				themeFile="$(reg query 'HKCU\Software\Microsoft\Windows\CurrentVersion\Themes' //v 'CurrentTheme')"
			else
				themeFile="$(reg query 'HKCU\Software\Microsoft\Windows\CurrentVersion\Themes' /v 'CurrentTheme')"
			fi
			Win_theme=$(echo $themeFile| awk -F"\\" '{print $NF}' | sed 's|\.theme$||')
		fi
	fi

	verboseOut "Finding window manager theme...found as '$Win_theme'"
}
# WM Theme Detection - END

# GTK Theme\Icon\Font Detection - BEGIN
detectgtk () {
	gtk2Theme="Not Found"
	gtk3Theme="Not Found"
	gtkIcons="Not Found"
	gtkFont="Not Found"
	# Font detection (OS X)
	if [[ ${distro} == "Mac OS X" ]]; then
		gtk2Theme="Not Applicable"
		gtk3Theme="Not Applicable"
		gtkIcons="Not Applicable"
		if ps -U ${USER} | grep [F]inder >/dev/null 2>&1; then
			if [[ ${TERM_PROGRAM} == "iTerm.app" ]] && [ -f ~/Library/Preferences/com.googlecode.iterm2.plist ]; then
				# iTerm2

				iterm2_theme_uuid=$(defaults read com.googlecode.iTerm2 "Default Bookmark Guid")

				OLD_IFS=$IFS
				IFS=$'\n'
				iterm2_theme_info=($(defaults read com.googlecode.iTerm2 "New Bookmarks" | grep -e Guid -e "Normal Font"))
				IFS=$OLD_IFS

				for i in $(seq 0 $((${#iterm2_theme_info[*]}/2-1))); do
					found_uuid=$(str1=${iterm2_theme_info[$i*2]};echo ${str1:16:${#str1}-16-2})
					if [[ $found_uuid == $iterm2_theme_uuid ]]; then
						gtkFont=$(str2=${iterm2_theme_info[$i*2+1]};echo ${str2:25:${#str2}-25-2})
						break
					fi
				done
			else
				# Terminal.app

				termapp_theme_name=$(defaults read com.apple.Terminal "Default Window Settings")

				OLD_IFS=$IFS
				IFS=$'\n'
				termapp_theme_info=($(defaults read com.apple.Terminal "Window Settings" | grep -e "name = " -e "Font = "))
				IFS=$OLD_IFS

				for i in $(seq 0 $((${#termapp_theme_info[*]}/2-1))); do
					found_name=$(str1=${termapp_theme_info[$i*2+1]};echo ${str1:15:${#str1}-15-1})
					if [[ $found_name == $termapp_theme_name ]]; then
						gtkFont=$(str2=${termapp_theme_info[$i*2]};echo ${str2:288:${#str2}-288})
						gtkFont=$(echo ${gtkFont%%[dD]2*;} | xxd -r -p)
						break
					fi
				done
			fi
		fi
	else
		case $DE in
			'KDE'*) # Desktop Environment found as "KDE"
				if type - p kde4-config >/dev/null 2>&1; then
					KDE_CONFIG_DIR=$(kde4-config --localprefix)
					if [[ -d ${KDE_CONFIG_DIR} ]]; then
						if [[ -f "${KDE_CONFIG_DIR}/share/config/kdeglobals" ]]; then
							KDE_CONFIG_FILE="${KDE_CONFIG_DIR}/share/config/kdeglobals"
						fi
					fi
				elif type -p kde5-config >/dev/null 2>&1; then
					KDE_CONFIG_DIR=$(kde5-config --localprefix)
					if [[ -d ${KDE_CONFIG_DIR} ]]; then
						if [[ -f "${KDE_CONFIG_DIR}/share/config/kdeglobals" ]]; then
							KDE_CONFIG_FILE="${KDE_CONFIG_DIR}/share/config/kdeglobals"
						fi
					fi
				elif type -p kde-config >/dev/null 2>&1; then
					KDE_CONFIG_DIR=$(kde-config --localprefix)
					if [[ -d ${KDE_CONFIG_DIR} ]]; then
						if [[ -f "${KDE_CONFIG_DIR}/share/config/kdeglobals" ]]; then
							KDE_CONFIG_FILE="${KDE_CONFIG_DIR}/share/config/kdeglobals"
						fi
					fi
				fi

				if [[ -n ${KDE_CONFIG_FILE} ]]; then
					if grep -q "widgetStyle=" "${KDE_CONFIG_FILE}"; then
						gtk2Theme=$(awk -F"=" '/widgetStyle=/ {print $2}' "${KDE_CONFIG_FILE}")
					elif grep -q "colorScheme=" "${KDE_CONFIG_FILE}"; then
						gtk2Theme=$(awk -F"=" '/colorScheme=/ {print $2}' "${KDE_CONFIG_FILE}")
					fi

					if grep -q "Theme=" "${KDE_CONFIG_FILE}"; then
						gtkIcons=$(awk -F"=" '/Theme=/ {print $2}' "${KDE_CONFIG_FILE}")
					fi

					if grep -q "Font=" "${KDE_CONFIG_FILE}"; then
						gtkFont=$(awk -F"=" '/font=/ {print $2}' "${KDE_CONFIG_FILE}")
					fi
				fi

				if [[ -f $HOME/.gtkrc-2.0 ]]; then
					gtk2Theme=$(grep '^gtk-theme-name' $HOME/.gtkrc-2.0 | awk -F'=' '{print $2}')
					gtk2Theme=${gtk2Theme//\"/}
					gtkIcons=$(grep '^gtk-icon-theme-name' $HOME/.gtkrc-2.0 | awk -F'=' '{print $2}')
					gtkIcons=${gtkIcons//\"/}
					gtkFont=$(grep 'font_name' $HOME/.gtkrc-2.0 | awk -F'=' '{print $2}')
					gtkFont=${gtkFont//\"/}
				fi

				if [[ -f $HOME/.config/gtk-3.0/settings.ini ]]; then
					gtk3Theme=$(grep '^gtk-theme-name=' $HOME/.config/gtk-3.0/settings.ini | awk -F'=' '{print $2}')
				fi
			;;
			'Cinnamon'*) # Desktop Environment found as "Cinnamon"
				if type -p gsettings >/dev/null 2>&1; then
					gtk3Theme=$(gsettings get org.cinnamon.desktop.interface gtk-theme)
					gtk3Theme=${gtk3Theme//"'"}
					gtk2Theme=${gtk3Theme}

					gtkIcons=$(gsettings get org.cinnamon.desktop.interface icon-theme)
					gtkIcons=${gtkIcons//"'"}
					gtkFont=$(gsettings get org.cinnamon.desktop.interface font-name)
					gtkFont=${gtkFont//"'"}
					if [ "$background_detect" == "1" ]; then gtkBackground=$(gsettings get org.gnome.desktop.background picture-uri); fi
				fi
			;;
			'GNOME'*|'Unity'*|'Budgie') # Desktop Environment found as "GNOME"
				if type -p gsettings >/dev/null 2>&1; then
					gtk3Theme=$(gsettings get org.gnome.desktop.interface gtk-theme)
					gtk3Theme=${gtk3Theme//"'"}
					gtk2Theme=${gtk3Theme}
					gtkIcons=$(gsettings get org.gnome.desktop.interface icon-theme)
					gtkIcons=${gtkIcons//"'"}
					gtkFont=$(gsettings get org.gnome.desktop.interface font-name)
					gtkFont=${gtkFont//"'"}
					if [ "$background_detect" == "1" ]; then gtkBackground=$(gsettings get org.gnome.desktop.background picture-uri); fi
				elif type -p gconftool-2 >/dev/null 2>&1; then
					gtk2Theme=$(gconftool-2 -g /desktop/gnome/interface/gtk_theme)
					gtkIcons=$(gconftool-2 -g /desktop/gnome/interface/icon_theme)
					gtkFont=$(gconftool-2 -g /desktop/gnome/interface/font_name)
					if [ "$background_detect" == "1" ]; then
						gtkBackgroundFull=$(gconftool-2 -g /desktop/gnome/background/picture_filename)
						gtkBackground=$(echo "$gtkBackgroundFull" | awk -F"/" '{print $NF}')
					fi
				fi
			;;
			'MATE'*) # MATE desktop environment
				#if type -p gsettings >/dev/null 2&>1; then
				gtk3Theme=$(gsettings get org.mate.interface gtk-theme)
				# gtk3Theme=${gtk3Theme//"'"}
				gtk2Theme=${gtk3Theme}
				gtkIcons=$(gsettings get org.mate.interface icon-theme)
				gtkIcons=${gtkIcons//"'"}
				gtkFont=$(gsettings get org.mate.interface font-name)
				gtkFont=${gtkFont//"'"}
				#fi
			;;
			'XFCE'*) # Desktop Environment found as "XFCE"
				if type -p xfconf-query >/dev/null 2>&1; then
					gtk2Theme=$(xfconf-query -c xsettings -p /Net/ThemeName)
				fi

				if type -p xfconf-query >/dev/null 2>&1; then
					gtkIcons=$(xfconf-query -c xsettings -p /Net/IconThemeName)
				fi

				if type -p xfconf-query >/dev/null 2>&1; then
					gtkFont=$(xfconf-query -c xsettings -p /Gtk/FontName)
				fi
			;;
			'LXDE'*)
				config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
				if [ -f "$config_home/lxde/config" ]; then
					lxdeconf="/lxde/config"
				elif [ "$distro" == "Trisquel" ] || [ "$distro" == "FreeBSD" ]; then
					lxdeconf=""
				elif [ -f "$config_home/lxsession/Lubuntu/desktop.conf" ]; then
					lxdeconf="/lxsession/Lubuntu/desktop.conf"
				else
					lxdeconf="/lxsession/LXDE/desktop.conf"
				fi

				if grep -q "sNet\/ThemeName" "${config_home}${lxdeconf}" 2>/dev/null; then
					gtk2Theme=$(awk -F'=' '/sNet\/ThemeName/ {print $2}' ${config_home}${lxdeconf})
				fi

				if grep -q IconThemeName "${config_home}${lxdeconf}" 2>/dev/null; then
					gtkIcons=$(awk -F'=' '/sNet\/IconThemeName/ {print $2}' ${config_home}${lxdeconf})
				fi

				if grep -q FontName "${config_home}${lxdeconf}" 2>/dev/null; then
					gtkFont=$(awk -F'=' '/sGtk\/FontName/ {print $2}' ${config_home}${lxdeconf})
 				fi
			;;

			# /home/me/.config/rox.sourceforge.net/ROX-Session/Settings.xml

			*)	# Lightweight or No DE Found
				if [ -f "$HOME/.gtkrc-2.0" ]; then
					if grep -q gtk-theme $HOME/.gtkrc-2.0; then
						gtk2Theme=$(awk -F'"' '/^gtk-theme/ {print $2}' $HOME/.gtkrc-2.0)
					fi

					if grep -q icon-theme $HOME/.gtkrc-2.0; then
						gtkIcons=$(awk -F'"' '/^gtk-icon-theme/ {print $2}' $HOME/.gtkrc-2.0)
					fi

					if grep -q font $HOME/.gtkrc-2.0; then
						gtkFont=$(awk -F'"' '/^gtk-font-name/ {print $2}' $HOME/.gtkrc-2.0)
					fi
				fi
				# $HOME/.gtkrc.mine theme detect only
				if [[ -f "$HOME/.gtkrc.mine" ]]; then
					minegtkrc="$HOME/.gtkrc.mine"
				elif [[ -f "$HOME/.gtkrc-2.0.mine" ]]; then
					minegtkrc="$HOME/.gtkrc-2.0.mine"
				fi
				if [ -f "$minegtkrc" ]; then
					if grep -q "^include" "$minegtkrc"; then
						gtk2Theme=$(grep '^include.*gtkrc' "$minegtkrc" | awk -F "/" '{ print $5 }')
					fi
					if grep -q "^gtk-icon-theme-name" "$minegtkrc"; then
						gtkIcons=$(grep '^gtk-icon-theme-name' "$minegtkrc" | awk -F '"' '{print $2}')
					fi
				fi
				# /etc/gtk-2.0/gtkrc compatability
				if [[ -f /etc/gtk-2.0/gtkrc && ! -f "$HOME/.gtkrc-2.0" && ! -f "$HOME/.gtkrc.mine" && ! -f "$HOME/.gtkrc-2.0.mine" ]]; then
					if grep -q gtk-theme-name /etc/gtk-2.0/gtkrc; then
						gtk2Theme=$(awk -F'"' '/^gtk-theme-name/ {print $2}' /etc/gtk-2.0/gtkrc)
					fi
					if grep -q gtk-fallback-theme-name /etc/gtk-2.0/gtkrc  && ! [ "x$gtk2Theme" = "x" ]; then
						gtk2Theme=$(awk -F'"' '/^gtk-fallback-theme-name/ {print $2}' /etc/gtk-2.0/gtkrc)
					fi

					if grep -q icon-theme /etc/gtk-2.0/gtkrc; then
						gtkIcons=$(awk -F'"' '/^icon-theme/ {print $2}' /etc/gtk-2.0/gtkrc)
					fi
					if  grep -q gtk-fallback-icon-theme /etc/gtk-2.0/gtkrc  && ! [ "x$gtkIcons" = "x" ]; then
						gtkIcons=$(awk -F'"' '/^gtk-fallback-icon-theme/ {print $2}' /etc/gtk-2.0/gtkrc)
					fi

					if grep -q font /etc/gtk-2.0/gtkrc; then
						gtkFont=$(awk -F'"' '/^gtk-font-name/ {print $2}' /etc/gtk-2.0/gtkrc)
					fi
				fi

				# EXPERIMENTAL gtk3 Theme detection
				if [ -f "$HOME/.config/gtk-3.0/settings.ini" ]; then
					if grep -q gtk-theme-name $HOME/.config/gtk-3.0/settings.ini; then
						gtk3Theme=$(awk -F'=' '/^gtk-theme-name/ {print $2}' $HOME/.config/gtk-3.0/settings.ini)
					fi
				fi

				# Proper gtk3 Theme detection
				#if type -p gsettings >/dev/null 2>&1; then
				#	gtk3Theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null)
				#	gtk3Theme=${gtk3Theme//"'"}
				#fi

				# ROX-Filer icon detect only
				if [ -a "${XDG_CONFIG_HOME:-${HOME}/.config}/rox.sourceforge.net/ROX-Filer/Options" ]; then
					gtkIcons=$(awk -F'[>,<]' '/icon_theme/ {print $3}' ${XDG_CONFIG_HOME:-${HOME}/.config}/rox.sourceforge.net/ROX-Filer/Options)
				fi

				# E17 detection
				if [ $E_ICON_THEME ]; then
					gtkIcons=${E_ICON_THEME}
					gtk2Theme="Not available."
					gtkFont="Not available."
				fi

				# Background Detection (feh, nitrogen)
				if [ "$background_detect" == "1" ]; then
					if [ -a $HOME/.fehbg ]; then
						gtkBackgroundFull=$(awk -F"'" '/feh --bg/{print $2}' $HOME/.fehbg 2>/dev/null)
						gtkBackground=$(echo "$gtkBackgroundFull" | awk -F"/" '{print $NF}')
					elif [ -a ${XDG_CONFIG_HOME:-${HOME}/.config}/nitrogen/bg-saved.cfg ]; then
						gtkBackground=$(awk -F"/" '/file=/ {print $NF}' ${XDG_CONFIG_HOME:-${HOME}/.config}/nitrogen/bg-saved.cfg)
					fi
				fi

				if [[ "$distro" == "Cygwin" || "$distro" == "Msys" ]]; then
					if [ "$gtkFont" == "Not Found" ]; then
						if [ -f "$HOME/.minttyrc" ]; then
							gtkFont="$(grep '^Font=.*' "$HOME/.minttyrc" | grep -o '[0-9A-z ]*$')"
						fi
					fi
				fi
			;;
		esac
	fi
	verboseOut "Finding GTK2 theme...found as '$gtk2Theme'"
	verboseOut "Finding GTK3 theme...found as '$gtk3Theme'"
	verboseOut "Finding icon theme...found as '$gtkIcons'"
	verboseOut "Finding user font...found as '$gtkFont'"
	[[ $gtkBackground ]] && verboseOut "Finding background...found as '$gtkBackground'"
}
# GTK Theme\Icon\Font Detection - END




#######################
# End Detection Phase
#######################


asciiText () {
# Distro logos and ASCII outputs
	myascii="${distro}"
	if [[ "$no_color" != "1" ]]; then
		c1=$(getColor 'light cyan') # Light Blue
		c2=$(getColor 'light blue') # Light Red
		c3=$(getColor 'cyan') # Light Red
		c4=$(getColor 'light cyan') # Light Red
		c5=$(getColor 'rosa_blue') # Light Red
	fi
	if [ -n "${my_lcolor}" ]; then c1="${my_lcolor}"; c2="${my_lcolor}"; fi
	startline="0"
	logowidth="32"
	fulloutput=(
"   mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm  %s"
"   mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm  %s"
"   mmmQ                       Ymmmm  %s"
"   mmm#   .2A929     .12iQ7   :mmmm  %s"
"   mmmp    ;mmmm#   :mmmmp.   ,mmmm  %s"
"   mmm#     ,mmmQ5 .Ymmmp     :mmmm  %s"
"   mmmp      ,mmmp ,mmmp      ,mmmm  %s"
"   mmm#       ;mmmmNmmp       :mmmm  %s"
"   mmmp       .YmmmmmA;       ,mmmm  %s"
"   mmm#        .KmmmQY        :mmmm  %s"
"   mmmp         :mmm#         ,mmmm  %s"
"   mmm#        .7mmmp,        :mmmm  %s"
"   mmmp         7mmm#,        ,mmmm  %s"
"   mmm#                       :mmmm %s"
"   mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm %s"
"   mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm %s")

	# Truncate lines based on terminal width.
	if [ "$truncateSet" == "Yes" ]; then
		missinglines=$((${#out_array[*]} + ${startline} - ${#fulloutput[*]}))
		for ((i=0; i<${missinglines}; i++)); do
			fulloutput+=("${c1}$(printf '%*s' "$logowidth")%s")
		done
		for ((i=0; i<${#fulloutput[@]}; i++)); do
			my_out=$(printf "${fulloutput[i]}$c0\n" "${out_array}")
			my_out_full=$(echo "$my_out" | cat -v)
			termWidth=$(tput cols)
			SHOPT_EXTGLOB_STATE=$(shopt -p extglob)
			read SHOPT_CMD SHOPT_STATE SHOPT_OPT <<< ${SHOPT_EXTGLOB_STATE}
			if [[ ${SHOPT_STATE} == "-u" ]]; then
				shopt -s extglob
			fi

			stringReal="${my_out_full//\^\[\[@([0-9]|[0-9];[0-9][0-9])m}"

			if [[ ${SHOPT_STATE} == "-u" ]]; then
				shopt -u extglob
			fi

			if [[ "${#stringReal}" -le "${termWidth}" ]]; then
				echo -e "${my_out}"$c0
			elif [[ "${#stringReal}" -gt "${termWidth}" ]]; then
				((NORMAL_CHAR_COUNT=0))
				for ((j=0; j<=${#my_out_full}; j++)); do
					if [[ "${my_out_full:${j}:3}" == '^[[' ]]; then
						if [[ "${my_out_full:${j}:5}" =~ ^\^\[\[[[:digit:]]m$ ]]; then
							if [[ ${j} -eq 0 ]]; then
								j=$((${j} + 5))
							else
								j=$((${j} + 4))
							fi
						elif [[ "${my_out_full:${j}:8}" =~ ^\^\[\[[[:digit:]]\;[[:digit:]][[:digit:]]m ]]; then
							if [[ ${j} -eq 0 ]]; then
								j=$((${j} + 8))
							else
								j=$((${j} + 7))
							fi
						fi
					else
						((NORMAL_CHAR_COUNT++))
						if [[ ${NORMAL_CHAR_COUNT} -ge ${termWidth} ]]; then
							echo -e "${my_out:0:$((${j} - 5))}"$c0
							break 1
						fi
					fi
				done
			fi

			if [[ "$i" -ge "$startline" ]]; then
				unset out_array[0]
				out_array=( "${out_array[@]}" )
			fi
		done

	elif [[ "$portraitSet" = "Yes" ]]; then
		for ((i=0; $i<${#fulloutput[*]}; i++)); do
			printf "${fulloutput[$i]}$c0\n"
		done

		printf "\n"

		for ((i=0; $i<${#fulloutput[*]}; i++)); do
			[[ -z "$out_array" ]] && continue
			printf "%s\n" "${out_array}"
			unset out_array[0]
			out_array=( "${out_array[@]}" )
		done

	elif [[ "$display_logo" == "Yes" ]]; then
		for ((i=0; i<${#fulloutput[*]}; i++)); do
			printf "${fulloutput[i]}$c0\n"
		done

	else
		if [[ "$lineWrap" = "Yes" ]]; then
			availablespace=$(($(tput cols) - ${logowidth} + 16)) #I dont know why 16 but it works
			new_out_array=("${out_array[0]}")
			for ((i=1; i<${#out_array[@]}; i++)); do
				lines=$(echo ${out_array[i]} | fmt -w $availablespace)
				IFS=$'\n' read -rd '' -a splitlines <<<"$lines"
				new_out_array+=("${splitlines[0]}")
				for ((j=1; j<${#splitlines[*]}; j++)); do
					line=$(echo -e "$labelcolor $textcolor  ${splitlines[j]}")
					new_out_array=( "${new_out_array[@]}" "$line" );
				done
			done
			out_array=("${new_out_array[@]}")
		fi
		missinglines=$((${#out_array[*]} + ${startline} - ${#fulloutput[*]}))
		for ((i=0; i<${missinglines}; i++)); do
			fulloutput+=("${c1}$(printf '%*s' "$logowidth")%s")
		done
		#n=${#fulloutput[*]}
		for ((i=0; i<${#fulloutput[*]}; i++)); do
			# echo "${out_array[@]}"
			febreeze=$(awk 'BEGIN{srand();print int(rand()*(1000-1))+1 }')
			if [[ "${febreeze}" == "411" || "${febreeze}" == "188" || "${febreeze}" == "15" || "${febreeze}" == "166" || "${febreeze}" == "609" ]]; then
				f_size=${#fulloutput[*]}
				o_size=${#out_array[*]}
				f_max=$(( 32768 / f_size * f_size ))
				#o_max=$(( 32768 / o_size * o_size ))
				for ((a=f_size-1; a>0; a--)); do
					while (( (rand=$RANDOM) >= f_max )); do :; done
					rand=$(( rand % (a+1) ))
					tmp=${fulloutput[a]} fulloutput[a]=${fulloutput[rand]} fulloutput[rand]=$tmp
				done
				for ((b=o_size-1; b>0; b--)); do
					rand=$(( rand % (b+1) ))
					tmp=${out_array[b]} out_array[b]=${out_array[rand]} out_array[rand]=$tmp
				done
			fi
			printf "${fulloutput[i]}$c0\n" "${out_array}"
			if [[ "$i" -ge "$startline" ]]; then
				unset out_array[0]
				out_array=( "${out_array[@]}" )
			fi
		done
	fi
	# Done with ASCII output
}

infoDisplay () {
	textcolor="\033[0m"
	[[ "$my_hcolor" ]] && textcolor="${my_hcolor}"
	#TODO: Centralize colors and use them across the board so we only change them one place.
	myascii="${distro}"
	[[ "${asc_distro}" ]] && myascii="${asc_distro}"
	labelcolor=$(getColor 'light cyan')
	[[ "$my_lcolor" ]] && labelcolor="${my_lcolor}"
	if [[ "$art" ]]; then source "$art"; fi
	if [[ "$no_color" == "1" ]]; then labelcolor=""; bold=""; c0=""; textcolor=""; fi
	# Some verbosity stuff
	[[ "$screenshot" == "1" ]] && verboseOut "Screenshot will be taken after info is displayed."
	[[ "$upload" == "1" ]] && verboseOut "Screenshot will be transferred/uploaded to specified location."
	#########################
	# Info Variable Setting #
	#########################
	
	if [[ "${display[@]}" =~ "host" ]]; then myinfo=$(echo -e "${labelcolor} ${myUser}$textcolor${bold}@${c0}${labelcolor}${myHost}"); out_array=( "${out_array[@]}" "$myinfo" ); ((display_index++)); fi
	if [[ "${display[@]}" =~ "distro" ]]; then
		
		if [ -n "$distro_more" ]; then mydistro=$(echo -e "$labelcolor OS:$textcolor $distro_more")
		else mydistro=$(echo -e "$labelcolor OS:$textcolor $distro $sysArch"); fi
		
		out_array=( "${out_array[@]}" "$mydistro$uow" )
		((display_index++))
	fi
	if [[ "${display[@]}" =~ "kernel" ]]; then mykernel=$(echo -e "$labelcolor Kernel:$textcolor $kernel"); out_array=( "${out_array[@]}" "$mykernel" ); ((display_index++)); fi
	if [[ "${display[@]}" =~ "cpu" ]]; then mycpu=$(echo -e "$labelcolor CPU:$textcolor $cpu"); out_array=( "${out_array[@]}" "$mycpu" ); ((display_index++)); fi
	if [[ "${display[@]}" =~ "gpu" ]] && [[ "$gpu" != "Not Found" ]]; then mygpu=$(echo -e "$labelcolor GPU:$textcolor $gpu"); out_array=( "${out_array[@]}" "$mygpu" ); ((display_index++)); fi
	if [[ "${display[@]}" =~ "uptime" ]]; then myuptime=$(echo -e "$labelcolor Uptime:$textcolor $uptime"); out_array=( "${out_array[@]}" "$myuptime" ); ((display_index++)); fi
	if [[ "${display[@]}" =~ "disk" ]]; then mydisk=$(echo -e "$labelcolor Disk:$textcolor $diskusage"); out_array=( "${out_array[@]}" "$mydisk" ); ((display_index++)); fi
	if [[ "${display[@]}" =~ "mem" ]]; then mymem=$(echo -e "$labelcolor RAM:$textcolor $mem"); out_array=( "${out_array[@]}" "$mymem" ); ((display_index++)); fi
	if [[ "${display[@]}" =~ "publicip" ]]; then mypublicip=$(echo -e "$labelcolor Public IP:$textcolor $publicip"); out_array=( "${out_array[@]}" "$mypublicip" ); ((display_index++)); fi
	if [[ "${display[@]}" =~ "localip" ]]; then mylocalip=$(echo -e "$labelcolor Local IP:$textcolor $localip"); out_array=( "${out_array[@]}" "$mylocalip" ); ((display_index++)); fi
	if [[ "${display[@]}" =~ "pkgs" ]]; then mypkgs=$(echo -e "$labelcolor Packages:$textcolor $pkgs"); out_array=( "${out_array[@]}" "$mypkgs" ); ((display_index++)); fi
	if [[ "${display[@]}" =~ "shell" ]]; then myshell=$(echo -e "$labelcolor Shell:$textcolor $myShell"); out_array=( "${out_array[@]}" "$myshell" ); ((display_index++)); fi
	if [ -e /etc/yunohost/installed ]; then
		if [[ "${display[@]}" =~ "ynhversion" ]]; then myynhversion=$(echo -e "$labelcolor YunoHost version:$textcolor $ynhversion"); out_array=( "${out_array[@]}" "$myynhversion" ); ((display_index++)); fi
		if [[ "${display[@]}" =~ "maindomain" ]]; then mymaindomain=$(echo -e "$labelcolor Main domain:$textcolor $maindomain"); out_array=( "${out_array[@]}" "$mymaindomain" ); ((display_index++)); fi
	fi
	if [[ "$use_customlines" = 1 ]]; then customlines; fi

	asciiText
	
}

##################
# Let's Do This!
##################

if [[ -f "$HOME/.screenfetchOR" ]]; then
	source $HOME/.screenfetchOR
fi


for i in "${display[@]}"; do
	if [[ ! "$i" == "" ]]; then
		if [[ $i =~ wm ]]; then
			 ! [[ $WM  ]] && detectwm;
			 ! [[ $Win_theme ]] && detectwmtheme;
		else
			if [[ "${display[*]}" =~ "$i" ]]; then
				if [[ "$errorSuppress" == "1" ]]; then
					detect${i} 2>/dev/null
				else
					detect${i}
				fi
			fi
		fi
	fi
done

infoDisplay
[ "$screenshot" == "1" ] && takeShot
[ "$exportTheme" == "1" ] && themeExport

if ! [ -e /etc/yunohost/installed ]; then
	echo -e "You can go to $labelcolor http://$localip/ $textcolor to execute the post-installation or do it right here."
	read -p "Proceed to post-installation? (y/n) " -n 1
	RESULT=1
	while [ $RESULT -gt 0 ]; do
		if [[ $REPLY =~ ^[Nn]$ ]]; then
		echo -e "\n"
			exit 0
		fi
		echo -e "\n"
		/usr/bin/yunohost tools postinstall
		let RESULT=$?
		if [ $RESULT -gt 0 ]; then
			echo -e "\n"
			read -p "Retry? (y/n) " -n 1
		fi
	done
fi
chvt 2
exit 0

