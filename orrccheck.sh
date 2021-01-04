#!/usr/bin/bash

# see; http://ahmed.amayem.com/bash-arrays-3-different-methods-for-copying-an-array/
# for info on copying arrays
export topdatadir #why exporting this and mypths?
export mypths
# shellcheck source=/dev/null
source genpramdic.sh
# shellcheck source=/dev/null
source bashfunctions.sh

declare -A mypths  # information about path and if this is the first execution
declare -A options # information about command line options
declare -A dict   # information used when processing
rsdatedfiles=() # value is set by reversesortfiles
outfilename=''  # value is set by getdatedfilename

# Name of the script
SCRIPT=$( basename "$0" )

# Current version
VERSION="1.0.0B1"

function version(){
    local txt=(
        "$SCRIPT version $VERSION"
    )
    printf "%s\n" "${txt[@]}"
}

function printdatedfiles(){
    title=$1
    len=${#rsdatedfiles[@]}
    printf "\n##############\n%s\n############\n" "$title "
    for (( i=0; i<len; i++ ));do
        echo "${rsdatedfiles[$i]}"
    done
}

function printOptions(){
    echo 'in options is:'
    local i
    for i in "${!options[@]}"
    do
        printf "\t%s\n" "${i} => ${options[$i]}"
        #do echo "$k: ${options[$k]}"
    done
}

function printdict(){
    echo 'in dict is '
    local i
    for i in "${!dict[@]}"
    do
        printf "\t%s\n" "${i} => ${dict[$i]}"
    done
    echo ""
}

function printmypth(){
    echo 'in mypaths is '
    local i
    for i in "${!mypths[@]}"
    do
        printf "\t%s\n" "${i} => ${mypths[$i]}"
    done
    echo ""
}

function keyexists(){
    #
    # use like keyexists 'junk' || echo 'no junk key'
    # 
    for k in "${!options[@]}"
    do 
        [[ "$1" == "$k" ]] && return 0 
    done
    return 1
}

function checkIfFirstRun(){
    : '
    test like this
    ((mypths[firsttime])) && firsttime || notfirsttime 
    '
    local testpath="$HOME/.config/orrccheck.d/"
    if [ -d "$testpath" ]; then
        mypths[firsttime]=0  # false
    else
        mypths[firsttime]=1  # true
    fi
}

function setupPaths(){
    : '
    The configuration directory is ~/.config/orrccheck.d
    it contains a file /filepre.txt --for each default prefix
    it also contains /lastusedpre.txt that contains one line which is the filepre.txt name of the last one used.

    The Data dirctory  is ~/.local/share/orrccheck.d/filepre.d/www.orrc.org/Coordinations/
    which contains files of the form filepreraw_YYYYMMDDHHMMSS.txt i.e. k7rvmraw_20201209135901.txt
    
    '

    if [ -z ${XDG_CONFIG_HOME+x} ]
    then 
        #echo "var is unset"
        XDG_CONFIG_HOME="$HOME/.config"
        export XDG_CONFIG_HOME
    fi
    local pth="$XDG_CONFIG_HOME/orrccheck.d"
    mkdir -p --verbose "$pth"
    configdir="$pth"
    lastusedpth="$configdir/lastusedpre.txt"

    #echo "lup -> $lastusedpth"
    #printmypth

    mypths["lastusedpth"]="$lastusedpth"
    # printmypth
    # echo 1

    [[ -f "$lastusedpth" ]] || touch "$lastusedpth"
    while read -r line
    do
        [ -z "$line" ] && continue  # ignore leading blank lines
        lastusedconfigpth="$pth/$line"  # take the first non blank line
        break

    done < "$lastusedpth"

    #echo "lucp -> $lastusedconfigpth"

    mypths[dlastusedconfig]="$lastusedconfigpth"  # if empty, then the config needs to be built
    # printmypth
    # echo 2


    if [ -z ${XDG_DATA_HOME+x} ]
    then 
        #echo "var is unset"
        XDG_DATA_HOME="$HOME/.local/share"
        export XDG_CONFIG_HOME
    fi
    pth="$XDG_DATA_HOME/orrccheck.d"
    mkdir -p --verbose "$pth"
    topdatadir="$pth"
    mypths[topdatadir]="$pth"
    #printmypth

}

function initializeprams(){
    : '
    Used to create the initial bla bla alb alb
    '
    local configfiletext=(
        '#'
        '# this is a comment'
        '# blank lines are not allowed, but the last line must be empty'
        '# values must not contain [[:blank:]] charaters (well they are removed)'
        '#'
        '# default prefix - the data files are named prefixraw_YYYYMMDDHHMMSS.txt'
        'deffilepre:k7rvm'
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
        read -r -p 'searchstring? ' sstring 
        read -r -p 'default file prefix? ' defaultfileprefix
        read -r -p 'max files to keep? ' maxfiles

        configfiletext[6]="deffilepre:$defaultfileprefix"
        configfiletext[9]="maxfiles2keep:$maxfiles"
        configfiletext[15]="searchstring:$sstring"

        echo "check parameter file at: $configfile"   # TOFIX need to update the last used config file 
        printf "%s\n" "${configfiletext[@]}" > "$configfile"    # TOFIX and mark this one as --- more complex than this
    }
    [ ! -r "${mypths[dlastusedconfig]}"  ] && makeconfigfile
}

function initializePramsFromNothing(){
    echo 'first time initialization'
    setupPaths
    initializeprams
}


function processarguments(){

    function showhelp(){
        local text=(
            'command line options and parameters.'
            './orrccheck.sh -s -d -f fileprefix -e fileprefix -n num -h'
            ''
            '-s do not delete any files implies -d and ignores -n val'
            '-d do not check for identical adjacent files '
            '-f use fileprefix as a onetime prefix '
            '-e use fileprefix this time and set as default Not Yet IMPLEMENTED'
            '-n use num to specify the number of different files to keep and set as default'
            '-x specify search-for regex with \\ escape characters'
            '   eg.: input "n6wn\\|ku6y\\|wt6k"  -- overrides the config file'
            '-r recreate the config file Not Yet IMPLEMENTED'
            '-h print this'
            ''
        )
        version
        printf "%s\n" "${text[@]}"
    }

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

    function debugging(){
        echo "hidden debugging command activated"
        options+=([debugging]='yes')
    }

    function setextractregex(){
        options+=([regex]="$1")
    }

    function usesaved(){
        echo ' use unchanged saved ' 

    }

    function nousesaved(){
        echo 'use modified saved ' 
    }

    : '
    processarguments starts here
    '
    inputargs=("$1")  # these are the command line arguments
    optionprovided=0 # if it remains 0, then use the default if it exists
    while getopts "bhsdf:e:n:x:r:" opt $inputargs; do 
        case $opt in 
            b)
                debugging
            ;;
            s)
                saveall
                saveiaf
                optionprovided=1
            ;;
            d)
                saveiaf 
                optionprovided=1
            ;;
            f)
                onetimeprefix "$OPTARG"
                optionprovided=1
            ;;
            e)
                setprefix "$OPTARG"
                optionprovided=1
            ;;
            n)
                num2save "$OPTARG"
                optionprovided=1
            ;;
            x)
                setextractregex "$OPTARG"
                optionprovided=1
            ;;
            r)
                resetconfigfile "$OPTARG"
                optionprovided=1
            ;;
            h)
                showhelp
                exit 1
            ;;
            \?)
                showhelp
                exit 1
            ;;
        esac
    done
    ((optionprovided)) && nousesaved || usesaved
    
    function fixargs(){
        # to resolve conflicting selected options
        keyexists 'saveall' && num2save -1
    }
    fixargs

}
: '
##################
Execution starts here
################
'
checkIfFirstRun
setupPaths
((mypths[firsttime])) && initializePramsFromNothing #|| notfirsttime 

