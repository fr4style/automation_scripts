#!/bin/bash 
#
#	The script used to rename an APK in the following format: FILENAME_DATETIME_VERSION.apk where
#	   	- FILENAME is the first argument of the script
#	   	- DATETIME is the current timestamp in the following format YYYYMMDDHHMMSS
#	   	- VERSION is the version of the APK defined into the Manifest file.  
#	   	
#	You can use the script as 'renameApk.sh {APK_FILE} {FILE_NAME} {OUTPUT_PATH}', 
#	where:
#		- the {APK_FILE} is the file to upload. The file must be an APK app file. If needed, you can add the relative or the absolute path. 
#		- the {FILENAME} is the output file name prefix.
#		- the {OUTPUT_PATH} is the path where the output file will be saved.
#
#	For example, if you use:
#	
#		renameApk.sh 'app/build/output/release/app-release.apk' 'my_app' '.'
#
#	the output will be:
#
#		./my_app_20180904120000_1.0.apk
#
#	Enjoy ;-)	
#
# Created by Francesco Florio
# francesco.florio@nttdata.com

if [ $# -eq 1 ] && [ "$1" == "-h" -o "$1" == "--help" ]; then
	cat <<EOF

	The script used to rename an APK in the following format: FILENAME_DATETIME_VERSION.apk where
	   	- FILENAME is the first argument of the script
	   	- DATETIME is the current timestamp in the following format YYYYMMDDHHMMSS
	   	- VERSION is the version of the APK defined into the Manifest file.  


	You can use the script as 'renameApk.sh {APK_FILE} {FILE_NAME} {OUTPUT_PATH}', 
	where:
		- the {APK_FILE} is the file to upload. The file must be an APK app file. If needed, you can add the relative or the absolute path. 
		- the {FILENAME} is the output file name prefix.
		- the {OUTPUT_PATH} is the path where the output file will be saved.

	For example, if you use:
	
		renameApk.sh 'app/build/output/release/app-release.apk' 'my_app' '.'

	the output will be:

		./my_app_20180904120000_1.0.apk

	Enjoy ;-)	


EOF
	exit -1;
fi

if [ $# -ne 3 ]; then
	cat <<EOF

	/!\ Warning /!\

	The script is not used correctly. The right format is:

		renameApk.sh {APK_FILE} {FILE_NAME} {OUTPUT_PATH}

	or use 
	
		renameApk.sh --help 

	for more info.

EOF
	exit -1;
fi

#Ottiene la cartella con la versione più nuova dei build-tools
buildToolsList=(`ls $ANDROID_HOME/build-tools | sort -r`)
BUILD_TOOLS_VERSION=${buildToolsList[0]}

inputFile="$1"
fileName="$2"
outputPath="$3"
AAPT_PATH="$ANDROID_HOME/build-tools/$BUILD_TOOLS_VERSION"

dateTime=`date '+%Y%m%d%H%M%S'`

if [[ $inputFile != *.apk ]]; then
	echo "!! The input file must be an APK"
	exit -1
fi

if [[ ! -d $outputPath ]]; then
    echo "!! The output path doesn't exist!"
	exit -1
fi

AAPT_EXEC="$AAPT_PATH/aapt"
if [[ ! -f $AAPT_EXEC ]]; then
    echo "!! aapt command not found!"
	exit -1
fi

versionName=$($AAPT_EXEC dump badging "$inputFile" | awk '/package/{gsub("versionName=|'"'"'","");  print $4}')

mv "$inputFile" "${outputPath}/${fileName}_${dateTime}_${versionName}.apk"

echo "${outputPath}/${fileName}_${dateTime}_${versionName}.apk"