#!/bin/bash

# This is a remastering script for Swift Linux.
# There is a slightly different remastering script for each edition of Swift Linux.
# The only difference is the line beginning with "chroot $1 sh $DIR_SCRIPT"

# The critical lines for Swift Linux follow the line containing the following text:
# Execute if script is NOT called with --build-iso, --chroot, --from-hdd arguments

# The major steps for remastering Swift Linux:
# 1.  Initializing variables 
#     (STARTPATH, ERROR, BUILD, CHROOT, HD, GENERIC, CUSTOM, and USERNAME)
# 2.  get_iso_path: Sets the path name of the antiX Linux ISO file (/dev/cdrom)
# 3.  set_host_path: Sets HOSTPATH as $STARTPATH.
# 4.  create_host_dir: Sets REM as $HOSTPATH/remaster.
# 5A.  create_remaster_env: creates directories for remastering
#     ($REM/iso, $REM/squashfs, $REM/new-squashfs, $REM/new-iso)
# 5B.  mount_iso: Copy the contents of the antiX Linux ISO to $REM/iso
# 5C.  copy_iso: Copy the contents of $REM/iso to $REM/new-iso
# 5D.  mount_compressed_fs: Copies the full directory structure of the antiX Linux ISO to
#      $REM/squashfs
# 5E.  Copy $REM/squashfs to $REM/new-squashfs
# 6.  update_new_iso: Updates $REM/new-iso to include changes to the antiX Linux live CD
#     needed for the Swift Linux live CD
# 7A.  chroot_env newsquashfs: Copy files from /home/$USERNAME/develop to $REM/new-squashfs
#      so that the Swift Linux scripts can be used in the chroot procedure
# 7B.  mount_all: sets up the chroot environment in $REM/new-squashfs
# 7C.  Execute the Swift Linux scripts within the chroot environment (/ = $REM/new-squashfs)
# 7D.  umount_all: removes the chroot environment in $REM/new-squashfs
# 7E.  Remove /usr/local/bin/develop from $REM/new-squashfs
# 8.  build new-squashfs: Create ISO file from the contents of the new-squashfs directory.
# 8A.  set_iso_path: Sets ISOPATH=$REM, the location of the ISO file
# 8B.  set_iso_name: Sets the ISO file name as "remastered.iso".
# 8C.  make_squashfs $1: Creates the file within new-iso/antiX/antiX
# 8D.  make_iso $ISONAME: Creates the ISO file based on the above file within make_squashfs.

# -------------------------------------------------------------------------------------- #
# Script:    remaster.sh                                                                 #
# Details:   remasters antiX and possibly other Live CDs created with SquashFS           #
#                                                                                        #
# This program is distributed in the hope that it will be useful, but WITHOUT            #
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS          #
# -------------------------------------------------------------------------------------- #

# Provides a synopsis:
function usage {
	echo "$0 [-b|--build-iso] [-c|--chroot] [-d|--from-hdd] [old-iso]"
	echo "$0 {-h|--help}"
}

# Offers help:
function help {
	usage
	echo "    old-iso            the path to the original ISO image"
	echo
	echo "    -b|--build-iso     skip creating the chroot environment"
	echo "    -c|--chroot        logs into already created chroot environment"
	echo "    -d|--from-hdd      remasters from harddisk installation (experimental feature)" 
	echo "    -h|--help          display this help"
	echo
	exit
}

# Checks whether a given file system is configured.
function fs_configured {
	grep -q $1 /proc/filesystems
}

# Checks whether squshfs-tools is installed and if it's the right version (needs to be from Etch)
# (modify this for distros that are not based on Debian)
function check_squashfs-tools {
	SQUASH_STATUS=$(dpkg-query -W -f='${Status}' squashfs-tools | cut -d " " -f 2-3)
	SQUASH_VER=$(dpkg-query -W -f='${version}' squashfs-tools)
	if [[ $SQUASH_VER > 1:3.2 || $SQUASH_STATUS != "ok installed" ]]; then
		echo -n "This script needs to use squashfs-tools package from Etch, can I install it" 
		Y_or_n || {
			echo -e "Squshfs-tools is a required package. Script aborted.\n"
			exit
		}
		install_squashfs-tools
	fi	
}

