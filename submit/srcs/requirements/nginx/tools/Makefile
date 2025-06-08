
# nginx
COMPOSE_CONTEXT      = ../../../
COMPOSE_ENV_FILE      = $(COMPOSE_CONTEXT)/.env
NGINX_CONTEXT        = ..
NGINX_ENV_FILE       = $(NGINX_CONTEXT)/.env
NGINX_ENV_FILES      = $(NGINX_ENV_FILE) $(COMPOSE_ENV_FILE)
NGINX_ENV_NAMES       = $(call env_names, $(NGINX_ENV_FILES))
NGINX_ENV_GEN_SCRIPT = $(NGINX_CONTEXT)/tools/print_new_env.sh
NGINX_CONF_DIR       = $(NGINX_CONTEXT)/conf
NGINX_CONF_DIST_DIR  = $(NGINX_CONTEXT)/dist/conf

NGINX_CONF           = $(subst $(NGINX_CONF_DIR)/,,$(shell find $(NGINX_CONF_DIR) -type f))
NGINX_DST_CONF       = $(addprefix $(NGINX_CONF_DIST_DIR)/,$(NGINX_CONF))

all: $(NGINX_DST_CONF) $(NGINX_ENV_FILE)

clean:
	rm -f $(NGINX_DST_CONF)

fclean: clean
	rm -f $(NGINX_ENV_FILE)

re: fclean all

$(NGINX_ENV_FILE): $(NGINX_ENV_GEN_SCRIPT)
	@mkdir -p $(@D)
	@bash $< > $@ || (rm $@ ; exit 1)
	@echo 'created $@'

$(NGINX_CONF_DIST_DIR)/%: $(NGINX_CONF_DIR)/% $(NGINX_ENV_FILE)
	@mkdir -p $(@D)
	@$(call load_environment,$(COMPOSE_ENV_FILE)) $(call load_environment,$(NGINX_ENV_FILE)) \
			$(call generate_conf_file,$(NGINX_ENV_NAMES),$<,$@)
	@echo 'created $@'

# functions

# Desc : generate config file by replacement value of env_names EX: HOGE=123 {{HOGE}} -> 123
# Usage: $(call generate_conf_file,env_names,input_file,output_file)
FILE_GENERATOR_SCRIPT   =  ./file_generator.sh
define generate_conf_file
	bash $(FILE_GENERATOR_SCRIPT) $(1) < $(2) > $(3)
endef

# Desc : load environment from envfile
# Param 1: environment file
# Usage: $(call load_environment,env_file)
define load_environment
	$(shell cat $(1) \
	| sed -E 's/[[:space:]]+\#.*$$//' \
	| grep -vE '^[[:space:]]*\#' \
	| sed -E 's/"/\"/' \
	| grep -E '=' \
	| awk -F = '{print "export " "\""$$0"\" ;"}' )
endef

# Desc: get env names
# Usage: $(call env_names)
define env_names
	$(shell \
		$(foreach file,$(1), \
			$(call load_environment,$(file)) \
		) \
		env | sed 's/=.*$$//' \
	)
endef
