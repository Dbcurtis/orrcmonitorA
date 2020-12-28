#!/usr/bin/bash

source genpramdic.sh

declare -A dict 
#gen_pram_dict "/mnt/m/Python/Python3_packages/orrcmonitor/orrcprams.txt"
gen_pram_dict "orrcprams.txt"

for x in "${!dict[@]}"
    do printf "[%s]=>-%s-\n" "$x" "${dict[$x]}"
done 
echo "test 7"
exit 0
