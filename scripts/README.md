# Scripts

Portable project scripts interface<br>
that is independent of project implementation and usage environment,<br>
including languages, tools, components, & operating systems


## Prerequisites

Bash >= 4 shell


## Configuration

[`.config.bashrc`](.config.bashrc)


## Usage

The scripts are lexicographically in workflow-ish order:

See `--help` option output for more information.

| Scripts                                                                |
| ---------------------------------------------------------------------- |
| [`../script.sh`](../script.sh)                                         |
| [`.config.bashrc`](.config.bashrc)                                     |
| [`.bashrc`](.bashrc)                                                   |
| [`bootstrap`](bootstrap)                                               |
| [`bootstrap-env`](bootstrap-env)                                       |
| [`engage-env.bashrc`](engage-env.bashrc)                               |
| [`disengage-env.bashrc`](disengage-env.bashrc)                         |
| [`install`](install)                                                   |
| [`install-dependencies`](install-dependencies)                         |
| [`install-os-packages`](install-os-packages)                           |
| [`install-packages`](install-packages)                                 |
| [`install-packages-all`](install-packages-all)                         |
| [`install-rest`](install-rest)                                         |
| [`list-installed-packages-licenses`](list-installed-packages-licenses) |
| [`run`](run)                                                           |
| [`test`](test)                                                         |
| [`test-scripts`](test-scripts)                                         |
| [`update`](update)                                                     |
| [`update-database`](update-database)                                   |
| [`update-modules`](update-modules)                                     |
| [`upgrade-dependencies`](upgrade-dependencies)                         |
| [`upgrade-dependencies-spec`](upgrade-dependencies-spec)               |
| [`upgrade-dependencies-spec-check`](upgrade-dependencies-spec-check)   |


### First run

e.g., after `git clone`

```
bootstrap

. engage-env.bashrc

run
```


### Later shell sessions

```
. engage-env.bashrc

# Run scripts
```
