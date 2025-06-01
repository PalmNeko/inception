
COMPOSE  =  docker compose -f srcs/docker-compose.yml

up:
	$(COMPOSE) up --build $(service)

detach:
	$(COMPOSE) up --build -d $(service)

build:
	$(COMPOSE) build

bash:
	$(COMPOSE) exec -it $(service) bash
