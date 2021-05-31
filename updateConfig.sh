#!/bin/bash

echo "#### command started ####"

ENVIRONMENTS=("QA" "STAGING" "STAGING_EMEA" "PRODUCTION" "PRODUCTION_EMEA")
OPTION=$1
CURRENT_ENV=""
REGRESSION_DATA_FILE_PATH=$(pwd)"/regression-data.txt"

cd ../HQ-api-server-functional-tests/config || exit

# READ regression-data to store it locally
while read line
do
  if [[ " ${ENVIRONMENTS[*]} " =~ $line ]]; then
    CURRENT_ENV=$line
    declare -a "$CURRENT_ENV=()"
    continue
  else
    line=(${line//:/ })
    val=${line[1]}
    eval "$CURRENT_ENV+=($val)"
#    eval 'nEntries=${'${CURRENT_ENV}'[@]}'
  fi
done < "$REGRESSION_DATA_FILE_PATH"

# look for the places to be replaced
if [ "$OPTION" == "ALL" ] || [ -z "$OPTION" ] ; then

  echo "====> running all test environments"

  for el in "${ENVIRONMENTS[@]}";
  do
      echo "====> working on $el..."

      lower=$(echo "$el" | awk '{print tolower($0)}') # toLowerCase
      dash_replacement=$(echo "$lower" | tr _ -) # replace underscore with dash

      LAYOUT_TEST_FILE_NAME="$dash_replacement-regression.json"
      TARGET_FILE_PATH=$(pwd)"/local.json"

      cp "$LAYOUT_TEST_FILE_NAME" "$TARGET_FILE_PATH"

      eval 'client_id=${'${el}'[0]}'
      eval 'secret_id=${'${el}'[1]}'
      eval 'account_fulfillment=${'${el}'[2]}'
      eval 'sed -i "" -e "s|{{CLIENT_ID}}|'${client_id}'|g" '${TARGET_FILE_PATH}
      eval 'sed -i "" -e "s|{{CLIENT_SECRET}}|'${secret_id}'|g" '${TARGET_FILE_PATH}
      eval 'sed -i "" -e "s|{{ACCOUNT_FULFILLMENT_UID}}|'${account_fulfillment}'|g" '${TARGET_FILE_PATH}

      # run the command for the current environment
      echo "====> running regression..."
      npm run test:regression:v1api
  done
else
  #something here
  echo "particular case..."
fi

echo "#### command finished ####"
