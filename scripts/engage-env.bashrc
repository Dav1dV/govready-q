# Engages (e.g., activates) an isolated environment,  after bootstrapping,
#
#     you can have more than 1 of
#
#
#   Usage:  . engage-env.bashrc [OPTION]... [ENVIRONMENT_ID]
#
#     See --help option output
#
#
#   Afterward,  use disengage-env.bashrc  to disengage the resulting isolated environment.
#
#     e.g., `. engage-env.bashrc ;  run ;  . disengage-env.bashrc`
#
#
#   See bootstrap-env & bootstrap

description='Engages an isolated environment  (after bootstrapping)'
arguments_optional=ENVIRONMENT_ID

. "$(dirname -- "${BASH_SOURCE[0]}")/.config.bashrc"  # Bootstrap in this script's directory
declare -A arguments_descriptions
arguments_descriptions=( [$arguments_optional]="Default is  $env_default   (See configuration's env_default setting)" )

sourcing_required=true  # Must be after config sourcing validation above

. "$scripts_dir/.bashrc"  # Bootstrap in this script's directory


[ ! "$aborting" ]  &&  log_command . "${1:-$env_default}/bin/activate"
# https://govready-q.readthedocs.io/en/latest/developing-for-govready-q/installing-govready-q-for-development.html?highlight=%22env%2Fbin%2Factivate%22#updating-the-source-code

undo_bootstrap
