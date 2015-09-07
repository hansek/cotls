***Not a First Alpha version - but still use with respect :)***

# Condensed Tools = Cotls

**Cotls** is a set of tools for (web) developers to they can easily manage their daily routines (backuping, deployment, dumping, batch commands, ...).

You can also make groups of commands (batch) and they can be run by one command.

## Install

Minimum requirement is **BASH 4.x**

### Automatic install with cURL or Wget
Run in your command line

**cURL**

```bash
curl https://raw.githubusercontent.com/hansek/cotls/master/cotls-installer.sh | bash
```

**Wget**

```bash
wget -qO- https://raw.githubusercontent.com/hansek/cotls/master/cotls-installer.sh | bash
```


### Manual install

1. Download **cotls.sh** script and **actions/** dir and put them somewhere (for eg. into your home directory)
2. Add execute permission
   `chmod +x ~/cotls.sh`
3. Update your PATH or make alias in your **.bashrc** 
   `alias cotls="~/cotls.sh"`
4. Put the config file **.cotls** (a copy of **.cotls.sample**) to your project directory or desire location
5. Update variables in your config file
6. Run command in your project directory
   `cotls syncdown`

## Actions
- **batch** - run defined batch operations (self commands) from config file
- **dumpdown** - remotely dump mysql database to localhost over SSH
- **syncdown** - rsync files from remote server to localhost over SSH
- **import** - helper for import to local mysql database (can handle `*.sql`, `*.zip`, `*.gz` formats)
- **fulldrop** - drop all tables in local mysql database
- **deploy** - deploy of latest GIT commits from remote repository
- **rechmod** - apply correct access rights for directories/files on localhost
- **self-update** - update COTLS to latest version from GitHub (only if installed as GIT repository)


## Completion install
***Will be simplified later***

```bash
cp ./cotls_completion.sh /etc/bash_completion.d/cotls
```


## Arguments

#### Version
`-v`


#### Custom config filename suffix
`-c=<config-suffix>`

You can have more than one config files in your project directory e.g. **.cotls** (default without suffix), **.cotls.dev** (*dev* suffix), **.cotls.stage** (*stage* suffix), ...


#### Set path to config file
`-cp=<path-to-config-file>`

Path can be relative or absolute, default value is current directory.

Allow to call Cotls outside of folder with config file


#### CLI password prompt for remote DB
`-prdb`

Prompt user for remote database password to it havn't to be stored inside config file



## Config examples for each action

### Basic configs

#### dumpdown - Remote DB dump to localhost
```bash
SSH_USER="user"
SSH_SERVER="server.example.com"

# For connection to remote database you can use:

# A) auto loading of DB credentials from PHP files
PROJECT_CMS="drupal7" # drupal7 | wordpress | modx | nette | prestashop | radek
PROJECT_SETTINGS_FILE="httpdocs/sites/default/settings.php"

# B) defining database credentials here
DB_REMOTE_NAME="my_project"
DB_REMOTE_USER="project_user"
DB_REMOTE_PASS="password"

DB_REMOTE_IGNORED_TABLES=(
    "log"
)

DB_REMOTE_PARAMETERS=(
    # "--no-data"
)

CUSTOM_TARGET_FILENAME="dump"
```

#### fulldrop - drop all tables in database on localhost
```bash
DB_LOCAL_NAME="my_project_local"
DB_LOCAL_USER="root"
DB_LOCAL_PASS="root"
```


#### import - import database dump into local database
```bash
DB_LOCAL_NAME="my_project_local"
DB_LOCAL_USER="root"
DB_LOCAL_PASS="root"

FILE_TO_IMPORT="dump"
```


#### syncdown - sync local media with remote host
```bash
SSH_USER="user"
SSH_SERVER="server.example.com"

PROJECT_LOCAL_ROOT="www/"

RSYNC_PARAMETERS=(
)

RSYNC_REMOTE_ROOT_PATH="httpdocs/"

RSYNC_REMOTE_PATHS=(
    "www"
)

RSYNC_EXCLUDE__WWW=(
    "cache/*"
)

RSYNC_FORCE_LOCAL__WWW=(
    "sites/default/settings.php"
)
```


#### rechmod - re-aplly 777 on certain directories/files on localhost
```bash
PROJECT_LOCAL_ROOT="www/"

CHMOD_PATHS_WRITE=(
    "sites/default/files/"
    "tmp/"
)
```


#### deploy - reset remote GIT repository to latest commit
```bash
SSH_USER="user"
SSH_SERVER="server.example.com"

PROJECT_REMOTE_GIT_ROOT="httpdocs/"
PROJECT_REMOTE_GIT_BRANCH="origin master"
```


#### batch - definition of batch commands sets
```bash
# you have to have config variables for each command set ;)

BATCH__FULL=(
    "dumpdown -tf=dump"
    "fulldrop"
    "import -tf=dump"
    "syncdown"
)
```

### Multiple / inherited configs
*... TBD ...*



## Examples
Example commands to run in command line:

```
... TBD ...
```


## TODO
- [ ] rename commands to better equivalents
- [ ] better logs
- [ ] config validation (warn user if required variables are not set)
- [ ] `--password` argument to load all password on script start by user prompt
- [ ] better success / error handling for nested external commands (mysql_dump, mysql, rsync, ...)
- [ ] multiple environment settings in only one config file (dev, staging, ...)
- [ ] ability to define command parameters by cli arguments of cli prompt
- [ ] commands parameters autocompletion
- [ ] refactor script to contain completion (similar to [z.sh])
- [ ] refactor script to be called as alias and have custom name (similar to [z.sh])

### New commands
  - [ ] dump - export database

### Batch
  - [ ] ability to run external commands as batch item

### Dumpdown
  - [ ] unify with new **dump** command (use arguments for remote DB)
  - [ ] remove compression from default behavior

### Syncdown
  - [ ] make hardcoded arguments as just default values
  - [ ] improve password handling

### Self Update
  - [ ] allow set update stream/branch (master/test/develop)
  - [ ] option to update not only as GIT repository



## License
All contents of this package are licensed under the [MIT license].

[MIT license]: LICENSE
[z.sh]: https://github.com/rupa/z