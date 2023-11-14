# POSTGRES_PASSWORD - excempt 
# POSTGRES_USER - postgres
# POSTGRES_DB - postgres

# POSTGRES_INITDB_ARGS - ["--username","postgres","-D","/var/lib/postgresql/data/pgdata","--encoding=UTF8","--lc-collate=C","--lc-ctype=C"]
#   postgres directory - storage class with pvc?
#   locale customization

# POSTGRES_INITDB_WALDIR - /var/lib/postgresql/data/pgdata
#   wal directory - storage class with pvc?

# POSTGRES_HOST_AUTH_METHOD - scram-sha-256
#   Note 1: It is not recommended to use trust since it allows anyone to connect without a password, even if one is set (like via POSTGRES_PASSWORD). For more information see the PostgreSQL documentation on Trust Authentication.
#   Note 2: If you set POSTGRES_HOST_AUTH_METHOD to trust, then POSTGRES_PASSWORD is not required.
#   Note 3: If you set this to an alternative value (such as scram-sha-256), you might need additional POSTGRES_INITDB_ARGS for the database to initialize correctly (such as POSTGRES_INITDB_ARGS=--auth-host=scram-sha-256).

# PGDATA - /var/lib/postgresql/data
#  This optional variable can be used to define another location - like a subdirectory - for the database files. The default is /var/lib/postgresql/data. If the data volume you're using is a filesystem mountpoint (like with GCE persistent disks), or remote folder that cannot be chowned to the postgres user (like some NFS mounts), or contains folders/files (e.g. lost+found), Postgres initdb requires a subdirectory to be created within the mountpoint to contain the data.

# *_FILE - add environment variable data per file instead
#   Currently, this is only supported for POSTGRES_INITDB_ARGS, POSTGRES_PASSWORD, POSTGRES_USER, and POSTGRES_DB.
#   ex.: POSTGRES_PASSWORD_FILE=/run/secrets/postgres-passwd

# Initialization scripts
#   mount any *.sql, *.sh within the /docker-entrypoint-initdb.d

# Database Configuration
#   postgresql.conf

# /dev/shm - default is 64MB

  ##
  # Available recovery methods:
  # * `backup` - Recovers a CNPG cluster from a CNPG backup (PITR supported) Needs to be on the same cluster in the same namespace.
  # * `object_store` - Recovers a CNPG cluster from a barman object store (PITR supported).
  # * `pg_basebackup` - Recovers a CNPG cluster viaa streaming replication protocol. Useful if you want to
  #        migrate databases to CloudNativePG, even from outside Kubernetes. # TODO
  #method: backup



