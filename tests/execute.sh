#!/bin/bash

source .env
export GIT_SSL_NO_VERIFY=1

cd ./tests/repo

#sudo rm -r .git
#git init
#git add -A
#git commit -m "Initial commit"
#git remote add origin https://${GITLAB_DOMAIN}/root/test.git
#git push --force origin master
#sudo rm -r .git

docker pull hello-world
docker tag hello-world ${REGISTRY_DOMAIN}/root/test:latest
docker push ${REGISTRY_DOMAIN}/root/test:latest
docker pull ${REGISTRY_DOMAIN}/root/test:latest
docker run ${REGISTRY_DOMAIN}/root/test:latest
