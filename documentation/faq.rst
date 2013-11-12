.. _frequently-asked-questions:


Frequently Asked Questions
=============================

Installation
^^^^^^^^^^^^^^^^^^^^^^^^^

When running `gpi-pipeline` it says, "gpi-pipeline: Command not found"
------------------------------------------------------------------------
This indicates that the pipeline/scripts directory has not been added to the $PATH. There could be several possible reasons for this:
1. The script that sets your environment variables (e.g. setenv_GPI_sample.csh or setenv_GPI_sample.bash) has not been sourced. These are generally sourced from the .tcshrc or .bash_profile scripts located in the home directory. Details can be found :ref:`Here<config-sourcing>`. Remember to open a new terminal after modifying any shell scripts to ensure they are properly loaded.
2. The shell script (e.g. setenv_GPI_sample.csh or setenv_GPI_sample.bash) has an error in the line that modifies the ``$PATH``. Check to make sure the pipeline/scripts directory is properly inserted. The users can check if the directory is in the path by typing `echo $PATH` from a shell prompt. We recommend you copy and paste in the pipeline/scripts output to make sure the directory exists. Remember that paths are case sensitive.


When trying to start the pipeline, I get the error "xterm: Can't execvp idl: No such file or directory"
----------------------------------------------------------------------------------------------------------
This cryptic message means that you are trying to start the gpi-pipeline script without having the idl executable
in your path. Perhaps you have it aliased instead, but that's not detected by the gpi-pipeline starter script. 
You can either (1) change your $PATH to include the directory with idl, (2) put a symlink pointing to idl in some
directory already in your path, or (3) edit your local copy of the gpi-pipeline script to explicitly set the full
path to the idl executable.

Why did the pipeline stop and return to a prompt in the middle of my reduction?
----------------------------------------------------------------------------------
This is most likely an IDL_PATH issue. See 'How do I diagnose an IDL_PATH error?'
 
How do I diagnose an IDL_PATH error?
----------------------------------------------------------
The user should check to make sure that the proper dependency is being called. For example, if the pipeline crashes in a function called APER (which is part of the IDL astrolib library). The user should issue the command:

.. code-block:: idl 

    IDL> which, aper

Doing this will show each aper.pro file that is in the ``$IDL_PATH``, the one that is in the pipeline directory should be the first on the list. If it is not, then the pipeline directory does not have the priority when calling this function. To correct this, ensure that the pipeline directory comes before the other directories in your IDL path by setting the ``$IDL_PATH`` in your setup script (or wherever you set the ``$IDL_PATH variable``) as follows:

For sh/csh/tcsh shells - ``setenv IDL_PATH "+/home/labuser1/GPI/pipeline:${IDL_PATH}"``

For bash shells - ``export IDL_PATH="+/home/labuser1/GPI/pipeline/${IDL_PATH}"``

If the which command is not defined, this means that the pipeline and external directories have not been added to the $IDL_PATH. Verify that the modifications to the $IDL_PATH in the environment variable configuration scripts (e.g. setenv_GPI_sample.csh or setenv_GPI_sample.bash) is correct.


Common pipeline errors
^^^^^^^^^^^^^^^^^^^^^^^^^

Variable is undefined: STR_SEP.
--------------------------------
For users having IDL 8.2+, the str_sep.pro program is now an obsolete command. Although no pipeline source code calls this function, it is still used in other external dependencies. For the time being, users should add the idl/lib/obsolete folder to their $IDL_PATH to remedy this issue. This can be done in the last line of hte configuration scripts (e.g setenv_GPI_custom.csh or setenv_GPI_custom.bash - as discussed :ref:`here <configuring>`)

Mac OSX Time machine issues
--------------------------------
Mac OSX Lion and Mountain Lion users running IDL 8.2 have been known to see the following error:

``2011-07-21 12:12:39.649 idl[11368:1603] This process is attempting to exclude an item from Time Machine by path without administrator privileges. This is not supported.``

Although a nuisance, this error should have no affect on pipeline operation. Possible workarounds exist; details can be found `here <http://www.exelisvis.com/Support/HelpArticlesDetail/TabId/219/ArtMID/900/ArticleID/5251/5251.aspx>`_