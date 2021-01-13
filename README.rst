.. This is the README file for the orrcmonitor Python 3 module.
  From inside a python 3 virtual environment that has spinx installed,
  use "rst2html README.rst readme.html" to convert file to html

####################
ORRCMONITOR Overview
####################

This module is a tool for detecting when the published coordinations for a particular 
coordination holder, contact, or sponser
changes.  It executes on a Linux system using bash and python 3.8 and above.

The problem
___________
The ORRC.org website ("http://www.orrc.org/") publicly provides coordination 
information about repeaters in Oregon.
While the public may read what coordination exist, 
the Holders, and Contacts may make chages that remove an
active coordination from the public list without 
notice to the coordination Holders or Contacts.  

Sometimes there appear to be changes that just happen without 
the coordination holders or contacts knowing about it.

Approach
________

This project:
  
  1) periodically scrapes the ORRC website to extract 
      specific published coordination records

  2) compares the contents of the extracted records 
      with prior records

  3) if a change will send an email to specified addresses

  4) provides a tab delmited file for ** to be **

Programming tool use
--------------------
This project was written using a Windows 10 computer with WSL***.  
Most of the original Python programming and testing 
was done using Visual Studio Code in the Windows envrionment.

The initial bash shell coding and debugging was done using 
Visual Studio Code, and tested on the 14.??? LTS ubuntu installed
in WSL*** 2.  This was my first bash coding project and it shows.

**Not all of this is implemented Yet**

Command line options and parameters
.. code-block::

  [path]/orrccheck.sh -h -l -s -d -x -p -u prefix -c prefix -z prefix

    ===== ============= =================================================
    opt    Argument          Description
    ===== ============= =================================================
    -h                   print this
    -l                   list existing prefixes
    -s                   do not delete any files implies -d
    -d                   do not check for identical adjacent files 
    -x     prefix        create new prefix (no white space)
    -p                   persist this reading
    -u     prefix        use an existing prefix onetime 
    -c     prefix        set prefix as new default prefix
    -z     prefix        delete the prefix file from .config, 
                          and the corrosponding data files
    ===== ============= =================================================

Usage comments: 
----------------

This includes setup and operational comments. 

The first time run should be ``./orrccheck.sh -h`` and the program will print out the help as listed above and automatically
setup the directory heirochy for ``~/.config/orrccheck.d`` and ``~/.local/share/orrccheck.d``. 

The next command is: ``./orrccheck.sh -x prefix`` where 'prefix' 
could be a call sign, or name, but not including whitespace.
You will be prompted for:: 

  1) a regex ``searchstring`` (for example, "n6wn" or "n6wn\|k7rvm" -- the "\|" allows the 
  regex "|" to be used as an or search.

  2) a ``default file prefix?`` which should be the same as the -x prefix. 

  3) a ``max files to keep?``  which limits the number of readings kept for the specified prefix.


The next command ``./orrccheck.sh -c prefix`` will set the just defined prefix as the defalut.
Now, each time you submit a ``./orrccheck.sh`` command, you will get readings for the search regex for
the default prefix.

You can create multiple prefixes and you can invoke a non-defaulted prefix using the ``-u`` option.

Use the ``-l`` switch to list the available prefixes and which is the default.

The progam will by default remove identical readings (except for those marked as persistent using the ``-p`` switch).
And will try to limit the number of saved files to the value specified for the prefix.  

Attempts to remove defaulted files requires user intervention to allow (Need to disable this for automatic operation)

The ``-s`` switch disables deleation of any of the saved files.

The ``-z prefix`` option deletes the prefix (unless it is the default) and deletes the associated data files.




Starting the program
=====================
The program can be manually executed by 
running ``[path]/orrccheck.sh`` from any directory.

The file heirochy is subsequently described.

First Time Configuration
========================
1. run:
      test test test

2. edit:
      test test test

3. aaa

.. code-block:: 

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

6. file structure:
    The configuration directory is ``~/.config/orrccheck.d``.
    It contains a file ``/prefix.txt`` -- for each known prefix.
    It also contains a file ``/lastusedpre.txt`` that contains one 
    line which is the path to the last used prefix.txt file.

    The Data dirctory is ``~/.local/share/orrccheck.d/prefix.d/www.orrc.org/Coordinations/``
    which contains files of the form ``filepreraw_YYYYMMDDHHMMSS.txt`` i.e. 
    ``k7rvmraw_20201209135901.txt``


Testing Sequence
========================
Testing process from the start:
(I have not verified that you have enough information here to do the tests)

#. verify that test_loadprams.py passes.  If it does not, nothing will work.

#. verify that test_resettnc.py passes.  You should hear the relay click.

#. verify that test_myemail passes.  Check that you actually receive some test messages.

#. verify that test_findlogfile.py passes. 

#. verify that test_check4noinit.py passes.


Problems
==========

-up switch/option combo crashs and that is because u takes a parameeter and it aint p.
probably a documentation fix.

Currently puting a junk.txt file in the config direcory.  It is not seen by -l, but it is not 
a pretty solution.  Easy work around of a bug I do not want to take the time to fix right now.

To find persistent readings, do  ``grep -r -n -i --include="*.txt" Persist``.

Need to automatically send an email when the current and last reading differ.






How do I make the html for this ``.rst`` file?
==============================================
run ``makehtml.py``

It will generate the html in the same directory as the ``.rst`` file.
