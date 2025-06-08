

# functions
FILE_GENERATOR_SCRIPT   =  ./file_generator.sh

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
NGINX_CONTEXT        = ..
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
	@$(call on_environment,$(NGINX_ENV_FILE), \
		$(call generate_conf_file,$(NGINX_ENVIRONS),$<,$@)) 
	@echo 'created $@'
