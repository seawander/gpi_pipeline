Appendix: Recipe XML File ('DRF') Format
#####################################################

In normal usage, Recipe XML files are typically created using the GUI, but they
may be edited by hand. We describe here the file format, called a "Data Reduction File (DRF)" in terminology adapted from the Keck OSIRIS pipeline. 

.. note::
        The DRF file format is extremely similar to and descended from, but **not** exactly identical to, 
        the format of Keck OSIRIS DRFs.  The following explanatory text is derived and adapted from 
        from the OSIRIS manual by Larkin et al., with modifications for GPI.

In general, an XML document is a simple ASCII file composed of markup tags. For GPI Recipe files, 
the most common tag is used to specify the operation of a particular primitive such as::

        <primitive Name="Load Wavelength Calibration" CalibrationFile='AUTOMATIC' Skip="0"/>

In this example, the tag is enclosed in a `<` and `/>` to indicate the start and
end of the tag. Alternatively, we could have used a `<` and a `>` around the tag
contents, but then the complete tag would require an additional </primitive> to
specify the end of the tag. This would look like::

        <primitive Name="Load Wavelength Calibration" CalibrationFile='AUTOMATIC' Skip="0"> </module> 

The module is the element start tag and specifies the type of tag, in this case
a module (primitive) call. Then Name , CalibrationFile, and Skip specify 'attributes' of the tag. It is up to
the pipeline to interpret these attributes. In many cases, tags can be nested,
and in fact a DRF is really just one `<DRF>` tag with many sub-tags. Generally
white space such as spaces and carriage returns are ignored.

To add a comment to an xml file surround the text in a `<!--` and a `-->` such as in this example::

        <!--This is a comment -->

Recipe DRF XML tags
=====================
Now we"ll begin looking at DRF specific XML tags. All DRFs must start with a header specifying the flavor of xml to use::
        <?xml version="1.0" encoding="UTF-8"?>

This is then followed by a DRF tag which can include
a Name attribe and/or a ReductionType attribute.  Name provides a descriptive name for use in the Data Parser and Recipe Editor GUIs, but does not have any quantitiative effect on the data processing. Similarly, ReductionType provides a way to divide recipes into different sets for convenience, but does not directly impact the data processing.

So an example DRF tag might look like::
        <DRF ReductionType="regular'>

Note that the `>` does not end the tag and future tags are really attributes within the DRF tag. At the end of the file, you must close the DRF tag with a `</DRF>`. See below for examples.

After the DRF tag, you need to define the data frames that should be processed. This is done with the DATASET tag. It must include series of FITS elements that list the filenames. It *may* include an InputDir attribute, in which case this string will be added before each of the individual filenames. As of GPI DRP 0.9.3, if you wish to include files from multiple directories, this is supported: just enter the full filenames for each and leave the InputDir tag missing or blank. 
Optionally you can outputdir attribute. So 
An example of the DATASET tag might be::

    <dataset InputDir="/mnt/gpi/Detector/130717/" >
	<fits FileName="S20130717S0001.fits" /> 
	<fits FileName="S20130717S0002.fits" /> 
	<fits FileName="S20130717S0003.fits" /> 
	<fits FileName="S20130717S0004.fits" /> 
    </dataset>

The typical DRF is then composed of a series of items specifying the order of the reduction steps as well as any calibration files and parameters that are needed. The name of the module must be specified using the Name attribute. These names are not negotiable and the exact name must be used. Examples::

        <primitive name="Extract Spectral Datacube" Save="0" />?
        <primitive name="Simple SSDI" L1Min="1.55" L1Max="1.57" L2Min="1.60" L2Max="1.65" k="1.0" Save="1" gpitv="5" />


.. note::
        The XML element "module" is taken to be synonymous with "primitive", for back compatibility reasons. There is no difference between these two names in terms of pipeline functionality. The terms will be used interchangeably in the following.


Datasets can also have an associated OutputDir attribute. This can be used to specific a particular directory into which data will be written. 
Optionally instead this can be the string 'AUTOMATIC', in which case the output directory will be chosen automatically as a 
YYMMDD-labeled subdirectory of the $GPI_REDUCED_DATA_DIR.

Common parameters
======================

Each primitive can have an arbitrary list of parameters, just like keywords in IDL. However, due to the required way the XML file is parsed, all attributes must be strings enclosed in quotes. This is true even for simple integer values.

If the step needs a calibration file (i.e., Subtract Dark Frame, Extract Spectra) the attribute will look like::

        CalibrationFile='/directory/SPEC/calib/calibration_file.fits'

If you decide to re-run a DRF and would like to skip a particular module, the easiest way is with the Skip attribute. Set it to �1" in order to skip the file, and set it back to �0" to execute the file. The default is �0" and is not required. ::

        Skip="1"

Many modules allow the output data to be piped to a GPItv window for immediate display. Just set the gpitv argument equal to the session number of the window to display in. ::

        gpitv="3"

Others allow the user to save the results of this step (distinct from saving the final output at the end of the whole list of steps) ::

        save="1"

Other attributes are specific to each module or used by a subset of modules and are described elsewhere. 

Example DRF 
=============
:: 

  <?xml version="1.0" encoding="UTF-8"?>
  <DRF LogPath="/Users/mperrin/projects/GPI/pipnew/drp_code" ReductionType="Final">
  <dataset InputDir="/Users/mperrin/projects/GPI/data" OutputDir="/Users/mperrin/projects/GPI/pipnew/drp_code">
   <fits FileName="Ima10_H.fits" />
   <fits FileName="Ima11_H.fits" />
   <fits FileName="Ima12_H.fits" />
   <fits FileName="Ima13_H.fits" />
   <fits FileName="Ima14_H.fits" />
   <fits FileName="Ima15_H.fits" />
   <fits FileName="Ima16_H.fits" />
   <fits FileName="Ima17_H.fits" />
   <fits FileName="Ima18_H.fits" />
  </dataset>
  <primitive name="Read Wavelength Calibration" CalibrationFile="/Users/mperrin/GPI/pipnew/drp_code/Ima2_HH-wavcal-comb.fits" />
  <primitive name="Display Data with GPITV" gpitv="1" />
  <primitive name="Extract Spectral Datacube" Save="0" />
  <primitive name="Divide spectral data by flat" CalibrationFile="/Users/mperrin/projects/GPI/pipnew/drp_code/Ima4_Hflat.fits" Save="1" gpitv="2" />
  <primitive name="Interpolate Wavelength Axis" Save="1" gpitv="2" />
  <primitive name="Simple SSDI" L1Min="1.55" L1Max="1.57" L2Min="1.60" L2Max="1.65" k="1.0" Save="1" gpitv="5" />
  <primitive name="Accumulate Images" Method="OnDisk" />
  <primitive name="ADI based on Marois et al" numimmed="3" nfwhm="1.5" Save="0" gpitv="10" />
  <primitive name="Median ADI data-cubes" Save="1" gpitv="10" />
  </DRF>


