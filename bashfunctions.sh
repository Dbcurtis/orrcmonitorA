#!/bin/bash
# bashfunctions.sh
# use by source bashfunctions.sh
# then invoke the function you want
#####################################
#>>>>getdatedfilename pre post
#####################################
# GLOBALS: outfilename
# ARGUMENTS: pre post
# OUTPUTS: $outfilename
# RETURN:
#
# the filename is structured as pre_YYYYMMDDHHMMSSpost
# post needs to include the "." if you are trying for an extension

#####################################

getdatedfilename() {

    ## get current date ##
    local _now
    local _us
    local _infile
    local _outext

    _now=$(date +"%Y%m%d%H%M%S")
    _us="_"
    _infile=$1
    _outext=$2
# shellcheck disable=SC2034 #calling shell has exported this
    outfilename="$_infile$_us$_now$_outext"
#    echo $outfilename
}


#####################################
#>>>>reversesortfiles() 
# GLOBALS:  rsdatedfiles -reverse sort of dated files in current working dir
# ARGUMENTS: something like 'k7rvmraw_'
# OUTPUTS:
# RETURN:
#
#####################################

reversesortfiles() {
  local prefix=$1
  local files=("$prefix*.txt")
  #echo "${files[@]}"
  local OLDIFS=$IFS
  IFS=$'\n' rsdatedfiles=($(sort -r <<<"${files[*]}"));
  IFS=$OLDIFS
  #echo "${rsdatedfiles[@]}"
}


#####################################
#####################################