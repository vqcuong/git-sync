### Build docker image
```
./docker/build.sh <dockerhub repository> <tag_name|version>

Example: ./docker/build.sh vqcuong96/ latest (image name is vqcuong96/git-sync:latest)
```

### Usage
Currently only support public repositories or private repositories with ssh authentication

Environment:

- Basic
```
GIT_REPO (require): git repository endpoint, supported for both https and ssh protocol
GIT_BRANCH (optional): target branch to clone, default: master
GIT_DEST_NAME (optional): subdirectory inside /git folder to clone repository into, default: <repository name>
GIT_DEST_DIR (optional): destionation directory to clone repository into, default: /git/$GIT_DEST_NAME
GIT_SYNC_WAIT_SECOND (optional): number of seconds delay for each sync time, default: 10
GIT_SSH_ENABLE (optional): whether ssh enabled or not, default: false
```
- For ssh
```
GIT_SSH_KNOWN_HOSTS (optional): known_hosts file path. If not provided, it will be auto-scaned from git server
GIT_SSH_PRIVATE_KEY (require when GIT_SSH_ENABLE=true): ssh private key path
GIT_SECRET_DIR (optional): ssh secret directory containing known_hosts and ssh private key, may use as replacement of GIT_SSH_KNOWN_HOSTS and GIT_SSH_PRIVATE_KEY
```
### Deployment (example docker-compose.yaml)
```
version: "3.8"
services:
  git-sync:
    image: vqcuong96/git-sync:latest
    container_name: git-sync
    environment:
      - GIT_REPO=git@gitlab.com/vqcuong96/git-sync.git
      - GIT_BRANCH=master
      - GIT_SSH_ENABLE=true
      - GIT_SSH_PRIVATE_KEY=/.private-key
    volumes:
      - .ssh-private-key:/.private-key
      - ./myvolume:/git:rw # default cloned directory is /git/git-sync
```
