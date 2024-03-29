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

;fill quickTemp list
;qt=quickTemp structure for given modality
;SELECT_NAME = string of the template
pro fillQuickTempList, qT, SELECT_NAME=select_name
  COMPILE_OPT hidden
  COMMON VARI
  IF N_ELEMENTS(qT) EQ 0 OR SIZE(qt, /TNAME) EQ 'INT' THEN BEGIN
    WIDGET_CONTROL, listSelMultiTemp, SET_VALUE='', SET_DROPLIST_SELECT=0
    clearMulti
    marked=-1
    WIDGET_CONTROL, btnUseMulti, SET_BUTTON=0
  ENDIF ELSE BEGIN
    IF SIZE(qT, /TNAME) EQ 'STRUCT' THEN BEGIN
      tempNames=TAG_NAMES(qT)
      WIDGET_CONTROL, listSelMultiTemp, SET_VALUE=['',tempNames]
      selno=0
      IF N_ELEMENTS(select_name) NE 0 THEN BEGIN
        tagNo=WHERE(STRUPCASE(tempNames) EQ STRUPCASE(select_name))
        IF tagNo(0) NE -1 THEN selno=tagNo
        WIDGET_CONTROL, listSelMultiTemp, SET_DROPLIST_SELECT=selno+1
      ENDIF ELSE BEGIN;fill new
        WIDGET_CONTROL, listSelMultiTemp, SET_DROPLIST_SELECT=0
        clearMulti
        marked=-1
        WIDGET_CONTROL, btnUseMulti, SET_BUTTON=0
      ENDELSE
    ENDIF ELSE BEGIN
      WIDGET_CONTROL, listSelMultiTemp, SET_VALUE=''
      clearMulti
      marked=-1
      WIDGET_CONTROL, btnUseMulti, SET_BUTTON=0
    ENDELSE
  ENDELSE
  
  If structImgs NE !Null THEN tags=TAG_NAMES(structImgs) ELSE tags='EMPTY'
  IF tags(0) NE 'EMPTY' THEN BEGIN
    IF WIDGET_INFO(lstShowFile, /DROPLIST_SELECT) EQ 0 THEN RDtemp='' ELSE RDtemp=modalityName
    fileList=getListOpenFiles(structImgs,0,marked,markedMulti,RENAMEDICOM=RDtemp, CONFIGPATH=configPath, PARENT=evTop)
    sel=WIDGET_INFO(listFiles, /LIST_SELECT)
    oldTop=WIDGET_INFO(listFiles, /LIST_TOP)
    WIDGET_CONTROL, listFiles, SET_VALUE=fileList, SET_LIST_SELECT=sel(N_ELEMENTS(sel)-1), SET_LIST_TOP=oldTop
  ENDIF
  
end

