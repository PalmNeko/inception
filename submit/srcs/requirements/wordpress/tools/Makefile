
# wordpress
COMPOSE_CONTEXT      = ../../../
COMPOSE_ENV_FILE      = $(COMPOSE_CONTEXT)/.env

WORDPRESS_CONTEXT        = ..
WORDPRESS_ENV_FILE       = $(WORDPRESS_CONTEXT)/.env
WORDPRESS_ENV_GEN_SCRIPT = $(WORDPRESS_CONTEXT)/tools/print_new_env.sh
WORDPRESS_CONF_DIR       = $(WORDPRESS_CONTEXT)/conf
WORDPRESS_CONF_DIST_DIR  = $(WORDPRESS_CONTEXT)/dist/conf

WORDPRESS_CONF           = $(subst $(WORDPRESS_CONF_DIR)/,,$(shell find $(WORDPRESS_CONF_DIR) -type f))
WORDPRESS_DST_CONF       = $(addprefix $(WORDPRESS_CONF_DIST_DIR)/,$(WORDPRESS_CONF))

all: $(WORDPRESS_DST_CONF) $(WORDPRESS_ENV_FILE)

clean:
	rm -f $(WORDPRESS_DST_CONF)

fclean: clean
	rm -f $(WORDPRESS_ENV_FILE)

re: fclean all

$(WORDPRESS_ENV_FILE): $(WORDPRESS_ENV_GEN_SCRIPT)
	@mkdir -p $(@D)
	@bash $< > $@ || (rm $@ ; exit 1)
	@echo 'created $@'

$(WORDPRESS_CONF_DIST_DIR)/%: $(WORDPRESS_CONF_DIR)/% $(WORDPRESS_ENV_FILE)
	@mkdir -p $(@D)
	@$(call load_environment,$(COMPOSE_ENV_FILE)) $(call load_environment,$(WORDPRESS_ENV_FILE)) \
		$(call generate_conf_file,$<,$@)
	@echo 'created $@'


# functions

# Desc : generate config file by environment EX: HOGE=123 {{HOGE}} -> 123
# Usage: $(call generate_conf_file,input_file,output_file)
FILE_GENERATOR_SCRIPT   =  ./file_generator.sh
define generate_conf_file
	bash $(FILE_GENERATOR_SCRIPT) < $(1) > $(2)
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
