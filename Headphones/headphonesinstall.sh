#!/usr/bin/env bash

# Author:  Mar2zz
# blogs: mar2zz.tweakblogs.net
# License: GNU GPL v3
# 
# This installer is part of "Lazy admins Scripted installers (LaSi)"
# Download main script @
# http://dl.dropbox.com/u/18712538/LaSi/LaSi.sh
#
# please report bugs/issues @
# https://github.com/Mar2zz/LaSi/issues
#  ___________________________________________________________________________________
# | 
# | When not using LaSi's Menuscript:
# | execute this script with the command sudo chmod +x headphonesinstall.sh
# | and run with ./headphonesinstall.sh 
# |            
# | answer all questions the terminal asks,
# | and headphones will be running in no time!
# |___________________________________________________________________________________
#
# Tested succesful on OS's:
# Ubuntu 10.4 Desktop, Ubuntu 10.4 Minimal server, XBMC Live Dharma
#
#######################################################################################
#######################################################################################

VERSION=v0.2
                         
TESTOS1=Ubuntu_10.4_Desktop
TESTOS2=Ubuntu_10.4_Server
TESTOS3=XBMC_Live_Dharma

#######################################################################################
#################### LIST OF VARIABLES USED ###########################################


#SET SOME VARIABLES (SOME VARIABLES WILL BE SET THROUGH LIVE USERINPUT IN TERMINAL)

APP=Headphones;		# name of app to install 
			# APP needs to be exactly the same (caps) as on Github (App.git, without .git)
APPLOW=headphones;	# lowercase appname

CONN1=github.com; 	# to test connections needed to install apps
CONN2=dropbox.com;

GITHUB=https://github.com/rembo10/headphones.git; 	#github-adres
DROPBOX=http://dl.dropbox.com/u/18712538/ 		#dropbox-adres

PACK1=git-core; 	#needed packages to run (using apt to check and install)
PACK1_EXE=git;		#EXE only needed when packagename differs from executable
PACK2=python; 		##names can be changed to distrospecific in IF=statements

INSTALLDIR=/home/$USER/.$APPLOW; #directory you want to install to.
DAEMONUSER=$USER; 	#the user the app is started with
INITD=headphonesinit.d;		#name of default init-script

IPADRESS=0.0.0.0; 	#default ipadress to listen on
PORT=8181; 		#default port to listen on





#######################################################################################


#######################################################################################


LaSi_Logo (){
clear
echo " Lazy admin Scripted installers -----------------------"
echo "                    ___           ___                  "
echo "                   /\  \         /\__\                 "
echo "                  /::\  \       /:/ _/_       ___      "
echo "                 /:/\:\  \     /:/ /\  \     /\__\     "
echo "  ___     ___   /:/ /::\  \   /:/ /::\  \   /:/__/     "
echo " /\  \   /\__\ /:/_/:/\:\__\ /:/_/:/\:\__\ /::\  \     "
echo " \:\  \ /:/  / \:\/:/  \/__/ \:\/:/ /:/  / \/\:\  \__  "
echo "  \:\  /:/  /   \::/__/       \::/ /:/  /     \:\/\__\ "
echo "   \:\/:/  /     \:\  \        \/_/:/  /       \::/  / "
echo "    \::/  /       \:\__\         /:/  /        /:/  /  "
echo "     \/__/         \/__/         \/__/         \/__/   "
echo 
echo "----------------------------------------------- Mar2zz "
echo 
echo
}

show_Author () {
echo '-------------------------------------'
echo 'HEADPHONES IS CREATED BY REMBO10'
echo 'https://github.com/rembo10/headphones'
echo 
echo "LaSi $VERSION"
}

#######################################################################################
####################### TEST IF USER CAN COMPLETE THIS INSTALL ########################


#### 1ST TEST IF USER CAN SUDO ####
	root_Test() {
	if [ "$(id -u)" = "0" ]
		then
		echo "Do not use this installer when logged in as root, it will mess things up!"
		LaSi_Menu
	fi
	if [ "$(sudo id -u)" != "0" ] 
		then
		echo "...but that's not gonna work, you need to sudo to install $APP, now exiting" &&
		LaSi_Menu
	fi
	}

#### 2ND TEST IF USER IS ONLINE ####
	conn_Test () {
		
		git_test () {
		if ! ping -c 1 $CONN1 > /dev/null 2>&1
			then
			echo "Hmmm $CONN1 seems down..." &&
			echo "Need $CONN1 to install... Now exiting" &&
			LaSi_Menu
		fi
		}
		
		dropbox_test () {
		if ! ping -c 1 $CONN2 > /dev/null 2>&1 
			then
			echo "Hmmm $CONN2 seems down..."
			echo "Need $CONN2 to install... Now exiting"
			LaSi_Menu
		fi
		}
	git_test
	dropbox_test
	}


