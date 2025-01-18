echo "RUNNING my service"

echo ${PDB_HOST}
echo ${PDB_PORT}

echo "Waiting for my service Postgres Database"
while ! nc -z ${PDB_HOST} ${PDB_PORT}; do sleep 2; done
echo "Connected to my Database"

if [[ $# -gt 0  ]]; then
	echo "Execute Command..."
	INPUT=$@
	sh -c "$INPUT"
else
	mkdir -p /var/logs/application_logs

	if [[ "$DEBUG" = "True" ]]; then
		python /home/my_service/manage.py migrate --noinput
		if [ $? -ne 0 ]; then
			echo "Migration my_service DB failed." >&2
			exit 1
		fi
	fi

	echo "Starting Gunicorn..."

	exec gunicorn my_service.wsgi:application \
	   --name my_service-gunicorn \
	   --bind 0.0.0.0:8080 \
	   --workers $GUNICORN_WORKER_NUMBER \
	   --pythonpath "/home/my_service" \
	   --log-level=info \
	   --log-file=- \
	   --timeout $GUNICORN_TIMEOUT \
	   --reload

fi
