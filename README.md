# Dockerized Django + PostgreSQL + Nginx

This project contains a Dockerized Django application with PostgreSQL and Nginx.

## Services

- web: Django application
- db: PostgreSQL database
- nginx: reverse proxy

## Quick start

1. Create environment file:

```bash
cp .env.example .env
```

2. Start all containers:

```bash
docker-compose up -d --build
```

3. Open:

- http://localhost

## Stop

```bash
docker-compose down
```
