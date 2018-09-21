#!/usr/bin/env bash

set -e
# set -x	## Uncomment for debugging

printf 'Downloading plugin details\n'

find . -name "sonar-typescript*jar" |xargs rm -rf
ls -al /opt/sonarqube/extensions/plugins


sleep 20

curl -L -sS -o /tmp/pluginList.txt https://update.sonarsource.org/update-center.properties
printf "Downloading additional plugins\n"

cd /opt/sonarqube/extensions-init/plugins/

for PLUGIN in "$@"
do
  printf '\tExtracting plugin download location - %s\n' ${PLUGIN}

  ## Build Breaker plugin is no longer listed in Update Center, have to add it by URL
  if [[ "${PLUGIN}" == "buildbreaker" ]]; then
		 DOWNLOAD_URL=https://github.com/SonarQubeCommunity/sonar-build-breaker/releases/download/2.2/sonar-build-breaker-plugin-2.2.jar
	else 
		DOWNLOAD_URL=$(grep "^${PLUGIN}.downloadUrl" /tmp/pluginList.txt |awk -F '=' '{print $2}' | sed 's/\\//g')
	fi

	echo "{$DOWNLOAD_URL}"
	## Check to see if plugin exists, attempt to download the plugin if it does exist.
	if ! [[ -z "${DOWNLOAD_URL}" ]]; then
		printf "\t\t%-15s" ${PLUGIN}
		curl -L -sS -O -J ${DOWNLOAD_URL} && printf "%10s" "DONE" || printf "%10s" "FAILED"
		printf "\n"
	else
		## Plugin was not found in the plugin inventory
		printf "\t\t%-15s%10s\n" "${PLUGIN}" "NOT FOUND"
	fi

done

ls -al
cd -
rm -f /tmp/pluginList.txt
