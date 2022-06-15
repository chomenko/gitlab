#!/bin/bash

source .env

mkdir -p data/certs

mkdir -p data/traefik
mkdir -p data/traefik/dynamic_conf
mkdir -p data/traefik/letsencrypt

mkdir -p data/runner

mkdir -p data/gitlab
mkdir -p data/gitlab/config
sudo chmod 0777 data/gitlab/config
sudo chmod 0777 data/gitlab/config/gitlab.rb


docker network create proxy_bridge || true
[[ -f ./data/runner/config.toml ]] || cp ./init/runner_config.toml ./data/runner/config.toml


[[ -f ./data/traefik/dynamic_conf/config.yml ]] || cp ./init/traefik_config.yml ./data/traefik/dynamic_conf/config.yml
sed -i 's|$GITLAB_DOMAIN|'"${GITLAB_DOMAIN}"'|g' ./data/traefik/dynamic_conf/config.yml


[[ -f ./data/gitlab/config/gitlab.rb ]] || cp ./init/gitlab.rb ./data/gitlab/config/gitlab.rb
sed -i 's|$GITLAB_DOMAIN|'"${GITLAB_DOMAIN}"'|g' data/gitlab/config/gitlab.rb
sed -i 's|$REGISTRY_DOMAIN|'"${REGISTRY_DOMAIN}"'|g' data/gitlab/config/gitlab.rb


[[ -f ./data/domain.cnf ]] || cp ./init/domain.cnf ./data/certs/domain.cnf
sed -i 's|$GITLAB_DOMAIN|'"${GITLAB_DOMAIN}"'|g' ./data/certs/domain.cnf
sed -i 's|$REGISTRY_DOMAIN|'"${REGISTRY_DOMAIN}"'|g' ./data/certs/domain.cnf


if [ ! -f ./data/certs/RootCA.crt ]; then
  openssl req -x509 -nodes -new -sha256 -days 1024 -newkey rsa:2048 -keyout ./data/certs/RootCA.key -out ./data/certs/RootCA.pem -subj "/C=CZ/CN=Localhost-Root-CA"
  openssl x509 -outform pem -in ./data/certs/RootCA.pem -out ./data/certs/RootCA.crt
fi

if [ ! -f ./data/certs/${GITLAB_DOMAIN}.crt ]; then
  openssl req -new -nodes -newkey rsa:2048 -keyout ./data/certs/${GITLAB_DOMAIN}.key -out ./data/certs/${GITLAB_DOMAIN}.csr -subj "/C=CZ/ST=Czech/L=Prague/O=Localhost/CN=localhost"
  openssl x509 -req -sha256 -days 1024 -in ./data/certs/${GITLAB_DOMAIN}.csr -CA ./data/certs/RootCA.pem -CAkey ./data/certs/RootCA.key -CAcreateserial -extfile ./data/certs/domain.cnf -out ./data/certs/${GITLAB_DOMAIN}.crt
fi
