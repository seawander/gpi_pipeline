;+
; NAME: extract_one_spectrum
; PIPELINE PRIMITIVE DESCRIPTION: Extract one spectrum 
;
;	
;	
;
; INPUTS: data-cube
;
;
; KEYWORDS:
;	/Save	Set to 1 to save the output image to a disk file. 
;
; OUTPUTS:  
;
; PIPELINE COMMENT: Extract one spectrum from a datacube somewhere in the FOV specified by the user.
; PIPELINE ARGUMENT: Name="xcenter" Type="int" Range="[0,1000]" Default="141" Desc="x-locations in pixel on datacube where extraction will be made"
; PIPELINE ARGUMENT: Name="ycenter" Type="int" Range="[0,1000]" Default="141" Desc="y-locations in pixel on datacube where extraction will be made"
; PIPELINE ARGUMENT: Name="radius" Type="float" Range="[0,1000]" Default="5." Desc="Aperture radius (in pixel i.e. mlens) to extract photometry for each wavelength. Set 0 for one mlens spectrum extraction."
; PIPELINE ARGUMENT: Name="method" Type="string"  Default="total" Range="[median|mean|total]"  Desc="method of photometry extraction:median,mean,total"
; PIPELINE ARGUMENT: Name="ps_figure" Type="int" Range="[0,500]" Default="2" Desc="1-500: choose # of saved fig suffix name, 0: no ps figure "
; PIPELINE ARGUMENT: Name="Save" Type="int" Range="[0,1]" Default="1" Desc="1: save output (fits) on disk, 0: don't save"
; PIPELINE ARGUMENT: Name="suffix" Type="string"  Default="-spec" Desc="Enter output suffix (fits)"
; PIPELINE ORDER: 2.51
; PIPELINE TYPE: ALL-SPEC
; PIPELINE SEQUENCE: 
;
; HISTORY:
; 	
;   JM 2010-03 : created module.
;- 

function extract_one_spectrum, DataSet, Modules, Backbone
common PIP
COMMON APP_CONSTANTS

primitive_version= '$Id$' ; get version from subversion to store in header history
	getmyname, functionname

   	; save starting time
   	T = systime(1)

  	main_image_stack=*(dataset.currframe[0])

        band=strcompress(sxpar( *(dataset.headers[numfile]), 'FILTER',  COUNT=cc),/rem)
        if cc eq 1 then begin
          cwv=get_cwv(band)
          CommonWavVect=cwv.CommonWavVect
          lambda=cwv.lambda
          lambdamin=CommonWavVect[0]
          lambdamax=CommonWavVect[1]
          NLam=CommonWavVect[2]
        endif else begin
          NLam=0
          lambda=(indgen((size(main_image_stack))[3]))
        endelse
	
	thisModuleIndex = Backbone->GetCurrentModuleIndex()

   x = float(Modules[thisModuleIndex].xcenter)
   y = float(Modules[thisModuleIndex].ycenter)
   radi = float(Modules[thisModuleIndex].radius)
   currmeth = Modules[thisModuleIndex].method

;;method radial plot
  if radi gt 0 then begin
      distsq=shift(dist(2*radi+1),radi,radi)
    inda=array_indices(distsq,where(distsq le radi))
    inda[0,*]+=x-radi
    inda[1,*]+=y-radi
    ;;be sure circle doesn't go outside the image:
    inda_outx=intersect(where(inda[0,*] ge 0,cxz),where(inda[0,*] lt ((size(main_image_stack))[1]) ))
    inda_outy=intersect( where(inda[1,*] ge 0,cyz), where(inda[1,*] lt ((size(main_image_stack))[2])) )
    inda_out=intersect(inda_outx,inda_outy)
    inda2x=inda[0,inda_out]
    inda2y=inda[1,inda_out]
    inda=[inda2x,inda2y]
endif else begin
inda=intarr(2,1)
inda[0,0]=x
inda[1,0]=y
endelse