;if paramSetName NE '' Then update also shown name
pro refreshParam, paramSet, paramSetName
  COMPILE_OPT hidden
  COMMON VARI

  clearRes

  IF paramSetName NE '' THEN WIDGET_CONTROL, lblSettings, SET_VALUE=paramSetName

  decimMark=paramSet.deciMark
  CASE deciMark OF
    '.':  WIDGET_CONTROL, listDeciMark, SET_DROPLIST_SELECT=0
    ',':  WIDGET_CONTROL, listDeciMark, SET_DROPLIST_SELECT=1
    ELSE:
  ENDCASE
  
  copyHeader=paramSet.copyHeader
  WIDGET_CONTROL, btnCopyHeader, SET_BUTTON=paramSet.COPYHEADER
  transposeTable=paramSet.transposeTable
  WIDGET_CONTROL, btnTranspose, SET_BUTTON=paramSet.TRANSPOSETABLE
  WIDGET_CONTROL, btnIncFilename, SET_BUTTON=paramSet.INCLUDEFILENAME
  WIDGET_CONTROL, btnAppend, SET_BUTTON=paramSet.APPEND
  ;extra offset xy
  offxyMTF=paramSet.offxyMTF
  offxyMTF_X=paramSet.offxyMTF_X
  offxyROI=paramSet.offxyROI
  offxyROIX=paramSet.offxyROIX
  offxyROIMR=paramSet.offxyROIMR
  WIDGET_CONTROL, unitDeltaO_MTF_CT, SET_VALUE=paramSet.OFFXYMTF_UNIT
  WIDGET_CONTROL, unitDeltaO_MTF_X, SET_VALUE=paramSet.OFFXYMTF_X_UNIT
  WIDGET_CONTROL, unitDeltaO_ROI_CT, SET_VALUE=paramSet.OFFXYROI_UNIT
  WIDGET_CONTROL, unitDeltaO_ROI_X, SET_VALUE=paramSet.OFFXYROIX_UNIT
  WIDGET_CONTROL, unitDeltaO_ROI_MR, SET_VALUE=paramSet.OFFXYROIMR_UNIT
  strOff=STRING(paramSet.OFFXYMTF(0), FORMAT='(i0)')+','+STRING(paramSet.OFFXYMTF(1), FORMAT='(i0)')
  WIDGET_CONTROL, lblDeltaO, SET_VALUE=strOff
  strOff=STRING(paramSet.OFFXYMTF_X(0), FORMAT='(i0)')+','+STRING(paramSet.OFFXYMTF_X(1), FORMAT='(i0)')
  WIDGET_CONTROL, lblDeltaOX, SET_VALUE=strOff
  strOff=STRING(paramSet.OFFXYROI(0), FORMAT='(i0)')+','+STRING(paramSet.OFFXYROI(1), FORMAT='(i0)')
  WIDGET_CONTROL, lblDeltaO_ROI, SET_VALUE=strOff
  strOff=STRING(paramSet.OFFXYROIX(0), FORMAT='(i0)')+','+STRING(paramSet.OFFXYROIX(1), FORMAT='(i0)')
  WIDGET_CONTROL, lblDeltaO_ROIX, SET_VALUE=strOff
  strOff=STRING(paramSet.OFFXYROIMR(0), FORMAT='(i0)')+','+STRING(paramSet.OFFXYROIMR(1), FORMAT='(i0)')
  WIDGET_CONTROL, lblDeltaO_ROIMR, SET_VALUE=strOff

  ;CT tests
  WIDGET_CONTROL, cw_typeMTF, SET_VALUE=paramSet.MTFTYPE
  WIDGET_CONTROL, cw_plotMTF, SET_VALUE=paramSet.PLOTMTF
  WIDGET_CONTROL, cw_tableMTF, SET_VALUE=paramSet.TABLEMTF
  WIDGET_CONTROL, cw_cyclMTF, SET_VALUE=paramSet.CYCLMTF
  WIDGET_CONTROL, txtMTFroiSz, SET_VALUE=STRING(paramSet.MTFROISZ, FORMAT='(f0.1)')
  WIDGET_CONTROL, btnCutLSF, SET_BUTTON=paramSet.CUTLSF
  WIDGET_CONTROL, txtCutLSFW, SET_VALUE=STRING(paramSet.CUTLSF1, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtCutLSFW2, SET_VALUE=STRING(paramSet.CUTLSF2, FORMAT='(f0.1)')
  
  WIDGET_CONTROL, btnSearchMaxMTF, SET_BUTTON=paramSet.SEARCHMAXMTF_ROI
  WIDGET_CONTROL, txtLinROIrad, SET_VALUE=STRING(paramSet.LINROIRAD, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtLinROIradS, SET_VALUE=STRING(paramSet.LINROIRADS, FORMAT='(f0.1)')
  ysz=N_ELEMENTS(paramSet.LINTAB.Materials)
  fillLin=STRARR(4,ysz)
  fillLin[0,*]=TRANSPOSE(paramSet.LINTAB.Materials)
  fillLin[1,*]=STRING(TRANSPOSE(paramSet.LINTAB.posX), FORMAT='(f0.1)')
  fillLin[2,*]=STRING(TRANSPOSE(paramSet.LINTAB.posY), FORMAT='(f0.1)')
  fillLin[3,*]=STRING(TRANSPOSE(paramSet.LINTAB.RelMassD), FORMAT='(f0.3)')
  tableHeaders=updateMaterialHeaders(tableHeaders, TRANSPOSE(paramSet.LINTAB.Materials))
  WIDGET_CONTROL, tblLin, TABLE_YSIZE=ysz, SET_VALUE=fillLin, SET_TABLE_SELECT=[-1,-1,-1,-1], SET_TABLE_VIEW=[0,0]
  WIDGET_CONTROL, txtRampDist, SET_VALUE=STRING(paramSet.RAMPDIST, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtRampLen, SET_VALUE=STRING(paramSet.RAMPLEN, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtRampBackG, SET_VALUE=STRING(paramSet.RAMPBACKG, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtRampSearch, SET_VALUE=STRING(paramSet.RAMPSEARCH, FORMAT='(i0)')
  WIDGET_CONTROL, txtRampAverage, SET_VALUE=STRING(paramSet.RAMPAVG, FORMAT='(i0)')
  WIDGET_CONTROL, cw_ramptype, SET_VALUE=paramSet.RAMPTYPE
  WIDGET_CONTROL, cw_rampDens, SET_VALUE=paramSet.RAMPDENS
  WIDGET_CONTROL, txtHomogROIsz, SET_VALUE=STRING(paramSet.HOMOGROISZ, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtHomogROIdist, SET_VALUE=STRING(paramSet.HOMOGROIDIST, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtHomogROIrot, SET_VALUE=STRING(paramSet.HOMOGROIROT, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtNoiseROIsz, SET_VALUE=STRING(paramSet.NOISEROISZ, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtHUwaterROIsz, SET_VALUE=STRING(paramSet.HUWATERROISZ, FORMAT='(f0.1)')
  WIDGET_CONTROL, typeROI, SET_VALUE=paramSet.TYPEROI
  WIDGET_CONTROL, txtROIrad, SET_VALUE=STRING(paramSet.ROIRAD, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtROIx, SET_VALUE=STRING(paramSet.ROIX, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtROIy, SET_VALUE=STRING(paramSet.ROIY, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtROIa, SET_VALUE=STRING(paramSet.ROIA, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtRingMedian, SET_VALUE=STRING(paramSet.RINGMEDIAN, FORMAT='(i0)')
  WIDGET_CONTROL, txtRingSmooth, SET_VALUE=STRING(paramSet.RINGSMOOTH, FORMAT='(f0.1)') 
  WIDGET_CONTROL, txtRingStart, SET_VALUE=STRING(paramSet.RINGSTOP(0), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtRingStop, SET_VALUE=STRING(paramSet.RINGSTOP(1), FORMAT='(f0.1)')
  WIDGET_CONTROL, cw_ringArtTrend, SET_VALUE=paramSet.RINGARTTREND

  WIDGET_CONTROL, txtNPSroiSz, SET_VALUE=STRING(paramSet.NPSROISZ, FORMAT='(i0)')
  WIDGET_CONTROL, txtNPSroiDist, SET_VALUE=STRING(paramSet.NPSROIDIST, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtNPSsubNN, SET_VALUE=STRING(paramSet.NPSSUBNN, FORMAT='(i0)')
  ;Xray tests
  WIDGET_CONTROL, txtStpROIsz, SET_VALUE=STRING(paramSet.STPROISZ, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtNoiseX, SET_VALUE=STRING(paramSet.NOISEXPERCENT, FORMAT='(i0)')
  WIDGET_CONTROL, cw_formLSFX, SET_VALUE=paramSet.MTFtypeX
  WIDGET_CONTROL, cw_plotMTFX, SET_VALUE=paramSet.plotMTFX
  WIDGET_CONTROL, cw_tableMTFX, SET_VALUE=paramSet.TABLEMTFX
  WIDGET_CONTROL, txtCutLSFWX, SET_VALUE=STRING(paramSet.cutLSFX1, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtMTFroiSzX, SET_VALUE=STRING(paramSet.MTFroiSzX(0), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtMTFroiSzY, SET_VALUE=STRING(paramSet.MTFroiSzX(1), FORMAT='(f0.1)')
  WIDGET_CONTROL, btnCutLSFX, SET_BUTTON=paramSet.CUTLSFX
  WIDGET_CONTROL, txtHomogROIszX, SET_VALUE=STRING(paramSet.HOMOGROISZX, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtHomogROIrotX, SET_VALUE=STRING(paramSet.HOMOGROIROTX, FORMAT='(f0.1)')
  IF paramSet.HOMOGROIDISTX EQ 0. THEN WIDGET_CONTROL, txtHomogROIdistX, SET_VALUE='' ELSE WIDGET_CONTROL, txtHomogROIdistX, SET_VALUE=STRING(paramSet.HOMOGROIDISTX, FORMAT='(f0.1)')
  WIDGET_CONTROL, cw_HomogAltX, SET_VALUE=paramSet.ALTHOMOGX
  WIDGET_CONTROL, typeROIX, SET_VALUE=paramSet.TYPEROIX
  WIDGET_CONTROL, txtROIXrad, SET_VALUE=STRING(paramSet.ROIXRAD, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtROIXx, SET_VALUE=STRING(paramSet.ROIXX, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtROIXy, SET_VALUE=STRING(paramSet.ROIXY, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtROIXa, SET_VALUE=STRING(paramSet.ROIXA, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtNPSroiSzX, SET_VALUE=STRING(paramSet.NPSROISZX, FORMAT='(i0)')
  WIDGET_CONTROL, txtNPSsubSzX, SET_VALUE=STRING(paramSet.NPSSUBSZX, FORMAT='(i0)')
  WIDGET_CONTROL, btnNPSavg, SET_BUTTON=paramSet.NPSAVG
  nn=((2*LONG(paramSet.NPSsubSzX)-1)*LONG(paramSet.NPSroiSzX))^2
  WIDGET_CONTROL, lblNPStotPixX, SET_VALUE=STRING(nn, FORMAT='(i0)')
  ;NM tests
  WIDGET_CONTROL, cw_typeMTFNM, SET_VALUE=paramSet.MTFtypeNM
  WIDGET_CONTROL, cw_plotMTFNM, SET_VALUE=paramSet.plotMTFNM
  WIDGET_CONTROL, txtMTFroiSzXNM, SET_VALUE=STRING(paramSet.MTFroiSzNM(0), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtMTFroiSzYNM, SET_VALUE=STRING(paramSet.MTFroiSzNM(1), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtNAvgSpeedNM, SET_VALUE=STRING(paramSet.scanSpeedAvg, FORMAT='(i0)')
  WIDGET_CONTROL, txtSpeedROIheight, SET_VALUE=STRING(paramSet.scanSpeedHeight, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtScanSpeedMedian, SET_VALUE=STRING(paramSet.scanSpeedFiltW, FORMAT='(i0)')
  WIDGET_CONTROL, txtUnifAreaRatio, SET_VALUE=STRING(paramSet.UNIFAREARATIO, FORMAT='(f0.2)')
  WIDGET_CONTROL, btnUnifCorr, SET_BUTTON=paramSet.UNIFCORR
  WIDGET_CONTROL, cw_posfitUnifCorr, SET_VALUE=paramSet.UNIFCORRPOS
  IF paramSet.UNIFCORRRAD EQ -1. THEN BEGIN
    WIDGET_CONTROL, btnLockRadUnifCorr, SET_BUTTON=0 
    WIDGET_CONTROL, txtLockRadUnifCorr, SET_VALUE=''
  ENDIF ELSE BEGIN
    WIDGET_CONTROL, btnLockRadUnifCorr, SET_BUTTON=1
    WIDGET_CONTROL, txtLockRadUnifCorr, SET_VALUE=STRING(paramSet.UNIFCORRRAD, FORMAT='(f0.1)')   
  ENDELSE
  WIDGET_CONTROL, txtSNIAreaRatio, SET_VALUE=STRING(paramSet.SNIAREARATIO, FORMAT='(f0.2)')
  WIDGET_CONTROL, btnSNICorr, SET_BUTTON=paramSet.SNICORR
  WIDGET_CONTROL, cw_posfitSNICorr, SET_VALUE=paramSet.SNICORRPOS
  IF paramSet.SNICORRRAD EQ -1. THEN BEGIN
    WIDGET_CONTROL, btnLockRadSNICorr, SET_BUTTON=0
    WIDGET_CONTROL, txtLockRadSNICorr, SET_VALUE=''
  ENDIF ELSE BEGIN
    WIDGET_CONTROL, btnLockRadSNICorr, SET_BUTTON=1
    WIDGET_CONTROL, txtLockRadSNICorr, SET_VALUE=STRING(paramSet.SNICORRRAD, FORMAT='(f0.1)')
  ENDELSE
  WIDGET_CONTROL, txtSNI_f, SET_VALUE=STRING(paramSet.SNI_fcd[0], FORMAT='(f0.1)')
  WIDGET_CONTROL, txtSNI_c, SET_VALUE=STRING(paramSet.SNI_fcd[1], FORMAT='(i0)')
  WIDGET_CONTROL, txtSNI_d, SET_VALUE=STRING(paramSet.SNI_fcd[2], FORMAT='(i0)')
  WIDGET_CONTROL, cw_plotSNI, SET_VALUE=paramSet.plotSNI
  WIDGET_CONTROL, txtBarROIsize, SET_VALUE=STRING(paramSet.barROIsz, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtBar1, SET_VALUE=STRING(paramSet.barWidths(0), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtBar2, SET_VALUE=STRING(paramSet.barWidths(1), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtBar3, SET_VALUE=STRING(paramSet.barWidths(2), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtBar4, SET_VALUE=STRING(paramSet.barWidths(3), FORMAT='(f0.1)')
  ;SPECT tests
  WIDGET_CONTROL, cw_typeMTFSPECT, SET_VALUE=paramSet.MTFtypeSPECT
  WIDGET_CONTROL, cw_plotMTFSPECT, SET_VALUE=paramSet.plotMTFSPECT
  WIDGET_CONTROL, txtMTFroiSzSPECT, SET_VALUE=STRING(paramSet.MTFroiSzSPECT, FORMAT='(f0.1)')
  WIDGET_CONTROL, MTF3dSPECT, SET_BUTTON=paramSet.MTF3dSPECT
  WIDGET_CONTROL, txtConR1SPECT, SET_VALUE=STRING(paramSet.contrastRad1, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtConR2SPECT, SET_VALUE=STRING(paramSet.contrastRad2, FORMAT='(f0.1)')
  ;PET tests
  WIDGET_CONTROL, txtCrossROIsz, SET_VALUE=STRING(paramSet.crossROIsz, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtCrossVol, SET_VALUE=STRING(paramSet.crossVol, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtHomogROIszPET, SET_VALUE=STRING(paramSet.HomogROIszPET, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtHomogROIdistPET, SET_VALUE=STRING(paramSet.HomogROIdistPET, FORMAT='(f0.1)')
  ;MR tests
  WIDGET_CONTROL, txtSNR_MR_ROI, SET_VALUE=STRING(paramSet.SNR_MR_ROI, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtSNR_MR_ROIcut, SET_VALUE=STRING(paramSet.SNR_MR_ROIcut, FORMAT='(i0)')
  WIDGET_CONTROL, txtPIU_MR_ROI, SET_VALUE=STRING(paramSet.PIU_MR_ROI, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtPIU_MR_ROIcut, SET_VALUE=STRING(paramSet.PIU_MR_ROIcut, FORMAT='(i0)')
  WIDGET_CONTROL, ghost_MR_optC, SET_BUTTON=ROUND(paramSet.GHOST_MR_ROI(4))
  WIDGET_CONTROL, txtGhost_MR_ROIszC, SET_VALUE=STRING(paramSet.GHOST_MR_ROI(0), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtGhost_MR_ROIszW, SET_VALUE=STRING(paramSet.GHOST_MR_ROI(1), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtGhost_MR_ROIszH, SET_VALUE=STRING(paramSet.GHOST_MR_ROI(2), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtGhost_MR_ROIszD, SET_VALUE=STRING(paramSet.GHOST_MR_ROI(3), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtGhost_MR_ROIcut, SET_VALUE=STRING(paramSet.GHOST_MR_ROIcut, FORMAT='(i0)')
  WIDGET_CONTROL, txtGD_MR_act, SET_VALUE=STRING(paramSet.GD_MR_ACT, FORMAT='(f0.1)')
  WIDGET_CONTROL, slice_MR_optC, SET_BUTTON=ROUND(paramSet.SLICE_MR_ROI(5))
  WIDGET_CONTROL, txtSlice_MR_TANA, SET_VALUE=STRING(paramSet.SLICE_MR_ROI(0), FORMAT='(f0.3)')
  WIDGET_CONTROL, txtSlice_MR_ROIszW, SET_VALUE=STRING(paramSet.SLICE_MR_ROI(1), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtSlice_MR_ROIszH, SET_VALUE=STRING(paramSet.SLICE_MR_ROI(2), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtSlice_MR_ROIszD, SET_VALUE=STRING(paramSet.SLICE_MR_ROI(3), FORMAT='(f0.1)')
  WIDGET_CONTROL, txtSlice_MR_ROIszD2, SET_VALUE=STRING(paramSet.SLICE_MR_ROI(4), FORMAT='(f0.1)')
  WIDGET_CONTROL, typeROIMR, SET_VALUE=paramSet.TYPEROIMR
  WIDGET_CONTROL, txtROIMRrad, SET_VALUE=STRING(paramSet.ROIMRRAD, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtROIMRx, SET_VALUE=STRING(paramSet.ROIMRX, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtROIMRy, SET_VALUE=STRING(paramSet.ROIMRY, FORMAT='(f0.1)')
  WIDGET_CONTROL, txtROIMRa, SET_VALUE=STRING(paramSet.ROIMRA, FORMAT='(f0.1)')

end
