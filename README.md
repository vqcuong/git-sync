### Build docker image
```
./docker/build.sh [repo] [tag_version]

Example: ./docker/build.sh vqcuong96/ latest
```

### Usage
Currently only support public repositories or private repositories with ssh authentication

Environment:

- Basic
```
GIT_REPO: git repository endpoint, supported for both https and ssh protocol
GIT_BRANCH: target branch to clone
GIT_REPO_PORT: your git port. default: 22
GIT_DEST: destionation directory to clone repository into, default: /git/[repository_name]
GIT_SYNC_WAIT: number of seconds delay for each sync time
GIT_SSH_ENABLE: whether ssh enabled or not, default: false
```
- For ssh
```
GIT_SSH_KNOWN_HOSTS: known_hosts file path (optional). if not provided, it will be auto-scaned from git server
GIT_SSH_PRIVATE_KEY: ssh private key path
GIT_SECRET_DIR: ssh secret directory containing known_hosts and ssh private key, may use as replacement of GIT_SSH_KNOWN_HOSTS and GIT_SSH_PRIVATE_KEY
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