if (size(main_image_stack))[0] eq 3 then begin
  if radi gt 0 then begin
  mi=dblarr((size(inda))(2),(size(main_image_stack))(3),/nozero)
    for i=0,(size(inda))(2)-1 do $
    mi[i,*]=main_image_stack[inda(0,i),inda(1,i), *]
    p1d=fltarr((size(main_image_stack))(3))
    if STRMATCH(currmeth,'Total',/fold) then $
    p1d=total(mi,1,/nan)
    if STRMATCH(currmeth,'Median',/fold) then $
    p1d=median(mi,dimension=1)
    if STRMATCH(currmeth,'Mean',/fold) then $
    for i=0,(size(mi))(2)-1 do $
    p1d[i]=mean(mi(*,i),/nan)
    endif else begin
    p1d=main_image_stack[x, y, *]
    endelse



      indf=where(finite(p1d))
      if (NLam gt 0)  then $
        xlam=(lambda)[indf] $
        else xlam=(indgen((size(main_image_stack))[3]))[indf]


ps_figure = Modules[thisModuleIndex].ps_figure 
calunits=sxpar( *(dataset.headers[numfile]), 'CUNIT',  COUNT=cc)
ifsunits=sxpar( *(dataset.headers[numfile]), 'IFSUNIT',  COUNT=ci)
units='counts/s'
if ci eq 1 then units=ifsunits 
if cc eq 1 then units=calunits 

  s_Ext='-spectrum_x'+Modules[thisModuleIndex].xcenter+'_y'+Modules[thisModuleIndex].ycenter
 filnm=sxpar(*(DataSet.Headers[numfile]),'DATAFILE')
 slash=strpos(filnm,path_sep(),/reverse_search)
 psFilename = Modules[thisModuleIndex].OutputDir+strmid(filnm, slash,strlen(filnm)-5-slash)+s_Ext+'.ps'

;;;;method photometric
    cubcent2=main_image_stack
    phpadu = 1.0                    ; don't convert counts to electrons
apr = float(radi)
skyrad = [6.,10.]
; Assume that all pixel values are good data
badpix = [-1.,1e6];state.image_min-1, state.image_max+1
    
    ;;do the photometry of the companion
    phot_comp=fltarr(CommonWavVect[2])
      for i=0,CommonWavVect[2]-1 do begin
          aper, cubcent2[*,*,i], [x], [y], flux, errap, sky, skyerr, phpadu, (lambda[i]/lambda[0])*apr, $
            skyrad, badpix, /flux, /silent ;, flux=abs(state.magunits-1)
            print, 'slice#',i,' flux comp #'+'=',flux[0],'at positions ['+strc(x)+','+strc(y)+']',' sky=',sky[0]
          phot_comp[i]=(flux[0]-sky[0])
      endfor

     
; overplot the phot apertures on radial plot
if (ps_figure gt 0)  then begin
  openps, psFilename
  if n_elements(indf) gt 1 then $
  if NLam eq 0 then plot, xlam, p1d[indf],ytitle='Intensity ['+units+']', xtitle='spaxel', psym=-1
  if NLam gt 0 then plot, xlam, p1d[indf],ytitle='Intensity ['+units+']', xtitle='Wavelength (um)', psym=-1, yrange=[0,1.3*max(p1d)]
  oplot, xlam,phot_comp
  closeps
  set_plot,'win'
endif 

suffix+='-spec'

	thisModuleIndex = Backbone->GetCurrentModuleIndex()
    if tag_exist( Modules[thisModuleIndex], "Save") && ( Modules[thisModuleIndex].Save eq 1 ) then begin
		  if tag_exist( Modules[thisModuleIndex], "gpitv") then display=fix(Modules[thisModuleIndex].gpitv) else display=0
		  wav_spec=[[lambda],[p1d],[phot_comp]] 
		    sxaddpar, hdr, "SPECCENX", Modules[thisModuleIndex].xcenter, "x-locations in pixel on datacube where extraction has been made"
        sxaddpar, hdr, "SPECCENY", Modules[thisModuleIndex].ycenter, 'y-locations in pixel on datacube where extraction has been made'  
    	b_Stat = save_currdata( DataSet,  Modules[thisModuleIndex].OutputDir, suffix ,savedata=wav_spec, display=display)
    	if ( b_Stat ne OK ) then  return, error ('FAILURE ('+functionName+'): Failed to save dataset.')
    endif else begin
      if tag_exist( Modules[thisModuleIndex], "gpitv") && ( fix(Modules[thisModuleIndex].gpitv) ne 0 ) then $
          gpitvms, double(*DataSet.currFrame), ses=fix(Modules[thisModuleIndex].gpitv),head=*(dataset.headers)[numfile]
    endelse

endif 
;drpPushCallStack, functionName
return, ok


end
