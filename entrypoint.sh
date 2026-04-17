#!/bin/sh
set -e

echo "Waiting for PostgreSQL to be ready..."
python - <<'PY'
import os
import time
import psycopg2

db_name = os.getenv("POSTGRES_DB", "django_db")
db_user = os.getenv("POSTGRES_USER", "django_user")
db_password = os.getenv("POSTGRES_PASSWORD", "django_password")
db_host = os.getenv("POSTGRES_HOST", "db")
db_port = os.getenv("POSTGRES_PORT", "5432")

for attempt in range(30):
	try:
		psycopg2.connect(
			dbname=db_name,
			user=db_user,
			password=db_password,
			host=db_host,
			port=db_port,
		).close()
		print("PostgreSQL is ready")
		break
	except psycopg2.OperationalError:
		time.sleep(1)
else:
	raise SystemExit("PostgreSQL is not available after waiting")
PY

python manage.py migrate --noinput
python manage.py runserver 0.0.0.0:8000
