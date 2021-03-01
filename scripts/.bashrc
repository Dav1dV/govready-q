# Bootstraps scripts
#
#   Usage:  . .bashrc
#
#   Environment:
#
#     File:
#       .config.bashrc                Configuration script
#
#     Variables:
#
#       Input:
#         description                 Script description
#         arguments_required          Script required arguments' names            (array)
#         arguments_optional          Script optional arguments' names            (array)
#         arguments_optional_multi    Script optional, multi arguments' names     (array)
#         arguments_descriptions      Script arguments' descriptions  (associative array
#                                                                        [name]=description)
#
#       Output:
#         options_by_name             Implemented script options by name  (associative array [name]=option)
#         aborting                    Not '' if script sourced & aborting  (e.g., help option specified)
#         dry_running                 Not '' if dry run option specified
#         options                     Specified script options,    not including arguments  (array)
#         arguments                   Specified script arguments,  not including options    (array)
#         scripts_dir                 Project-relative path to the scripts directory
#
#     Functions:
#
#       Output:
#         print_basename PATH         Prints basename natively  w/o shell execution
#         print_help                  Prints help,  including usage
#         log_command    ARGUMENT...  Logs & runs parameter(s) as command arguments  in the current shell,
#                                       only logging without running  if dry run option specified
#         undo_bootstrap              Undoes all changes made during bootstrapping
#
#   Prerequisites:
#      Bash >=4

# TODO Add help description subline (indented) support  e.g., for examples in script comment headers and/or online doc refs
# TODO Add help arguments' descriptions column-formatting w/ line breaking
# TODO Add argument verification?

config_filename=.config.bashrc  # relative to this script's directory
_scripts_path=$(dirname -- "${BASH_SOURCE[0]}")
_config_filepath="$_scripts_path/$config_filename"

