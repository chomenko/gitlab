include .env

prepare:
	bash ./prepare.sh
up: prepare
	@docker-compose up
exec-runer:
	@docker-compose exec gitlab-runner bash
addRuner:
	@docker-compose exec gitlab-runner gitlab-runner register
addRunerTls:
	@docker-compose exec gitlab-runner sh -c "openssl s_client -showcerts -connect ${GITLAB_DOMAIN}:443 -servername ${GITLAB_DOMAIN} < /dev/null 2>/dev/null | openssl x509 -outform PEM > /certs/runner.access.crt"
	@docker-compose exec gitlab-runner gitlab-runner register --tls-ca-file="/certs/runner.access.crt" --executor="docker" --docker-image="docker:19.03.1" --docker-volumes="/cache:/cache" --url="https://${GITLAB_DOMAIN}" --docker-network-mode="proxy_bridge" --docker-links="proxy_bridge:${GITLAB_DOMAIN}" --docker-links="proxy_bridge:${REGISTRY_DOMAIN} "
test:
	@docker login ${REGISTRY_DOMAIN}
	@bash ./tests/execute.sh
