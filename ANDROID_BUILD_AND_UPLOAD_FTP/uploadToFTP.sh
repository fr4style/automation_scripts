#!/bin/bash

# This script uploads a file to a FTP server. It's used to automate the IPA APK distribution
# over FTP. Note: The configuration file 'uploadToFTP.config' must be filled with the info required.
#
# Created by Francesco Florio
# floriofrancesco@gmail.com
#


. uploadToFTP.config

mkdir $OUTPUT_APK_FOLDER
mv $INPUT_APK_FILE $OUTPUT_APK_FILE

LOCALE="\"$OUTPUT_APK_FILE\""
REMOTE="\"$OUTPUT_APK_FILE_NAME\""

ftp -n $HOST <<END_SCRIPT
quote USER $USER
quote PASS $PASSWD
cd $DIR
binary
put $LOCALE $REMOTE
quit
END_SCRIPT

exit 0
