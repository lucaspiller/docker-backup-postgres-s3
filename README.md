# backup-postgres-s3

Docker image to periodically backup a PostgreSQL database to S3.

# Why this container?

Yes there are a lot of other containers that promise to do similar things, however I found they didn't fulfil my requirements.

* I needed an image that was up to date - you can't backup Postgres 11 with a 10 client.
* A lot of the other images do weird stuff like re-implement cron.
* This image runs on Alpine, so it's small. Additionally it's based on the official PostgreSQL image, so if you already have that, then there is even less to download.

## Required Envionment Variables

- `S3_ACCESS_KEY_ID` - Your AWS access key.
- `S3_SECRET_ACCESS_KEY` - Your secret access key.
- `S3_PATH` - S3 bucket, and optionally path. Should not end in a trailing slash, e.g. `s3://myapp/db-backups`.

- `POSTGRES_HOST` - Hostname of the PostgreSQL database to backup, alternatively this container can be linked to the container with the name `postgres`.
- `POSTGRES_DATABASE` - Name of the PostgreSQL database to backup.
- `POSTGRES_USER` - PostgreSQL user, with priviledges to dump the database.

### Optional Enviroment Variables

- `POSTGRES_PASSWORD` - Password for the PostgreSQL user, if you are using a database on the same machine this isn't usually needed.
- `POSTGRES_PORT` - Port of the PostgreSQL database, uses the default 5432.
- `POSTGRES_EXTRA_OPTS` - Extra arguments to pass to the `pg_dump` command.
- `S3_REGION` - Set the default AWS region to send the upload request to.
- `AWS_EXTRA_OPTS` - Extra arguments to pass to the `aws` command.
- `SCHEDULE` - Cron schedule to run periodic backups.

## Examples

By default if you run the container without any extra arguments it'll run cron and backup periodically based on `SCHEDULE`:

    $ docker run --rm
      -e S3_ACCESS_KEY_ID=<aws-key> \
      -e S3_SECRET_ACCESS_KEY=<aws-secret-key> \
      -e S3_BUCKET=<bucket> \
      -e S3_PATH=s3://myapp/db-backups \
      -e POSTGRES_DATABASE=postgres \
      -e POSTGRES_HOST=localhost \
      -e POSTGRES_USER=postgres \
      -e SCHEDULE=@daily \
      lucaspiller/backup-postgres-s3
    crond: crond (busybox 1.28.4) started, log level 8

`SCHEDULE` can either be a cron five field format `45 3 * * *` (every day at 3:45am) or a predefined format (`@weekly`). See [crontab guru](http://crontab.guru/) for more details.

If you pass the `backup` argument it'll run a backup right now:

    $ docker run --rm
      -e S3_ACCESS_KEY_ID=<aws-key> \
      -e S3_SECRET_ACCESS_KEY=<aws-secret-key> \
      -e S3_BUCKET=<bucket> \
      -e S3_PATH=s3://myapp/db-backups \
      -e POSTGRES_DATABASE=postgres \
      -e POSTGRES_HOST=localhost \
      -e POSTGRES_USER=postgres \
      -e SCHEDULE=@daily \
      lucaspiller/backup-postgres-s3 backup
    Creating dump of postgres database from localhost...
    Uploading dump to s3://myapp/db-backups/postgres_2019-01-24T20:23:25Z.sql.gz
    SQL backup uploaded successfully

The tags are based on the PostgreSQL version the image is built with. You should just be able to use the latest version, even with older PostgreSQL server versions, but if you need a different version for any reason they are available.

## Acknowledgements

Some scripts based on [schickling/postgres-backup-s3](https://github.com/schickling/dockerfiles/tree/master/postgres-backup-s3).
