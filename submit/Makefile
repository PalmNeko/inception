
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

init: mariadb-init nginx-init

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

# functions
FILE_GENERATOR_SCRIPT   =  tools/file_generator.sh

# Desc : command on environment is .env file environment
# Usage: $(call on_environment,env_file,command)
on_environment = bash -c "$$(cat $(1) \
		| sed -E 's/[[:space:]]+\#.*$$//' \
		| grep -vE '^[[:space:]]*\#' \
		| sed -E 's/"/\"/' \
		| awk -F = '{print "export " "\""$$0"\""}' \
	)"' ; \
	$(2) ; '

# Desc : generate config file by replacement value of env_names EX: HOGE=123 {{HOGE}} -> 123
# Usage: $(call generate_conf_file,env_names,input_file,output_file)
generate_conf_file = bash $(FILE_GENERATOR_SCRIPT) $(1) < $(2) > $(3)


# nginx

NGINX_CONTEXT        = srcs/requirements/nginx
NGINX_ENVIRONS       = \
	CGI_HOSTNAME \
	CGI_PORT \
	CGI_ROOT \
	NGINX_SERVER_NAME
NGINX_ENV_FILE       = $(NGINX_CONTEXT)/.env
NGINX_ENV_GEN_SCRIPT = $(NGINX_CONTEXT)/tools/print_new_env.sh
NGINX_CONF_DIR       = $(NGINX_CONTEXT)/conf
NGINX_CONF_DIST_DIR  = $(NGINX_CONTEXT)/dist/conf

NGINX_CONF           = $(subst $(NGINX_CONF_DIR)/,,$(shell find $(NGINX_CONF_DIR) -type f))
NGINX_DST_CONF       = $(addprefix $(NGINX_CONF_DIST_DIR)/,$(NGINX_CONF))

nginx-init: $(NGINX_DST_CONF) $(NGINX_ENV_FILE)

$(NGINX_ENV_FILE): $(NGINX_ENV_GEN_SCRIPT)
	@mkdir -p $(@D)
	@bash $< > $@ || (rm $@ ; exit 1)
	@echo 'created $@'

$(NGINX_CONF_DIST_DIR)/%: $(NGINX_CONF_DIR)/% $(NGINX_ENV_FILE)
	@mkdir -p $(@D)
	@$(call on_environment,$(NGINX_ENV_FILE), \
		$(call generate_conf_file,$(NGINX_ENVIRONS),$<,$@)) 
	@echo 'created $@'

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
	@mkdir -p $(@D)
	@bash $< > $@ || (rm $@ ; exit 1)
	@echo 'created $@'

$(MARIADB_CONF_DIST_DIR)/%: $(MARIADB_CONF_DIR)/% $(MARIADB_ENV_FILE)
	@mkdir -p $(@D)
	@$(call on_environment,$(MARIADB_ENV_FILE), \
		$(call generate_conf_file,$(MARIADB_ENVIRONS),$<,$@)) 
	@echo 'created $@'
