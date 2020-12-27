#!/usr/bin/bash

declare -A dict #needs to be exported from calling program in real implementatoin

#echo "$IFS" | cat -ETv

read_pram_file(){
    
    local priorIFS=$IFS
    while IFS= read -r line
    do 
        [[ $line =~ ^#.* ]] && continue # remove comment lines
        lines=( "${lines[@]}" "$line" ) # i think IFS screws up the += syntax   
    done < "$1"
    IFS=$priorIFS
    
}
#echo "$IFS" | cat -ETv

make_dict(){
    local priorIFS=$IFS
    local arg1 # not sure this is usefull
    declare -a arg1=("${!1}")
    IFS=':'
    for i in "${arg1[@]}"
    do 
        read -ra temp <<< "$i"
        keya="${temp[0]}"
        vala="${temp[1]}"
        dict["$keya"]="$vala"
    done
    IFS=$priorIFS
    
}

declare -a lines
read_pram_file "/mnt/m/Python/Python3_packages/orrcmonitor/orrcprams.txt"
make_dict lines[@]


for x in "${!dict[@]}"
    do printf "[%s]=>%s\n" "$x" "${dict[$x]}"
done 
exit 0
