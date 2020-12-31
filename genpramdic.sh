#!/usr/bin/bash

printarr() { declare -n __p="$1"; for k in "${!__p[@]}"; do printf "%s=%s\n" "$k" "${__p[$k]}" ; done ;  }  

gen_pram_dict(){
    declare -a lines

    read_pram_file(){
        
        local priorIFS=$IFS
        local linea
        while IFS= read -r linea
        do 
            [[ $linea =~ ^#.* ]] && continue # remove comment lines
            line=${linea//[[:blank:]]/}
            [[ -z $line ]] && continue # remove blank lines
            #echo $line
            lines=( "${lines[@]}" "$line" ) # i think IFS screws up the += syntax   
        done < "$1"
        IFS=$priorIFS

        
    }

    make_dict(){
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
    read_pram_file "$1"
    make_dict lines[@]
    
}

