
COMPOSE  =  docker compose -f srcs/docker-compose.yml

up:
	$(COMPOSE) up --build $(service)

detach:
	$(COMPOSE) up --build -d $(service)

down:
	$(COMPOSE) down $(service)

build:
	$(COMPOSE) build

bash:
	$(COMPOSE) exec -it $(service) bash

install-dev-tools:
	$(COMPOSE) exec $(service) apt-get install -y \
		unar \
		libfcgi \
		iproute2 \
		iputils-ping \
	; : unzip and zipfile \
		 cgi-fcgi \
		 ss \
		 ping \
		 command
	$(COMPOSE) exec $(service) apt-get install -y \
		vim-tiny \
		man \
		less \
		netcat-openbsd \
		apt-file \
		lsof \
		; : for \
		 vim.tiny \
		 man \
		 less \
		 nc \
		 apt-file \
		 lsof \
		 command
