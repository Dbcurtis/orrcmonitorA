#!/usr/bin/bash

#this function has not been tested
printarr() { declare -n __p="$1"; for k in "${!__p[@]}"; do printf "%s=%s\n" "$k" "${__p[$k]}" ; done ;  }  

gen_pram_dict(){
    declare -a lines

    read_pram_file(){
    #####################################
    #>>>>read_pram_file()
    # extracts data from the file of $1 that is not a blank line or a comment
    # GLOBALS:  
    # ARGUMENTS: $1 -- the path to the file
    # OUTPUTS:  lines containing the extracted lines with [[:blank:]] removed
    # RETURN: none
    #
    #####################################       
        local priorIFS=$IFS
        local linea
        while IFS= read -r linea
        do 
            [[ $linea =~ ^#.* ]] && continue # remove comment lines
            line=${linea//[[:blank:]]/}   # trim spaces and tab
            [[ -z $line ]] && continue # remove blank lines
            #echo $line
            lines=( "${lines[@]}" "$line" ) # i think IFS screws up the += syntax   
        done < "$1"
        IFS=$priorIFS        
    }

    make_dict(){
    #####################################
    #>>>>make_dict()
    # GLOBALS:  
    # ARGUMENTS: $1 an array of lines from read_pram_file
    # each line is of the form 'key:text'
    # OUTPUTS: a dict of keyword value from the lines
    # RETURN: 
    #
    #####################################
        local priorIFS=$IFS
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
##################################
    read_pram_file "$1" # extract non comments from prameter file
    make_dict lines[@]  # make dict from non comments.
    
}

