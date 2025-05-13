# Setup

Restic performs encrypted backups that work like rsync snapshots. It has multiple backend types that it supports but the
best one is `rclone` which can support any cloud storage or remote backend. In this doc we describe how to use both 
tools to back up your files to an SSH server.

# Ubuntu

Install packages

```shell
$ sudo apt-get install restic rclone
```

Add an `rclone` configuration for ssh to the recommended server. Ask your sysadmin for the hostname and SSH key to use.

Syntax is: `rclone config create <name> <type> [<key> <value>]...`
 
```shell
export BACKUP_HOST=my-backup-host
```

```shell
$ rclone config create "$BACKUP_HOST" sftp host "$BACKUP_HOST"
```

Test the SSH connection

```shell
$  rclone ls "$BACKUP_HOST":
      267 .bash_history
      402 .ssh/authorized_keys
     1675 .ssh/id_rsa
      402 .ssh/id_rsa.pub
```

Initialise the `restic` backup repository

```shell
$ restic -r rclone:${BACKUP_HOST}:$(hostname) init
enter password for new repository: 
enter password again: 
created restic repository cf39342691 at rclone:my-backup-host:my-laptop
```

Please note that knowledge of your password is required to access the repository. Losing your password means that your
data is irrecoverably lost.

Add the passphrase given in response to the above command to Bitwarden and store it in a file for
creating/pruning/restoring backups. (There are other ways to get the passphrase from Bitwarden or a keyring but that’s
for another time.)

```shell
$ cat >~/.restic_pass <<EOF
ThePassWord
EOF
$ chmod 400 ~/.restic_pass
```

Create a configuration file for scripts. See further down for contents of the exclude file.

```shell
$ mkdir ~/etc
$ cp etc/restic_glob_exclude.txt ~/etc
```

Then execute the backup

```shell
$ restic-backup.sh 
repository cf393426 opened successfully, password is correct
created new cache in /home/mbaker/.cache/restic
rclone: 2023/11/29 13:56:21 ERROR : locks: error listing: directory not found
rclone: 2023/11/29 13:56:22 ERROR : index: error listing: directory not found
rclone: 2023/11/29 13:56:22 ERROR : snapshots: error listing: directory not found

Files:       11403 new,     0 changed,     0 unmodified
Dirs:            1 new,     0 changed,     0 unmodified
Added to the repo: 1.107 GiB

processed 11403 files, 1.118 GiB in 3:42
snapshot f7fe4a2b saved
```

And check the backup exists on the remote end. (This should not error and have a significant number of files.)

```shell
$ rclone ls "$BACKUP_HOST:$(hostname)" | wc -l
235
```

Profit!

# Next steps

## Exclude files

Create a file with a list of files and/or directories to exclude from the backup.
Something like the following, adjusted to your needs.
See the [restic documentation](https://restic.readthedocs.io/en/latest/040_preparing_a_backup.html#excluding-files-and-directories)
for more details.

```
**/.gem
/home/mbaker/.config/google-chrome*
/home/mbaker/.config/slack
/home/mbaker/.config/Slack
/home/mbaker/.rvm/gems
/home/mbaker/.cache
/home/mbaker/.gimp-*
/home/mbaker/.local
/home/mbaker/.rvm
/home/mbaker/.thunderbird/*.default*/ImapMail
/home/mbaker/.thunderbird/*.default*/global-messages-db.sqlite
/home/mbaker/.m2
/home/mbaker/.npm
/home/mbaker/Downloads
/home/mbaker/tmp
/home/mbaker/.debug
/home/mbaker/.minikube
/home/mbaker/src
```

## Prune old backups

This ensures the retention of backups and removes old files.

```shell
$ restic-prune.sh 
repository cf393426 opened successfully, password is correct
Applying Policy: keep the last 7 daily, 5 weekly, 3 monthly snapshots
keep 1 snapshots:
ID        Time                 Host              Tags        Reasons           Paths
-------------------------------------------------------------------------------------------
f7fe4a2b  2023-11-29 13:56:19  my-laptop              daily snapshot    /home/mbaker
                                                             weekly snapshot
                                                             monthly snapshot
-------------------------------------------------------------------------------------------
1 snapshots

repository cf393426 opened successfully, password is correct
counting files in repo
building new index for repo
[0:09] 100.00%  231 / 231 packs
repository contains 231 packs (13552 blobs) with 1.113 GiB
processed 13552 blobs: 0 duplicate blobs, 0 B duplicate
load all snapshots
find data that is still in use for 1 snapshots
[0:00] 100.00%  1 / 1 snapshots
found 13552 of 13552 data blobs still in use, removing 0 blobs
will remove 0 invalid files
will delete 0 packs and rewrite 0 packs, this frees 0 B
counting files in repo
[0:09] 100.00%  231 / 231 packs
finding old index files
saved new indexes as [244f97a4]
remove 2 old index files
done
```

## Test restores

This is to ensure that backups are being created and can be restored.

Make sure the restore directory exists for the user. (Should be outside the directory being backed up to avoid backing 
up the backup if they stick around. Ideally they get deleted after each test.)

```shell
sudo mkdir -p "/var/restore/$USER"
sudo chown $USER:$USER "/var/restore/$USER"
sudo chmod 700 "/var/restore/$USER"
```

Run the test like so:
```shell
$ restic-restore-test.sh 
```

## Configure crontab

To get all of the above to run on a regular basis add the following to your crontab entry.

If you do not have a crontab entry yet, create one with the following command:

```shell
$ crontab <etc/crontab.in
```
