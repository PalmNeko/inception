
COMPOSE_ENV = COMPOSE_BAKE=true
COMPOSE  = $(COMPOSE_ENV) docker compose -f srcs/docker-compose.yml

up: init
	mkdir -p ${HOME}/data/wordpress-core
	mkdir -p ${HOME}/data/mariadbd-data
	$(COMPOSE) up $(CMD_FLAGS) $(service)

detach: CMD_FLAGS += -d
detach: up

init: mariadb-init

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

# common
FILE_GENERATOR_SCRIPT   =  tools/file_generator.sh

# mariadb

MARIADB_CONTEXT        = srcs/requirements/mariadb
MARIADB_ENVIRONS       = \
	WORDPRESS_USERNAME \
	WORDPRESS_DBNAME \
	WORDPRESS_PASSWORD \
	MARIADB_SOCKET \
	MARIADB_PID_FILE \
	INIT_DB_FILE_PATH \
	INIT_DB_FILE_DIR
MARIADB_ENV_FILE       = $(MARIADB_CONTEXT)/.env
MARIADB_ENV_GEN_SCRIPT = $(MARIADB_CONTEXT)/tools/print_new_env.sh
MARIADB_CONF_DIR       = $(MARIADB_CONTEXT)/conf/mysql
MARIADB_CONF_DIST_DIR  = $(MARIADB_CONTEXT)/dist/conf

MARIADB_CONF           = $(subst $(MARIADB_CONF_DIR)/,,$(shell find $(MARIADB_CONF_DIR) -name "*.cnf" -o -name "*.sql"))
MARIADB_DST_CONF       = $(addprefix $(MARIADB_CONF_DIST_DIR)/,$(MARIADB_CONF))

mariadb-init: $(MARIADB_DST_CONF) $(MARIADB_ENV_FILE)

$(MARIADB_ENV_FILE): $(MARIADB_ENV_GEN_SCRIPT)
	mkdir -p $(@D)
	test -f $@ && env $$(cat $@ | sed 's/[[:space:]]+#.*$$//' | xargs) \
		bash $< > $@

$(MARIADB_CONF_DIST_DIR)/%: $(MARIADB_CONF_DIR)/% $(MARIADB_ENV_FILE)
	mkdir -p $(@D)
	env - $$(cat $(MARIADB_ENV_FILE) | sed 's/[[:space:]]+#.*$$//' | xargs) \
		bash $(FILE_GENERATOR_SCRIPT) $(MARIADB_ENVIRONS) < $< > $@
