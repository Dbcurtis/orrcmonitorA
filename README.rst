.. This is the README file for the orrcmonitor Python 3 module.
  From inside a python 3 virtual environment that has spinx installed,
  use "rst2html README.rst readme.html" to convert file to html

####################
ORRCMONITOR Overview
####################

This module is a tool for detecting when the published coordinations for a particular coordination holder, contact, or sponser
changes.  It executes on a Linux system using bash and python 3.8 and above.

The problem
___________
The ORRC.org website ("http://www.orrc.org/") publicly provides coordination information about repeaters in Oregon.
While the public may read what coordination exist, the Holders, and Contacts may make chages that remove an
active coordination from the public list without notice to the Holders or Contacts.  

Sometimes there appear to be changes that just happen without the coordination holders or contacts knowing about it.

Approach to the problem
____________________________

This project:
  1) periodically scrapes the ORRC website to extract specific published coordination records
  2) compares the contents of the extracted records with prior records
  3) if a change will send an email to specified addresses
  4) provides a tab delmited file for ** to be **

Programming tool use
--------------------
This project was written using a Windows 10 computer with WSL***.  Most of the original Python programming and testing 
was done using Visual Studio Code in the Windows envrionment.

The initial bash shell coding and debugging was done using Visual Studio Code, and tested on the 14.??? LTS ubuntu installed
in WSL*** 2.  This was my first bash coding project and it shows.

Not all of this is implemented Yet
-----------------------------------

Command line options and parameters::

  [path]/orrccheck.sh -s -d -f:fileprefix -e:fileprefix -n:num -h' 

    ===== ============= =================================================
    opt    Argument          Description
    ===== ============= =================================================
    -h                   show this help message and exit
    -s                   do not delete any files implies -d and ignores -n val
    -d                   do not check for identical adjacent files 
    -f    text           use prefix as a onetime prefix 
    -e    text           use fileprefix this time and set as default Not Yet IMPLEMENTED'
    -n    integer        specify the number of different files to keep and set as default'
    -x    regex          specify search-for regex with \\\\ escape characters eg.: input "n6wn\\\\|ku6y\\\\|wt6k"  -- overrides the config file value
    -r                   recreate the config file Not Yet IMPLEMENTED'
    ===== ============= =================================================


Parameter file
==============



Future version may provide a means for selecting the parameeter file.




Starting the program
====================
The program can be manually executed by running [path]/orrccheck.sh from any directory.
The currently the config file is "~/.config/orrccheck.d/orrcprams.txt" or prefix_orrcpramx.txt.
lastused.txt contains the path of the last used prams file. ****

The data files are stored in ~/.local/share/orrccheck/www.orrc.org/Coordinations/prefix
The data files are named [prefix]_YYYYMMDDHHMMSS.txt where prefix is user selected.

Need to add the prefix directory!!!

The tncmonitor program maintains a log at ``./log/orrccheck``. *check this*  The tncmonitor program runs checks the RMS log file directory every 10 minutes


First Time Configuration
========================
1. run ::

2. edit ::

3. aaa ::

{
    "name": "Python: Current File",
    "type": "python",
    "request": "launch",
    "program": "${file}",
    "args": [ ],
    "justMyCode": false,
    "console": "integratedTerminal"
}

4. create 

5. create 

Testing Sequence
========================
Testing process from the start:
(I have not verified that you have enough information here to do the tests)

#. verify that test_loadprams.py passes.  If it does not, nothing will work.

#. verify that test_resettnc.py passes.  You should hear the relay click.

#. verify that test_myemail passes.  Check that you actually receive some test messages.

#. verify that test_findlogfile.py passes. 

#. verify that test_check4noinit.py passes.




How do I make the html for this file?
=====================================
run makehtml.py

It will generate the html in the same direcotry.
