#!/bin/bash  
#
#  The script is used to configure the iOS mobile provisioning on the Jenkins nodes.
#  It must be included into the iOS build pipeline, before start the IPA build.
#  The script checks if the mobileprovisioning passed as param exists inside the jenkins node.
#
#  Warning: the .mobileprovisioning must be committed to the GIT repository, allowing the version check and the installation.
#  Indeed if the .mobileprovisioning file doesn't exist, or is different than the previously saved version, the script save the file, otherwise it does nothing.
#
#  Warning: the .mobileprovisioning must be associated to a valid Apple certificate previously installed to the Jenkins node.
#
#
#  You can use the script as 'jenkinsMobileProvisioningConfig.sh {MOBILE_PROVISIONING}', 
#  where:
#    - the {MOBILE_PROVISIONING} is mobile provisioning used into the project.
#
#  For example, if you use:
#  
#    jenkinsMobileProvisioningConfig './demo.mobileprovisioning'
#
#  Enjoy ;-) 
#
# Created by Francesco Florio
# francesco.florio@nttdata.com
echo "== Configure mobile provisioning == "


if [ $# -ne 1 ]; then
  cat <<EOF

  /!\ Warning /!\

  The script is not used correctly. The right format is:

    jenkinsMobileProvisioningConfig.sh {MOBILEPROVISIONING_FILE}

  or use 
  
     jenkinsMobileProvisioningConfig.sh --help 

  for more info.

EOF
  exit -1;
fi

if [ "$1" == "-h" -o "$1" == "--help" ]; then
  cat <<EOF

  The script is used to configure the iOS mobile provisioning on the Jenkins nodes.
  It must be included into the iOS build pipeline, before start the IPA build.
  The script checks if the mobileprovisioning passed as param exists inside the jenkins node.

  Warning: the .mobileprovisioning must be committed to the GIT repository, allowing the version check and the installation.
  Indeed if the .mobileprovisioning file doesn't exist, or is different than the previously saved version, the script save the file, otherwise it does nothing.

  Warning: the .mobileprovisioning must be associated to a valid Apple certificate previously installed to the Jenkins node.


  You can use the script as 'jenkinsMobileProvisioningConfig.sh {MOBILE_PROVISIONING}', 
  where:
    - the {MOBILE_PROVISIONING} is mobile provisioning used into the project.

  For example, if you use:
  
    jenkinsMobileProvisioningConfig './demo.mobileprovisioning'

  Enjoy ;-) 


EOF
  exit -1;
fi


#Input to config
PROVISIONING_FILE="$1"

SCRIPT_FOLDER=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
PRJ_PROVISIONING_FOLDER=$SCRIPT_FOLDER

PROVISIONING_FOLDER="~/Library/$USER/Provisioning\ Profiles"
PRJ_MOBILE_PROVISIONING="$PRJ_PROVISIONING_FOLDER/$PROVISIONING_FILE"
SYS_MOBILE_PROVISIONING="$PROVISIONING_FOLDER/$PROVISIONING_FILE"

echo "++ Mobile Provisioning to use is '$PROVISIONING_FILE'"

if [[ -f $SYS_MOBILE_PROVISIONING ]]; then
   	echo "++ File exists, check if they are the same."
   	diff "$SYS_MOBILE_PROVISIONING" "$PRJ_MOBILE_PROVISIONING"
    
    DIFF_VALUE=$(echo $?)
   	if [ $DIFF_VALUE -ne 0 ]; then
   		cp "$PRJ_MOBILE_PROVISIONING" "$PROVISIONING_FOLDER"
   		echo "!! Provisionings replaced!"
    else
    	echo "++ Provisionings are the same, nothing to do"
    fi
else
	echo "!! Provisioning not found, I'm copying it into the system folder"
    cp "$PRJ_MOBILE_PROVISIONING" "$PROVISIONING_FOLDER" 
fi
