#!/usr/bin/env bash

set -e
# set -x	## Uncomment for debugging

printf 'Downloading plugin details\n'

sleep 20

curl -L -sS -o /tmp/pluginList.txt https://update.sonarsource.org/update-center.properties
printf "Downloading additional plugins\n"
for PLUGIN in "$@"
do
  printf '\tExtracting plugin download location - %s\n' ${PLUGIN}

  DOWNLOAD_URL = ""
  ## Build Breaker plugin is no longer listed in Update Center, have to add it by URL
  if [[ "${PLUGIN}" == "buildbreaker" ]]; then
		 DOWNLOAD_URL=https://github.com/SonarQubeCommunity/sonar-build-breaker/releases/download/2.2/sonar-build-breaker-plugin-2.2.jar
	else 
		DOWNLOAD_URL=$(grep "^${PLUGIN}.downloadUrl" /tmp/pluginList.txt |awk -F '=' '{print $2}' | sed 's/\\//g')

	## Check to see if plugin exists, attempt to download the plugin if it does exist.
	if ! [[ -z "${DOWNLOAD_URL}" ]]; then
		printf "\t\t%-15s" ${PLUGIN}
		curl -L -sS -o /opt/sonarqube/extensions-init/plugins/${PLUGIN}.jar ${DOWNLOAD_URL} && printf "%10s" "DONE" || printf "%10s" "FAILED"
		printf "\n"
	else
		## Plugin was not found in the plugin inventory
		printf "\t\t%-15s%10s\n" "${PLUGIN}" "NOT FOUND"
	fi

done

rm -f /tmp/pluginList.txt
