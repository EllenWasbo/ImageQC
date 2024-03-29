;ImageQC - quality control of medical images
;Copyright (C) 2018 Ellen Wasbo, Stavanger University Hospital, Norway
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

pro exportMulti
  COMPILE_OPT hidden
  COMMON VARI
   
  IF N_ELEMENTS(multiExpTable) GT 1 THEN BEGIN

    IF copyHeader EQ 0 THEN BEGIN
      szME=SIZE(multiExpTable, /DIMENSIONS)
      multiExpTableTemp=multiExpTable[1:szME(0)-1,*] 
    ENDIF ELSE multiExpTableTemp=multiExpTable

    incFilenames=WIDGET_INFO(btnIncFilename, /BUTTON_SET)
    imgWithMark=WHERE(TOTAL(markedMulti,1) GT 0, nFilenames)
    IF incFilenames EQ 0 THEN BEGIN;remove filenames
      dateLine=multiExpTableTemp[*,0]
      resultsTab=multiExpTableTemp[*,nFilenames+1:-1]
      multiExpTableTemp=[[dateLine],[resultsTab]]
      nAvoidDeciMark=0
    ENDIF ELSE nAvoidDeciMark=nFilenames
    
    ;IF incFilenames THEN imgWithMark=WHERE(TOTAL(markedMulti,1) GT 0, nAvoidDeciMark) ELSE nAvoidDeciMark=0
    szT=SIZE(multiExpTableTemp, /DIMENSIONS)
    IF deciMark EQ ',' THEN BEGIN
      IF N_ELEMENTS(szT) EQ 2 THEN BEGIN
        FOR i=0, szT(0)-1 DO BEGIN
          FOR j=nAvoidDeciMark+1, szT(1)-1 DO BEGIN
            multiExpTableTemp[i,j]=STRJOIN(STRSPLIT(multiExpTableTemp[i,j], '.',/EXTRACT),',')
          ENDFOR
        ENDFOR
      ENDIF ELSE BEGIN
        FOR i=nAvoidDeciMark+1, szT(0)-1 DO multiExpTableTemp[i]=STRJOIN(STRSPLIT(multiExpTableTemp[i], '.',/EXTRACT),',')
      ENDELSE
    ENDIF

    IF transposeTable EQ 1 THEN multiExpTableTemp=TRANSPOSE(multiExpTableTemp)

    CLIPBOARD.set, STRJOIN(multiExpTableTemp, STRING(9B))
  ENDIF ELSE sv=DIALOG_MESSAGE('No results to copy to clipboard.', DIALOG_PARENT=evTop)
  
end