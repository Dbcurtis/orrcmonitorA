#!/usr/bin/bash

: '
    resets the orrccheck.sh directory structure
    so after this need to follow the setup instructions
'
cd 
cd .config
ls
rm -r orrccheck.d
ls
cd ../.local/share
ls
rm -r orrccheck.d
ls

