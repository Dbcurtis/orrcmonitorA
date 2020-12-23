.. This is the README file for the orrcmonitor Python 3 module.
  From inside a python 3 virtual environment that has spinx installed,
  use "rst2html README.rst readme.html" to convert file to html

####################
ORRCMONITOR Overview
####################

This module is a tool for detecting when the published coordinations for a particular coordination holder, contact, or sponser
changes.  It executes on a Linux system using python 3.8 and above.

The problem
___________
The ORRC.org website ("http://www.orrc.org/") publicly provides coordination information about repeaters in Oregon.
While the public may read what coordination exist, the Holders, and Contacts may make chages that remove an
active coordination from the public list without notice to the Holders or Contacts.  

There appear to be changes that just happen without the holders knowing about it.

This approach to the problem
____________________________

This project:
  1) periodically scrapes the ORRC website to extract specific published coordination records
  2) compares the contents of the extracted records with prior records
  3) if a change will send an email to specified addresses


THE FOLLOWING IS JUNK AND WILL BE CHANGED WHEN THE PROGRAM IS COMPLETE
-----------------------------------------------------------------------------
  
Python version
---------------
I have tested this on windows 10 using python version 3.8.0 using a virtual environment.
I do not expect it to work using Python 2 or Python 3 prior to 3.7. It "could" work on 3.7, but I have not tried it.
 

Usage to Monitor the TNC Error Logs
======================================
Invoke the program in accordance with::
  usage: ``tncmonitor.py [-h] [-li] [-ld] [-eo] [-ese] [-t] pramfile``

  Required argument :
    ``pramfile``
          where ``pramfile`` is a Parameter file that is a subsequently described ``.yaml`` file.

  Optional arguments : 
    ===== ============= =================================================
    opt    lopt          Description
    ===== ============= =================================================
    -h    --help         show this help message and exit
    -li   --loginfo      enable INFO logging
    -ld   --logdebug     enable DEBUG logging
    -eo   --emailonly    do not unpower the tnc just send email
    -ese  --emstartend   send email when program starts and when it ends
    -t    --testing      use testing data from the ./tests/testLogData dir
    ===== ============= =================================================


Parameter file
==============
The parameters are described in the file ``prototypetncprams.yaml``.  This file should be copied ``tncprams.yaml`` and the values provided.

Additional Parameters are added to the dict created by the above file by the program.
These include:

* *emailonly* -- boolean, if True does the email operations without trying to reset the relay
* *testing*  -- boolean, if True, then do not use the "rmslogdir" as the source to the rms logger data (doesn't do anything)

In addition, if a value includes ``--comment--``, that key and value will removed when the file is processed.
Not removed from the file, but no corrsponding dict value will be passed to the program.

Starting the program
====================
The program can be manually executed by running ``python -m tncmonitor tncprams.json`` in the tncmonitor directory.
The tncmonitor program maintains a log at ``./log/tncMonitor``.  The tncmonitor program runs checks the RMS log file directory every 10 minutes
and responds to the communication error as previously specified.

Generally, the program should be executed out of the distribution directory when the computer is restarted, or at least at the same time RMS is stvarted.

First Time Configuration
========================
1. run tncmonitor with a command line. For windows: ``python -m tncmonitor -h``. 
For linux: ``python3 -m tncmonitor -h``.
Both executed in the tncmonitor directory.
This verifies that the help switch works 
as it and the starting message should be the only output.

2. edit test_resettnc.py and enter your values for the relay
module id and relay number in the ``argdic`` Dict for ``test_01instant``
because the test program does not use the .yaml configuration file.

3. run the test, you should hear the relay clicking.  I had to run the test from visual studio code, 
using launch.json of::

  {
    "name": "Python: Current File",
    "type": "python",
    "request": "launch",
    "program": "${file}",
    "args": [ ],
    "justMyCode": false,
    "console": "integratedTerminal"
  }

4. create a ``testtncprams.yaml`` file based off of ``prototypetncprams.yaml`` 
and in the same directory with the currect ``SMTPServer`` information including the 
account and password as well as  valid email addresses in the ``fromemail`` 
and ``toemail`` fields.  In addition, 
``rmslogdir`` pointing to a drectory with captured log data for testing (For
example, data files in the tncmonitor/test/testLogData distribution dirctory).

5. create a ``tncprams.yaml`` based off of ``testtncprams.yaml`` with real email addresses
and ``rmslogdir`` being an absolute path to the actual RMS log directory.

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