# Installs Squashfs-tools (modify this for distros that don't use apt-get)
# (modify this for distros that are not based on Debian)
function install_squashfs-tools {
	apt-get update
	apt-get install squashfs-tools/stable
	if [[ $? -ne 0 ]]; then
		echo -e "Error installing required package. Script aborted.\n"
		exit
	fi
}

# Utility function: asks yes/no question and return true for "y" and false for "n"; default is "yes" 
function Y_or_n {
	echo -en " (Y/n)? " 
	read answer
	echo
	case $answer in
		no|n) 	return 1;;
		*)	return 0;;
	esac
} 

# Utility function: asks yes/no question and return true for "y" and false for "n"; default is "no" 
function y_or_N {
	echo -en " (y/N)? " 
	read answer
	echo
	case $answer in
		yes|y)	return 0;;
		*)	return 1;;
	esac
}

# Utility function: asks if ready, if "no" exits, continue otherwise
function ready? {
	echo -n "Are you ready to start building the ISO" 
	Y_or_n || { 
		echo -e "OK, to remaster later on, run this script with \"build-iso\" argument, like this \"$0 --build-iso\" or \"$0 -b\" "
		echo
		exit
	}
}

# Set working path where everything is copied
# NOTE: Swift Linux automatically removes any existing remaster directory
# within /usr/local/bin and sets /usr/local/bin/remaster as the remastering
# directory.

function set_host_path {
	shopt -s dotglob # Hidden files are included in rm and cp commands.
	echo -e "Removing /usr/local/bin/remaster/ \n"
	rm -r /usr/local/bin/remaster/
	echo -e "/usr/local/bin/remaster/ removed \n"
	shopt -u dotglob # Hidden files are excluded in rm and cp commands.

	# Execute this section if script was NOT executed with --from-hdd option
	# Sets the current directory as working path, if "remaster" directory already exists prompt for another path
	$HD || {
		if [[ -e $STARTPATH/remaster ]]; then 
			# echo -e "Enter the host path (i.e. /home/username) in which you want to remaster your project:\n"
			# read HOSTPATH
			# Note that the above lines are bypassed in the interest of automation
			echo
			create_host_dir $HOSTPATH || set_host_path
		else
			HOSTPATH=$STARTPATH
			create_host_dir $HOSTPATH || { 
				echo -e "Error creating \"remaster\" directory. Script aborted. \n"
				exit
			}
		fi
		cd $REM
	}
	# Set target path where the remastered ISO will be placed when running the script with --from-hdd option
	$HD && {
		echo -e "Enter the host path (i.e. /mnt/hda5/home/username) in which you want to remaster your project."
		echo -e "When remastering from harddisk you need to specify a different partition than the one you remaster:\n" 
		read HOSTPATH
		echo
		if [[ $HOSTPATH =~ $ROOTPART ]]; then
			set_host_path
		else
			PART=$(echo $HOSTPATH | cut -d "/" -f 3)
			HOSTPART=/mnt/$PART
			grep "$HOSTPART " /etc/mtab >/dev/null || {
				mkdir $HOSTPART &>/dev/null
				mount /dev/$PART $HOSTPART
				if [[ $? -ne 0 ]]; then 
					echo "Could not mount \"$HOSTPART\""
					set_host_path
				fi
			}
		fi
		create_host_dir $HOSTPATH || set_host_path
		cd $REM
	}
}

function create_host_dir {
	if [[ -e $1/remaster ]]; then 
		echo -e "Error: the $1/remaster directory already exists, please use another path.\n"
		return 1
	fi
	mkdir -p $1/remaster
	if [[ $? -ne 0 ]]; then 
		echo -e "Error: the directory was not created, please try again \n"
		return 1
	else 
		echo -e "The project will be created in \"$1/remaster\" directory \n"
		REM=$1/remaster
		echo -e "Okay, we have added a \"remaster\" subdirectory to your host path.\n"
	fi 
}

# Sets the path to iso or cdrom
# NOTE: This Swift Linux version bypasses the manual entry of the path name
# and automatically sets it as /dev/cdrom.
function get_iso_path {
	# if [[ -e $1 ]]; then 
		# CD=$1
		# echo -e  "This script will remaster \"$CD\"  \n"
	# else
		#echo -e "Enter the path of your optical drive with the antiX CD (i.e. /dev/hdc)" 
		# echo -e "Or enter the complete path to a antiX iso on your hard disk (i.e. /path_to_iso/antiX.iso): \n"
		# read CD
		# Note that the above lines under "if" and "else" are deactivated.
		echo -e "The path of the optical drive is /dev/cdrom".
		CD=/dev/cdrom
		echo
		if [[ ! -e $CD ]]; then
			echo -e "Path or file doesn't exist, please try again \n" 
			get_iso_path
		fi
	# fi
}

