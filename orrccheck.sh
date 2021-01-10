#!/usr/bin/bash
: 'Copyright (c) 2021 by Daniel B. Curtis
  usage is per the GNU GENERAL PUBLIC LICENSE Version 3
  which has been distributed herewith.
'

# next two commands see: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

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

options+=([debugging]=false)
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

function getdefaultprepath(){
    echo "${mypths[dlastusedconfig]}"
}

function gettopdatadir(){
    echo "${mypths[topdatadir]}"
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
    sets mypths[firsttime] to 0 (false) or 1(true)
    dependent on existance of the .config/orrccheck.d directory

    test like this
    (( mypths[firsttime] )) && firsttime || notfirsttime
    or more correctly like this
    if (( mypths[firsttime] ))
    then
        firsttime
    else
        notfirsttime
    fi
    '
    local testpath="$HOME/.config/orrccheck.d/"
    if [ -d "$testpath" ]; then
        mypths[firsttime]=0  # false
    else
        mypths[firsttime]=1  # true
    fi
}

function setupPaths1(){
    # shellcheck disable=SC2016
    : '
    defines:
        XDG_CONFIG_HOME
        XDG_DATA_HOME

    creates:
        $XDG_CONFIG_HOME/orrccheck.d  --
        $XDG_CONFIG_HOME/orrccheck.d/lastusedpre.txt --empty file
        $XDG_DATA_HOME/orrccheck.d  --topdatadir

    sets mypths:
        topconfigdir
        lastusedpth
        topdatadir
        dlastusedconfig -- initalized with bogus info
    '
    if [ -z ${XDG_CONFIG_HOME+x} ]
    then
        #echo "var is unset"
        XDG_CONFIG_HOME="$HOME/.config"
        export XDG_CONFIG_HOME
    fi
    local topconfigdir
    local lastusedconfigpth
    local lastusedpth
    local topdatadir

    topconfigdir="$XDG_CONFIG_HOME/orrccheck.d"
    mypths["topconfigdir"]=$topconfigdir
    mkdir -p --verbose "$topconfigdir"
    lastusedpth="$topconfigdir/lastusedpre.txt"
    mypths["lastusedpth"]="$lastusedpth"
    if [[ -f "$lastusedpth" ]]
    then
        while read -r line
            do
                [ -z "$line" ] && continue  # ignore leading blank lines
                lastusedconfigpth="${mypths[topconfigdir]}/$line"  # take the first non blank line
                break
            done < "${mypths[lastusedpth]}"
            mypths[dlastusedconfig]="$lastusedconfigpth"
    else
        touch "$lastusedpth"
        mypths[dlastusedconfig]=''
    fi
    [[ -f "$lastusedpth" ]] || touch "$lastusedpth"

    if [ -z ${XDG_DATA_HOME+x} ]
    then
        #echo "var is unset"
        XDG_DATA_HOME="$HOME/.local/share"
        export XDG_DATA_HOME
    fi
    topdatadir="$XDG_DATA_HOME/orrccheck.d"
    mkdir -p --verbose "$topdatadir"
    mypths[topdatadir]="$topdatadir"
    #mypths[dlastusedconfig]='lkjaslkjflasjfljllk'
    #printmypth
}

function setupPaths2(){
    # shellcheck disable=SC2016
    : '
    defines:
        XDG_CONFIG_HOME
        XDG_DATA_HOME

    creates:
        $XDG_CONFIG_HOME/orrccheck.d  --
        $XDG_CONFIG_HOME/orrccheck.d/lastusedpre.txt --empty file
        $XDG_DATA_HOME/orrccheck.d  --topdatadir

    sets mypths:
        dlastusedconfig
    uses mypths:
        topconfigdir
        lastusedpth
    '
    #lastusedpth="${mypths[lastusedpth]}"
    #topdatadir="${mypths[topdatadir]}"
    #topconfigdir="${mypths[topconfigdir]}"
    while read -r line
    do
        [ -z "$line" ] && continue  # ignore leading blank lines
        lastusedconfigpth="${mypths[topconfigdir]}/$line"  # take the first non blank line
        break
    done < "${mypths[lastusedpth]}"
    mypths[dlastusedconfig]="$lastusedconfigpth"
}

