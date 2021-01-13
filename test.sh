#!/usr/bin/bash

set -euo pipefail
IFS=$'\n\t'


function deleatablefile(){
    
    : '
    input: a file path
    read one line
    respond dependent on if the -Persist exists.
    if it exists say so and rm with -i 
    if canIdeletefiles; then
        echo "yes you can"
    else
        echo "no you cannot"
    fi
    '
    #echo "$1"
    [[ -e "$1" && -r "$1" && -f "$1" ]] || return 1
    while read -r line; do 
    # line is available for processing
        #echo  "$line"
        if [[ "$line" == *"-Persist"* ]]; then
            return 1
        fi 
        break
    done < "$1"
    return 0
}
cd 

cd .local/share/orrccheck.d/k7rvm.d/www.orrc.org/Coordinations
#k7rvmraw_20210112182913.txt should not be deleted with out conf
#k7rvmraw_20210112193830.txt can delete

pwd


if deleatablefile "junk"
then
    echo "yes I can delete"
else
    echo "no I can not delete"
fi


if deleatablefile "k7rvmraw_20210112182913.txt"
then
    echo "yes I can delete"
else
    echo "no I can not delete"
fi



if deleatablefile "k7rvmraw_20210112193830.txt"
then
    echo "yes I can delete"
else
    echo "no I can not delete"
fi



exit 0
