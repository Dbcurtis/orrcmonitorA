#!/usr/bin/bash

set -euo pipefail
IFS=$'\n\t'



# function test(){
#     #aa='-h  -b bbb -c'
#     aa=("$1")
#     #echo "--${#}--" did not work
    
#     while getopts "hb:c" opt $aa; do
#         case $opt in
#             h)
#                 echo 'saw h'
#             ;;
#             b)
#                 echo 'saw b'
#                 echo "--$OPTARG--"
#             ;;
#             c)
#                 echo 'saw c'
#             ;;
#             *)
#                 echo 'badflag'
#             ;;
#         esac
#     done
# }
 
# list=$@
# # echo $list
# # arr=("${list[@]}")
# # for i in $arr; do echo "$i"; done

# istrue=true

#declare -A mypths
#test "$list"
# function checkiffirstrun(){
#     : '
#     test like this
#     ((optionprovided)) && nousesaved || usesaved --- if optionprovided is 1 use nousesaved

#     ((mypths[firsttime])) && initialize || noinit
    
#     '
#     testpath="$HOME/.config/orrccheck.d/"
#     if [ -d "$testpath" ]; then
#         mypths[firsttime]=0
#     else
#         mypths[firsttime]=1
#     fi
# }

# function printmypth(){
#     echo 'in mypaths is '
#     for i in "${!mypths[@]}"
#     do
#         echo "${i} => ${mypths[$i]}"
#     done
# }

# function initialize(){
#     echo 'must init'
# }
# function noinit(){
#     echo 'no init'
# }
# checkiffirstrun
# printmypth
# ((mypths[firsttime])) && initialize || noinit

function getprefixnames(){
    local topconfigdir
    local __resultvar
    local filesa
    local -a files
    local result
    local -a arr
    local -a arr_s
    local -A __prefix2path

    topconfigdir="$1"
    __resultvar="$2"
    

    filesa="$( find "$topconfigdir" -maxdepth 1 -type f -iregex ".*[.]txt"  )"
    for f in $filesa; do 
        [[ "$f" != *"lastusedpre"* ]] && files+=("$f"); done
    
    # #declare -A prefix2path
    # if [[ $# -ge 3 ]]; then
    #     __prefix2path=$3   
    #     if [[ "$__resultvar" ]]; then
    #         for f in "${files[@]}"; do
    #             name=$(basename -s .txt $f)
    #             __prefix2path[$name]=$f
    #         done
    #     fi
    # fi
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
echo start
declare -a tarr
getprefixnames  "$HOME/.config/orrccheck.d" tarr
echo ${tarr[*]}
echo end1
# declare -A dict
# getprefixnames  "$HOME/.config/orrccheck.d" tarr dict
# for key in "${tarr[@]}"; do 
#     echo "$key"
#     echo "$dict[$key]"
# done


exit 

# if [[ -e "$topconfigdir" && -r "$topconfigdir" && -d "$topconfigdir" ]] 
# then
   
#     jj="$( find "$topconfigdir" -maxdepth 1 -type f -iregex ".*[.]txt" )"
#     dd=$(echo "$jj")
    
#     kk="$( basename -as .txt "$dd" )"
#     declare -a ll 
#     echo 1
#     for l in "${kk[@]}"; do
#         #echo "$l"
#         #[[ "$l" =~ w9pci ]] || echo "$l"
#         if [[ "$l" == 'n6wn' ]]
#         then
#             echo "$l"
#         fi
#     done
#     echo 2
#     # for l in "${kk[@]}"; do
#     #     test="$l"
#     #     echo "$test"
#     #     if [[ "$test" =~ . ]];then
#     #         echo match
#     #         continue
#     #     else
#     #         #[[ "$test" =~ lastusedpre ]] && continue
#     #         ll+=("$test")
#     #     fi
#     #done
#     echo "${ll[@]}"
#     echo 3

    
#     : '
    
#     for i in ${!HOSTNAMES[@]}; do
# 	host="${HOSTNAMES[i]}"
# 	[ "$host" == "$HOSTNAME" ] && continue
# 	ping $host 1 &> /dev/null || unset HOSTNAME[i]
# done
#     '

# else
#     echo "$topconfigdir not found"
#     exit 1
# fi

# #aa=basename -a "${files[*]}"


# # for l in "${files[@]}"; do
    
# #     jj="$(basename $l)"
# #     echo "$l"
# #     echo "$jj"
# #     echo "tick"
# # done

exit 0