list=$@
processarguments "$list"
initializeprams

function amIdebugging(){
    : '
    if amIdebugging; then
        echo "I am debugging"
    else
        echo "I am NOT debugging"
    fi
    '
    local db="${options[debugging]}"
    if [[ "$db" == 'yes' ]]; then
        return 0
    else
        return 1
    fi
}


if amIdebugging; then
    printOptions
    printmypth
fi

configfile="${mypths[dlastusedconfig]}"
gen_pram_dict "$configfile"
if amIdebugging; then
    printdict
fi

function canIdeletefiles(){
    : '
    if canIdeletefiles; then
        echo "yes you can"
    else
        echo "no you cannot"
    fi
    '
    local maxfile="${dict['maxfiles2keep']}"
    #echo "$maxfile"
    if [[ "$maxfile" == -1 ]]; then
        #echo "keep all files"
        return 1
    else
        #echo "allow files to be deleated"
        return 0
    fi
}

# modify dict values based on options
keyexists 'regex' && dict+=([searchstring]=${options[regex]})
keyexists 'num2save' && dict+=([maxfiles2keep]=${options[num2save]})
keyexists 'onetimeprefix' && dict+=([deffilepre]=${options[onetimeprefix]})

if amIdebugging; then
    printdict
fi

fileprefix="${dict['deffilepre']}"
getdatedfilename "$fileprefix" .txt #returns new dated file name in $outfilename
topdatadir="${mypths[topdatadir]}"

