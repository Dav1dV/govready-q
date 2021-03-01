#!/usr/bin/env bash
# Runs a script in scripts/
#
#   Usage:  script.sh [OPTION]... SCRIPT_NAME [SCRIPT_OPTION]... [SCRIPT_ARGUMENT]...
#
#     See help output  (e.g., w/o arguments)

# TODO Add scripts.sh that  runs multiple scripts  w/o script arguments

scripts_dirname=scripts  # This-script-relative scripts directory path

description="Runs a script in $scripts_dirname/"
arguments_required=(SCRIPT_NAME)
arguments_optional_multi=(SCRIPT_OPTION SCRIPT_ARGUMENT)


scripts_currpath=$(dirname -- "$0")/$scripts_dirname  # PWD-relative


scripts_filenames=$(ls -1 "$scripts_currpath"  | grep -v README.md)
# script filenames separated by \n

print_scripts_filenames() {  # separator
  echo -n "$scripts_filenames"  | perl -pe "s/\n/$1/g"
}


declare -A arguments_descriptions
arguments_descriptions=( [$arguments_required]=$(print_scripts_filenames ' | ') )

. "$scripts_currpath/.bashrc"  # Bootstrap in this script's directory


run_script() {
  local args=("$scripts_dir/$arguments")
  [ "$dry_running" ] && args+=("${options[dry-run]}")
  args+=("${arguments[@]:1}")

  dry_running= log_command "${args[@]}"
}

eval $(cat << EOF
case "$1" in
  $(print_scripts_filenames '|'))
    run_script
    ;;

  *)
    print_help
    ;;
esac
EOF
)