function _bootstrap() {  # Enclosure for local variables

  # Variables

  ## Constants
  local _description='Bootstraps scripts'

  declare -Ag options_by_name
  options_by_name=( [help]='--help' [dry-run]='--dry-run' [end]='--' )
  # If change --help,  update throughout script header comments


  ## Output

  print_basename() {  # path
    # Prints basename natively  w/o shell execution
    echo "${1##*/}"
  }

  scripts_dir=$(print_basename "$(realpath -- "$_scripts_path")")


  # Validate usage

  _print_usage() {  # argument...
    # Prints usage

    cat << EOF
Usage:  $@
EOF

    if [ ! -z "$description" ]; then
      cat << EOF

  $description
EOF
    fi
  }

  _print_sourcing_usage() {
    _print_usage . "$(print_basename "${BASH_SOURCE[-1]}")"
  }

  ## Verify this script was sourced  instead of executed
  ##
  ##   If not,  exit w/ usage error message & status

  if [ "$0" -ef "${BASH_SOURCE[0]}" ]; then  # Executed file is this one
    description=$_description
    >&2 _print_sourcing_usage
    exit 1
  fi


  ## Verify sourcing script was sourced instead of executed  if required
  ##
  ##   If not,  exit w/ usage error message & status

  _was_sourced() {
    # Tests if sourcing script was sourced instead of executed

    [[ "$0" =~ ^-?bash$ ]]  # '-bash' or 'bash' for login shell or not
  }

  _was_this_started_directly() {
    [ "${BASH_SOURCE[-1]}" -ef "${BASH_SOURCE[0]}" ]
  }

  _was_config_started_directly() {
    [ "${BASH_SOURCE[-1]}" -ef "$_config_filepath" ]
  }

  local this_was_started_directly=
  print_help() {
    # Prints help,  including usage

    # Usage

    _was_this_started_directly && this_was_started_directly=true

    if [ "$this_was_started_directly" ] || _was_config_started_directly ; then

      [ "$this_was_started_directly" ] && description=$_description
      _print_sourcing_usage

    else
      _print_argument_optional() {  # argument_optional
        echo -n "[$1]"
      }

      _print_argument_multiple() {  # argument_multiple
        echo -n "$1..."
      }

      _print_argument_optional_multiple() {  # argument_optional_multiple
        _print_argument_multiple "$(_print_argument_optional "$1")"
      }

      local arguments=()
      [ "$sourcing_required" ] && arguments+=(.)
      arguments+=("$(print_basename "${BASH_SOURCE[-1]}")"  \
                  "$(_print_argument_optional_multiple OPTION)"  \
                  "${arguments_required[@]}")

      _append_arguments() {  # function_name argument...
        local i
        for i in "${@:2}"; do
          arguments+=("$("$1" "$i")")
        done
      }
      _append_arguments _print_argument_optional          "${arguments_optional[@]}"
      _append_arguments _print_argument_optional_multiple "${arguments_optional_multi[@]}"

      unset _print_argument_optional \
            _print_argument_multiple \
            _print_argument_optional_multiple \
            _append_arguments

      _print_usage "${arguments[@]}"


      # Options

      local option_width_max=1
      local option
      local option_width
      for option in "${options_by_name[@]}"; do
        local option_width=${#option}
        [ "$option_width" -gt "$option_width_max" ] && option_width_max=$option_width
      done
      cat << EOF

  Options:
    $(printf "%-${option_width_max}s" "${options_by_name[help]}"   )  Output this help & exit
    $(printf "%-${option_width_max}s" "${options_by_name[dry-run]}")  Simulate without making changes
    $(printf "%-${option_width_max}s" "${options_by_name[end]}"    )  Stop processing script options
EOF


      # Arguments' descriptions  if any

      if [ ${#arguments_descriptions[@]} -gt 0 ]; then
        cat << EOF

  Arguments:
EOF
        local name
        for name in "${!arguments_descriptions[@]}"; do
          cat << EOF
    $name  ${arguments_descriptions[$name]}
EOF
        done
      fi
    fi
  }

  if ( [ "$sourcing_required" ] || _was_config_started_directly )  &&  ! _was_sourced ; then
    >&2 print_help
    exit 2
  fi


  ## Process options  if config either not sourcing or sourced directly

  _is_config_sourcing() {
    [ "${BASH_SOURCE[3]}" -ef "$_config_filepath" ]
  }

  if ! _is_config_sourcing || _was_config_started_directly ; then

    options=()
    while [ $# -gt 0 ]; do
      case $1 in

        ${options_by_name[help]})
          print_help

          # Exit if not sourcing;  otherwise, set $aborting
          _was_sourced && aborting=true || exit 0
          ;;

        ${options_by_name[dry-run]})
          dry_running=true
          ;;

        ${options_by_name[end]})  # End of options
          options+=($1)
          shift
          break
          ;;

        *)                # First non-option argument
          break
      esac

      options+=($1)
      shift
    done

    arguments=("$@")
  fi


  # Continue if
  #   - Not aborting after this script was started directly  (i.e., aborting directly)
  #   - Sourcing script isn't the configuration file

  [[ "$aborting" && "$this_was_started_directly" ]]  &&  local aborting_directly=true

  if [ ! "$aborting_directly" ]  &&  ! _is_config_sourcing ; then

    # Load configuration

    . "$_config_filepath"


    # Define additional output functions

    log_command() {  # argument...
      # Logs & runs parameter(s) as command arguments  in the current shell

      # Log a la `set -x`

      ## Prefix
      local prefix=+
      [ "$SHLVL" -gt 1 ]  &&  prefix=$(eval "printf '+%.s' {1..$((SHLVL-1))}")

      ## Quote arguments containing spaces
      args_quoted=()
      for arg in "$@"; do
        if [[ $arg = *[$' \t\n']* ]]; then
          args_quoted+=("'$arg'")
        else
          args_quoted+=("$arg")
        fi
      done

      >&2 echo -e "\n$prefix ""${args_quoted[@]}"
      # w/ blank line before to separate multiple commands


      # Run
      [ "$dry_running" ]  ||  "$@"

      local status=$?

      echo  # blank line after to separate multiple commands and from command prompt after

      return $status


      # e.g., instead of just `(set -x ;  "$@")` so don't echo any subscripts
    }


    # Change current directory to project root  if not already there

    _pushd_status=
    local project_root_path=$_scripts_path/..

    if [ ! "$(pwd)" -ef "$project_root_path" ]; then

      log_command pushd "$(realpath --relative-to .  "$project_root_path")"
      # realpath --relative-to .  to simplify  (e.g., .. instead of ./..)

      _pushd_status=$?
    fi
  fi


  undo_bootstrap() {
    # Undoes all changes made during bootstrapping  above & below this function

    undo_configuration

    [ "$_pushd_status" = "0" ]  &&  log_command popd

    _undo_bootstrap_definitions
  }
  _undo_bootstrap_definitions() {
    # Undefines everything global defined during bootstrapping above

    # In definition order:
    unset description \
          sourcing_required \
          arguments_required \
          arguments_optional \
          arguments_optional_multi \
          arguments_descriptions \
          \
          _scripts_path \
          _config_filepath \
          options_by_name \
          print_basename \
          scripts_dir \
          _print_usage \
          _print_sourcing_usage \
          _was_this_started_directly \
          _was_config_started_directly \
          print_help \
          _is_config_sourcing \
          aborting \
          dry_running \
          arguments \
          log_command \
          _pushd_status \
          undo_bootstrap \
          _undo_bootstrap_definitions
  }


  # Undefine variables & functions no longer needed
  unset config_filename \
        _bootstrap \
        _was_sourced


  # Undo if aborting or dry running directly

  [ "$aborting_directly" ] && \
    _undo_bootstrap_definitions

  [ "$dry_running" ] && _was_this_started_directly && ! _is_config_sourcing && \
    undo_bootstrap
}

_bootstrap "$@"

# Drop options processed above  if config not sourcing
[ "${BASH_SOURCE[1]}" -ef "$_config_filepath" ]  ||  set -- "${arguments[@]}"
