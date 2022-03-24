#!/bin/sh
if [ ! -n $GIT_REPO ]; then
	echo "!!!	Have to specify your repo in GIT_REPO env to clone"
	exit 1
fi

GIT_DEST=${GIT_DEST:-"/git/cloned_repo"}
GIT_SSH_ENABLE=${GIT_SSH_ENABLE:-"false"}
GIT_REPO_PORT=${GIT_REPO_PORT:-"22"}

if [ "$GIT_SSH_ENABLE" == "true" ]; then
	echo "***	Enabling SSH to clone repo ..."
	GIT_SECRET_DIR=${GIT_SECRET_DIR:-"/etc/git-secret"}
	mkdir -p ~/.ssh/

	if [ -f "$GIT_SSH_PRIVATE_KEY" ]; then
		cp -rL $GIT_SSH_PRIVATE_KEY ~/.ssh/private
	elif [ -f "$GIT_SECRET_DIR/ssh" ]; then
		cp -rL $GIT_SECRET_DIR/ssh ~/.ssh/private
	else
		echo "!!! You have to specify GIT_SSH_PRIVATE_KEY (absolute path)"
		echo "		or mount private key named 'ssh' to GIT_SECRET_DIR folder"
		exit 1
	fi

	if [ -f "$GIT_SSH_KNOWN_HOSTS" ]; then
		cp -rL $GIT_SSH_KNOWN_HOSTS ~/.ssh/known_hosts
	elif [ -f "$GIT_SECRET_DIR/known_hosts" ]; then
		cp -rL $GIT_SECRET_DIR/known_hosts ~/.ssh/known_hosts
	elif [ "$GIT_REPO_HOST" != "" ]; then
		echo "***	Run keyscan from GIT_REPO_HOST: ${GIT_REPO_HOST}"
		ssh-keyscan -p $GIT_REPO_PORT $GIT_REPO_HOST > ~/.ssh/known_hosts
		echo -e "Host $GIT_REPO_HOST\n  Port $GIT_REPO_PORT\n  IdentityFile ~/.ssh/private" > ~/.ssh/config
	else
		echo "!!! You have to specify GIT_SSH_KNOWN_HOSTS (absolute path)"
		echo "		or mount file named 'known_hosts' to GIT_SECRET_DIR folder"
		echo "		or give GIT_REPO_HOST (ex: gitlab.com) to run ssh-keyscan"
		exit 1
	fi
	chmod 600 ~/.ssh/*
fi

GIT_INIT_CLONE=${GIT_INIT_CLONE:-"true"}
if [ "$GIT_INIT_CLONE" == "true" ]; then
	GIT_BRANCH=${GIT_BRANCH:-"master"}
	if [ -d "$GIT_DEST" ]; then
		rm -rf $(find $GIT_DEST -mindepth 1)
	else
		mkdir -p $GIT_DEST
	fi
	git clone $GIT_REPO -b $GIT_BRANCH $GIT_DEST
fi

# to break the infinite loop when we receive SIGTERM
trap "exit 0" SIGTERM

function git_fetch() {
	git fetch origin $GIT_BRANCH
	git reset --hard origin/$GIT_BRANCH
	git clean -fd
	date
}

GIT_SYNC_WAIT=${GIT_SYNC_WAIT:-"10"}
cd $GIT_DEST
while true; do
	git_fetch
	sleep $GIT_SYNC_WAIT
done
