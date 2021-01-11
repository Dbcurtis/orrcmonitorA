#!/bin/bash
# next two commands see: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

: ' bashfunctions.sh
    use by --source bashfunctions.sh--
    then invoke the function you want
#####################################

>>>>getdatedfilename pre post
#####################################
    GLOBALS: outfilename
    ARGUMENTS: pre post
    OUTPUTS: $outfilename  
    RETURN:

    the filename is structured as preraw_YYYYMMDDHHMMSSpost
    post needs to include the "." if you are trying for an extension

#####################################
'
getdatedfilename() {

    ## get current date ##
    local _now
    local _us
    local _infile
    local _outext

    _now=$(date +"%Y%m%d%H%M%S")
    _us="raw_"
    _infile=$1
    _outext=$2
# shellcheck disable=SC2034 #calling shell has exported this
    outfilename="$_infile$_us$_now$_outext"
#    echo $outfilename
}

: '
>>>>reversesortfiles()
##############################
    GLOBALS:  rsdatedfiles -reverse sort of dated files in current working dir
    ARGUMENTS: something like 'k7rvmraw_'
    OUTPUTS:
    RETURN: rsdatedfiles  sorted newest to oldest
#
#####################################
'

reversesortfiles() {
    local prefix=$1
    local files=($prefix*.txt)
    local oldifs="$IFS"
# shellcheck disable=SC2034 #calling shell has exported this
    IFS=$'\n' rsdatedfiles=($(sort -r <<<"${files[*]}"))
    IFS="$oldifs"
}
: '
ways to display rsdtaedfiles content:
    for i in "${rsdatedfiles[@]}"; do echo "$i"; done
    for (( i=0; i<$len; i++ )); do echo "${rsdatedfiles[$i]}"; done
#####################################
'

: '
>>>>getprefixnames() pth resultarray 
##############################
    GLOBALS:  
    ARGUMENTS:  pth: the path to look for the prefix files usually ~.config/orrccheck.d
                resultarray: an array to store the results in
    OUTPUTS:    fills the resultarray with the prefixs 
    RETURN: 

Example use:
    declare -a tarr
    getprefixinfo  "$HOME/.config/orrccheck.d" tarr
    echo ${tarr[*]}
#
#####################################
'
function getprefixnames(){

    local topconfigdir
    local __resultvar
    local filesa
    local -a files
    local result
    local -a arr
    local -a arr_s
    #local -A __prefix2path

    topconfigdir="$1"
    __resultvar=$2
    #__prefix2path=$3

    filesa="$( find "$topconfigdir" -maxdepth 1 -type f -iregex ".*[.]txt"  )"
    for f in $filesa; do 
        [[ "$f" != *"lastusedpre"* ]] && files+=("$f"); done # drop the lastusedpre.txt file
    
    result=$(basename -as .txt ${files[*]}) # result is a string  
    arr=($result)   
    readarray -t arr_s < <(printf '%s\n' "${arr[@]}" | sort)
    if [[ "$__resultvar" ]]; then
        #echo ==============
        eval $__resultvar="( ${arr_s[@]} )"
    else
        echo -------------
        echo $arr_s[*]
    fi

}

: '
#####################################
#####################################
'

