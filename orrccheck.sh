#!/usr/bin/bash

# TODO not sure I need to export these
export  outfilename
export  rsdatedfiles
# shellcheck source=/dev/null
source ~/bashfunctions.sh
rawfileprefix='k7rvmraw'

getdatedfilename $rawfileprefix .txt #returns file name in $outfilename

wget -p http://www.orrc.org/Coordinations/Published
cd www.orrc.org || exit 50
rm -r Scripts bundles Content  # do not need data in here
cd Coordinations/ || exit 51  # do need data in Coordinations
pwdv=$(pwd)
#
# look at  /Coordnations/Published, extract all records that contain
# n6wn or kg7foj or k7rvm upper or lower case
# dump to the dated file name from outfilename
#
grep -i 'N6wn\|KG7FOJ\|K7RVM' Published > "$outfilename"
out_file_path="$pwdv/$outfilename"    # get the absolute pate

echo "output filepath is $out_file_path"

#files=(k7rvmraw_*.txt) #  files is an array(?) of matching files
##
##IFS set to recognize new lines
## sorted is an array of the file names reverse sorted
## is IFS is set back to default (I hope)
##
#IFS=$'\n' sorted=($(sort -r <<<"${files[*]}")); unset IFS;

reversesortfiles 'k7rvmraw_'

if [ "${rsdatedfiles[0]}" = "$outfilename" ]
then
    echo "$outfilename" 
    rm Published   # if the most current file is the one we expect, delete Published
    len=${#rsdatedfiles[@]}
    #
    # check if there was a change between the last file and the current file
    #

    local temp=$(diff -s "$outfilename" "${rsdatedfiles[1]}")
    sub='are identical'
    if [[ "$temp" == *"$sub"* ]]
    then
	echo "removing ${rsdatedfiles[1]}"
	rm -i "${rsdatedfiles[1]}"   # the -i requires user to agree to delete
    fi
else
    echo "something screwy 1"
    exit 1

fi
reverseortfiles 'k7rvmraw_'




    for (( i=2; i<len+1; i++ ));  # copied from an example, I would have used i=1; i<len; i++
    do
	echo "${sorted[$i-1]}"
	temp=$(diff -s "$outfilename" "${sorted[$i-1]}")
	sub='are identical'
	if [[ "$temp" == *"$sub"* ]]
	then
		echo "removing ${sorted[$i-1]}"
		rm -i "${sorted[$i-1]}"   # the -i requires user to agree to delete
		break
	fi
	
    done

    echo "removed current duplictes"


    files=(k7rvmraw_*.txt)
    IFS=$'\n' sorted=($(sort -r <<<"${files[*]}")); unset IFS;
    len=${#sorted[@]}
#    for j in "${sorted[@]}"; do echo "$j"; done
#    echo "sorted len is $len"
    if [ "$len" -gt 10 ]
    then
	#delete files from 9 to end
	for (( i=9; i<len+1; i++ ));
	do
#		echo "i is $i"
#		echo "removeing ${sorted[$i-1]}"
		rm -i "${sorted[$i-1]}"
	done
    fi
else
    echo "unexpected condition"
    exit 53
fi

unset outfillename
#rm Published
cd ../..
exit 0

