#!/bin/sh
# linux-terminal-local-UILOTS.sh

# This script is an adjusted linux-terminal.sh version.
# Basically it copies the content of the folder this script is called.
# The target location is a local location (default: /tmp/)
# This is because a lot of researchers call a Zep script from a share.
# Share is a network based drive and hence calling pictures / sounds
# can be slow which messes up experiment timings.
# To still alow the research group to pool a database the local 
# 'data folder and the 'db' folder are actually symbolic links that link
# to the representative folders in the share drive.

# This file should be a standard include when researchers request a Zep
# script that is meant to be used in the lab.

# Chris van Run
# (UiL-OTS labs, C.P.A.vanRun@uu.nl)
# 2014/07/14
#-------------------------------------------------------------------------------

# Define required Zep version:
ZEP_VER=1.16

# If installed at nonstandard location, define installation location here:
#ZEP_DIR=/opt/zep

#-------------------------------------------------------------------------------
USE=`echo use-zep-[0-9]*`
if [ -e $USE ]; then
	USE=`basename $USE .txt`
	VER=`echo $USE | cut -d- -f3`
	if [ -n "$VER" ]; then
	    ZEP_VER=$VER
	fi
fi

DONE=""
if [ -n "$ZEP_DIR" ]; then
	INITIAL_ZEP_DIR=$ZEP_DIR
	if [ -x $ZEP_DIR/$ZEP_VER/bin/zep ]; then
		DONE=1
	fi
fi

if [ ! "$DONE" ]; then
	ZEP_DIR=/usr/local/lib/zep
	if [ -x $ZEP_DIR/$ZEP_VER/bin/zep ]; then
		DONE=1
	fi
fi

if [ ! "$DONE" ]; then
	ZEP_DIR=/usr/lib/zep
	if [ -x $ZEP_DIR/$ZEP_VER/bin/zep ]; then
		DONE=1
	fi
fi

if [ ! "$DONE" ]; then
	PROGNAME=`basename $0`
	ZEP_DIR=
	echo Unable to locate Zep $ZEP_VER on your system. Tested following folders:
	if [ -n "$INITIAL_ZEP_DIR" ]; then
	    echo "  $INITIAL_ZEP_DIR"
	fi
	echo "  /usr/local/lib/zep"
	echo "  /usr/lib/zep"
	echo ""
	echo "Please (ask your system administrator to) install Zep $ZEP_VER into any"
	echo "of these locations or, in case you already have installed it (or want"
	echo "to install it) at a different location, then define the installation"
	echo "location in $PROGNAME."
	echo ""
	echo "For example if you have installed Zep $ZEP_VER at /home/john/mystuff/zep,"
	echo "then edit $PROGNAME and change this line:"
	echo "   #ZEP_DIR=/opt/zep"
	echo "to"
	echo "   ZEP_DIR=/home/john/mystuff/zep"
	echo "and try again."
	exit
fi

#-------------------------------------------------------------------------------
# This part creates a local copy of the contents of the ZEP folder but symlinks the data and database folder.
#-------------------------------------------------------------------------------
# Define the 'default' names of the database folder ('db') and data folder ('data').
DB_DIR='db' 						# Typical name of the databases
DATA_DIR='data'						# Typical name of the data directory

TEMP_FOLDER='/tmp/zep-tmp/'					# The location to make a local account, using the /tmp/ makes sure it gets cleaned up at every boot!
DATE=$(date +%H)					# To make the local copy unique (hourly and user)
#-------------------------------------------------------------------------------

# Let the caller know that a transfer is about to happen. Won't detail it to much though!

MESSAGE="The ZEP script will be prepared for use in the lab facilities.\n\nDepending on the script size this might take a few moments. A terminal will be opened once the setup has been complete.\n\nPlease be patient."
echo $MESSAGE | zenity --text-info --height=250 --width=400 --title="Copying Zep script files to $TEMP_FOLDER"

if [ $? = 1 ]; then
	exit
