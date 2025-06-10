
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

init: compose-init secrets nginx-init

logs: CMD_FLAGS += -f
stats restart down watch build logs:
	$(COMPOSE_ENV) $(COMPOSE) $@ $(CMD_FLAGS) $(service)

clean-volumes:
	ls ~/data
	docker run --mount type=bind,source=$(HOME)/data,target=/data --rm alpine sh -c "rm -rf /data/*"
	ls ~/data

re: build up

bash:
	$(COMPOSE) exec -it $(service) bash

#
# init environ
#

COMPOSE_CONTEXT           = srcs
COMPOSE_ENV_FILE          = $(COMPOSE_CONTEXT)/.env
COMPOSE_SAMPLE_ENV        = $(COMPOSE_CONTEXT)/.env.sample

NGINX_TOOL_CONTEXT        = srcs/requirements/nginx/tools

clean:
	$(MAKE) -C $(NGINX_TOOL_CONTEXT) clean
	$(MAKE) -C $(WORDPRESS_TOOL_CONTEXT) clean

fclean:
	$(MAKE) -C $(NGINX_TOOL_CONTEXT) fclean
	$(MAKE) -C $(WORDPRESS_TOOL_CONTEXT) fclean
	rm -f $(COMPOSE_ENV_FILE)

nginx-init:
	bash -c "$(MAKE) -C $(NGINX_TOOL_CONTEXT)"

compose-init: $(COMPOSE_ENV_FILE)

$(COMPOSE_ENV_FILE): $(COMPOSE_SAMPLE_ENV)
	whoami
	test -f "$@" || cp -f $< $@ && touch $@

#
# secrets
#

ifndef DOMAIN
	$(error DOMAIN is not set.)
endif

SECRETS_DIR      = secrets
NGINX_SECRET_KEY = $(SECRETS_DIR)/nginx/ssl.key
NGINX_SECRET_CRT = $(SECRETS_DIR)/nginx/ssl.crt
DB_PASSWORD      = $(SECRETS_DIR)/db_password.txt
DB_ROOT_PASSWORD = $(SECRETS_DIR)/db_root_password.txt

.PHONY: secrets
secrets: $(NGINX_SECRET_KEY) $(NGINX_SECRET_CRT) $(DB_PASSWORD) $(DB_ROOT_PASSWORD)

$(NGINX_SECRET_KEY) $(NGINX_SECRET_CRT):
	mkdir -p $(@D)
	. $(ENV_FILE) ; openssl req -x509 -nodes -days 15 -newkey rsa:2048 \
		-keyout "$(NGINX_SECRET_KEY)" -out "$(NGINX_SECRET_CRT)" \
		-subj "/CN=$(DOMAIN)"

$(DB_PASSWORD) $(DB_ROOT_PASSWORD):
	echo -n "password" > $@
