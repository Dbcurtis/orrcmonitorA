#!/usr/bin/bash

source genpramdic.sh

declare -A dict 
#gen_pram_dict "/mnt/m/Python/Python3_packages/orrcmonitor/orrcprams.txt"
gen_pram_dict "orrcprams.txt"
dict['deffilepre']='updated'
dict+=(['deffilepre']='updated again')

for x in "${!dict[@]}"; do printf "[%s]=>-%s-\n" "$x" "${dict[$x]}"; done 

bb='N6wn\|KG7FOJ\|K7RVM'
aa=${bb//|/\\|}
echo "$aa"

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
