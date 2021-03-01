# Disengages (e.g., deactivates) the engaged isolated environment
#
#   Usage:  . disengage-env.bashrc [OPTION]...
#
#     See --help option output
#
#
#   e.g., `. engage-env.bashrc ;  run ;  . disengage-env.bashrc`

description='Disengages the engaged isolated environment'
sourcing_required=true

. "$(dirname -- "${BASH_SOURCE[0]}")/.bashrc"  # Bootstrap in this script's directory


[ ! "$aborting" ]  &&  log_command deactivate
# https://govready-q.readthedocs.io/en/latest/developing-for-govready-q/installing-govready-q-for-development.html?highlight=%22env%2Fbin%2Factivate%22#updating-the-source-code

undo_bootstrap
