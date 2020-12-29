#!/usr/bin/bash

# see; http://ahmed.amayem.com/bash-arrays-3-different-methods-for-copying-an-array/
# for info on copying arrays

# Name of the script
SCRIPT=$( basename "$0" )

# Current version
VERSION="1.0.0"

function version
{
    local txt=(
        "$SCRIPT version $VERSION"
    )
    printf "%s\n" "${txt[@]}"
}


function keyexists(){
    #
    # use like keyexists 'junk' || echo 'no junk key'
    # 
    for k in "${!options[@]}"
    do 
        [[ "$1" == "$k" ]] && return 0 || continue
    done
    return 1
}


function showhelp(){
    local text=(
        'command line options and parameters.'
        './orrccheck.sh -s -d -f:fileprefix -e:fileprefix -n:num -h'
        ''
        '-s do not delete any files implies -d and ignores -n val'
        '-d do not check for identical adjacent files '
        '-f use fileprefix as a onetime prefix '
        '-e use fileprefix this time and set as default'
        '-n use num to specify the number of different files to keep and set as default'
        '-x specify search-for regex with \ escape characters'
        '   eg.: "n6wn\|ku6y\|wt6k"  -- overrides the config file'
        '-h print usage'
        ''
    )
    version
    printf "%s\n" "${text[@]}"
}

declare -A options
#options=([marker]="markera")


function saveall(){
    num2save -1
    options+=([saveall]=true)
}

function saveiaf(){
    options+=([saveiaf]=true)
}

function num2save(){
    options+=([num2save]="$1")
}

function onetimeprefix(){
    options+=([onetimeprefix]="$1")
}

function setprefix(){
    echo 'setprefix needs more work'
    options+=([setprefix]="$1")
}

function setextractregex(){
    options+=([regex]="$1")
}

#num2save 10 ## init number to save
if [ $# -gt 0 ];
then
    while getopts "hsdf:e:n:x:" opt; do 
        case $opt in 
            s)
                saveall
                saveiaf
                
            ;;
            d)
                saveiaf 
            ;;
            f)
                onetimeprefix "$OPTARG"
            ;;
            e)
                setprefix "$OPTARG"
            ;;
            n)
                num2save "$OPTARG"
            ;;
            x)
                setextractregex "$OPTARG"
            ;;
            h)
                #works
                showhelp
                exit 1
            ;;
            \?)
                #works
                showhelp
                exit 1
            ;;
        esac
    done
else
    
    echo 'using saved config'

fi

function fixargs(){
    keyexists 'saveall' && num2save -1
}

fixargs
for k in "${!options[@]}"; do echo "$k: ${options[$k]}"; done

rsdatedfiles=() # value is set by reversesortfiles
outfilename=''  # value is set by getdatedfilename

source genpramdic.sh
declare -A dict 
gen_pram_dict "orrcprams.txt"

keyexists 'regex' && dict+=([searchstring]=${options[regex]})
keyexists 'num2save' && dict+=([maxfiles2keep]=${options[num2save]})
keyexists 'onetimeprefix' && dict+=([deffilepre]=${options[onetimeprefix]})

for k in "${!dict[@]}"; do echo "$k: ${dict[$k]}"; done

exit 0

defaultrawfileprefix="${dict['deffilepre']}"

if [ $# -gt 0 ];
then 
    rawfileprefix=$1
else 
    rawfileprefix="$defaultrawfileprefix"
fi 
echo "$rawfileprefix"

printarray(){
    title=$1
    #filarray=rsdatedfiles[@]
    len=${#rsdatedfiles[@]}
    printf "\n##############\n%s\n############\n" "$title "
    for (( i=0; i<len; i++ ));do
        echo "${rsdatedfiles[$i]}"
    done

}


# shellcheck source=/dev/null
source ./bashfunctions.sh

getdatedfilename $rawfileprefix .txt #returns new dated file name in $outfilename
# the dated file name is of the form $rawfileprefix_YYYYMMDDHHMMSS.txt

wget -p http://www.orrc.org/Coordinations/Published
cd www.orrc.org || exit 50
rm -r Scripts bundles Content # do not need data in Scripts, bundles, or Content
cd Coordinations/ || exit 51  # do need data in Coordinations


: '
    look at  /Coordnations/Published, extract all records that contain
    n6wn or kg7foj or k7rvm upper or lower case
    put a first line showing the version of the shell script and add a missin <tr>,
    clean up the records seperating out the <td>...</td> lines
    and making the <tr>...</tr> obvious
    dump to the dated file name from outfilename
'

grep -i 'N6wn\|KG7FOJ\|K7RVM' Published | \
sed 's#</td><td#</td>\n<td#g' | \
sed 's#</tr>#\n</tr>\n<tr>#' | \
sed '1 i v1.0.0<tr>' \
> "$outfilename"

#pwdv=$(pwd)
#out_file_path="$pwdv/$outfilename"    # get the absolute path
#echo "output filepath is $out_file_path"

arg="${rawfileprefix}_"
echo "arg is: $arg"
reversesortfiles "$arg"

if [ "${rsdatedfiles[0]}" = "$outfilename" ] #checking for consistancy
then
    echo "current file is: $outfilename"
    echo "removing Published dir"
    rm Published   # if the most current file is the one we expect, delete Published
    #
    # check if there was a change between the last file and the current file
    #
    if  diff "$outfilename" "${rsdatedfiles[1]}" > /dev/null 
    then
	    echo "removing ${rsdatedfiles[1]}"
	    rm -i "${rsdatedfiles[1]}"   # deleating the older identical file
    fi
else
    echo "something screwy 1"
    echo "outfilename = -$outfilename-"
    aaa="${rsdatedfiles[0]}"
    echo "most recient file is: -$aaa-"
    exit 1
fi

#  for i in "${rsdatedfiles[@]}"; do echo "$i"; done
#  for (( i=0; i<$len; i++ )); do echo "${rsdatedfiles[$i]}"; done

reversesortfiles "$arg"  # do it again as one file may have been deleated
printarray "purging history of changes "


declare -a toB_deleated
toB_deleated=()

for (( i=1; i<len; i++ )); do # find duplicate file contents mark for deletion
    #echo "compare ${rsdatedfiles[$i-1]} and ${rsdatedfiles[$i]}"
    if  diff "${rsdatedfiles[$i-1]}" "${rsdatedfiles[$i]}" > /dev/null 
    then 
        toB_deleated+=("${rsdatedfiles[$i]}")
    fi
done

echo "duplicate files to be deleated"
for f in ${toB_deleated[*]}; do 
    echo "$f"
    rm -i "$f"
done

reversesortfiles "$arg" 
len=${#rsdatedfiles[@]}

printarray "saved files"
if [[ $len -gt 9 ]]; then
    toB_gone=("${rsdatedfiles[@]:10:$len}")

    len=${#toB_gone[@]}
    printf "\n##############\n%s\n############\n" "too many files, deleting:"
    for (( i=0; i<len; i++ ));do
        echo "deleating ${toB_gone[$i]}"
        rm "${toB_gone[$i]}"
    done
fi

unset outfillename
#rm Published
cd ../..
exit 0
