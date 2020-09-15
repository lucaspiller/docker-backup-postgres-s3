#!/usr/bin/env bash
# vim: set noexpandtab ts=4 sw=4 nolist:
set -Eeo pipefail

if [ -z "${S3_ACCESS_KEY_ID}" ]; then
	echo "You need to set the S3_ACCESS_KEY_ID environment variable."
	exit 1
fi

if [ -z "${S3_SECRET_ACCESS_KEY}" ]; then
	echo "You need to set the S3_SECRET_ACCESS_KEY environment variable."
	exit 1
fi

if [ -z "${S3_PATH}" ]; then
	echo "You need to set the S3_PATH environment variable."
	exit 1
fi

if [ -z "${POSTGRES_DATABASE}" ]; then
	echo "You need to set the POSTGRES_DATABASE environment variable."
	exit 1
fi

if [ -z "${POSTGRES_HOST}" ] && [ -z "${POSTGRES_PORT_5432_TCP_ADDR}" ]; then
	echo "You need to set the POSTGRES_HOST environment variable or link to a container named POSTGRES."
	exit 1
fi

if [ -z "${POSTGRES_USER}" ]; then
	echo "You need to set the POSTGRES_USER environment variable."
	exit 1
fi

if [ "$1" = 'run-cron' ]; then
	if [ -z "${SCHEDULE}" ]; then
		echo "You need to set the SCHEDULE environment variable."
		exit 1
	fi

	# Normal startup
	echo "$SCHEDULE /usr/local/bin/backup.sh" | crontab -
	crontab -l
	crond -f -L /dev/stdout

elif [ "$1" = 'backup' ]; then
	# Backup now
	/usr/local/bin/backup.sh

else
	# Run command as given by user
	exec "$@"
fi
