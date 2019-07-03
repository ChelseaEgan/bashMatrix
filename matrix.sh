#!/bin/bash

###############################################################################
# Script Name	:
# Description	:
# Args		:
# Author	: Chelsea Egan
# Class		: CS 344-400
# Assignment	:
###############################################################################

datafilepath="datafile$$"

function perror(){
  # NAME
  #   perror - print a stack trace and error message
  # SYNOPSIS
  #   perror [STRING]
  # DESCRIPTION
  #   Echoes the STRING(s) to standard error with a stack trace for debugging.
  # AUTHOR
  #   Written by Ryan Gambord (gambordr@oregonstate.edu)
  #   Adapted by Chelsea Egan (eganch@oregonstate.edu)

  status=1 # Set an error status
  echo -e "\e[36mTraceback (most recent call last):\e[0m" >&2
  i=${#BASH_LINENO[@]} # Get number of items in stack trace

  # This section prints a stack trace of the current execution stack
  while
    [ $i -gt 0 ] # Iterate to the top of the stack
  do
    until # Loop until we get to the bottom of caller stack (this is safer than offsetting $i)
      ((i--))
      info=("$(caller $i)") # Get caller info
    do :; done # Do nothing

    echo "  File \"${info[2]}\", line ${info[0]}, in ${info[1]}()" >&2 # Print caller info
    if [ $i -ne 0 ] # Check if we're at the top of the stack (perror call is at top)
    then
      echo "    ""$(head "${info[2]}" -n "${info[0]}" | tail -n 1)" >&2 # Print trace if not at top
    else
      echo -en "\e[31mERROR\e[0m: " >&2 # Print error message if at top
      [ $# -gt 0 ] && echo "$*" >&2 || echo "(no error message specified)" >&2
    fi
  done
  exit $status
}

checkArgCount() {
    [[ $2 -gt $1 ]] && perror "invalid number of arguments"
}

copyInputToTempFile() {
    if [[ $1 = 0 ]]; then
	cat > "$datafilepath"
    elif [[ $1 = 1 ]]; then
	cat "$2" > "$datafilepath"
    fi
}

checkFileIsValid() {
    [[ ! -s $datafilepath ]] && perror "cannot read that file"
}

dims() {
    datafilepath="datafile$$"
    checkArgCount 1 "$#"
    copyInputToTempFile "$#" "$1"
    checkFileIsValid
    
    numcols=0
    read -r firstline<"$datafilepath"
    for num in $firstline; do
	numcols=$((numcols + 1))
    done
    
    numrows=0
    while read -r row; do
	numrows=$((numrows + 1))
    done < "$datafilepath"

    echo "$numrows $numcols"

    rm "$datafilepath"
}

# https://www.thelinuxrain.com/articles/transposing-rows-and-columns-3-methods
transpose() {
    checkArgCount 1 "$#"
    copyInputToTempFile "$#" "$1"
    checkFileIsValid

    read -r firstrow<"$datafilepath"

    index=1
    for num in $firstrow; do
	cut -f${index} "$datafilepath" | paste -s
	index=$((index + 1))
    done
    rm "$datafilepath"
}

mean() {
    checkArgCount 1 "$#"
    copyInputToTempFile "$#" "$1"
    checkFileIsValid

    read -r firstrow<"$datafilepath"

    index=1
    results=''
    for col in $firstrow; do
	numbers=$(cut -f${index} "$datafilepath")
	mean=0
	amount=0
	for num in $numbers; do
	    mean=$((mean + num))
	    amount=$((amount + 1))
	done
	mean=$(((mean + (amount/2)*((mean>0)*2-1))/amount))
	index=$((index + 1))
	$results$mean	
    done

    rm "$datafilepath"
}

$1 "${@:2}"



