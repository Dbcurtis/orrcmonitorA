#!/usr/bin/bash





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

declare -A mypths
#test "$list"
function checkiffirstrun(){
    : '
    test like this
    ((optionprovided)) && nousesaved || usesaved --- if optionprovided is 1 use nousesaved

    ((mypths[firsttime])) && initialize || noinit
    
    '
    testpath="$HOME/.config/orrccheck.d/"
    if [ -d "$testpath" ]; then
        mypths[firsttime]=0
    else
        mypths[firsttime]=1
    fi

}

function printmypth(){
    echo 'in mypaths is '
    for i in "${!mypths[@]}"
    do
        echo "${i} => ${mypths[$i]}"
    done
}

function initialize(){
    echo 'must init'
}
function noinit(){
    echo 'no init'
}
checkiffirstrun
printmypth
((mypths[firsttime])) && initialize || noinit



echo "test 7"
exit 0
