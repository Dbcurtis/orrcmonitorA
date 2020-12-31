#!/usr/bin/bash

# see; http://ahmed.amayem.com/bash-arrays-3-different-methods-for-copying-an-array/
# for info on copying arrays
export datadir

function setupPaths(){
    if [ -z ${XDG_CONFIG_HOME+x} ]
    then 
        #echo "var is unset"
        XDG_CONFIG_HOME="$HOME/.config"
        export XDG_CONFIG_HOME
    fi
    local pth="$XDG_CONFIG_HOME/orrccheck.d"
    mkdir -p --verbose $pth
    configdir=$pth
    configfile="$pth/orrcprams.txt"

    if [ -z ${XDG_DATA_HOME+x} ]
    then 
        #echo "var is unset"
        XDG_DATA_HOME="$HOME/.local/share"
        export XDG_CONFIG_HOME
    fi
    pth="$XDG_DATA_HOME/orrccheck"
    mkdir -p --verbose $pth
    datadir=$pth

}

function initializeprams(){
    local text=(
        '#'
        '# this is a comment'
        '# blank lines are not allowed, but the last line must be empty'
        '# values must not contain [[:blank:]] charaters (well they are removed)'
        '#'
        '# default raw prefix'
        'deffilepre:k7rvmraw'
        '#'
        '# default max number of dated raw files to keep'
        'maxfiles2keep:10'
        '#'
        '# grepsearch with required escapes this string will be'
        '# inclosed in single quotes in bash'
        '# for example N6wn\|KG7FOJ\|K7RVM'
        '#'
        'searchstring:W9PCI\|K7RVM'
        '#'
        '# program inserted diffinitions follow.'
        '#'
        '#'
        '# last line (the next one) must be empty (blank, no chacters)'
        ''
        )
    function makeconfigfile(){
        printf "%s\n" "initializing config file"
        read -p 'searchstring? ' sstring 
        read -p 'default raw prefix? ' defaultrawfileprefix
        read -p 'max files to keep? ' maxfiles

        text[6]="deffilepre:$defaultrawfileprefix"
        text[9]="maxfiles2keep:$maxfiles"
        text[15]="searchstring:$sstring"

        echo "check parameter file at: $configfile"
        printf "%s\n" "${text[@]}" > "$configfile" 
    }
    [ ! -r $configfile  ] && makeconfigfile
}


setupPaths # setup std XDG paths
initializeprams

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
        '-e use fileprefix this time and set as default Not Yet IMPLEMENTED'
        '-n use num to specify the number of different files to keep and set as default'
        '-x specify search-for regex with \\ escape characters'
        '   eg.: input "n6wn\\|ku6y\\|wt6k"  -- overrides the config file'
        '-r recreate the config file Not Yet IMPLEMENTED'
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
    echo "-n NOT COMPLETLY IMPLEMENTED"
    options+=([num2save]="$1")
}

function onetimeprefix(){
    options+=([onetimeprefix]="$1")
}

function resetconfigfile(){
    echo '-r Not Yet IMPLEMENTED' 
}


function setprefix(){
    echo '-e Not Yet IMPLEMENTED'
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
            r)
                resetconfigfile "$OPTARG"
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
#echo "$configfile"
gen_pram_dict "$configfile"

keyexists 'regex' && dict+=([searchstring]=${options[regex]})
keyexists 'num2save' && dict+=([maxfiles2keep]=${options[num2save]})
keyexists 'onetimeprefix' && dict+=([deffilepre]=${options[onetimeprefix]})

#for k in "${!dict[@]}"; do echo "$k: ${dict[$k]}"; done

rawfileprefix="${dict['deffilepre']}"



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
cd $datadir || exit 49
wget -p http://www.orrc.org/Coordinations/Published
cd www.orrc.org || exit 50
rm -r Scripts bundles Content # do not need data in Scripts, bundles, or Content
cd Coordinations/ || exit 51  # do need data in Coordinations



: '
    look at  /Coordnations/Published, extract all records that contain
    n6wn or kg7foj or k7rvm upper or lower case
    put a first line showing the version of the shell script and add a missing <tr>,
    clean up the records seperating out the <td>...</td> lines
    and making the <tr>...</tr> obvious
    dump to the dated file name from outfilename
'

grep -i "${dict['searchstring']}" Published | \
sed 's#</td><td#</td>\n<td#g' | \
sed 's#</tr>#\n</tr>\n<tr>#' | \
sed '1 i v1.0.0<tr>' \
> "$outfilename"

arg="${rawfileprefix}_"
echo "arg is: $arg"
reversesortfiles "$arg"

#for i in "${rsdatedfiles[@]}"; do echo "$i"; done


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
len=${#rsdatedfiles[@]}

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
for f in ${toB_deleated[@]}; do 
    echo "$f"
    rm "$f"
done

reversesortfiles "$arg" 
len=${#rsdatedfiles[@]}

max="${dict[maxfiles2keep]}"
printarray "saved files"
if [[ $len -ge $max ]]; then
    toB_gone=("${rsdatedfiles[@]:$max:$len}")

    len=${#toB_gone[@]}
    printf "\n##############\n%s\n############\n" "too many files, deleting:"
    for (( i=0; i<len; i++ ));do
        echo "deleating ${toB_gone[$i]}"
        rm "${toB_gone[$i]}"
    done
fi

unset outfillename
#rm Published
#cd ../..
exit 0
