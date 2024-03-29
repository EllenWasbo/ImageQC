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

pro updateTable
  COMPILE_OPT hidden
  COMMON VARI

  nCols=-1
  szM=SIZE(markedMulti, /DIMENSIONS)
  IF analyse NE 'ENERGYSPEC' THEN BEGIN
    sel=WIDGET_INFO(listFiles, /LIST_SELECT) & sel=sel(0)
    nImg=N_TAGS(structImgs)
    pix=structImgs.(sel).pix(0)
    markedTemp=INDGEN(nImg); all default
    IF marked(0) EQ -1 THEN BEGIN
      IF N_ELEMENTS(szM) EQ 2 THEN nI=MIN([nImg,szM(1)]) ELSE nI=nImg
      nRows=nI
    ENDIF ELSE BEGIN
      nRows=N_ELEMENTS(marked)
      markedTemp=marked
    ENDELSE
  ENDIF

  cellSelHighLight=1

  curMode=WIDGET_INFO(wtabModes, /TAB_CURRENT)
  CASE curMode OF
    ;********************************CT*************************************************
    0: BEGIN
      curTab=WIDGET_INFO(wtabAnalysisCT, /TAB_CURRENT)
      IF results(curTab) EQ 1 THEN BEGIN

        CASE analyse OF

          'MTF': BEGIN
            ;table results @50,10,2%
            multipRes=WHERE(TAG_NAMES(MTFres) EQ 'M0')
            WIDGET_CONTROL, cw_tableMTF, GET_VALUE= tableWhich
            WIDGET_CONTROL, cw_cyclMTF, GET_VALUE=MTFcyclWhich
            IF MTFcyclWhich EQ 0 THEN cyclFactor=1.0 ELSE cyclFactor=10.0
            IF multipRes(0) NE -1 THEN BEGIN
              nCols=6
              currentHeaderAlt(curTab)=0
              headers=tableHeaders.CT.MTF.BEAD_XY;['MTFx 50%','MTFx 10%','MTFx 2%','MTFy 50%','MTFy 10%','MTFy 2%']
              resArrString=STRARR(nCols,nRows)
              nTags=N_TAGS(MTFres)
              FOR i =0, MIN([nRows,nTags])-1 DO BEGIN
                tagn=TAG_NAMES(MTFres.(markedTemp(i)))
                IF tableWhich EQ 0 THEN BEGIN
                  IF tagn.HasValue('F50_10_2') THEN resArrString[*,i]=STRING(cyclFactor*MTFres.(markedTemp(i)).F50_10_2, FORMAT='(F0.3)')
                ENDIF ELSE BEGIN
                  IF tagn.HasValue('F50_10_2DISCRETE') THEN resArrString[*,i]=STRING(cyclFactor*MTFres.(markedTemp(i)).F50_10_2DISCRETE, FORMAT='(F0.3)')
                ENDELSE
              ENDFOR

            ENDIF ELSE BEGIN
              nRows=1
              nCols=3
              currentHeaderAlt(curTab)=1
              headers=tableHeaders.CT.MTF.WIRE_OR_CIRCULAR_EDGE;['MTF 50%','MTF 10%','MTF 2%']
              tagn=TAG_NAMES(MTFres)
              IF tableWhich EQ 0 THEN BEGIN
                IF tagn.HasValue('F50_10_2') THEN resArrString=STRING(cyclFactor*MTFres.F50_10_2[0:2], FORMAT='(F0.3)')
              ENDIF ELSE BEGIN
                IF tagn.HasValue('F50_10_2DISCRETE') THEN resArrString=STRING(cyclFactor*MTFres.F50_10_2DISCRETE[0:2], FORMAT='(F0.3)')
              ENDELSE
              cellSelHighLight=0
            ENDELSE
          END

          'CTLIN': BEGIN
            szTab=SIZE(CTlinRes, /DIMENSIONS)
            nCols=szTab(0)
            headers=tableHeaders.CT.CTLIN.Alt1;WIDGET_CONTROL, tblLin, GET_VALUE=linTable; headers=TRANSPOSE(linTable[0,*])
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO BEGIN
              resArrString[*,i]=STRING(CTlinRes[*,markedTemp(i)], FORMAT='(F0.1)')
              ;resArrString[nCols-1,i]=STRING(CTlinRes[nCols-1,markedTemp(i)], FORMAT='(F0.4)')
            ENDFOR
          END

          'SLICETHICK': BEGIN
            nCols=7
            WIDGET_CONTROL, cw_ramptype, GET_VALUE=ramptype
            currentHeaderAlt(curTab)=ramptype
            headers=tableHeaders.CT.SLICETHICK.(ramptype)
            IF ramptype EQ 2 THEN nCols=3
            resArrString=STRARR(nCols,nRows)
            IF rampType EQ 2 THEN BEGIN
              FOR i=0, nRows-1 DO BEGIN
                resArrString[0,i]=STRING(sliceThickResTab[0,markedTemp(i)], FORMAT='(f0.2)')
                resArrString[1:2,i]=STRING(sliceThickResTab[3:4,markedTemp(i)], FORMAT='(f0.2)')
              ENDFOR
            ENDIF ELSE BEGIN
              FOR i=0, nRows-1 DO resArrString[0:nCols-1,i]=STRING(sliceThickResTab[0:nCols-1,markedTemp(i)], FORMAT='(f0.2)')
            ENDELSE
          END

          'HOMOG': BEGIN
            szTab=SIZE(homogRes, /DIMENSIONS)
            nCols=9
            headers=tableHeaders.CT.HOMOG.Alt1;['12oClock','15oClock','18oClock','21oClock','Center HU','Diff C 12','Diff C 15','Diff C 18','Diff C 21']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO BEGIN
              resArrString[0:3,i]=STRING(homogRes[1:4,markedTemp(i)], FORMAT=formatCode(homogRes[1:4,markedTemp(i)]))
              resArrString[4,i]=STRING(homogRes[0,markedTemp(i)], FORMAT=formatCode(homogRes[0,markedTemp(i)]))
              resArrString[5:8,i]=STRING(homogRes[1:4,markedTemp(i)]-homogRes[0,markedTemp(i)], FORMAT=formatCode(homogRes[1:4,markedTemp(i)]))
              ;resArrString[5:8,i]=STRING(homogRes[6:9,markedTemp(i)], FORMAT='(f0.'+nDecimals(homogRes[6:9,markedTemp(i)])+')')
              ;resArrString[9,i]=STRING(homogRes[5,markedTemp(i)], FORMAT='(f0.'+nDecimals(homogRes[5,markedTemp(i)])+')')
            ENDFOR
          END

          'EXP':BEGIN
            nCols=N_ELEMENTS(tableHeaders.CT.EXP.Alt1)
            headers=tableHeaders.CT.EXP.Alt1;['kVp','mAs','CTDIvol','SWversion']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=expRes[*,markedTemp(i)]
          END

          'NOISE': BEGIN
            nCols=4
            headers=tableHeaders.CT.NOISE.Alt1;['CT number (HU)','Noise=Stdev (HU)','Diff avg noise(%)', 'Avg noise (HU)']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(noiseRes[*,markedTemp(i)],FORMAT=formatCode(noiseRes[*,markedTemp(i)]))
            ;IF nRows GT 1 THEN resArrString[3,1:nRows-1]=''
          END

          'HUWATER': BEGIN
            nCols=2
            headers=tableHeaders.CT.HUWATER.Alt1;['CT number (HU)','Noise=Stdev (HU)']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(HUwaterRes[*,markedTemp(i)],FORMAT=formatCode(HUwaterRes[*,markedTemp(i)]))
          END

          'ROI': BEGIN
            nCols=2
            headers=tableHeaders.CT.ROI.Alt1;['CT number (HU)','Stdev (HU)']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(ROIres[*,markedTemp(i)],FORMAT=formatCode(ROIres[*,markedTemp(i)]))
          END
          
          'RING': BEGIN
            nCols=2
            headers=tableHeaders.CT.RING.Alt1
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(ringArtRes[*,markedTemp(i)],FORMAT='(f0.1)')
            END

          'FWHM': BEGIN
            nCols=3
            headers=['FWHM','FWHM_korr','mcorr']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(fwhmRes[*,markedTemp(i)], FORMAT='(f0.4)')
          END

          'DIM': BEGIN
            nCols=6
            headers=['Horisontal 1','Horisontal 2','Vertical 1','Vertical 2','Diagonal 1','Diagonal 2']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(dimRes[0:5,markedTemp(i)], FORMAT='(f0.2)')
          END

          ELSE:
        ENDCASE

      ENDIF
    END
    ;********************************Xray*************************************************
    1:BEGIN
      curTab=WIDGET_INFO(wtabAnalysisXray, /TAB_CURRENT)
      IF results(curTab) EQ 1 THEN BEGIN

        CASE analyse OF
          'STP':BEGIN
            nCols=4
            headers=tableHeaders.XRAY.STP.Alt1;['Dose','Q','Mean pix','Stdev pix']
            resArrString=STRARR(nCols,nRows)
            WIDGET_CONTROL, txtRQA, GET_VALUE=Qvalue
            Qvalue=LONG(Qvalue(0))
            stpRes.table[1,*]=stpRes.table[0,*]*Qvalue
            FOR j=0, nRows-1 DO BEGIN
              FOR i=0, nCols-1 DO BEGIN
                resArrString[i,j]=STRING(stpRes.table[i,markedTemp(j)], FORMAT=formatCode(stpRes.table[i,markedTemp(j)]))
              ENDFOR
            ENDFOR
          END
          'HOMOG':BEGIN
            szTab=SIZE(homogRes, /DIMENSIONS)
            nCols=szTab(0)
            resArrString=STRARR(nCols,nRows)
            WIDGET_CONTROL, cw_HomogAltX, GET_VALUE=tabType
            currentHeaderAlt(curTab)=tabType
            headers=tableHeaders.XRAY.HOMOG.(tabType)
            CASE tabType OF
              0: FOR i=0, nRows-1 DO resArrString[*,i]=STRING(homogRes[*,markedTemp(i)], FORMAT=formatCode(homogRes[*,markedTemp(i)]))
              1: BEGIN
                FOR i=0, nRows-1 DO BEGIN
                  resArrString[0:4,i]=STRING(homogRes[0:4,markedTemp(i)], FORMAT=formatCode(homogRes[0:4,markedTemp(i)]))
                  avg=MEAN(homogRes[0:4,i])
                  diff=homogRes[0:4,markedTemp(i)]-avg
                  resArrString[5:9,i]=STRING(diff, FORMAT=formatCode(homogRes[0:4,markedTemp(i)]))
                ENDFOR
              END
              2: BEGIN
                FOR i=0, nRows-1 DO BEGIN
                  resArrString[0:4,i]=STRING(homogRes[0:4,markedTemp(i)], FORMAT=formatCode(homogRes[0:4,markedTemp(i)]))
                  avg=MEAN(homogRes[0:4,i])
                  diff=100.0*(homogRes[0:4,markedTemp(i)]-avg)/avg
                  resArrString[5:9,i]=STRING(diff, FORMAT='(f0.1)')
                ENDFOR
              END
              ELSE:
            ENDCASE

          END
          'NOISE':BEGIN
            nCols=2
            headers=tableHeaders.XRAY.NOISE.Alt1;['Mean pixel value','Stdev']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(noiseRes[*,markedTemp(i)], FORMAT=formatCode(noiseRes[*,markedTemp(i)]))
          END
          'EXP':BEGIN
            nCols=6
            headers=tableHeaders.XRAY.EXP.Alt1;['kVp','mAs','EI','DAP','SDD','DetID']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=expRes[*,markedTemp(i)]
          END

          'MTF':BEGIN
            szMTF=SIZE(MTFres, /TNAME)
            IF szMTF EQ 'STRUCT' THEN BEGIN
              ;table results 0.5-2.5 lp/mm + frq @ MTF 0.5
              nCols=6
              headers=tableHeaders.XRAY.MTF.Alt1;['MTF @ 0.5/mm','MTF @ 1.0/mm','MTF @ 1.5/mm','MTF @ 2.0/mm','MTF @ 2.5/mm','Freq @ MTF 0.5']
              resArrString=STRARR(nCols,nRows)
              multipRes=WHERE(TAG_NAMES(MTFres) EQ 'M0')
              WIDGET_CONTROL, cw_tableMTFX, GET_VALUE= tableWhich
              IF multipRes(0) NE -1 THEN BEGIN
                IF tableWhich EQ 0 THEN BEGIN
                  FOR i =0, nRows-1 DO IF N_TAGS(MTFres.(markedTemp(i))) NE 1 THEN resArrString[*,i]=STRING(MTFres.(markedTemp(i)).lpmm, FORMAT='(F0.3)')
                ENDIF ELSE BEGIN
                  FOR i =0, nRows-1 DO IF N_TAGS(MTFres.(markedTemp(i))) NE 1 THEN resArrString[*,i]=STRING(MTFres.(markedTemp(i)).lpmm_discrete, FORMAT='(F0.3)')
                ENDELSE
              ENDIF ELSE BEGIN
                IF tableWhich EQ 0 THEN BEGIN
                  resArrString[*,0]=STRING(MTFres.lpmm, FORMAT='(F0.3)')
                ENDIF ELSE BEGIN
                  resArrString[*,0]=STRING(MTFres.lpmm_discrete, FORMAT='(F0.3)')
                ENDELSE
              ENDELSE
            ENDIF ELSE resArrString=STRARR(6,nRows)
          END

          'ROI': BEGIN
            nCols=2
            headers=tableHeaders.XRAY.ROI.Alt1;[mean,stdev]
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(ROIres[*,markedTemp(i)],FORMAT=formatCode(ROIres[*,markedTemp(i)]))
          END

          'NPS':
          ELSE:
        ENDCASE
      ENDIF
    END
    ;******************************** NM *************************************************
    2:BEGIN
      curTab=WIDGET_INFO(wtabAnalysisNM, /TAB_CURRENT)
      IF results(curTab) EQ 1 THEN BEGIN

        CASE analyse OF

          'UNIF':BEGIN
            nCols=4
            headers=tableHeaders.NM.UNIF.Alt1;['IU_UFOV %', 'DU_UFOV %', 'IU_CFOV %', 'DU_CFOV %']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(unifRes.table[0:3,markedTemp(i)], FORMAT='(F0.2)')
          END

          'SNI':BEGIN
            nCols=9
            headers=tableHeaders.NM.SNI.Alt1;['SNI max','SNI L1','SNI L2','SNI S1','SNI S2','SNI S3','SNI S4','SNI S5','SNI S6']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO IF N_TAGS(SNIres.(markedTemp(i))) NE 1 THEN resArrString[*,i]=STRING(SNIres.(markedTemp(i)).SNIvalues, FORMAT='(F0.2)')
          END

          'ACQ':BEGIN
            nCols=2
            headers=tableHeaders.NM.ACQ.Alt1;['Total Count','Frame Duration (ms)']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(acqRes[*,markedTemp(i)], FORMAT='(i0)')
          END

          'BAR': BEGIN
            nCols=8
            headers=tableHeaders.NM.BAR.Alt1;['MTF_1','MTF_2','MTF_3','MTF_4','FWHM1','FWHM2','FWHM3','FWHM4']
            resArrString=STRARR(nCols, nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(barRes[*,markedTemp(i)], FORMAT='(F0.3)')
          END

          'ENERGYSPEC': BEGIN
            nCols=7
            nRows=2
            cellSelHighLight=0
            headers=['Method','Max (counts)','keV at max','Stdev (keV)','FWHM','FWTM','Energy res.']
            resArrString=STRARR(nCols,nRows)
            resArrString(0,0)='Interpolated'
            maxC=MAX(energyRes.curve[1,*])
            resArrString(1,0)=STRING(maxC, FORMAT='(i0)')
            posMax=WHERE(energyRes.curve[1,*] EQ maxC)
            IF posMax GT N_ELEMENTS(energyRes.curve[0,*])-11 THEN BEGIN
              sv=DIALOG_MESSAGE('Max point in curve to close to end of curve. Calculation not possible.', DIALOG_PARENT=evTop)
            ENDIF ELSE BEGIN
              resArrString(2,0)=STRING(energyRes.curve[0,posMax], FORMAT='(f0.2)')
              resArrString(3,0)='-'
              dx=TOTAL(energyRes.curve[0,posMax-10:posMax+10]-energyRes.curve[0,posMax-11:posMax+9])/21.;mean dx assume close to equispaced
              fwhm=(getWidthAtThreshold(energyRes.curve[1,*],0.5*maxC))*dx  &  fwhm=fwhm(0)
              fwtm=(getWidthAtThreshold(energyRes.curve[1,*],0.1*maxC))*dx  &  fwtm=fwtm(0)
              resArrString(4,0)=STRING(fwhm, FORMAT=formatCode(fwhm))
              resArrString(5,0)=STRING(fwtm, FORMAT=formatCode(fwtm))
              resArrString(6,0)=STRING(100.0*fwhm/energyRes.curve[0,posMax], FORMAT='(f0.2," %")')

              resArrString(0,1)='Gaussian fit'
              resArrString(1,1)=STRING(energyRes.gausscoeff(0), FORMAT=formatCode(energyRes.gausscoeff(0)))
              resArrString(2,1)=STRING(energyRes.gausscoeff(1), FORMAT=formatCode(energyRes.gausscoeff(1)))
              resArrString(3,1)=STRING(energyRes.gausscoeff(2), FORMAT=formatCode(energyRes.gausscoeff(2)))
              fwhm=energyRes.gausscoeff(2)*2*SQRT(2*ALOG(2))
              fwtm=energyRes.gausscoeff(2)*2*SQRT(2*ALOG(10))
              resArrString(4,1)=STRING(fwhm, FORMAT=formatCode(fwhm))
              resArrString(5,1)=STRING(fwtm, FORMAT=formatCode(fwtm))
              resArrString(6,1)=STRING(100.0*fwhm/energyRes.gausscoeff(1), FORMAT='(f0.2," %")')
            ENDELSE
          END

          'MTF': BEGIN
            IF SIZE(MTFres, /TNAME) EQ 'STRUCT' THEN BEGIN
              tagMTFres=tag_names(MTFres)

              WIDGET_CONTROL, cw_typeMTFNM, GET_VALUE=typeMTF
              IF typeMTF EQ 0 THEN nCols=4 ELSE nCols=2
              IF typeMTF EQ 0 THEN headers=['FWHM x (mm)','FWTM x (mm)','FWHM y (mm)','FWTM y (mm)'] ELSE headers=['FWHM (mm)','FWTM (mm)']
              multipRes=WHERE(tagMTFres EQ 'M0')
              IF multipRes(0) NE -1 THEN BEGIN
                resArrString=STRARR(4,nRows)
                FOR i =0, nRows-1 DO BEGIN
                  tagMTFresThis=tag_names(MTFres.(markedTemp(i)))
                  IF tagMTFresThis.HasValue('FITLSFX') THEN BEGIN
                    xprof=MTFres.(markedTemp(i)).fitLSFx
                    maxval=max(xprof)
                    minval=min(xprof)
                    resFWHM=getWidthAtThreshold(xprof,(maxval+minval)/2.)
                    resFWTM=getWidthAtThreshold(xprof,(maxval-minval)/10.+minval)

                    IF typeMTF EQ 0 THEN pixFac=1. ELSE pixFac=0.1
                    resArrString[0:1,i]=[STRING(resFWHM(0)*pixFac*pix,FORMAT='(f0.3)'),STRING(resFWTM(0)*pixFac*pix,FORMAT='(f0.3)')]
                    IF typeMTF EQ 0 THEN BEGIN
                      yprof=MTFres.(markedTemp(i)).fitLSFy
                      maxval=max(yprof)
                      minval=min(yprof)
                      resFWHM=getWidthAtThreshold(yprof,(maxval+minval)/2.)
                      resFWTM=getWidthAtThreshold(yprof,(maxval-minval)/10.+minval)
                      resArrString[2:3,i]=[STRING(resFWHM(0)*pixFac*pix,FORMAT='(f0.3)'),STRING(resFWTM(0)*pixFac*pix,FORMAT='(f0.3)')]
                    ENDIF
                    IF tagMTFresThis.HasValue('FWHMG') THEN BEGIN
                      resArrString[2:3,i]=[STRING(MTFres.(markedTemp(i)).FWHMG,FORMAT='(f0.3)'),STRING(MTFres.(markedTemp(i)).FWTMG,FORMAT='(f0.3)')]
                    ENDIF
                  ENDIF
                ENDFOR
                IF nRows EQ 1 THEN noFWHMg=WHERE(resArrString[2:3] NE '') ELSE noFWHMg=WHERE(resArrString[2,*] NE '')
                IF noFWHMg(0) NE -1 THEN BEGIN
                  nCols=4
                  headers=['FWHM LSF smoothed (mm)','FWTM LSF smoothed (mm)','FWHM (mm)','FWTM (mm)']
                ENDIF
              ENDIF
            ENDIF

          END
          ELSE:
        ENDCASE
      ENDIF
    END; NM

    ;******************************** SPECT *************************************************
    3:BEGIN
      curTab=WIDGET_INFO(wtabAnalysisSPECT, /TAB_CURRENT)
      IF results(curTab) EQ 1 THEN BEGIN

        CASE analyse OF

          'CONTRAST':BEGIN
            szTab=SIZE(contrastRes, /DIMENSIONS)
            nCols=szTab(0)*2-1
            headers=['min 1','min 2','min 3','min 4','min 5','min 6', 'Background','%Con 1','%Con 2','%Con 3','%Con 4','%Con 5','%Con 6']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO BEGIN
              resArrString[0:5,i]=STRING(contrastRes[0:5,markedTemp(i)], FORMAT=formatCode(contrastRes[0:5,markedTemp(i)]))
              resArrString[6,i]=STRING(contrastRes[6,markedTemp(i)], FORMAT=formatCode(contrastRes[6,markedTemp(i)]))
              contr=-(contrastRes[0:5,markedTemp(i)]-contrastRes(6,markedTemp(i)))/contrastRes(6,markedTemp(i))
              resArrString[7:12,i]=STRING(contr, FORMAT=formatCode(contr))
            ENDFOR
          END

          'MTF': BEGIN
            tagMTFres=tag_names(MTFres)
            resforeach=WHERE(tagMTFres EQ 'M0')
            v3d=0
            IF resforeach(0) EQ -1 THEN v3d=1

            WIDGET_CONTROL, cw_typeMTFSPECT, GET_VALUE=typeMTF
            IF typeMTF EQ 0 THEN nCols=4 ELSE nCols=2
            IF typeMTF EQ 0 THEN headers=['FWHM x (mm)','FWTM x (mm)','FWHM y (mm)','FWTM y (mm)'] ELSE headers=['FWHM (mm)','FWTM (mm)']

            IF v3d EQ 1 THEN BEGIN
              IF tagMTFres.HasValue('FITLSFX') THEN BEGIN
                nRows=1
                cellSelHighLight=0
                xprof=MTFres.fitLSFx
                maxval=max(xprof)
                minval=min(xprof)
                resFWHM=getWidthAtThreshold(xprof,(maxval+minval)/2.)
                resFWTM=getWidthAtThreshold(xprof,(maxval-minval)/10.+minval)
                resArrString=[STRING(resFWHM(0)*0.1*pix,FORMAT='(f0.3)'),STRING(resFWTM(0)*0.1*pix,FORMAT='(f0.3)')]
                IF tagMTFres.HasValue('FWHMG') THEN BEGIN
                  headers=['FWHM LSF smoothed (mm)','FWTM LSF smoothed (mm)','FWHM (mm)','FWTM (mm)']
                  nCols=4
                  resArrString=[resArrString, STRING(MTFres.FWHMG,FORMAT='(f0.3)'),STRING(MTFres.FWTMG,FORMAT='(f0.3)')]
                ENDIF
              ENDIF
            ENDIF ELSE BEGIN
              multipRes=WHERE(tagMTFres EQ 'M0')
              IF multipRes(0) NE -1 THEN BEGIN
                resArrString=STRARR(4,nRows)
                FOR i =0, nRows-1 DO BEGIN
                  tagMTFresThis=tag_names(MTFres.(markedTemp(i)))
                  IF tagMTFresThis.HasValue('FITLSFX') THEN BEGIN
                    xprof=MTFres.(markedTemp(i)).fitLSFx
                    maxval=max(xprof)
                    minval=min(xprof)
                    resFWHM=getWidthAtThreshold(xprof,(maxval+minval)/2.)
                    resFWTM=getWidthAtThreshold(xprof,(maxval-minval)/10.+minval)

                    IF typeMTF EQ 0 THEN pixFac=1. ELSE pixFac=0.1
                    resArrString[0:1,i]=[STRING(resFWHM(0)*pixFac*pix,FORMAT='(f0.3)'),STRING(resFWTM(0)*pixFac*pix,FORMAT='(f0.3)')]
                    IF typeMTF EQ 0 THEN BEGIN
                      yprof=MTFres.(markedTemp(i)).fitLSFy
                      maxval=max(yprof)
                      minval=min(yprof)
                      resFWHM=getWidthAtThreshold(yprof,(maxval+minval)/2.)
                      resFWTM=getWidthAtThreshold(yprof,(maxval-minval)/10.+minval)
                      resArrString[2:3,i]=[STRING(resFWHM(0)*pixFac*pix,FORMAT='(f0.3)'),STRING(resFWTM(0)*pixFac*pix,FORMAT='(f0.3)')]
                    ENDIF
                    IF tagMTFresThis.HasValue('FWHMG') THEN BEGIN
                      resArrString[2:3,i]=[STRING(MTFres.(markedTemp(i)).FWHMG,FORMAT='(f0.3)'),STRING(MTFres.(markedTemp(i)).FWTMG,FORMAT='(f0.3)')]
                    ENDIF
                  ENDIF
                ENDFOR
                IF nRows EQ 1 THEN noFWHMg=WHERE(resArrString[2:3] NE '') ELSE noFWHMg=WHERE(resArrString[2,*] NE '')
                IF noFWHMg(0) NE -1 THEN BEGIN
                  nCols=4
                  headers=['FWHM LSF smoothed (mm)','FWTM LSF smoothed (mm)','FWHM (mm)','FWTM (mm)']
                ENDIF
              ENDIF

            ENDELSE

          END

          ELSE:
        ENDCASE

      ENDIF
    END

    ;******************************** PET *************************************************
    4:BEGIN
      curTab=WIDGET_INFO(wtabAnalysisPET, /TAB_CURRENT)
      IF results(curTab) EQ 1 THEN BEGIN

        CASE analyse OF
          'CROSSCALIB': BEGIN
            nCols=3
            headers=['Mean pixel value','stdev','Mean of means']
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO BEGIN
              resArrString[0,i]=STRING(crossRes[0,markedTemp(i)],FORMAT=formatCode(crossRes[0,markedTemp(i)]))
              resArrString[1,i]=STRING(crossRes[1,markedTemp(i)],FORMAT=formatCode(crossRes[1,markedTemp(i)]))
            ENDFOR
            IF nRows GT 1 THEN resArrString[2,0]=STRING(crossRes[2,0],FORMAT=formatCode(crossRes[2,0]))
          END
          'HOMOG': BEGIN
            szTab=SIZE(homogRes, /DIMENSIONS)
            nCols=10
            headers=tableHeaders.PET.HOMOG.Alt1;['Center','12oClock','15oClock','18oClock','21oClock','dMean C','dMean 12','dMean 15','dMean 18','dMean 21']
            resArrString=STRARR(nCols,nRows)
            resMarked=FLTARR(szTab(0),N_ELEMENTS(markedTemp))

            FOR i=0, nRows-1 DO resMarked[*,i]=homogRes[*,markedTemp(i)]
            meanVals=TOTAL(resMarked,2)/nRows
            formatVal=formatCode(MEAN(resMarked[0:4,*]))
            formatDiff=formatCode(MEAN(resMarked[5:9,*]))
            formatDiff=STRMID(formatDiff, 0, STRLEN(formatDiff)-1)
            FOR i=0, nRows-1 DO BEGIN
              resMarked[5:9,i]=100.*(resMarked[0:4,i]-meanVals)/meanVals
              resArrString[0:4,i]=STRING(resMarked[0:4,i], FORMAT=formatVal)
              resArrString[5:9,i]=STRING(resMarked[5:9,i], FORMAT=formatDiff+', "%")')
            ENDFOR
          END
          'RC': BEGIN
            nCols=7
            WIDGET_CONTROL, cw_rcType, GET_VALUE=meanOrMax
            IF meanOrMax EQ 0 THEN BEGIN
              headers =['A50 '+STRING(INDGEN(6)+1, FORMAT='(i0)'), 'BackGround']
              resArrString=[STRING(rcRes[7:12],FORMAT=formatCode(rcRes[7:12])), STRING(rcRes[6],FORMAT=formatCode(rcRes[6]))]
            ENDIF ELSE BEGIN
              headers =['Max '+STRING(INDGEN(6)+1, FORMAT='(i0)'), 'BackGround']
              resArrString=STRING(rcRes[0:6],FORMAT=formatCode(rcRes[0:6]))
            ENDELSE
          END
          ELSE:
        ENDCASE

      ENDIF
    END; PET
    ;******************************** MR *************************************************
    5:BEGIN
      curTab=WIDGET_INFO(wtabAnalysisMR, /TAB_CURRENT)
      IF results(curTab) EQ 1 THEN BEGIN

        CASE analyse OF
          'DCM':BEGIN
            nCols=3
            headers=tableHeaders.MR.DCM.Alt1
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=expRes[*,markedTemp(i)]
          END
          
          'SNR':BEGIN
            headers=tableHeaders.MR.SNR.Alt1
            nCols=N_ELEMENTS(headers)
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(SNRres[*,markedTemp(i)], FORMAT=formatCode(SNRres[*,markedTemp(i)]))
          END

          'PIU':BEGIN
            headers=tableHeaders.MR.PIU.Alt1
            nCols=N_ELEMENTS(headers)
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(PIUres[0:nCols-1,markedTemp(i)], FORMAT='(f0.1)')
          END
          
          'GHOST':BEGIN
            headers=tableHeaders.MR.GHOST.Alt1
            nCols=N_ELEMENTS(headers)
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO BEGIN
              resArrString[0:4,i]=STRING(ghostMRres[0:4,markedTemp(i)], FORMAT=formatCode(ghostMRres[0:4,markedTemp(i)]))
              resArrString[5,i]=STRING(ghostMRres[5,markedTemp(i)], FORMAT='(f0.2)')
            ENDFOR
          END
          
          'GEOMDIST': BEGIN
            headers=tableHeaders.MR.GEOMDIST.Alt1
            nCols=N_ELEMENTS(headers)
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO BEGIN
              resArrString[0:3,i]=STRING(GeomDistRes[0:3,markedTemp(i)], FORMAT=formatCode(GeomDistRes[0:3,markedTemp(i)]))
              resArrString[4:7,i]=STRING(GeomDistRes[4:7,markedTemp(i)], FORMAT=formatCode(GeomDistRes[4:7,markedTemp(i)]))
            ENDFOR
          END
          
          'SLICETHICK': BEGIN
            headers=tableHeaders.MR.SLICETHICK.Alt1
            nCols=N_ELEMENTS(headers)
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(sliceThickResTab[0:3,markedTemp(i)], FORMAT='(f0.1)')
          END
          
          'ROI': BEGIN
            nCols=2
            headers=tableHeaders.MR.ROI.Alt1;[mean,stdev]
            resArrString=STRARR(nCols,nRows)
            FOR i=0, nRows-1 DO resArrString[*,i]=STRING(ROIres[*,markedTemp(i)],FORMAT=formatCode(ROIres[*,markedTemp(i)]))
          END

          ;          'POS':BEGIN
          ;            nCols=2
          ;            headers=tableHeaders.MR.POS.Alt1
          ;            resArrString=STRARR(nCols,nRows)
          ;            FOR i=0, nRows-1 DO resArrString[*,i]=MRposRes[*,markedTemp(i)]
          ;          END
          ELSE:
        ENDCASE
      ENDIF
    END;MR

  ENDCASE

  IF nCols EQ -1 THEN BEGIN
    WIDGET_CONTROL, resTab, TABLE_XSIZE=4, TABLE_YSIZE=2, COLUMN_LABELS=['0','1','2','3'], COLUMN_WIDTHS=[100,100,100,100], $
      SET_VALUE=STRARR(4,5), SET_TABLE_SELECT=[-1,-1,-1,-1], SET_TABLE_VIEW=[0,0], FOREGROUND_COLOR=[0,0,0]
  ENDIF ELSE BEGIN
    ;which cell should be highlighted
    tabSelect=[-1,-1,-1,-1]
    IF cellSelHighLight THEN BEGIN
      markedArr=INTARR(nImg)
      ;tabSelect=[-1,-1,-1,-1]
      tabView=[0,0]
      IF N_ELEMENTS(szM) EQ 2 THEN nI=MIN([nImg,szM(1)]) ELSE nI=nImg
      IF marked(0) NE -1 THEN markedArr(marked)=1 ELSE markedArr[0:nI-1]=1

      IF sel LT nI THEN BEGIN
        IF markedArr(sel) EQ 1 THEN BEGIN
          nMarked=TOTAL(markedArr)
          IF marked(0) EQ -1 THEN rowNo=sel ELSE rowNo=WHERE(marked EQ sel)
          ; select row in result-table according to file
          oldSel=WIDGET_INFO(resTab,/TABLE_SELECT)
          colNo=oldSel(0);keep column number
          If colNo NE -1 THEN tabSelect=[colNo,rowNo,colNo,rowNo] ELSE tabSelect=[0,rowNo,nCols-1,rowNo]
        ENDIF
      ENDIF
      oldView=WIDGET_INFO(resTab,/TABLE_VIEW)
      tabView(0)=oldView(0)
      IF N_ELEMENTS(rowNo) GT 0 THEN BEGIN
        IF rowNo GT oldView(1)+10 OR rowNO LT oldView(1) THEN tabView(1)=rowNo ELSE tabView(1)=oldView(1)
      ENDIF ELSE tabView(1)=oldView(1)
    ENDIF

    IF nCols GT 0 THEN BEGIN
      WIDGET_CONTROL, resTab, TABLE_XSIZE=nCols, TABLE_YSIZE=nRows, COLUMN_LABELS=headers, COLUMN_WIDTHS=INTARR(nCols)+630/nCols, SET_VALUE=resArrString, ALIGNMENT=1
      IF MIN(tabSelect) EQ -1 THEN WIDGET_CONTROL, resTab, SET_TABLE_SELECT=[-1,-1,-1,-1] ELSE WIDGET_CONTROL, resTab, SET_TABLE_SELECT=tabSelect
      WIDGET_CONTROL, resTab, FOREGROUND_COLOR=[0,0,0]
      IF markedMulti(0) NE -1 AND TOTAL(markedMulti) GT 0 AND nRows GT 1 THEN BEGIN
        testNmb=getResNmb(modality,analyse,analyseStringsAll)
        markedArrTemp=markedMulti[testNmb,*]
        nI=MIN([nImg,N_ELEMENTS(markedArrTemp)])
        FOR ii=0, nI-1 DO BEGIN
          IF markedArrTemp(ii) EQ 0 THEN WIDGET_CONTROL, resTab, USE_TABLE_SELECT=[0,ii,nCols-1,ii], FOREGROUND_COLOR=[200,200,200]
        ENDFOR
      ENDIF
    ENDIF ELSE WIDGET_CONTROL, resTab, TABLE_XSIZE=4, TABLE_YSIZE=2, COLUMN_LABELS=['0','1','2','3'], COLUMN_WIDTHS=[100,100,100,100], SET_VALUE=STRARR(4,5), SET_TABLE_SELECT=tabSelect, FOREGROUND_COLOR=[0,0,0]

    WIDGET_CONTROL, resTab, SET_TABLE_VIEW=tabView

  ENDELSE
end
