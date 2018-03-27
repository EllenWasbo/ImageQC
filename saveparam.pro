;ImageQC - quality control of medical images
;Copyright (C) 2017  Ellen Wasbo, Stavanger University Hospital, Norway
;ellen@wasbo.no
;
;This program is free software; you can redistribute it and/or
;modify it under the terms of the GNU General Public License version 2
;as published by the Free Software Foundation.
;
;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.
;
;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.


;save parameters as current set or new set
;overWriteNo = parameter set number to overwrite (-1 if not to be used)
;newName = name of new parameter set (empty string '' if not to be used)
pro saveParam, overWriteNo, newName

  COMMON VARI
  COMPILE_OPT hidden

  RESTORE, thisPath+'data\config.dat'

  configTags=TAG_NAMES(configS.(selConfig))
  oldConfig=configS.(selConfig)
  oldSelConfig=selConfig
  ;CT tests
  WIDGET_CONTROL, cw_typeMTF, GET_VALUE=typeMTF
  WIDGET_CONTROL, cw_plotMTF, GET_VALUE= plotWhich
  WIDGET_CONTROL, txtMTFroiSz, GET_VALUE=MTFroiSz
  WIDGET_CONTROL, txtCutLSFW, GET_VALUE=LSFcut1
  WIDGET_CONTROL, txtCutLSFW2, GET_VALUE=LSFcut2
  WIDGET_CONTROL, txtLinROIrad, GET_VALUE=rad1
  WIDGET_CONTROL, txtLinROIradS, GET_VALUE=radS
  WIDGET_CONTROL, tblLin, GET_VALUE=tableLin
  lintab=CREATE_STRUCT('materials', TRANSPOSE(tableLin[0,*]), 'relMassD', FLOAT(TRANSPOSE(tableLin[3,*])), 'posX', FLOAT(TRANSPOSE(tableLin[1,*])), 'posY', FLOAT(TRANSPOSE(tableLin[2,*])))
  WIDGET_CONTROL, txtRampDist, GET_VALUE=rampDist
  WIDGET_CONTROL, txtRampLen, GET_VALUE=rampLen
  WIDGET_CONTROL, txtRampBackG, GET_VALUE=rampBackG
  WIDGET_CONTROL, txtRampSearch, GET_VALUE=rampSearch
  WIDGET_CONTROL, txtRampAverage, GET_VALUE=rampAvg
  WIDGET_CONTROL, cw_ramptype, GET_VALUE=ramptype
  WIDGET_CONTROL, cw_rampDens, GET_VALUE=rampdens
  WIDGET_CONTROL, txtHomogROIsz, GET_VALUE=homogROIsz
  WIDGET_CONTROL, txtHomogROIdist, GET_VALUE=homogROIdist
  WIDGET_CONTROL, txtNoiseROIsz, GET_VALUE=noiseROIsz
  WIDGET_CONTROL, txtNPSroiSz, GET_VALUE=NPSroiSz
  WIDGET_CONTROL, txtNPSroiDist, GET_VALUE=NPSroiDist
  WIDGET_CONTROL, txtNPSsubNN, GET_VALUE=NPSsubNN
  ;Xray tests
  WIDGET_CONTROL, txtStpROIsz, GET_VALUE=STProiSz
  WIDGET_CONTROL, cw_formLSFX, GET_VALUE=typeMTFX
  WIDGET_CONTROL, cw_plotMTFX, GET_VALUE= plotWhichX
  WIDGET_CONTROL, txtCutLSFWX, GET_VALUE=LSFcutX1
  WIDGET_CONTROL, txtMTFroiSzX, GET_VALUE=MTFroiSzX
  WIDGET_CONTROL, txtMTFroiSzY, GET_VALUE=MTFroiSzY
  WIDGET_CONTROL, txtHomogROIszX, GET_VALUE=homogROIszX
  WIDGET_CONTROL, txtNPSroiSzX, GET_VALUE=NPSroiSzX
  WIDGET_CONTROL, txtNPSsubSzX, GET_VALUE=NPSsubSzX
  ;NM tests
