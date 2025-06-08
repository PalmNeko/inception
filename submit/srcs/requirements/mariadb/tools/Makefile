

# mariadb

MARIADB_CONTEXT        = ..
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
MARIADB_CONF_DIR       = $(MARIADB_CONTEXT)/conf
MARIADB_CONF_DIST_DIR  = $(MARIADB_CONTEXT)/dist/conf

MARIADB_CONF           = $(subst $(MARIADB_CONF_DIR)/,,$(shell find $(MARIADB_CONF_DIR) -type f))
MARIADB_DST_CONF       = $(addprefix $(MARIADB_CONF_DIST_DIR)/,$(MARIADB_CONF))

all: $(MARIADB_DST_CONF) $(MARIADB_ENV_FILE)

clean:
	rm -f $(MARIADB_DST_CONF)

fclean: clean
	rm -f $(MARIADB_ENV_FILE)

re: fclean all

$(MARIADB_ENV_FILE): $(MARIADB_ENV_GEN_SCRIPT)
	@mkdir -p $(@D)
	@bash $< > $@ || (rm $@ ; exit 1)
	@echo 'created $@'

$(MARIADB_CONF_DIST_DIR)/%: $(MARIADB_CONF_DIR)/% $(MARIADB_ENV_FILE)
	@mkdir -p $(@D)
	@$(call load_environment,$(MARIADB_ENV_FILE)) \
		$(call generate_conf_file,$(MARIADB_ENVIRONS),$<,$@)
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