function setupPaths(){
    : '
    The configuration directory is ~/.config/orrccheck.d
    it contains a file /prefix.txt --for each prefix
    it also contains /lastusedpre.txt that contains one line which is the prefix.txt name of the last prefix used.

    The Data dirctory is ~/.local/share/orrccheck.d/prefix.d/www.orrc.org/Coordinations/
    which contains files of the form filepreraw_YYYYMMDDHHMMSS.txt i.e. k7rvmraw_20201209135901.txt

    '
    echo 'should not get here'
    setupPaths1
    setupPaths2

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

        configfile="${mypths[topconfigdir]}/$defaultfileprefix.txt"

        echo "check parameter file at: $configfile"   # TOFIX need to update the last used config file
        printf "%s\n" "${configfiletext[@]}" > "$configfile"    # TOFIX and mark this one as --- more complex than this
        echo "$configfile" > "${mypths[topconfigdir]}/lastusedpre.txt"
        mypths[dlastusedconfig]="$configfile"
    }

    [[ ! -r "${mypths[dlastusedconfig]}"  ]] && makeconfigfile

}

function initializePramsFromNothing(){
    setupPaths1
    initializeprams
}

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

function processarguments(){


    function saveall(){
        options+=([saveall]=true)
    }

    function saveiaf(){
        options+=([saveiaf]=true)
    }

    # function num2save(){
    #     echo "-n NOT COMPLETLY IMPLEMENTED"
    #     options+=([num2save]="$1")
    # }

    function createnewprefix(){
        prefix="$1"
        echo '************** -x not yet implemented ***********'
    }

    function useexistingprefix(){
        prefix=$1
        echo '************** -u not yet implemented ***********'
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

    function getprefixInfo(){
        topconfigdir="${mypths[topconfigdir]}"
        if [[ -e "$topconfigdir" && -r "$topconfigdir" && -d "$topconfigdir" ]] 
        then
            getprefixnames  "$topconfigdir" "$1"
        fi
    }

    function listPrefixInfo(){
        local -a prefixs
        local defprefixpth
        local defprefix 
        local cnt
        local idx

        getprefixInfo prefixs # get known prefixs
        cnt=${#prefixs[@]}
        idx=0
        defprefixpth="$(getdefaultprepath)"
        defprefix="$(basename -s .txt $defprefixpth)" # get default prefix
        printf "\n%s\n\n%s\n" "Default prefix is $defprefix" 'Known prefixs are:'
        while [[ idx -lt cnt ]]; do
            for (( i=0; i<4; i++)); do
                printf "%s\t" "${prefixs[$idx]}"
                (( idx=idx+1 ))
                [[ idx -ge cnt ]] && break
            done
            printf "\n"
        done
        printf "\n"
    }

    function locatePrefixInfo(){
        local -a junk
    }

    function removePrefix(){
        local -a prefixlist
        #local -A prefixdir
        getprefixInfo "$prefixlist"
        local cnt=${#prefixlist[@]}
        local toberemoved="$1"
        for prefix in "${prefixlist[@]}"; do
            [[ $toberemoved == "$prefix" ]] && break
        done
        echo "$prefix found"
        locatePrefixInfo "$toberemoved"  
        remove "$prefix"
    }

    function deleteprefix(){
        local prefix2delete
        local -a prefixs
        local defprefixpth
        local defprefix 
        local cnt
        local idx
        local -A pre2Path
        local prefix
        local config2delete
        local datadir2delete
        local target
        local userresponse

        getprefixInfo prefixs # get known prefixs

        prefix2delete="$1"
        defprefixpth="$(getdefaultprepath)"
        defprefix="$(basename -s .txt $defprefixpth)" # get default prefix
        if [[ $defprefix == $prefix2delete ]]; then    # cannot delete default prefix
            printf "\nCannot delete default prefix %s." "$defprefix"
            listPrefixInfo
            exit 0
        fi 

        target="not"
        for prefix in "${prefixs[@]}"; do # try to find requsted prefix in known list
            if [[ "$prefix2delete" == "$prefix" ]]; then
                target=$prefix2delete
                break
            fi
        done
        
        if [[ $target == 'not' ]]; then # not found, print list, end
            echo "Supplied prefix:$prefix2delete not found"
            listPrefixInfo
            exit 0
        fi
        datadir2dlete='not found'
        config2delete='not found'
        config2delete="$( find "$topconfigdir" -maxdepth 1 -type f -regex ".*$target.txt"  )"  
        datadir2dlete="$(gettopdatadir)/$target.d"
        
        if amIdebugging; then    
            echo "$target found"
            echo "config to delete: $config2delete"
            echo "datadir to delete: $datadir2dlete"; fi
        
        function dodelete(){
            # printf "\nDeleting prefix %s at %s\n" "$target" "$config2delete"
            # printf "Deleting prefix %s data at %s\n\n" "$target" "$datadir2dlete"
            rm -v "$config2delete"
            rm -rv "$datadir2dlete"
            echo "done"
        }
        printf "\n\nDo you want to delete?:\n\t%s/* and\n\t%s\n" "$config2delete" "$datadir2dlete"
        printf "If you delete these, there is no backup... Be sure..."
        read -p 'OK to delete these files(Y/N)' userresponse

        if [[ "$userresponse" =~ ^[Yy].* ]]
        then 
            dodelete
            listPrefixInfo
            exit 0
        else
            echo 'Prefix Delete aborted...'
            exit 0
        fi
        exit 0
    }

    function persistthisreading(){
        echo '************* -p not yet implemented ******'
        options+=([persist]=true)
    }

    function usesaved(){
        echo ' use unchanged saved '
    }

    function nousesaved(){
        echo 'use modified saved '
    }

    function showhelp(){
        local text=(
            'command line options and parameters.'
            './orrccheck.sh -h -l -s -d -x -p -u prefix -c prefix -z prefix'
            '-h print this'
            '-l list existing prefixes'
            '-s do not delete any files implies -d'
            '-d do not check for identical adjacent files '
            '-x create new prefix (no white space)'
            '-p persist this reading'
            '-u use an existing prefix onetime '
            '-c set prefix as new default prefix'
            '-z delete the prefix file from .config, and the corrosponding data files'
            ''
        )
        version
        printf "%s\n" "${text[@]}"
    }

    : '
    ###########################
    processarguments starts here
    '

    inputargs=("$1")  # these are the command line arguments
    options+=([modtosaved]=false)
    options+=([changeconfig]=false)
    modtosaved=false # if it remains 0, then use the default 
    changeconfig=false # if it 
    #echo 'start of getopts'
    # shellcheck disable=SC2128
    # shellcheck disable=SC2086
    #./orrccheck.sh -h -l -s -d -x -p -u prefix -c prefix -z prefix
    while getopts "bhsdlxpu:c:z:" opt $inputargs; do
        case $opt in
            b)
                debugging
            ;;
            s)
                # -s do not delete any files implies -d and ignores -n val
                saveall
                saveiaf
                modtosaved=true
            ;;
            d)
                # -d do not check for identical adjacent files 
                saveiaf
            ;;
            l)
                #working
                if amIdebugging; then  
                    printmypth ;fi
                
                listPrefixInfo
                exit 0
            ;;
            c)
                echo '************* -c not yet implemented ******'
            ;;
            u)
                # -f use an existing fileprefix as a onetime prefix 
                useexistingprefix "$OPTARG"
                modtosaved=true
            ;;
            x)
                createnewprefix "$OPTARG"
                changeconfig=true
            ;;
            p)               
                persistthisreading
            ;;
            z)
                if amIdebugging; then    
                    printmypth; fi
                deleteprefix "$OPTARG"
                exit 0
            ;;
            h)
                showhelp
                exit 0
            ;;
            \?)
                showhelp
                exit 1
            ;;
        esac
    done
    #echo 'end of gitops'

    # function fixargs(){
    # #     # to resolve conflicting selected options
    # #     keyexists 'saveall' && num2save -1
    #     echo 'in fixargs'
    # }
    # fixargs

    options[modtosaved]="$modtosaved"
    options[changeconfig]="$changeconfig"

    if amIdebugging
    then    
        printOptions
    fi
    
    if [[ "${options[modtosaved]}" == true ]]
    then
        nousesaved
    else
        usesaved
    fi
    exit

}
: '
##################
Execution starts here
################
'

checkIfFirstRun
if ((mypths[firsttime]))
then
        echo 'first time initialization'
        initializePramsFromNothing
else
        #echo 'setupPaths'
        setupPaths1
fi
# setupPaths
# ((mypths[firsttime])) && initializePramsFromNothing #|| notfirsttime

list=$*
processarguments "$list"

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
keyexists 'persist' && dict+=([persist]=${options[persist]})

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
    it contains a file /prefix.txt --for each defined prefix
    it also contains /lastusedpre.txt that contains one line which is the prefix.txt path to the last prefix used.

    The Data dirctory  is ~/.local/share/orrccheck.d/prefix.d/www.orrc.org/Coordinations/
    which contains files of the form filepreraw_YYYYMMDDHHMMSS.txt i.e. k7rvmraw_20201209135901.txt

    '

# the dated file name is of the form $prefixraw_YYYYMMDDHHMMSS.txt
echo 1
cd "$topdatadir" || exit 48
prefdatadir="$fileprefix.d"
echo 2
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
echo 3
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