#### PRESENT OPTIONS IN A MENU ####
show_Menu (){
LaSi_Logo 				#some basic info about installer
show_Author				#creator of the app installed
echo
echo "1. (re)Install $APP"
echo "2. Update $APP"
echo "3. Exit script"
echo
echo "Choose one of the above options"
read -p "Enter 1, 2 or 3: " CHOICE
case $CHOICE in
	1)
		check_Packs		#check dependencys
		set_Dir			#choose installation directory
		clone_Git		#clone the git repo and mv to $installdir
		cf_Daemon 		#let user confirm to daemonize
		path_Python		#test if necessary values are true and change if needed
		adj_Initscript		#change values to match installscripts
		cp_Initscript		#copy initscript to /etc/init.d/$applow
		cf_Config		#Let user confirm to start configuration
		new_Config		#import or download configurationfile
		set_IP			#Set Ipadress:Port
		set_UP			#Set Username:Password
		start_App		#Start the application and gl!
		show_Menu
		;;
	2)
		git_Update
		show_Menu
		;;
		
	3)
		LaSi_Menu		#Return to main script
		;;
	*)
		echo "Enter 1, 2 or 3"
		show_Menu
		;;
esac
}


#######################################################################################
#### CHECK AND INSTALL PACKAGES #######################################################

#### CHECK SOFTWARE: GIT-CORE AND PYTHON ####
	check_Packs () {

		check_Pack1 () {
		if ! which $PACK1_EXE
			then
			echo "Cannot find if $PACK1 is installed"
			echo "Trying to install..."
			echo
			INST_PACK=$PACK1
			use_PM
		else
			echo "$PACK1 installed"
		fi
		}

		check_Pack2 () {
		if ! which $PACK2
			then
			echo
			echo "Cannot find if $PACK2 is installed"
			echo "Trying to install..."
			echo
			INST_PACK=$PACK2
			use_PM
		else
			echo "$PACK2 installed"
		fi
		}
	check_Pack1
	check_Pack2
	}


#### DETERMINE PACKAGEMANAGER ####
	use_PM () {

		def_PM () {
		[ -x "$(which $1)" ]
		}

		use_Apt () {
		sudo apt-get install $INST_PACK ||
		use_Manual
		}
	
		use_Yum () {
		sudo yum install $INST_PACK ||
		use_Manual
		}
		
		use_Pac () {
		sudo pacman -S $INST_PACK ||
		use_Manual
		}
		
		use_Manual () {
		echo
		echo "Installing $INST_PACK failed"
		echo "Please install manually..."
		echo
		echo "Type the command to install $INST_PACK"
		echo "e.g. sudo apt-get install $INST_PACK"
		read -p "   :" MAN_INST
		if $MAN_INST 
			then
			echo "Succes!"
		else
			echo "Failed! Solve this before continuing installation"
			echo "Try again or press CTRL+C to quit"
			use_Manual
		fi
		}

	if def_PM apt-get
		then 
		use_Apt
	elif def_PM yum
		then
		use_Yum
	elif def_PM pacman 
		then 
		use_Pac
	else
		echo 'No package manager found!'
		use_Manual
	fi
	}


#### CHOOSE INSTALLATION DIRECTORY ####
	set_Dir () {

		cf_Overwrite () {
		echo "1. Choose another directory"
		echo "2. Backup $INSTALLDIR to LaSi/$APP"
		echo "3. Delete $INSTALLDIR"
		echo "Q. Quit"
		read -p "Press 1, 2, 3 or Q to select an option: " REPLY
		case $REPLY in
		1)
			choose_Dir
			;;
		2)
			echo "Backup $INSTALLDIR to /home/$USER/LaSi/$APP"
			if [ -d /home/$USER/LaSi ]
				then
				mv -f $INSTALLDIR /home/$USER/LaSi/$APP
			else
				mkdir LaSi
				mv -f $INSTALLDIR /home/$USER/LaSi/$APP
			fi
			;;
		3)
			echo "Deleting $INSTALLDIR."
			rm -R -f $INSTALLDIR
			;;
		[Qq]*)
			echo "Fini..."
			LaSi_Menu
			;;
		*)
			echo "Choose 1, 2, 3 or Q to quit"
			cf_Dir
			;;
		esac
		}

		choose_Dir() { 
		read -p 'Type the path of the directory you want to install in...   :' INSTALLDIR
		if [ -d $INSTALLDIR ]
			then
			echo
			echo "$INSTALLDIR allready exists, please choose an option:"
			cf_Overwrite
		else
			echo "Installing $APP in $INSTALLDIR."
		fi
		}

		cf_Dir () {
		if [ -d $INSTALLDIR ]
			then
			echo
			echo "$INSTALLDIR allready exists, please choose an option:"
			cf_Overwrite
		else
			echo "By default $APP will be installed in $INSTALLDIR."
			echo "Do you want to change this?"
			read -p "(yes/no): " REPLY
			case $REPLY in
			[Yy]*)
				choose_Dir
				;;
			[Nn]*)
				echo "Installing $APP in $INSTALLDIR"
				;;
			*)
				echo "Answer yes or no"
				cf_Dir
				;;
			esac
		fi
		}
	cf_Dir
	}


