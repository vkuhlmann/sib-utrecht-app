#!/run/current-system/sw/bin/bash

#set -e
echo "Source this script to expose the resulting environment variables to following commands"
echo 'i.e. `$ . set-request-env.sh` or `$ source set-request-env.sh`'
echo "The API url should not include the trailing slash"
echo -n "Enter API url: "
read api_url
echo -n "Enter user: "
read auth_user
echo -n "Enter app password: "
read auth_passw
echo -e ""

export SIB_AUTH="$auth_user:$auth_passw"
export SIB_API_URL="$api_url"