function create_remaster_env {
	echo "Creating directory structure for this operation"
	mkdir iso squashfs new-iso new-squashfs
	echo "($REM/iso) directory to mount CD on"
	echo "($REM/squashfs) directory for old squashfs"
	echo "($REM/new-squashfs) directory for new squashfs"
	echo -e "($REM/new-iso) directory for new iso \n"
	echo -e "mounting original CD to $REM/iso"
	mount_iso $CD
	copy_iso iso new-iso
	mount_compressed_fs $SQUASH squashfs
	echo -e "Copying mounted squashfs to $REM/new-squashfs (takes some time) \n"
	cp -a squashfs/* new-squashfs/
	umount squashfs
	umount iso
	rm -r squashfs
	rm -r iso
}

# Update menu.lst, menu.lst.extra, and version files in $REM/new-iso
function update_new_iso {
	echo -e "Updating $REM/new-iso directory for new ISO"
	DIR_DEVELOP=/home/$USERNAME/develop

	rm $REM/new-iso/boot/grub/menu.lst
	cp $DIR_DEVELOP/new-iso/files/boot_grub/menu.lst $REM/new-iso/boot/grub/menu.lst
	chown root:root $REM/new-iso/boot/grub/menu.lst

	rm $REM/new-iso/boot/grub/menu.lst.extra
	cp $DIR_DEVELOP/new-iso/files/boot_grub/menu.lst.extra $REM/new-iso/boot/grub/menu.lst.extra
	chown root:root $REM/new-iso/boot/grub/menu.lst.extra

	rm $REM/new-iso/version
	cp $DIR_DEVELOP/new-iso/files/version $REM/new-iso/version
	chown root:root $REM/new-iso/version
	
	rm $REM/new-iso/boot/grub/message
	cp $DIR_DEVELOP/new-iso/files/boot_grub/message $REM/new-iso/boot/grub
	chown root:root $REM/new-iso/boot/grub/message

	rm $REM/new-iso/boot/isolinux/bootlogo
	cp $DIR_DEVELOP/new-iso/files/boot_isolinux/bootlogo $REM/new-iso/boot/isolinux
	chown root:root $REM/new-iso/boot/isolinux/bootlogo
	
	rm $REM/new-iso/boot/isolinux/en.hlp
	cp $DIR_DEVELOP/new-iso/files/boot_isolinux/en.hlp $REM/new-iso/boot/isolinux
	chown root:root $REM/new-iso/boot/isolinux/en.hlp
	
	rm $REM/new-iso/boot/isolinux/isolinux.cfg
	cp $DIR_DEVELOP/new-iso/files/boot_isolinux/isolinux.cfg $REM/new-iso/boot/isolinux
	chown root:root $REM/new-iso/boot/isolinux/isolinux.cfg
	
	rm $REM/new-iso/boot/isolinux/languages
	cp $DIR_DEVELOP/new-iso/files/boot_isolinux/languages $REM/new-iso/boot/isolinux
	chown root:root $REM/new-iso/boot/isolinux/languages
	
	rm $REM/new-iso/boot/isolinux/message
	cp $DIR_DEVELOP/new-iso/files/boot_isolinux/message $REM/new-iso/boot/isolinux
	chown root:root $REM/new-iso/boot/isolinux/message

	rm $REM/new-iso/boot/isolinux/af.hlp
	rm $REM/new-iso/boot/isolinux/ar.hlp
	rm $REM/new-iso/boot/isolinux/ca.hlp
	rm $REM/new-iso/boot/isolinux/cs.hlp
	rm $REM/new-iso/boot/isolinux/da.hlp
	rm $REM/new-iso/boot/isolinux/de.hlp
	rm $REM/new-iso/boot/isolinux/el.hlp
	rm $REM/new-iso/boot/isolinux/es.hlp
	rm $REM/new-iso/boot/isolinux/et.hlp
	rm $REM/new-iso/boot/isolinux/fi.hlp
	rm $REM/new-iso/boot/isolinux/fr.hlp
	rm $REM/new-iso/boot/isolinux/gu.hlp 
	rm $REM/new-iso/boot/isolinux/hr.hlp 
	rm $REM/new-iso/boot/isolinux/hu.hlp
	rm $REM/new-iso/boot/isolinux/it.hlp 
	rm $REM/new-iso/boot/isolinux/ja.hlp
	rm $REM/new-iso/boot/isolinux/ko.hlp
	rm $REM/new-iso/boot/isolinux/ky.hlp
	rm $REM/new-iso/boot/isolinux/lt.hlp
	rm $REM/new-iso/boot/isolinux/mr.hlp 
	rm $REM/new-iso/boot/isolinux/nb.hlp
	rm $REM/new-iso/boot/isolinux/nl.hlp
	rm $REM/new-iso/boot/isolinux/pa.hlp
	rm $REM/new-iso/boot/isolinux/pl.hlp
	rm $REM/new-iso/boot/isolinux/pt_BR.hlp
	rm $REM/new-iso/boot/isolinux/pt.hlp
	rm $REM/new-iso/boot/isolinux/ro.hlp
	rm $REM/new-iso/boot/isolinux/ru.hlp
	rm $REM/new-iso/boot/isolinux/sk.hlp
	rm $REM/new-iso/boot/isolinux/sv.hlp
	rm $REM/new-iso/boot/isolinux/th.hlp
	rm $REM/new-iso/boot/isolinux/uk.hlp
	rm $REM/new-iso/boot/isolinux/xh.hlp
	rm $REM/new-iso/boot/isolinux/zh_CN.hlp
	rm $REM/new-iso/boot/isolinux/zh_TW.hlp

}

# Mounts ISO named $1 to $REM/iso
function mount_iso {
	cd $STARTPATH
	mount -o loop $1 $REM/iso
	if [[ $? -ne 0 ]]; then
		echo -n "Could not mount the CD image, do you want to try again"
		Y_or_n || exit 3
		$0
		exit
	fi
	cd $REM
}

# Copy cdrom content (except squash file) from $1 to $2
function copy_iso {
	# Finds the biggest file in ISO, which is most likely the squash file
	SQUASH=$(find $1 -type f -printf "%s %p\n" | sort -rn | head -n1 | cut -d " " -f 2)
	echo "Copying live CD files to $2"
	SQUASH_REL=${SQUASH#$1/}
	rsync -a $1/ $2 --exclude=$SQUASH_REL
}

# Function mounts file $1 of type $2
function mount_compressed_fs { 
	echo "Mounting original squashfs to $REM/squashfs"
	mount -t $2 -o loop $1 squashfs
	if [[ $? -ne 0 ]]; then
		umount iso
		echo "Error mounting squashfs file. \"$1\" is probable not a $2 file."
		echo "Cleaning up, removing \"remaster\" directory.\n"
		cd ..
		rm -r remaster
		exit 4
	fi
}

# Find the "remaster" directory when script launched with --chroot or --build-iso 
function get_remaster_dir {
	HOSTPATH=$PWD
	if [[ ! -d $HOSTPATH/remaster ]]; then 
		echo -e "Enter the path to the remaster directory (e.g., /home/username):\n"
		read HOSTPATH
		echo
		[[ ! -d $HOSTPATH/remaster ]] && {
			echo -e "\"remaster\" directory not found in that path, please try again:\n"
			get_remaster_dir
		}
	fi
	REM=$HOSTPATH/remaster
	cd $REM
}

# Mounts all needed directories for chroot environment
function mount_all {
	# Mount /proc and /sys and set up networking (I prefer to mount temporarily resolv.conf instead of copying it)
	mount --bind /proc $1/proc
	mount --bind /sys $1/sys
	mount --bind /dev $1/dev
	mount --bind /dev/pts $1/dev/pts
	mount --bind /tmp $1/tmp
	touch $1/etc/resolv.conf
	mount --bind /etc/resolv.conf $1/etc/resolv.conf
}

# Unmounts all mounted directories/files
function umount_all {
	grep "$1" /etc/mtab >/dev/null && {
		umount $1/tmp
		umount $1/dev/pts
		umount $1/dev
		umount $1/sys
		umount $1/proc
		umount $1/etc/resolv.conf
	}
	grep "gshadow" /etc/mtab >/dev/null && {
		cd /
		umount $ROOTPART/etc/group
		umount $ROOTPART/etc/gshadow
		umount $ROOTPART/etc/hostname
		umount $ROOTPART/etc/hosts
		umount $ROOTPART/etc/passwd
		umount $ROOTPART/etc/shadow
		umount $ROOTPART/etc/sudoers
		umount $ROOTPART/home
		cd $REM
	}
}

# Commands that clean up the chroot environment at log out
function cleanup {
	echo -n "Do you want to remove \"/root/.bash_history\", \"/root/.synaptic/log/\", \"/var/lib/apt/lists/*\""
	Y_or_n && {
		rm -f $1/root/.synaptic/log/*
		rm -f $1/root/.bash_history
		rm -r $1/var/lib/apt/lists/*
		mkdir $1/var/lib/apt/lists/partial
	}
}

# Builds squashfs from $1 folder and then makes the new ISO
function build { 
	# edit_version_file
	set_iso_path
	set_iso_name
	make_squashfs $1
	make_iso $ISONAME
}

# Mounts filesystems and chroots to remastering environment, at exit unmounts all filesystems and perform cleanup for remastering environment
function chroot_env {
	# Before chroot operations, copy the development files to the new-squashfs directory.
	# This is necessary to give the chroot environment access to the files in the
	# /home/$USERNAME/develop directory.
	echo "Copying the development files to the new-squashfs directory"

	cp -r /home/$USERNAME/develop $REM/new-squashfs/usr/local/bin

	mount_all $1

	# Assume root in our new squashfs 
	echo -e "Chrooting into your / \n"
	# echo -e "You should now be in the environment you want to remaster. To check please type \"ls\" - you should see a root directory tree."
	# echo -e "When done please type \"exit\" or press CTRL-D \n"
	# set_chroot_commands $1

	# Note that the above few lines are commented to bypass the manual process.

	# chroot $1 # Remove first # in this line to pause the action
	chroot $1 sh /usr/local/bin/develop/1-build/shared-regular.sh # Creates Swift Linux in the
	# chroot environment
	
	umount_all $1

	echo "Removing the development files from the new-squashfs directory"
	rm -r $REM/new-squashfs/usr/local/bin/develop
	
	# cleanup $1
}

# Execute commands automatically after you enter the chroot environment and at log out. 
function set_chroot_commands {
	# Backup original bash.bashrc
	cp $1/etc/bash.bashrc $1/etc/bash.bashrc_original
	echo '
		# Commands to be run automatically after entering chroot
		
		# Restore original file
		mv /etc/bash.bashrc_original /etc/bash.bashrc

		# Start a new session 
		/bin/bash

		# Commands to run automatically when exiting from chroot environment (e.g., clean-up commands) 
		echo
		echo -e "Cleaning chroot environment..."
		apt-get clean
		echo -e "Exiting chroot.\n"
		exit' >> $1/etc/bash.bashrc
}

function edit_version_file {
	echo -e "This is your current version file: \n"
	echo "----------------------------------------------------"
	cat new-iso/version
	echo
	echo -e "----------------------------------------------------\n"
	echo -n "Would you like to amend your version file"
	# The following section is bypassed in the interest of automation.
	# y_or_N && {
	# 	chmod +w new-iso/version
	# 	${EDITOR:-nano} new-iso/version
	# 	chmod -w new-iso/version
	#}
}

# Set ISO path
function set_iso_path {
	cd $STARTPATH
	ISOPATH=$REM
	echo -e "The ISO file will be placed by default in \"$REM\" directory. \n"
	# The following lines are bypassed in the interest of automation.
	# echo -n "Is that OK"
	# Y_or_n && ISOPATH=$REM || {
		# while true; do 
			# echo -e "Enter the path (i.e. /home/username) in which you want to place your ISO file: \n"
			# read ISOPATH
			# echo
			# if [[ -d $ISOPATH ]]; then 
				# break
			# else
				# echo -n "\"$ISOPATH\" doesn't exist, create"
				# Y_or_n && {
					# mkdir -p $ISOPATH
					# if [[ $? -ne 0 ]]; then
						# echo -e "Error: the directory was not created, please try again \n"
					# else
						# echo -e "The path will be \"$ISOPATH\" \n"
						# break
					# fi
				# }
			# fi
		# done
	# }
}

function set_iso_name {
	ISONAME="remastered.iso" # Name of ISO file is set as remastered.iso .
	ISONAME=$ISOPATH/$ISONAME # Revised to include the full path name.
	# You can rename the ISO file manually AFTER the remastering process is complete.
	# The following lines are bypassed in the interest of automation.
	# echo -e "Enter the name of the ISO file (default: remastered.iso) \n"
	# read ISONAME
	# if [[ $ISONAME = "" ]]; then
		# ISONAME="remastered.iso"
	# fi
	
	# echo
	# if [[ -e $ISONAME ]]; then 
		# echo -n "File exists, overwrite"
		# Y_or_n || set_iso_name
	# fi
}

# Create new squashfs in the new-iso
function make_squashfs {
	cd $REM
	echo -e "Good. We are now creating your iso. Sit back and relax, this takes some time (some 20 minutes on an AMD +2500 for a 680MB iso). \n"
	mksquashfs $1 new-iso/antiX/antiX -noappend
	if [[ $? -ne 0 ]]; then
		echo -e "Error making squashfs file. Script aborted.\n" 
		exit 5
	fi
}

# makes iso named $1 
function make_iso {
	cd $STARTPATH
	mkisofs -l -J -pad -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/isolinux/isolinux.bin -c boot/isolinux/isolinux.cat -o $1 $REM/new-iso && isohybrid $1 $REM/new-iso
	if [[ $? -eq 0 ]]; then 
		echo
		echo "Done. You will find your very own remastered home-made Linux here: $1"
		check_size $1
	else
		echo
		echo -e "ISO building failed.\n"
	fi
	cd $REM
}

# Displays size of created ISO file and recommends storage medium
function check_size {
	SIZE=$(ls -l $1 | cut -d " " -f 5)
	let SIZE=$SIZE/1048576 #convert in MB
	echo -n "File size = $SIZE MB, " 
	if [[ $SIZE -lt 50 ]]; then
		echo -e "you can burn this file on a business-card CD, or a larger medium\n"
	else if [[ $SIZE -lt 180 ]]; then
		echo -e "you can burn this file on a Mini CD, or a larger medium\n"
	else if [[ $SIZE -lt 650 ]]; then
		echo -e "you can burn this file on a 650 MB / 74 Min. CD, or a larger medium\n"
	else if [[ $SIZE -lt 700 ]]; then
		echo -e "you can burn this file on a 700 MB / 80 Min. CD, or a larger medium\n"
	else if [[ $SIZE -lt 4812 ]]; then 
		echo -e "this is too big for a CD, burn it on a DVD\n" 
	else if [[ $SIZE -lt  8704 ]]; then 
		echo -e "this is too big for a 4.7 GB DVD, burn it on a dual-layer DVD\n" 
	else 
		echo -e "the file is probably too big to burn even on a dual-layer DVD\n"
		fi; fi; fi; fi; fi
	fi
}

# "--from-hdd" or "-d" mode can be run only from a Live CD
function check_installed {
	# Determine if running from HDD
	INSTALLED="yes"
	if [[ -e /proc/sys/kernel/real-root-dev ]]; then
		case "$(cat /proc/sys/kernel/real-root-dev 2>/dev/null)" in 256|0x100) INSTALLED="" ; ;;
		esac
	fi
	if [[ $INSTALLED = "yes" ]]; then 
		echo
		echo -e "You started the script with \"--from-hdd\" option, you need to run the script from a Live CD\n"
		exit
	fi
}

# Chooses between two ways of creating a Live CD from hdd
function generic_or_custom? { 
	echo "You have two choices here:"
	echo "1. Remaster a generic Live CD -- you'll lose your user account(s), you have to use Live CD's default accounts and passwords, /home partition or directory will not be included in resulting ISO."
	echo -e "2. Remaster a custom Live CD -- you'll keep your own account(s) and paswords in the new Live CD\n (WARNING! NOT WORKING YET!) " 
	echo -e "Please enter your choice: 1 or 2\n" 
	read answer
	echo
	case $answer in
		2)	CUSTOM="true"; custom_cd;;
		*)	GENERIC="true"; generic_cd;;
	esac
}

# Temporary mount files that need to be included in the new squashfs file
function generic_cd {
	mount --bind /etc/group $ROOTPART/etc/group
	mount --bind /etc/gshadow $ROOTPART/etc/gshadow
	mount --bind /etc/hostname $ROOTPART/etc/hostname
	mount --bind /etc/hosts $ROOTPART/etc/hosts
	mount --bind /etc/passwd $ROOTPART/etc/passwd
	mount --bind /etc/shadow $ROOTPART/etc/shadow
	mount --bind /etc/sudoers $ROOTPART/etc/sudoers
	mount --bind /home $ROOTPART/home
}

function custom_cd {
	echo "This option DOESN'T completely work yet. To log in in the resulting Live CD you need to:"
	echo " 1. boot the Live CD using \"aufs\" option"
	echo " 2. press CTRL-ALT-F1, log in as root and execute this command: \"mount --bind /aufs/home /home\""
	echo " 3. run: \"/etc/init.d/kdm restart\"" 
}

# Asks user to entry / and /home partition to remaster
function get_remaster_partition {
	echo -e "Enter the partition that you want to remaster (e.g., hda3)\n" 
	read PART
	echo
	ROOTPART=/mnt/$PART
	if [[ ! -e $ROOTPART ]]; then
		mkdir $ROOTPART
	fi
	mount_partition /dev/$PART $ROOTPART 
	$CUSTOM && {
		echo -n "Do you have /home on a different partition"
		y_or_N && {
			echo -e "Enter /home partition (e.g., hda4)\n" 
			read HOMEPART
			echo
			mount_partition /dev/$HOMEPART $ROOTPART/home
		}
	}
}

function mount_partition {
	grep "$2 " /etc/mtab >/dev/null || {
		mount $1 $2
		if [[ $? -ne 0 ]]; then 
			echo
			echo -n "Could not mount \"$2\" partition, retry" 
			Y_or_n || exit 
			get_remaster_partition
		fi
	}
}

# Root check 
if [[ $UID != "0" ]]; then
	echo -e "You need to be root to execute this script.\n"
	exit 1
fi

# Check that we have a squashfs file system configured.
fs_configured squashfs || modprobe squashfs || {
	echo
	echo "This remastering process uses the \"squashfs\" file system which doesn't seem to be installed on your system. Without it we cannot proceed. Run \"apt-get install squashfs-modules-\$(uname -r)\" \n"
	echo -e "If you do have the package installed you might need to run this command \"modprobe squashfs\" before running this script\n"
	echo -e "Script aborted.\n"
	exit 2
}

# Initializing variables
STARTPATH=/usr/local/bin # instead of $PWD
ERROR=false
BUILD=false
CHROOT=false
HD=false
GENERIC=false
CUSTOM=false
USERNAME=$(logname)

# Captures command line options:
for args; do
	case "$1" in
		-b|--build-iso) BUILD=true;;
		-c|--chroot) 	CHROOT=true;;
		-d|--from-hdd) 	HD=true;;
		-h|--help) 	help;;
		--) 		shift; break;;
		-*) 		echo "Unrecognized option: $1"; ERROR=true;;
		*) 		break;;
	esac
	shift
done

# Exits to help if not understood:
$ERROR && help

# This checks if squshfs-tools is installed and if it's the right version
#check_squashfs-tools

# Execute this section if script called with --from-hdd or -d
$HD && {
	check_installed  ## check if script runs from HDD
	get_remaster_partition
	generic_or_custom?
	set_host_path
	mkdir new-iso
	copy_iso /cdrom $REM/new-iso
	echo
	echo -n "Do you want to chroot to $ROOTPART to add/remove programs" 
	Y_or_n && { 
		echo -e "WARNING!!! You are chrooting to $ROOTPART, any changes in the chroot environment will affect the actual hard disk installation. \n" 
		chroot_env $ROOTPART
	}
	build $ROOTPART
	umount_all 
	rm -r new-iso
	exit
}

# Execute this section if script called with --chroot or -c
$CHROOT && {
	get_remaster_dir
	chroot_env new-squashfs
	ready? 
	build new-squashfs
	exit
}

# Execute this section if script called with --build-iso or -b
$BUILD && {
	get_remaster_dir
	build new-squashfs
	exit
}

# THIS IS THE CRITICAL SECTION FOR SWIFT LINUX
# Execute if script is NOT called with --build-iso, --chroot, --from-hdd arguments
get_iso_path $1 # Revised for Swift Linux
set_host_path # Revised for Swift Linux
create_remaster_env
update_new_iso
chroot_env new-squashfs
# ready? # Manual procedure bypassed
build new-squashfs
echo "Please unmount the antiX Linux ISO from the CD drive."
