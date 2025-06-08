
ifeq ($(shell docker buildx bake print | grep -o "ERROR"),ERROR)
	COMPOSE_ENV = COMPOSE_BAKE=true
endif

COMPOSE  = $(COMPOSE_ENV) docker compose -f srcs/docker-compose.yml

up: init
	mkdir -p ${HOME}/data/wordpress-core
	mkdir -p ${HOME}/data/mariadbd-data
	$(COMPOSE) up $(CMD_FLAGS) $(service)

detach: CMD_FLAGS += -d
detach: up

init: mariadb-init nginx-init wordpress-init

build:
	$(COMPOSE) build

stats restart down:
	$(COMPOSE) $@ $(CMD_FLAGS) $(service)

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

NGINX_CONTEXT        = srcs/requirements/nginx
WORDPRESS_CONTEXT    = srcs/requirements/wordpress
MARIDB_CONTEXT       = srcs/requirements/mariadb

clean:
	make -C $(NGINX_CONTEXT) clean
	make -C $(WORDPRESS_CONTEXT) clean
	make -C $(MARIDB_CONTEXT) clean

fclean:
	make -C $(NGINX_CONTEXT) fclean
	make -C $(WORDPRESS_CONTEXT) fclean
	make -C $(MARIDB_CONTEXT) fclean

re:
	make -C $(NGINX_CONTEXT) re
	make -C $(WORDPRESS_CONTEXT) re
	make -C $(MARIDB_CONTEXT) re

nginx-init:
	make -C $(NGINX_CONTEXT)/tools

wordpress-init:
	make -C $(WORDPRESS_CONTEXT)/tools

mariadb-init:
	make -C $(MARIDB_CONTEXT)/tools