#### CLONING INTO GIT ####
	clone_Git () {
	echo ' '
	echo '-------'
	echo "Download and install the most recent version of $APP from GitHub"
	echo '-------'
	echo ' '
	command git clone $GITHUB $INSTALLDIR
	echo
	# echo "Delete $INSTALLDIR/.git to enable webupdates"
	# rm -R -f $INSTALLDIR/.git
	}


#### CONFIRM DAEMON INSTALL ####
	cf_Daemon () {
	echo
	echo '-------'
	echo "You can install $APP as a daemon, so it will start when your pc starts..."
	echo '-------'
	echo ' '

		Question() {
		echo "Do you want to install $APP as a daemon?"
		read -p "(yes/no): " REPLY
		case $REPLY in
	[Yy]*) # back to main
		echo 'As you wish, master...'
		;;
	[Nn]*)
		echo "You can start app manually by executing python $INSTALLDIR/$APP.py..."
		echo "I prefer the LaSi way though...but have fun using $APP!"
		LaSi_Menu
		;;
	*)
		echo "Answer yes or no"
		Question
		;;
		esac
		}
	Question
	} 


#### TEST NECESSARY DEFAULT PATHS ####
	path_Python() {
		PATH_PYTHON=$(which python)
		sed -i "s#/usr/bin/python#$PATH_PYTHON#g" $INSTALLDIR/$INITD
	}


#### CHANGE VALUES IN INITSCRIPT ####
	adj_Initscript () {
	sed -i "
		s#/usr/local/sbin/headphones#$INSTALLDIR#g
		s/root/$USER/g
		" /$INSTALLDIR/$INITD
	}


#### COPY INITSCRIPT TO /ETC/INIT.D/ ####
	cp_Initscript () {
	if [ -e /etc/init.d/$APPLOW ]
		then
		echo "Making backup of /etc/init.d/$APPLOW to $APPLOW.bak"
		echo "Copying $INSTALLDIR/$INITD to /etc/init.d/$APPLOW..."
		sudo cp -f --suffix=.bak $INSTALLDIR/$INITD /etc/init.d/$APPLOW &&
		sudo chmod +x /etc/init.d/$APPLOW &&
		sudo update-rc.d $APPLOW defaults
	else 
		echo "Copying $INSTALLDIR/$INITD to /etc/init.d/$APPLOW..."
		sudo cp -f $INSTALLDIR/$INITD /etc/init.d/$APPLOW &&
		sudo chmod +x /etc/init.d/$APPLOW &&
		sudo update-rc.d $APPLOW defaults
	fi
	}


#### LET USER CONFIRM CONFIGURATION ####
	cf_Config() {
	echo '-------'
	echo "Now you can start $APP with a clean configuration..."
	echo "By default $APP's webinterface adress is: http://$IPADRESS:$PORT."
	echo "That's the same as http://localhost:$PORT or http://127.0.0.1:$PORT."
	echo "It will not ask for a username and password."
	echo 

		Question() {
		echo "Do you want change the defaults or import your own configuration file?"
		read -p "(yes/no): " REPLY
		case $REPLY in
		[Yy]*)
			echo 'As you wish, master...'
			;;
		[Nn]*)
			sudo /etc/init.d/$APPLOW start &&
			echo "Point your webbrowser to http://$IPADRESS:$PORT and start configuring!"
			LaSi_Menu
			;;
		*)
			echo "Answer yes or no"
			Question
			;;
		esac
		}
	Question
	}

