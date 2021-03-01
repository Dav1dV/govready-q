# Configures scripts
#
#   Usage:  . .config.bashrc

description='Configures scripts' \
  . "$(dirname -- "${BASH_SOURCE[0]}")/.bashrc"  # Bootstrap in this script's directory
# e.g., Validate usage

# Continue if not aborting after being sourced directly
#   e.g., not `. .config.bashrc --help`

was_sourced_directly() {
  [ "${BASH_SOURCE[-1]}" = "${BASH_SOURCE[0]}" ]
}

if ! ( [ "$aborting" ]  &&  was_sourced_directly ) ; then



# Configuration

env_default=venv  # Virtualenv convention

python_default=python3.8


## Operating system level dependencies

declare -Ag python_os_packages_by_manager
python_os_packages_by_manager=( \
  [apt-get]="$python_default $python_default-dev" \
  [brew]='python@3.8' \
  [yum]='python38 python38-devel' \
)

declare -Ag os_packages_by_manager
os_packages_by_manager=( \
  [apt-get]=''"${python_os_packages_by_manager[apt-get]}" \
  [brew]=''"${python_os_packages_by_manager[brew]}" \
  [yum]=''"${python_os_packages_by_manager[yum]}" \
)
# e.g., [apt-get]='git '"${python_os_packages_by_manager[apt-get]}" \

declare -Ag os_package_managers_install_options
os_package_managers_install_options=( \
  [apt-get]='install -y' \
  [brew]='install' \
  [yum]='install -y' \
)


print_os_package_manager() {
  local manager
  for manager in "${!os_packages_by_manager[@]}" ;  do

    if which "$manager" >& /dev/null;  then
      echo "$manager"
      return
    fi
  done

  >&2 echo 'Error:  Supported package manager not found:  '"${!python_os_packages_by_manager[@]}"
  return 1
}

print_os_packages() {
  local manager
  manager=$(print_os_package_manager)  \
    && echo "${os_packages_by_manager[$manager]}"
}



undo_configuration() {
  # Undoes all changes made during configuration above

  unset env_default \
        python_default \
        python_os_packages \
        os_packages \
        was_sourced_directly \
        undo_configuration
}

# Undo if dry run after being sourced directly
! ( [ "$dry_running" ] && was_sourced_directly )  ||  undo_bootstrap
#   ! ... ||  for accurate exit status

fi
