### Build docker image
```
./docker/build.sh [repo] [tag_version]

Example: ./docker/build.sh vqcuong96/ latest
```

### Usage
Currently only support clone repository with ssh authentication or public

Environment:

GIT_REPO: ssh endpoint to clone
GIT_BRANCH: target branch to clone
GIT_DEST: destionation directory to clone repository into
GIT_SSH_ENABLE: weather ssh enabled or not, must be true
GIT_REPO_HOST: your git host. ex: gitlab.com
GIT_SSH_PRIVATE_KEY: ssh private key path
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
      - GIT_DEST=/git/git-sync
      - GIT_SSH_ENABLE=true
      - GIT_REPO_HOST=gitlab.vieon.vn
      - GIT_SSH_PRIVATE_KEY=/.private-key
    volumes:
      - .ssh-private-key:/.private-key
      - git-sync:/git:rw
    command:
      - /git-sync.sh
```