fi

#create the temporary folders
CURRENT_PATH=$PWD
ZEP_FOLDER_NAME=$(basename $PWD)
TEMP_LOCAL_FOLDER=$TEMP_FOLDER$DATE'h'-$USER-$ZEP_FOLDER_NAME # Building the full path to the tmp directory

#make a local copy of the directory the zep installation is in but exclude the current database and data directory
mkdir -p $TEMP_LOCAL_FOLDER
rsync -a --exclude=$DB_DIR --exclude=$DATA_DIR $CURRENT_PATH/*  $TEMP_LOCAL_FOLDER 

if [ ! -d $CURRENT_PATH/$DB_DIR ]; then
	rm -fr $TEMP_LOCAL_FOLDER/$DB_DIR # just make sure that here is no folder at the temp location
	mkdir $CURRENT_PATH/$DB_DIR # no database exists yet: create it at the call location
fi

if [ ! -d $DATA_DIR ]; then 
	rm -fr $TEMP_LOCAL_FOLDER/$DATA_DIR # just make sure that here is no folder at the temp location
	mkdir $CURRENT_PATH/$DATA_DIR # no data folder exists yet: create it at the call location
fi

# create a syslink from the network location to the local database and data folder
ln -sf $CURRENT_PATH'/'$DB_DIR $TEMP_LOCAL_FOLDER/$DB_DIR 
ln -sf $CURRENT_PATH'/'$DATA_DIR $TEMP_LOCAL_FOLDER/$DATA_DIR

#-------------------------------------------------------------------------------
# This part then opens up a terminal using the temporary local folder as a working directory
#-------------------------------------------------------------------------------
TERMINAL_TITLE="Zep Terminal"

terminal=`which gnome-terminal`
if [ -x "$terminal" ]; then
#	echo Starting gnome-terminal
	$terminal --geometry=100x30 --title="$TERMINAL_TITLE" --working-directory=$TEMP_LOCAL_FOLDER
	exit
fi

terminal=`which mate-terminal`
if [ -x "$terminal" ]; then
#	echo Starting mate-terminal
	$terminal --geometry=100x30 --title="$TERMINAL_TITLE" --working-directory=$TEMP_LOCAL_FOLDER
	exit
fi

terminal=`which xfce4-terminal`
if [ -x "$terminal" ]; then
#	echo Starting xfce4-terminal
	$terminal --geometry=100x30 --title="$TERMINAL_TITLE" --working-directory=$TEMP_LOCAL_FOLDER
	exit
fi

terminal=`which konsole`
if [ -x "$terminal" ]; then
#	echo Starting konsole
	$terminal --geometry=100x30 --title="$TERMINAL_TITLE"--workdir=$TEMP_LOCAL_FOLDER
	exit
fi

terminal=`which lxterminal`
if [ -x "$terminal" ]; then
#	echo Starting lxterminal
	$terminal --geometry=100x30 --title="$TERMINAL_TITLE" --working-directory=$TEMP_LOCAL_FOLDER
	exit
fi

terminal=`which rxvt-unicode`
if [ -x "$terminal" ]; then
#	echo Starting rxvt-unicode
	$terminal -geometry 100x30 -title "$TERMINAL_TITLE" -bg lemonchiffon -fg black -sb -cd=$TEMP_LOCAL_FOLDER &
	exit
fi

terminal=`which rxvt`
if [ -x "$terminal" ]; then
#	echo Starting rxvt
	$terminal -geometry 100x30 -title "$TERMINAL_TITLE" -bg lemonchiffon -fg black -sb -cd==$TEMP_LOCAL_FOLDER & 
	exit
fi

terminal=`which xterm`
if [ -x "$terminal" ]; then
#	echo Starting xterm
	$terminal -geometry 100x30 -title "$TERMINAL_TITLE" -bg lemonchiffon -fg black -sb -e 'cd '$TEMP_LOCAL_FOLDER' && /bin/bash'  &
	exit
fi
