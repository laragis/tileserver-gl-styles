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
	docker build \
		--tag ${ORG_NAME}/${APP_SLUG}:${APP_VERSION} \
		--tag ${ORG_NAME}/${APP_SLUG}:latest \
		--build-arg APP_NAME=${APP_NAME} \
		--build-arg APP_SLUG=${APP_SLUG} \
		--build-arg APP_VERSION=${APP_VERSION} \
		.

push:
	docker push ${ORG_NAME}/${APP_SLUG}:${APP_VERSION}

push-latest:
	docker push ${ORG_NAME}/${APP_SLUG}:latest

up:
	docker compose up -d

shell:
	docker compose exec --user=1001 tileserver-gl-styles bash

shell-root:
	docker compose exec --user=root tileserver-gl-styles bash

down:
	docker compose down