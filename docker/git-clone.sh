#!/bin/sh

echo "Git Clone ..."

if [ ! -n $GIT_REPO ]; then
	echo "!!!	Have to specify your repo in GIT_REPO env to clone"
	exit 1
fi

extract_git_host() {
	echo $(echo $GIT_REPO | sed 's|.*//||; s|.*@||; s|/.*||; s|:.*||')
}

extract_git_repo_name() {
    re="^.*\/(.+).git*$"
    if [[ $GIT_REPO =~ $re ]]; then    
        echo ${BASH_REMATCH[1]}
    fi
}

GIT_REPO_NAME=$(extract_git_repo_name)
GIT_DEST=${GIT_DEST:-"/git/$GIT_REPO_NAME"}
GIT_SSH_ENABLE=${GIT_SSH_ENABLE:-"false"}
GIT_SSH_PORT=${GIT_SSH_PORT:-"22"}
GIT_HOST=$(extract_git_host)

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
	else
		echo "Warn: known_hosts is not existed at $GIT_SSH_KNOWN_HOSTS or $GIT_SECRET_DIR/known_hosts"
		echo "Run keyscan from GIT_HOST: ${GIT_HOST}"
		ssh-keyscan -p $GIT_SSH_PORT $GIT_HOST > ~/.ssh/known_hosts
	fi

	echo -e "Host $GIT_HOST\n  Port $GIT_SSH_PORT\n  IdentityFile ~/.ssh/private" > ~/.ssh/config
	chmod 600 ~/.ssh/*
fi

# ensure the git directory is empty, so we can safely clone
GIT_BRANCH=${GIT_BRANCH:-"master"}
if [ -d "$GIT_DEST" ]; then
	rm -rf $(find $GIT_DEST -mindepth 1)
else
	mkdir -p $GIT_DEST
fi

git clone $GIT_REPO -b $GIT_BRANCH $GIT_DEST
echo "Cloned $GIT_REPO (branch: $GIT_BRANCH) into $GIT_DEST"