#### GET NEW CONFIGFILE ####
	new_Config(){

		get_Config () { #download new config.ini
		if [ -e $INSTALLDIR/config.ini ]
			then
			mv -f $INSTALLDIR/config.ini $INSTALLDIR/config.ini.bak &&
			wget -P $INSTALLDIR $DROPBOX/$APP/config.ini
		else
			wget -P $INSTALLDIR $DROPBOX/$APP/config.ini
		fi
		}

		import_Config() { # import config.ini
		echo
		echo 'Type the full path and filename of the configurationfile you want to import'
		echo 'or s to skip:'
		read -p ': ' IMPORTCONFIG
		if [ $IMPORTCONFIG = S -o $IMPORTCONFIG = s ]
			then
			cf_Import
		elif [ -e $IMPORTCONFIG ]
			then
			cp -f --suffix=.bak $IMPORTCONFIG $INSTALLDIR/config.ini &&
			sudo /etc/init.d/$APPLOW start &&
			echo "Point your webbrowser to you know where and have fun using $APP!"
			show_Menu
		else
			echo 'File does not exist, enter correct path as /path/to/file.ext' &&
			import_Config
		fi
		}

		cf_Import () { # Confirm import
		echo "Do you want to import your own configurationfile?"
		read -p "(yes/no): " REPLY
		case $REPLY in
		[Yy]*)
			import_Config
			;;
		[Nn]*)
			echo "Downloading fresh config from dropbox.com"
			get_Config
			;;
		*)
			echo "Answer yes or no"
			cf_Import
			;;
		esac
		}
	cf_Import
	}


#### CHANGE DEFAULTS IN CONFIGFILE ####

#### CHANGE IPADRESS AND PORT ####

	set_IP () {
	read -p 'Enter new ipadress, default is 0.0.0.0 ...: ' NEW_IP
	read -p 'Enter new port, default is 8181 ...: ' NEW_PORT

		cf_IP () {
		echo "You entered $NEW_IP:$NEW_PORT, is this correct?"
		read -p "(yes/no): " REPLY
		case $REPLY in
		[Yy]*)
			echo "Ok, adding $NEW_IP:$NEW_PORT to config.ini..."
			sed -i "
				s/http_host = 0.0.0.0/http_host = $NEW_IP/g
				s/http_port = 8181/http_port = $NEW_PORT/g 
			" $INSTALLDIR/config.ini
			;;
		[Nn]*)
			set_IP
			;;
		*)
			echo "Answer yes or no"
			cf_IP
			;;
		esac
		}
	cf_IP
	}

#### CHANGE USERNAME AND PASSWORD ####
	set_UP () {
	read -p 'Enter new username, leave blank for none ...    :' NEW_USER
	read -p 'Enter new password, leave blank for none ...    :' NEW_PASS

		cf_UP () {
		echo "You entered username '$NEW_USER' and password '$NEW_PASS', is this correct?"
		read -p "(yes/no or skip): " REPLY
		case $REPLY in
		[Yy]*)
			echo "Adding username and password to config.ini..."
			sed -i "
				s/http_username = \"\"/http_username = \"$NEW_USER\"/g
				s/http_password = \"\"/http_password = \"$NEW_PASS\"/g
			" $INSTALLDIR/config.ini
			;;
		[Nn]*)
			set_UP
			;;
		[Ss]*)
			echo "Skipped that one, it stays blank"
			;;
		*)
			echo "Answer yes or no or skip"
			cf_UP
			;;
		esac
		}
	cf_UP
	}


#### STARTING APP ####		
	start_App() {
		echo "Now starting $APP..."
		if sudo /etc/init.d/$APPLOW start
			then
			echo "Point your webbrowser to http://$NEW_IP:$NEW_PORT and have fun!"
		else
			echo "Can't start $APP, try starting manually..."
			echo "Execute sudo /etc/init.d/$APPLOW stop | start | restart | force-reload"
		fi
	}


#### UPDATE APP ####
	git_Update () {
	echo
	echo "===="
	echo "Checking for updates $APP"
	cd $INSTALLDIR
	if ! git pull | grep "Already up-to-date"
		then
		sudo /etc/init.d/$APPLOW restart
	fi
	read -sn 1 -p "Press a key to return to menu."
	echo "===="
	}


#### RETURN TO MENU ####
	LaSi_Menu () {

	echo 
	read -sn 1 -p "Press a key to continue."
	exit
	}



#### ALL FUNCTIONS ####	
conn_Test		#connection test for url's used in installation
root_Test		#test user is not root but has sudo
show_Menu

#### TEST OF MAPPEN AL BESTAAN EN STEL VOOR TE VERWIJDERN