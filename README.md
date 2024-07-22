# restic-pg-dump-k8s

Docker image that runs `pg_dump` individually for every database on a given server and saves incremental encrypted backups via [restic].

Instead of relying on crontab inside the image, this is designed to deploy k8s CronJobs.

By default:

- Uses S3 as restic repository backend.
- Runs every hour via cron job.
- Keeps 24 latest, 7 daily, 4 weekly, and 12 monthly snapshots.
- Prunes old snapshots every week.

**NOTE:** Pruning requires an exclusive lock, and should be done infrequently from a single host.


# Usage

See the CronJob examples in the k8s directory.

You can pass the following environment variables to override the defaults:

    PGPORT='5432'
    RESTIC_KEEP_HOURLY='24'
    RESTIC_KEEP_DAILY='7'
    RESTIC_KEEP_WEEKLY='4'
    RESTIC_KEEP_MONTHLY='12'

You can backup 5 different database clusters with `PG*_[1..5]`, and assign an arbitrary hostname with `HOSTNAME_[1..5]` (if `PGHOST` is not a fully qualified domain name) environment variables.  Note that `RESTIC_TAGS_[1..5]` can be customized per server.

    HOSTNAME_2='...'
    PGHOST_2='...'
    PGPASSWORD_2='...'
    PGPORT_2='5432'
    PGUSER_2='...'
    RESTIC_TAGS_2='tag1,tag2'


# Restore

Create a `.envrc` file from `.envrc.example` and update with your AWS, PostgreSQL and Restic credentials.

    $ wget https://raw.githubusercontent.com/agates/restic-pg-dump-k8s/master/.envrc.example -O .envrc

Restrict access to `.envrc`, because it contains AWS and restic credentials:

    $ chmod 600 .envrc

Install [direnv] via your package manager and configure to ensure your `.envrc` file is always sourced when you change to this directory:

    $ apt install direnv
    $ eval "$(direnv hook bash)"  # Change bash to zsh/fish/tcsh, if necessary, and add to your shell's RC file
    $ direnv allow

Install [restic] via your package manager:

    $ apt install restic

List snapshots:

    $ restic snapshots

Restore the latest snapshot for a given server:

    $ restic restore --host {HOSTNAME} --target "restore/{HOSTNAME}" latest

Restore the latest snapshot for given tags set in `RESTIC_TAGS`:

    $ restic restore --host {HOSTNAME} --tag nextcloud,postgresql --target "restore/{HOSTNAME}" latest

Restore files matching a pattern from latest snapshot for a given server:

    $ restic restore --host "{HOSTNAME}" --target "restore/{HOSTNAME}" --include '*-production.sql' latest

Mount the restic repository via fuse (read-only):

    $ restic mount mnt

Then, access the latest snapshot from another terminal:

    $ ls -l "mnt/hosts/{HOSTNAME}/latest"
    $ psql -f "mnt/hosts/{HOSTNAME}/latest/pg_dump/{DBNAME}.sql" {DBNAME}

**WARNING:** Mounting the restic repository via fuse will open an exclusive lock and prevent all scheduled backups until the lock is released.


[direnv]: https://direnv.net/
[restic]: https://restic.net/
