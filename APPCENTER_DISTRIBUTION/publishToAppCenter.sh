#!/bin/bash

############################################################################################################################################
#
# The script allows to automate the IPA / APK distribution by Appcenter (https://appcenter.ms/).
#
#	You can use the script as 'publishToAppCenter.sh {AppCenter project URL} {File (IPA|APK)} {API TOKEN}', 
#	where:
#		- the {AppCenter project URL} is the full URL for the getting started page, i.e.:
#		  https://appcenter.ms/users/fflorio/apps/ExampleApp/
#		- the {File (IPA|APK)} is the file to upload. The file must be an IPA or APK app file. If needed, you can add the relative or the absolute path. 
#		- the {API TOKEN} is the user API TOKEN, to grant the right upload and distribute permissions. To create a new API TOKEN, please read the official guide here: https://docs.microsoft.com/en-us/appcenter/api-docs/index
#
#	For example, you can use:
#	
#		publishToAppCenter.sh 'https://appcenter.ms/users/fflorio/apps/ExampleApp/' 'app/build/output/release/app-release.apk' '4ada12716b936c0e53921b21199dd763d4a2456j'
#	
#	Enjoy ;-)	
#
#
# Created by Francesco Florio
# francesco.florio@nttdata.com - floriofrancesco@gmail.com
#
############################################################################################################################################
if [ $# -eq 1 ] && [ "$1" == "-h" -o "$1" == "--help" ]; then
	cat <<EOF

	The script allows to automate the IPA / APK distribution by Appcenter (https://appcenter.ms/).

	You can use the script as 'publishToAppCenter.sh {AppCenter project URL} {File (IPA|APK)} {API TOKEN}', 
	where:
		- the {AppCenter project URL} is the full URL for the getting started page, i.e.:
		  https://appcenter.ms/users/fflorio/apps/ExampleApp/
		- the {File (IPA|APK)} is the file to upload. The file must be an IPA or APK app file. If needed, you can add the relative or the absolute path. 
		- the {API TOKEN} is the user API TOKEN, to grant the right upload and distribute permissions. To create a new API TOKEN, please read the official guide here: https://docs.microsoft.com/en-us/appcenter/api-docs/index

	For example, you can use:
	
		publishToAppCenter.sh 'https://appcenter.ms/users/fflorio/apps/ExampleApp/' 'app/build/output/release/app-release.apk' '4ada12716b936c0e53921b21199dd763d4a2456j'

	Enjoy ;-)	


EOF
	exit -1;
fi

if [ $# -ne 3 ]; then
	cat <<EOF

	/!\ Warning /!\

	The script is not used correctly. The right format is:

		publishToAppCenter.sh {AppCenter project URL} {File (IPA|APK)} {API TOKEN}
	
	or use 
	
		publishToAppCenter.sh --help 

	for more info.

EOF
	exit -1;
fi

PROJECT_URL=$1
FILE_PATH=$2
API_TOKEN=$3;

IFS='/' read -r -a url_items <<< "$PROJECT_URL"

APP_NAME=${url_items[6]};
OWNER_NAME=${url_items[4]};

function jsonval {
	json="$1"
	prop="$2"
    temp=`echo $json | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $prop | sed -e 's/^ *//g' -e 's/ *$//g' `
    echo ${temp##*|}
}

BASE_URL="https://api.appcenter.ms/v0.1/apps/$OWNER_NAME/$APP_NAME";
DISTRIBUTION_GROUPS=$(curl -X GET --header "X-API-Token: $API_TOKEN" "$BASE_URL/distribution_groups");
FIRST_STEP_URL="$BASE_URL/release_uploads"

FIRST_STEP_RESPONSE=$(curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header "X-API-Token: $API_TOKEN" "$FIRST_STEP_URL");

UPLOAD_ID_DELIM="upload_id=";

UPLOAD_URL=$(jsonval $FIRST_STEP_RESPONSE 'upload_url');
UPLOAD_ID=${UPLOAD_URL#*$UPLOAD_ID_DELIM}

echo "## UPLOAD ##"
UPLOAD_RESPONSE=$(curl -F "ipa=@$FILE_PATH" "$UPLOAD_URL");

echo "## COMMIT ##"
COMMIT_URL="$FIRST_STEP_URL/$UPLOAD_ID";

RELEASE_RESPONSE=$(curl -X PATCH --header 'Content-Type: application/json' --header 'Accept: application/json' --header "X-API-Token: $API_TOKEN" -d '{ "status": "committed" }' "$COMMIT_URL");
RELEASE_ID=$(jsonval $RELEASE_RESPONSE 'release_id')
LAST_STEP_URL="$BASE_URL/releases/$RELEASE_ID";

echo "## DELIVERY ##"
RESPONSE=$(curl -X PATCH --header 'Content-Type: application/json' --header 'Accept: application/json' --header "X-API-Token: $API_TOKEN" -d '{ "destinations": '$DISTRIBUTION_GROUPS',"release_notes": "Delivered by FFlorio script"}' "$LAST_STEP_URL");
echo $RESPONSE;