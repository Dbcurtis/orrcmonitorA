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
# RETURN: rsdatedfiles with sorted newest to oldest
#
#####################################

reversesortfiles() {
  local prefix=$1
  local files=($prefix*.txt)
  local oldifs="$IFS"
# shellcheck disable=SC2034 #calling shell has exported this
  IFS=$'\n' rsdatedfiles=($(sort -r <<<"${files[*]}"))
  IFS="$oldifs"
}
# ways to display rsdtaedfiles content:
#  for i in "${rsdatedfiles[@]}"; do echo "$i"; done
#  for (( i=0; i<$len; i++ )); do echo "${rsdatedfiles[$i]}"; done
#####################################
#####################################



