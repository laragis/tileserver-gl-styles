ifneq (,$(wildcard .env))
    ENV_FILE := .env
else ifneq (,$(wildcard .env.example))
    ENV_FILE := .env.example
else
    $(error "Neither .env nor .env.example file exists!")
endif

include $(ENV_FILE)
export $(shell sed 's/=.*//' $(ENV_FILE))

build:
  docker build -t ttungbmt/tileserver-gl-styles:latest --build-arg APP_VERSION=current .

push:
  docker push ttungbmt/tileserver-gl-styles:latest

up:
  docker compose up -d

shell:
  docker compose exec tileserver-gl-styles bash

down:
  docker compose down