;  WIDGET_CONTROL, txtHomogROIszNM, GET_VALUE=homogROIszNM
;  WIDGET_CONTROL, txtHomogROIdistXNM, GET_VALUE=homogROIdistXNM
;  WIDGET_CONTROL, txtHomogROIdistYNM, GET_VALUE=homogROIdistYNM
  WIDGET_CONTROL, cw_typeMTFNM, GET_VALUE=typeMTFNM
  WIDGET_CONTROL, cw_plotMTFNM, GET_VALUE= plotWhichNM
  WIDGET_CONTROL, txtMTFroiSzXNM, GET_VALUE=MTFroiSzXNM
  WIDGET_CONTROL, txtMTFroiSzYNM, GET_VALUE=MTFroiSzYNM
  WIDGET_CONTROL, txtNAvgSpeedNM, GET_VALUE=scanSpeedAvg
  WIDGET_CONTROL, txtSpeedROIheight, GET_VALUE=scanSpeedHeight
  WIDGET_CONTROL, txtScanSpeedMedian, GET_VALUE=scanSpeedFiltW
  ;SPECT tests
  WIDGET_CONTROL, cw_typeMTFSPECT, GET_VALUE=typeMTFSPECT
  WIDGET_CONTROL, cw_plotMTFSPECT, GET_VALUE= plotWhichSPECT
  WIDGET_CONTROL, txtMTFroiSzSPECT, GET_VALUE=MTFroiSzSPECT
  WIDGET_CONTROL, txtConR1SPECT, GET_VALUE=contrastRad1
  WIDGET_CONTROL, txtConR2SPECT, GET_VALUE=contrastRad2
  ;PET tests
  WIDGET_CONTROL, txtCrossROIsz, GET_VALUE=crossROIsz
  WIDGET_CONTROL, txtCrossVol, GET_VALUE=crossVol
  WIDGET_CONTROL, txtHomogROIszPET, GET_VALUE=homogROIszPET
  WIDGET_CONTROL, txtHomogROIdistPET, GET_VALUE=homogROIdistPET

  config=CREATE_STRUCT('defPath',defPath, 'deciMark', deciMark, 'copyHeader', copyHeader, 'append', WIDGET_INFO(btnAppend, /BUTTON_SET),$
    'typeROI',WIDGET_INFO(typeROI, /BUTTON_SET),'typeROIX',WIDGET_INFO(typeROIX, /BUTTON_SET),$
    'MTFtype',typeMTF,'MTFtypeX', typeMTFX, 'MTFtypeNM', typeMTFNM,'MTFtypeSPECT', typeMTFSPECT, 'plotMTF',plotWhich,'plotMTFX',plotWhichX,'plotMTFNM', plotWhichNM,'plotMTFSPECT', plotWhichSPECT,$
    'MTFroiSz',FLOAT(MTFroiSz(0)),'MTFroiSzX',[FLOAT(MTFroiSzX(0)),FLOAT(MTFroiSzY(0))],'MTFroiSzNM',[FLOAT(MTFroiSzXNM(0)),FLOAT(MTFroiSzYNM(0))],'MTFroiSzSPECT',FLOAT(MTFroiSzSPECT(0)),'MTF3dSPECT',WIDGET_INFO(MTF3dSPECT, /BUTTON_SET),$
    'cutLSF',WIDGET_INFO(btnCutLSF,/BUTTON_SET),'cutLSF1',LONG(LSFcut1),'cutLSF2',LONG(LSFcut2),'cutLSFX',WIDGET_INFO(btnCutLSFX,/BUTTON_SET),'cutLSFX1',LONG(LSFcutX1),'offxy',offxy,$
    'LinROIrad',FLOAT(rad1(0)),'LinROIradS',FLOAT(radS(0)), 'LinTab', lintab, $
    'RampDist',FLOAT(rampDist(0)),'RampLen',FLOAT(rampLen(0)),'RampBackG',FLOAT(rampBackG(0)),'RampSearch',LONG(RampSearch(0)),'RampAvg',LONG(rampAvg(0)),'RampType',ramptype,'RampDens',rampdens,$
    'HomogROIsz',FLOAT(homogROIsz(0)), 'HomogROIszPET',FLOAT(homogROIszPET(0)), 'HomogROIszX',FLOAT(homogROIszX(0)),'HomogROIdist',FLOAT(homogROIdist(0)), 'HomogROIdistPET',FLOAT(homogROIdistPET(0)),$
    'NoiseROIsz',FLOAT(noiseROIsz(0)), $
    'NPSroiSz', LONG(NPSroiSz(0)), 'NPSroiDist', FLOAT(NPSroiDist(0)),'NPSsubNN', LONG(NPSsubNN(0)), 'NPSroiSzX', LONG(NPSroiSzX(0)), 'NPSsubSzX', LONG(NPSsubSzX(0)), 'NPSavg',WIDGET_INFO(btnNPSavg, /BUTTON_SET),$
    'STProiSz', FLOAT(STProiSz(0)), $
    'scanSpeedAvg',LONG(scanSpeedAvg(0)), 'scanSpeedHeight', FLOAT(scanSpeedHeight(0)), 'scanSpeedFiltW', LONG(scanSpeedFiltW(0)), $
    'contrastRad1', FLOAT(contrastRad1(0)), 'contrastRad2', FLOAT(contrastRad2(0)),$
    'CrossROIsz', FLOAT(crossROIsz(0)), 'CrossVol', FLOAT(crossVol(0)) )

  tagsOldConfig=TAG_NAMES(oldConfig)
  IF tagsOldConfig.HasValue('QUICKTEMP') THEN BEGIN
    config=CREATE_STRUCT(config, 'QuickTemp', oldConfig.QUICKTEMP)
  ENDIF

  paramSetNames=TAG_NAMES(configS)
  IF overWriteNo NE -1 THEN BEGIN
    configS=replaceStructStruct(configS, config, overWriteNo)
    SAVE, configS, quickTemp, loadTemp, FILENAME=thisPath+'data\config.dat' 
    selConfig=overWriteNo
    ;current parameterset is active - just change name of parameter set label
    WIDGET_CONTROL, lblSettings, SET_VALUE=paramSetNames(overWriteNo)
  ENDIF ELSE BEGIN
    IF newName EQ '' THEN sv=DIALOG_MESSAGE('No name specified. Could not save.') ELSE BEGIN
      tempname=IDL_VALIDNAME(newName, /CONVERT_ALL)
      tempname=tempname(0)
      IF paramSetNames.HasValue(tempname) THEN BEGIN
        sv=DIALOG_MESSAGE(tempname+ ' already in use. Overwrite?',/QUESTION)
        IF sv EQ 'Yes' THEN BEGIN
          alreadyID=WHERE(paramSetNames EQ tempname)
          configS=replaceStructStruct(configS, config, alreadyID)
          SAVE, configS, quickTemp, loadTemp, FILENAME=thisPath+'data\config.dat'
          selConfig=alreadyID
        ENDIF
      ENDIF ELSE BEGIN
        configS=CREATE_STRUCT(configS, tempname, config)
        SAVE, configS, quickTemp, loadTemp, FILENAME=thisPath+'data\config.dat'
        selConfig=N_ELEMENTS(paramSetNames)
      ENDELSE
      IF selConfig NE oldSelConfig THEN BEGIN
        ;current parameterset is active - just change name of parameter set label
        WIDGET_CONTROL, lblSettings, SET_VALUE=tempname
      ENDIF
    ENDELSE
  ENDELSE

end