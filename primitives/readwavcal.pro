;+
; NAME: readwavcal
; PIPELINE PRIMITIVE DESCRIPTION: Load Wavelength Calibration
;
; 	Reads a wavelength calibration file from disk.
; 	The wavelength calibration is stored using pointers into the common block.
;
; KEYWORDS: DATE-OBS,TIME-OBS,FILTER,DISPERSR
; INPUTS:	CalibrationFile=	Filename of the desired wavelength calibration file to
; 						be read
; OUTPUTS: none
;
; PIPELINE COMMENT: Reads a wavelength calibration file from disk. This primitive is required for any data-cube extraction.
; PIPELINE ARGUMENT: Name="CalibrationFile" Type="wavcal" Default="GPI-wavcal.fits" Desc="Filename of the desired wavelength calibration file to be read"
; PIPELINE ORDER: 0.01
; PIPELINE TYPE: ALL-SPEC
;
; HISTORY:
; 	Originally by Jerome Maire 2008-07
; 	Documentation updated - Marshall Perrin, 2009-04
;   2009-09-02 JM: hist added in header
;   2009-09-17 JM: added DRF parameters
;   2010-03-15 JM: added automatic detection
;   2010-08-19 JM: fixed bug which created new pointer everytime this primitive was called
;   2010-10-19 JM: split HISTORY keyword if necessary
;-

function readwavcal, DataSet, Modules, Backbone

primitive_version= '$Id$' ; get version from subversion to store in header history
calfiletype = 'wavecal'
@__start_primitive


    ;open the wavecal file:
    ; (JM: this following piece of code using pointer is unuseful right now 
    ; as the common variable "wavcal" do the job. Maybe could serve later?)
    if ~ptr_valid(pmd_wavcalFrame) then $
    pmd_wavcalFrame        = ptr_new(READFITS(c_File, Header, /SILENT)) else $
    *pmd_wavcalFrame = READFITS(c_File, Header, /SILENT)
    wavcal=*pmd_wavcalFrame
    ptr_free, pmd_wavcalFrame


;    pmd_wavcalIntFrame     = ptr_new(READFITS(c_File, Header, EXT=1, /SILENT))
;    pmd_wavcalIntAuxFrame  = ptr_new(READFITS(c_File, Header, EXT=2, /SILENT))

    ;update header:
;    sxaddhist, functionname+": get wav. calibration file", *(dataset.headers[numfile])
;    sxaddhist, functionname+": "+c_File, *(dataset.headers[numfile])
  sxaddparlarge,*(dataset.headers[numfile]),'HISTORY',functionname+": get wav. calibration file"
  sxaddparlarge,*(dataset.headers[numfile]),'HISTORY',functionname+": "+c_File


@__end_primitive 

end
