.. _installing-from-zips:

Installing from Software Release Zip Files
=============================================

This section describes how to install the pipeline from Zip files containing
released source code of the pipeline. This is appropriate for anyone who has a
full copy of IDL, but does not immediately intend to contribute to ongoing
pipeline development. 

.. note::
    This method requires you have an IDL license. If you do not have an IDL
    license, please refer to  :ref:`this page <installing-from-compiled>` for 
    installing compiled executables instead.

.. comments
    ## DO NOT EDIT THIS LINE ## Marker for automated editing of this file by gpi_release.py

**Version 0.9.2** (2013 Sept 5):
 * `gpi_pipeline_0.9.2_r1926_source.zip <http://www.stsci.edu/~mperrin/gpi/downloads/gpi_pipeline_0.9.2_r1926_source.zip>`_ -  GPI pipeline source code, including all dependencies


**Version 0.9.1** (2013 July 18):
 * `gpi_pipeline_0.9.1_source.zip <http://www.stsci.edu/~mperrin/gpi/downloads/gpi_pipeline_0.9.1_source.zip>`_ -  GPI pipeline source code, including all dependencies



Unzip this file in a directory that is a part of your ``$IDL_PATH``.

.. admonition:: Mac OS and Linux

    .. image:: icon_mac2.png

    .. image:: icon_linux2.png
  
  On Mac OS and Linux, you will likely want to add the ``pipeline\scripts`` subdirectory
  to your shell's ``$PATH``.




.. warning::
   The usual caveats about name collisions between different versions of IDL routines apply.
   If you have old versions of e.g. the Goddard IDL library functions in your $IDL_PATH, 
   you may encounter difficulties. We suggest placing the data pipeline code first in your $IDL_PATH.
   

Proceed now to :ref:`configuring`.

