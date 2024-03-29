#!/bin/sh

echo "Git Sync ..."

if [ ! -n $GIT_REPO ]; then
	echo "!!!	Have to specify your repo in GIT_REPO env to clone"
	exit 1
fi

extract_git_host() {
	echo $(echo $GIT_REPO | sed 's|.*//||; s|.*@||; s|/.*||; s|:.*||')
}

extract_git_repo_name() {
	basename=$(basename $GIT_REPO)
	echo ${basename%.*}
}

GIT_DEST_NAME=${GIT_DEST_NAME:-$(extract_git_repo_name)}
GIT_DEST_DIR=${GIT_DEST_DIR:-"/git/$GIT_DEST_NAME"}
GIT_SSH_ENABLE=${GIT_SSH_ENABLE:-"false"}
GIT_SSH_PORT=${GIT_SSH_PORT:-"22"}
GIT_HOST=${GIT_HOST:-$(extract_git_host)}

if [ "$GIT_SSH_ENABLE" == "true" ]; then
	if [[ ! $GIT_REPO =~ ^git@.* ]]; then
 		echo "GIT_REPO must be startwith git@ when GIT_SSH_ENABLE=true"
		exit 1
	fi
 
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
elif [[ -n $GIT_USERNAME && -n $GIT_ACCESS_TOKEN ]]; then
	if [[ ! $GIT_REPO =~ ^https://.* ]]; then
 		echo "GIT_REPO must be startwith https:// when using username/password authentication"
		exit 1
	fi
	git_repo_without_https=${GIT_REPO#"https://"}
 	GIT_REPO="https://$GIT_USERNAME:$GIT_ACCESS_TOKEN@$git_repo_without_https"
fi

GIT_INIT_CLONE=${GIT_INIT_CLONE:-"true"}
if [ "$GIT_INIT_CLONE" == "true" ]; then
	GIT_BRANCH=${GIT_BRANCH:-"master"}
	if [ -d "$GIT_DEST_DIR" ]; then
		rm -rf $(find $GIT_DEST_DIR -mindepth 1)
	else
		mkdir -p $GIT_DEST_DIR
	fi
	git clone $GIT_REPO -b $GIT_BRANCH $GIT_DEST_DIR
	echo "Cloned $GIT_REPO (branch: $GIT_BRANCH) into $GIT_DEST_DIR"
fi

# to break the infinite loop when we receive SIGTERM
trap "exit 0" SIGTERM

function git_fetch() {
	git fetch origin $GIT_BRANCH
	git reset --hard origin/$GIT_BRANCH
	git clean -fd
	date
}

GIT_SYNC_WAIT_SECOND=${GIT_SYNC_WAIT_SECOND:-"10"}
echo "Synchronizing every $GIT_SYNC_WAIT_SECOND ..."

cd $GIT_DEST_DIR
while true; do
	git_fetch
	sleep $GIT_SYNC_WAIT_SECOND
done
