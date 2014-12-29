***First Alpha version - use with respect :)***

# Condensed Tools = Cotls

**Cotls** is a set of tools for (web) developers to they can easily manage their daily routines (backuping, deployment, dumping, batch commands, ...).

Currently inlcudes easily configurable commands for:
* rsync
* mysql dump
* mysql import

You can also make groups of commands (batch) and they can be run by one command.

## Install
### Automatic install with cURL or Wget
Run in your command line

**cURL**

```
curl https://raw.githubusercontent.com/hansek/cotls/master/cotls-installer.sh | bash
```

**Wget**

```
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


## Arguments
### Custom config filename suffix
`-c=<suffix> | --config=<suffix>`

You can have more than one config files in your project directory e.g. **.cotls** (default without suffix), **.cotls.dev** (*dev* suffix), **.cotls.stage** (*stage* suffix), ...

### CLI password prompt for remote DB
`-prdb|--password-remote-db`

Prompt user for remote database password to it havn't to be stored inside config file

### MODX Revolution CORE path on remote host
`-modx | --modx | -modx=<path> | --modx=<path>`

Relative path to MODX Revolution CORE folder on remote host

Default value for `-modx` and `--modx` arguments is **./**


## TODO
- [x] refactor to modular action structure
- [ ] rename commands to better equivalents
- [ ] better logs
- [ ] config validation (warn user if required variables are not set)
- [ ] `--password` argument to load all password on script start by user prompt
- [ ] better success / error handling for nested external commands (mysql_dump, mysql, rsync, ...)
- [ ] multiple environment settings in only one config file (dev, staging, ...)
- [ ] ability to define command parameters by cli arguments of cli prompt
- [ ] improve usage / help text
- [ ] commands autocompletion
- [ ] commands parameters autocompletion

### New commands
  - [ ] dump - export database

### Batch
  - [ ] "one multidimension array" to config more groups
  - [ ] ability to run external commands as batch item

### Dumpdown
  - [ ] unify with new **dump** command (use arguments for remote DB)
  - [ ] remove compression from default behavior
  - [ ] option to specify target folder for dumps (now in place of config file)

### Syncdown
  - [ ] make hardcoded arguments as just default values
  - [ ] option to specify ignored directories / files for specific paths (now only globaly for all paths)
  - [ ] improve password handling



## Examples
Example commands to run in command line:

```
... TBD ...
```

## Config examples

### Basic configs
#### Rsync
*... TBD ...*

#### Remote DB dump
*... TBD ...*

### Multiple / inherited configs
*... TBD ...*


## License
Cotls is licensed under the [WTFPL license][wtfpl_license]

[wtfpl_license]: http://www.wtfpl.net/
