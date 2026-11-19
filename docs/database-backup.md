# Local database backup and restore

Keep backups outside the public repository. A full backup can contain personal details and password hashes.

```sh
pg_dump -Fc -d smartcivic -f "$HOME/smartcivic-local.backup"
pg_restore -l "$HOME/smartcivic-local.backup"
```

For a restore rehearsal, create a new empty database (choose a name that does not already exist) and restore there rather than overwriting the active database.

```sh
createdb smartcivic_restore_test
pg_restore --exit-on-error --no-owner --no-privileges -d smartcivic_restore_test "$HOME/smartcivic-local.backup"
psql -d smartcivic_restore_test -c '\\dt'
```

This backs up PostgreSQL only. Qdrant collection data requires its own backup or a verified rebuild from PostgreSQL. Restore tests should not share the live Qdrant collection.