if amIdebugging; then
    echo "$outfilename"
    echo "$topdatadir"
fi

    : '
    The configuration directory is ~/.config/orrccheck.d
    it contains a file /filepre.txt --for each default prefix
    it also contains /lastusedpre.txt that contains one line which is the filepre.txt name of the last one used.

    The Data dirctory  is ~/.local/share/orrccheck.d/filepre.d/www.orrc.org/Coordinations/
    which contains files of the form filepreraw_YYYYMMDDHHMMSS.txt i.e. k7rvmraw_20201209135901.txt
    
    '

# the dated file name is of the form $fileprefixraw_YYYYMMDDHHMMSS.txt
cd "$topdatadir" || exit 48
prefdatadir="$fileprefix.d"
cd "$prefdatadir" || exit 50

wget -p http://www.orrc.org/Coordinations/Published
cd www.orrc.org || exit 55
rm -r Scripts bundles Content # do not need data in Scripts, bundles, or Content
cd Coordinations/ || exit 60  # do need data in Coordinations

: '
    look at  /Coordnations/Published, extract all records that match
    the user specified regex, upper or lower case
    put a first line showing the version of the shell script and add a missing <tr>,
    clean up the records seperating out the <td>...</td> lines
    and making the <tr>...</tr> obvious
    dump to the dated file name from outfilename
'

grep -i "${dict['searchstring']}" Published | \
sed 's#</td><td#</td>\n<td#g' | \
sed 's#</tr>#\n</tr>\n<tr>#' | \
sed '1 i v1.0.1<tr>' \
> "$outfilename"

echo "new outfile is: $outfilename"

arg="${fileprefix}raw_"
reversesortfiles "$arg"
if amIdebugging; then
    printdatedfiles "dated files for $fileprefix "
fi

if [ "${rsdatedfiles[0]}" = "$outfilename" ] #checking for consistancy
then
    if amIdebugging; then
        echo "current file is: $outfilename"
        echo "removing Published dir"
    fi    
    rm Published   # if the most current file is the one we expect, delete Published
    #
    # check if there was a change between the last file and the current file
    #
    if  diff "$outfilename" "${rsdatedfiles[1]}" > /dev/null 
    then
        if canIdeletefiles; then          
            echo "removing older identical file ${rsdatedfiles[1]}"
            rm -i "${rsdatedfiles[1]}"   # deleating the older identical file
        fi
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

if canIdeletefiles; then          
    printdatedfiles "purging adjacent duplicates from history of changes "
    len=${#rsdatedfiles[@]}
    declare -a toB_deleated
    toB_deleated=()

    for (( i=1; i<len; i++ )); do # find duplicate file contents mark for deletion
        if  diff "${rsdatedfiles[$i-1]}" "${rsdatedfiles[$i]}" > /dev/null 
        then 
            toB_deleated+=("${rsdatedfiles[$i]}")
        fi 
    done

    printf "\n##############\n%s\n############\n" "adjacent duplicates to be deleated"
    for f in "${toB_deleated[@]}"; do echo "$f" ;done

    printf "\n##############\n%s\n############\n" "deleating adjacent duplicate files"
    for f in "${toB_deleated[@]}"; do rm -i "$f" ;done
fi

reversesortfiles "$arg" 
len=${#rsdatedfiles[@]}
if canIdeletefiles; then 
    max="${dict[maxfiles2keep]}"
    printdatedfiles "saved files"
    if [[ $len -ge $max ]]; then
        toB_gone=("${rsdatedfiles[@]:$max:$len}")
        len=${#toB_gone[@]}
        printf "\n##############\n%s\n############\n" "too many files, deleting these:"
        for (( i=0; i<len; i++ ));do
            echo "deleating ${toB_gone[$i]}"
            rm -i "${toB_gone[$i]}"
        done
    fi
fi

exit 0
