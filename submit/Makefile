
# conf
DOMAIN    =   tookuyam.42.fr
ENV_FILE  =   srcs/.env

# main

COMPOSE  = docker compose -f srcs/docker-compose.yml


can_use_compose_bake_environ = $(shell $(COMPOSE) build --dry-run 2> /dev/stdout | grep -o "COMPOSE_BAKE=true" > /dev/null && echo -n true || echo -n false)

ifeq ($(call can_use_compose_bake_environ),true)
	COMPOSE_ENV += COMPOSE_BAKE=true
endif

up: init
	mkdir -p ${HOME}/data/wordpress-core
	mkdir -p ${HOME}/data/mariadbd-data
	$(COMPOSE_ENV) $(COMPOSE) $@ $(CMD_FLAGS) $(service)

detach: CMD_FLAGS += -d
detach: up

init: secrets mariadb-init nginx-init wordpress-init

logs: CMD_FLAGS += -f
stats restart down watch build logs:
	$(COMPOSE_ENV) $(COMPOSE) $@ $(CMD_FLAGS) $(service)

clean-volumes:
	docker run --mount type=bind,source=$(HOME)/data,target=/data --rm alpine sh -c "rm -rf /data/*"

re: build up

prune: down
	@printf '***** Are you sure delete all container, image, network and volume ***** ? y/n ' ; read YN ; test "$$YN" = "y"
	@echo 'containers - stop'
	@sleep 2
	@CONTAINERS=$$(docker container ls -aq) ; test -n "$$CONTAINERS" \
		&& docker container stop $$CONTAINERS || true
	@echo 'containers - remove'
	@sleep 2
	@CONTAINERS=$$(docker container ls -aq) ; test -n "$$CONTAINERS" \
		&& docker container remove $$CONTAINERS || true
	@echo 'networks - remove'
	@sleep 2
	@NETWORKS=$$(docker network ls -q) ; test -n "$$NETWORKS" \
		&& docker network rm $$NETWORKS || true
	@echo 'images - prune'
	@sleep 2
	@docker image prune -f
	@echo 'images - remove'
	@sleep 2
	@IMAGES=$$(docker image list --format "{{.Repository}}:{{.Tag}}") ; test -n "$$IMAGES" \
		&& docker image rm $$IMAGES || true
	@echo 'volumes - remove'
	@sleep 2
	@VOLUMES=$$(docker volume ls -q) ; test -n "$$VOLUMES" \
		&& docker volume remove $$VOLUMES || true
	@echo 'build cache - remove'
	@sleep 2
	@docker buildx prune -f

bash:
	$(COMPOSE) exec -it $(service) bash

install-cgi-tools:
	$(COMPOSE) exec $(service) apt-get install -y \
		libfcgi
	@: cgi-fcgi

install-network-tools:
	$(COMPOSE) exec $(service) apt-get install -y \
		iproute2 \
		iputils-ping \
		netcat-openbsd \
		lsof
	@: ss, ping, nc, lsof

install-utils:
	$(COMPOSE) exec $(service) apt-get install -y \
		vim-tiny \
		man \
		apt-file \
		less \
		lsof \
		procps


#
# init
#

NGINX_TOOL_CONTEXT        = srcs/requirements/nginx/tools
WORDPRESS_TOOL_CONTEXT    = srcs/requirements/wordpress/tools
MARIDB_TOOL_CONTEXT       = srcs/requirements/mariadb/tools

clean:
	$(MAKE) -C $(NGINX_TOOL_CONTEXT) clean
	$(MAKE) -C $(WORDPRESS_TOOL_CONTEXT) clean
	$(MAKE) -C $(MARIDB_TOOL_CONTEXT) clean

fclean:
	$(MAKE) -C $(NGINX_TOOL_CONTEXT) fclean
	$(MAKE) -C $(WORDPRESS_TOOL_CONTEXT) fclean
	$(MAKE) -C $(MARIDB_TOOL_CONTEXT) fclean

nginx-init:
	bash -c "$(MAKE) -C $(NGINX_TOOL_CONTEXT)"

wordpress-init:
	bash -c "$(MAKE) -C $(WORDPRESS_TOOL_CONTEXT)"

mariadb-init:
	bash -c "$(MAKE) -C $(MARIDB_TOOL_CONTEXT)"

#
# secrets
#

ifndef DOMAIN
	$(error DOMAIN is not set.)
endif

SECRETS_DIR      = secrets
NGINX_SECRET_KEY = $(SECRETS_DIR)/nginx/ssl.key
NGINX_SECRET_CRT = $(SECRETS_DIR)/nginx/ssl.crt

.PHONY: secrets
secrets: $(NGINX_SECRET_KEY) $(NGINX_SECRET_CRT)

$(NGINX_SECRET_KEY) $(NGINX_SECRET_CRT):
	mkdir -p $(@D)
	. $(ENV_FILE) ; openssl req -x509 -nodes -days 15 -newkey rsa:2048 \
		-keyout "$(NGINX_SECRET_KEY)" -out "$(NGINX_SECRET_CRT)" \
		-subj "/CN=$(DOMAIN)"
