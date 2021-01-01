#!/usr/bin/bash

source genpramdic.sh

# function lala(){
#     if [ -z ${XDG_CONFIG_HOME+x} ]
#     then 
#         echo "XDG_CONFIG_HOME is not set"
#         XDG_CONFIG_HOME="$HOME/.config"
#         export XDG_CONFIG_HOME
#     fi
#     pth="$XDG_CONFIG_HOME/orrccheck.d"
#     configdir=$pth
#     configfile="$pth/orrcprams.txt"
#     mkdir -p --verbose $pth
    

#     if [ -z ${XDG_DATA_HOME+x} ]
#     then 
#         echo "XDG_DATA_HOME is not set"
#         XDG_DATA_HOME="$HOME/.local/share"
#         export XDG_CONFIG_HOME
#     fi
#     pth="$XDG_DATA_HOME/orrccheck"
#     mkdir -p --verbose $pth
#     datadir=$pth
# }

# function initializeprams(){

#     local text=(
#         '#'
#         '# this is a comment'
#         '# blank lines are not allowed, but the last line must be empty'
#         '# values must not contain [[:blank:]] charaters (well they are removed)'
#         '#'
#         '# default raw prefix'
#         'deffilepre:k7rvmraw'
#         '#'
#         '# default max number of dated raw files to keep'
#         'maxfiles2keep:10'
#         '#'
#         '# grepsearch with required escapes this string will be'
#         '# inclosed in single quotes in bash'
#         '# for example N6wn\|KG7FOJ\|K7RVM'
#         '#'
#         'searchstring:W9PCI\|K7RVM'
#         '#'
#         '# program inserted diffinitions follow.'
#         '#'
#         '#'
#         '# last line (the next one) must be empty (blank, no chacters)'
#         ''
#         )
#     function makeconfigfile(){
#         printf "%s\n" "initializing config file"
#         read -p 'searchstring: ' sstring 
#         read -p 'default raw prefix: ' defaultrawfileprefix

#         text[6]="deffilepre:$defaultrawfileprefix"
#         text[15]="searchstring:$sstring"

#         echo "$configfile"
#         printf "%s\n" "${text[@]}" > "$configfile" 
#     }
#     [ ! -r $configfile  ] && makeconfigfile
# }


# lala

# echo "configfile = $configfile"
# echo "datadir = $datadir"


# initializeprams


# exit 0


declare -A dict 
#gen_pram_dict "/mnt/m/Python/Python3_packages/orrcmonitor/orrcprams.txt"
gen_pram_dict "/home/dbcurtis/.config/orrccheck.d/orrcprams.txt"


for x in "${!dict[@]}"; do printf "[%s]=>-%s-\n" "$x" "${dict[$x]}"; done 



# function keyexists(){
#     for k in "${!dict[@]}"
#     do 
#         [[ "$1" == "$k" ]] && return 0 || continue
#     done
#     return 1

# }
# #echo '1'
# keyexists 'junk' || echo 'no junk key'
# #echo '2'
# keyexists 'deffilepre'  && echo 'found deffilepre key'

echo "test 7"
exit 0
