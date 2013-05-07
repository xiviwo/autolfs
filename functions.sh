#!/bin/bash

# VT100 colors
declare -r  BLACK=$'\e[1;30m'
declare -r  DK_GRAY=$'\e[0;30m'

#declare -r  RED=$'\e[31m'
#declare -r  GREEN=$'\e[32m'
export RED="\[\e[1;31m\]"
export GREEN="\[\e[1;32m\]"
declare -r  YELLOW=$'\e[33m'
declare -r  BLUE=$'\e[34m'
declare -r  MAGENTA=$'\e[35m'
declare -r  CYAN=$'\e[36m'
declare -r  WHITE=$'\e[37m'

declare -r  OFF=$'\e[0m'
declare -r  BOLD=$'\e[1m'
declare -r  REVERSE=$'\e[7m'
declare -r  HIDDEN=$'\e[8m'

declare -r  tab_=$'\t'
declare -r  nl_=$'\n'

declare -r   DD_BORDER="${BOLD}==============================================================================${OFF}"
declare -r   SD_BORDER="${BOLD}------------------------------------------------------------------------------${OFF}"
declare -r STAR_BORDER="${BOLD}******************************************************************************${OFF}"

# bold yellow > <  pair
declare -r R_arrow=$'\e[1;33m>\e[0m'
declare -r L_arrow=$'\e[1;33m<\e[0m'

declare -r TRUE=0
declare -r FALSE=1
declare -r PASSWD_FILE=/etc/passwd
export BLACK DK_GRAY RED GREEN YELLOW BLUE MAGENTA CYAN WHITE OFF BOLD REVERSE HIDDEN tab_ nl_ DD_BORDER SD_BORDER STAR_BORDER R_arrow L_arrow TRUE FALSE
############################################################################
error () {
	# <error code> <name> <string> <args>
	local err="$1"
	local name="$2"
	local fmt="$3"
	shift; shift; shift
	#if [ "$USE_DEBIANINSTALLER_INTERACTION" ]; then
		(echo "\n${BOLD}${RED}ERROR: [$(date +'%Y-%d-%m %T')]${OFF} $name"
		for x in "$@"; do echo "\nEA: $x"; done
		echo "${BOLD}${RED}ERROR: [$(date +'%Y-%d-%m %T')]${OFF} $fmt") 
	#else
		#(printf "${BOLD}${RED}ERROR: [$(date +'%Y-%d-%m %T')]${OFF} $fmt\n" "$@") 
	#fi
	#exit $err
	cleanup $err $LINENO
}

warning () {
	# <name> <string> <args>
	local name="$1"
	local fmt="$2"
	shift; shift
	#if [ "$USE_DEBIANINSTALLER_INTERACTION" ]; then
		(echo "W: $name"
		for x in "$@"; do echo "WA: $x"; done
		echo "WF: $fmt") >&4
	#else
		#printf "W: $fmt\n" "$@" >&4
	#fi
}

info () {
	# <name> <string> <args>
	local name="$1"
	local fmt="$2"
	shift; shift
	#if [ "$USE_DEBIANINSTALLER_INTERACTION" ]; then
		(echo "I: $name"
		for x in "$@"; do echo "IA: $x"; done
		echo "IF: $fmt") >&4
	#else
	#	printf "I: $fmt\n" "$@" >&4
	#fi
}
##################################################################
# Purpose: to detect whether function is callable
# Arguments:
#   $1 ->  functionname
##################################################################
is_callable(){

local func=$1

if type "$func">/dev/null 2>&1 ; then
return 0
else 
return 1
fi

}
##################################################################
# Purpose: to provide error handling
# Arguments:
#   $1 -> 
##################################################################
function onexit() {
    local exit_status=${1:-$?}
    echo Exiting $0 with $exit_status
    exit $exit_status
}
##################################################################
# Purpose: to provide block logging
# Arguments:
#   $1 -> String to log
##################################################################
function block()
{
	local msg="$1"
	echo "-----------------INFO : [$(date +'%Y-%d-%m %T')]-------------------------"
	echo -en "               \n${BOLD}${BLACK}${msg}${OFF}\n"
	echo "----------------------------------------------------------------------"
}
##################################################################
# Purpose: to provide info logging
# Arguments:
#   $1 -> String to log
##################################################################
function log()
{
	local msg="$1"
	echo "${BOLD}${GREEN}INFO : [$(date +'%Y-%d-%m %T')]${OFF} ${msg}"
}
##################################################################
# Purpose: to provide debug logging
# Arguments:
#   $1 -> String to log
##################################################################
function debug()
{
	if [[ ${DEBUG_} = "true" ]]; then
		echo "\$${1}=${!1}" >&4
	fi
	
}
##################################################################
# Purpose: Converts a string to lower case
# Arguments:
#   $1 -> String to convert to lower case
##################################################################
function to_lower() 
{
    local str="$@"
    local output     
    output=$(tr '[A-Z]' '[a-z]'<<<"${str}")
    echo $output
}
##################################################################
# Purpose: Display an error message and die
# Arguments:
#   $1 -> Message
#   $2 -> Exit status (optional)
##################################################################
function die() 
{
    local m="$1"	# message
    local e=${2-1}	# default exit status 1
    echo "$m" 
    exit $e
}
##################################################################
# Purpose: Return true if script is executed by the root user
# Arguments: none
# Return: True or False
##################################################################
function is_root() 
{
   [ $(id -u) -eq 0 ] && return $TRUE || return $FALSE
}
 
##################################################################
# Purpose: Return true $user exits in /etc/passwd
# Arguments: $1 (username) -> Username to check in /etc/passwd
# Return: True or False
##################################################################
function is_user_exits() 
{
    local u="$1"
    grep -q "^${u}" $PASSWD_FILE && return $TRUE || return $FALSE
}
