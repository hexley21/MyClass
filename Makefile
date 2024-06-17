include .envrc

.PHONY:
.SILENT:
.DEFAULT_GOAL := dev

# DEVELOPMENT

dev: build
	docker-compose -f docker-compose.yml up --build --remove-orphans

prod: build
	docker compose -f docker-compose.prod.yml up --build --remove-orphans

# BUILD

build:
	CGO_ENABLED=0 GOOS=linux go build -o ./src/bin/app ./src/cmd/main.go

# POSTGRES

dev/migrate-up:
	migrate -path ./src/sql/migrations -database "postgresql://postgres:${DEV_PG_PASSWORD}@${DEV_PG_HOST}:${DEV_PG_PORT}/${DEV_PG_DB}?sslmode=disable" -verbose up

dev/migrate-down:
	migrate -path ./src/sql/migrations -database "postgresql://postgres:${DEV_PG_PASSWORD}@${DEV_PG_HOST}:${DEV_PG_PORT}/${DEV_PG_DB}?sslmode=disable" -verbose down

prod/migrate-up:
	migrate -path ./src/sql/migrations -database "postgresql://${PG_USER}:${PG_PASSWORD}@${PG_HOST}:${PG_PORT}/${PG_DB}?sslmode=require" -verbose up

prod/migrate-down:
	migrate -path ./src/sql/migrations -database "postgresql://${PG_USER}:${PG_PASSWORD}@${PG_HOST}:${PG_PORT}/${PG_DB}?sslmode=require" -verbose down

migrate-init:
	migrate create -ext sql -dir ./src/sql/migrations/ -seq init_schema

# REDIS

dev/redis:
	redis-cli -u redis://${DEV_REDIS_USER}:${DEV_REDIS_PASSWORD}@${DEV_REDIS_HOST}:${DEV_REDIS_PORT}

prod/redis:
	redli --tls -u rediss://${REDIS_USER}:${REDIS_PASSWORD}@${REDIS_HOST}:${REDIS_PORT}

# WINDOWS

dev/up/win:
	docker-compose up --remove-orphans

prod/up/win:
	docker compose -f docker-compose.prod.yml up --build --remove-orphans

dev/win: build/win
	docker-compose up --build --remove-orphans

prod/win: build/win
	docker compose -f docker-compose.prod.yml up --build --remove-orphans

build/win:
	set CGO_ENABLED=0&& set GOOS=linux&& go build -o ./src/bin/app ./src/cmd/main.go
