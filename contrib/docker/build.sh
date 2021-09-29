#!/bin/bash

BASE_DIR=$(dirname $(realpath $0 ))
moreBuilder=${BASE_DIR}/moreBuilder

defaultSysType=x86_64
SYSTYPE=`lscpu | head -1 | tr -s ' ' | cut -d ' ' -f2`
if [ ${SYSTYPE} != ${defaultSysType} ]; then
	sed -i "s/defaultSysType=x86_64/defaultSysType=${SYSTYPE}/" $0
	sed -i "s|x86_64|${SYSTYPE}|" ${BASE_DIR}/Dockerfile.ubuntu
	sed -i "s|x86_64|${SYSTYPE}|" $0

fi

# DockerHub Account

defaultDockerHub=blackcoinnl
read -p "What is your DockerHub Account Name? (default: ${defaultDockerHub}): " DockerHub
DockerHub=${DockerHub:-${defaultDockerHub}}
if [ ${DockerHub} != ${defaultDockerHub} ]; then
	sed -i "s/defaultDockerHub=blackcoinnl/defaultDockerHub=${DockerHub}/" $0
	sed -i "s|blackcoinnl|${DockerHub}|" ${BASE_DIR}/Dockerfile.ubuntu
	sed -i "s|blackcoinnl|${DockerHub}|" $0

fi

# Git Account

defaultHubLab=gitlab
read -p "Github or Gitlab? (default: ${defaultHubLab}): " HubLab
HubLab=${HubLab:-${defaultHubLab}}
if [ ${HubLab} != ${defaultHubLab} ]; then
	sed -i "s|defaultHubLab=gitlab|defaultHubLab=${HubLab}|" $0
	sed -i "s|HUBLAB=gitlab|HUBLAB=${HubLab}|" ${BASE_DIR}/Dockerfile.ubase
	sed -i "s|HUBLAB=gitlab|HUBLAB=${HubLab}|" ${BASE_DIR}/Dockerfile.minbase
	sed -i "s|HUBLAB=gitlab|HUBLAB=${HubLab}|" $0


fi

defaultGitName=blackcoin
read -p "Git account to use? (default: ${defaultGitName}): " Git
Git=${Git:-${defaultGitName}}
if [ ${Git} != ${defaultGitName} ]; then
	sed -i "s|defaultGitName=blackcoin|defaultGitName=${Git}|" $0
	sed -i "s|GITNAME=blackcoin|GITNAME=${Git}|" ${BASE_DIR}/Dockerfile.ubase
	sed -i "s|GITNAME=blackcoin|GITNAME=${Git}|" ${BASE_DIR}/Dockerfile.minbase
	sed -i "s|GITNAME=blackcoin|GITNAME=${Git}|" $0
fi

# Git Branch

defaultBranch=master
read -p "What branch/version? (default: ${defaultBranch}): " BRANCH
BRANCH=${BRANCH:-${defaultBranch}}
if [ ${BRANCH} != ${defaultBranch} ]; then
	sed -i "s|defaultBranch=master|defaultBranch=${BRANCH}|" $0
	sed -i "s|BRANCH=master|BRANCH=${BRANCH}|" ${BASE_DIR}/Dockerfile.ubase
	sed -i "s|BRANCH=master|BRANCH=${BRANCH}|" ${BASE_DIR}/Dockerfile.minbase
	sed -i "s|master|${BRANCH}|" ${BASE_DIR}/Dockerfile.ubuntu
	sed -i "s|BRANCH=master|BRANCH=${BRANCH}|" $0
	sed -i "s|master|${BRANCH}|" $0
fi

# x11 Desktop QT?
defaultX11=y
read -p "Are you going to need X11docker for QT (visual) client? (default: ${defaultX11}): " X11
X11=${X11:-${defaultX11}}
if [ ${X11} != ${defaultX11} ]; then
	sed -i "s/defaultX11=y/defaultX11=${X11}/" $0
fi

# timezone
defaultTimezone=America/Los_Angeles
read -p "What is your timezone? (default: ${defaultTimezone}): " timezone
timezone=${timezone:-${defaultTimezone}}
if [ ${timezone} != ${defaultTimezone} ]; then
	sed -i "s|defaultTimezone=America/Los_Angeles|defaultTimezone=${timezone}|" $0
	sed -i "s|defaultTimezone=America/Los_Angeles|${timezone}|" ${BASE_DIR}/Dockerfile.ubase
	sed -i "s|defaultTimezone=America/Los_Angeles|${timezone}|" ${BASE_DIR}/Dockerfile.minbase
	sed -i "s|defaultTimezone=America/Los_Angeles|${timezone}|" ${BASE_DIR}/Dockerfile.ubuntu
fi


echo "DockerHub Account: ${DockerHub}"
echo "Git Account: ${Git}"
echo ${BRANCH}
echo ${SYSTYPE}
echo ${timezone}

# tag names
base="${DockerHub}/blackcoin-more-base-${SYSTYPE}:${BRANCH}"
minimal="${DockerHub}/blackcoin-more-minimal-${SYSTYPE}:${BRANCH}"
ubuntu="${DockerHub}/blackcoin-more-ubuntu-${SYSTYPE}:${BRANCH}"

# build
# ubase (base using ubuntu)
# ubuntu (package with full ubuntu distro)
if ! [[ ${X11} =~ [no|n] ]]; then
	docker build -t ${base} - --network=host < ${BASE_DIR}/Dockerfile.ubase
	docker build -t ${ubuntu} - --network=host < ${BASE_DIR}/Dockerfile.ubuntu
	docker image push ${ubuntu}
else
	docker build -t ${base} - --network=host < ${BASE_DIR}/Dockerfile.minbase
fi
# minimal (only package binaries and scripts)
docker run -itd  --network=host --name base ${base} bash
docker cp base:/parts ${moreBuilder}
cd ${moreBuilder}
tar -C parts -c . | docker import - ${minimal}
docker image push ${minimal}