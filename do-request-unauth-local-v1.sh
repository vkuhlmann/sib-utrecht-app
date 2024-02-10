#!/run/current-system/sw/bin/bash

set -e
# echo "The API url should not include the trailing slash"
# echo -n "Enter API url: "
# read $api_url
# echo -n "Enter user: "
# read $auth_user
# echo -n "Enter app password: "
# read $auth_passw
# echo -e ""
# 
# AUTH="$auth_user:$auth_passw"

#echo curl --user \'"$SIB_AUTH"\' -X \'"$1"\' -d \'"$3"\' -H \'Content-Type: application/json\' \'"$SIB_API_URL$2"\'
#echo ""
SIB_API_URL="http://192.168.50.200/wordpress/wp-json/sib-utrecht-wp-plugin/v1"
curl -X "$1" -d "$3" -H 'Content-Type: application/json' "$SIB_API_URL$2"

