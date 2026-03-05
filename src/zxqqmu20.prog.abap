*****&---------------------------------------------------------------------*
*****& Include          ZXQQMU20
*****&---------------------------------------------------------------------*
DATA:SYSTEM_STATUS_LINE TYPE BSVX-STTXT.
BREAK AC_ADNAN.
CHECK SY-TCODE = 'IW21' OR  SY-TCODE = 'IW22' OR  SY-TCODE = 'IW31' OR  SY-TCODE = 'IW32'  OR  SY-TCODE = 'IW34'.
IMPORT SYSTEM_STATUS_LINE TO SYSTEM_STATUS_LINE FROM MEMORY ID 'SYSTEM_STATUS_LINE'.
IF SYSTEM_STATUS_LINE CS  'NOCO' AND (
     E_VIQMEL-QMART = 'M1'
     OR E_VIQMEL-QMART = 'M2' ).
  FIELD-SYMBOLS:<FS> TYPE ANY.
  ASSIGN ('(SAPLIQS0)VIQMFE-OTGRP') TO <FS>.
  IF <FS> IS ASSIGNED.
    IF <FS> IS INITIAL.
      MESSAGE 'Object Parts required at time of document complete' TYPE 'I' DISPLAY LIKE 'E'.
      RAISE EXIT_FROM_SAVE.
    ENDIF.
  ENDIF.
  UNASSIGN <FS>.

  ASSIGN ('(SAPLIQS0)VIQMFE-OTEIL') TO <FS>.
  IF <FS> IS ASSIGNED.
    IF <FS> IS INITIAL.
      MESSAGE 'Part of Object required at time of document complete' TYPE 'I' DISPLAY LIKE 'E'.
      RAISE EXIT_FROM_SAVE.
    ENDIF.
  ENDIF.
  UNASSIGN <FS>.

  ASSIGN ('(SAPLIQS0)VIQMFE-FEGRP') TO <FS>.
  IF <FS> IS ASSIGNED.
    IF <FS> IS INITIAL.
      MESSAGE 'Damage Code required at time of document complete' TYPE 'I' DISPLAY LIKE 'E'.
      RAISE EXIT_FROM_SAVE.
    ENDIF.
  ENDIF.
  UNASSIGN <FS>.

  ASSIGN ('(SAPLIQS0)VIQMFE-FECOD') TO <FS>.
  IF <FS> IS ASSIGNED.
    IF <FS> IS INITIAL.
      MESSAGE 'Damage Code required at time of document complete' TYPE 'I' DISPLAY LIKE 'E'.
      RAISE EXIT_FROM_SAVE.
    ENDIF.
  ENDIF.
  UNASSIGN <FS>.
ENDIF.
"Notification User Checkon release
SELECT SINGLE * FROM ZPM_WF_HST INTO @DATA(LS_HST)
  WHERE QMNUM = @E_VIQMEL-QMNUM.
IF SY-SUBRC <> 0.
  IF SYSTEM_STATUS_LINE = 'NOPR'.
    DATA: I_WF_ID   TYPE CHAR10,
          PARAMETER TYPE STANDARD TABLE OF SPAR,
          LV_ANS    TYPE CHAR01.
    BREAK AC_WF7.
    SELECT SINGLE ARBPL FROM CRHD INTO @DATA(LV_ARBPL)
      WHERE OBJID = @E_VIQMEL-ARBPL.

    IF ( ( E_VIQMEL-QMART EQ 'M1' OR E_VIQMEL-QMART EQ 'M2' )  AND  E_VIQMEL-INGRP <> 'PRD'  AND  LV_ARBPL(2) <> 'FA' ).
      I_WF_ID = 'WF-1.1'.
    ELSEIF ( ( E_VIQMEL-QMART EQ 'M1' OR E_VIQMEL-QMART EQ 'M2' )  AND  E_VIQMEL-INGRP EQ 'PRD'  AND  LV_ARBPL(2) <> 'FA' ).
      I_WF_ID = 'WF-1.2'.
    ELSEIF ( E_VIQMEL-QMART EQ 'M1'  AND  E_VIQMEL-INGRP <> 'PRD'  AND  LV_ARBPL(2) EQ 'FA' ).
      I_WF_ID = 'WF-1.3'.
    ELSEIF ( E_VIQMEL-QMART EQ 'M1'  AND  E_VIQMEL-INGRP EQ 'PRD'  AND LV_ARBPL(2) EQ 'FA' ).
      I_WF_ID = 'WF-1.4'.
    ELSEIF ( E_VIQMEL-QMART EQ 'M8'  AND  E_VIQMEL-TPLNR(3) EQ E_VIQMEL-ZQMTXT(3) )."e_viqmel-INGRP EQ 'MNT'  AND  e_viqmel-ARBPL(3) EQ 'MNT' ).
      I_WF_ID = 'WF-3'. "Inter Concession
    ELSEIF ( E_VIQMEL-QMART EQ 'M8'  AND  E_VIQMEL-TPLNR(3) NE E_VIQMEL-ZQMTXT(3) ).
      I_WF_ID = 'WF-4'. "Intra Concession
    ELSEIF ( E_VIQMEL-QMART EQ 'T4'  AND  E_VIQMEL-INGRP EQ 'MNT'  AND LV_ARBPL(3) EQ 'MNT' ).
      I_WF_ID = 'WF-5'.
    ELSEIF E_VIQMEL-QMART EQ 'M7'.
      I_WF_ID = 'WF-7'.
    ENDIF.

    IF I_WF_ID IS NOT INITIAL.
      SELECT SINGLE ZACTIVE FROM ZPM_WF INTO @DATA(LV_ACTIVE)
         WHERE WF_ID = @I_WF_ID.
      IF SY-SUBRC = 0.
        IF LV_ACTIVE <> 'X'.
          MESSAGE |Workflow { I_WF_ID } is not active| TYPE 'I' DISPLAY LIKE 'E'.
          RAISE EXIT_FROM_SAVE.
        ENDIF.

        DATA LV_RTYPE   TYPE SY-MSGTY.
        DATA LV_MESSAGE TYPE CHAR255.
        CLEAR: LV_RTYPE,  LV_MESSAGE.
        CALL FUNCTION 'ZPM_FM_CHECK_WF_SETTING_ALL'
          EXPORTING
            WF_ID   = I_WF_ID
            USER    = SY-UNAME
            VIQMEL  = E_VIQMEL
          IMPORTING
            RTYPE   = LV_RTYPE
            MESSAGE = LV_MESSAGE.
        IF LV_RTYPE = 'E'.
          MESSAGE |{ LV_MESSAGE }| TYPE 'I' DISPLAY LIKE 'E'.
          RAISE EXIT_FROM_SAVE.
        ENDIF.

      ENDIF.
    ENDIF.
  ENDIF.
ENDIF.

*For Restriction Type M8
IF  e_viqmel-qmart = 'M8'. "E_VIQMEL-QMART = 'M3' OR E_VIQMEL-QMART = 'T3' OR E_VIQMEL-QMART = 'M7' OR
  IF e_viqmel-zqmtxt IS INITIAL.
    MESSAGE 'Target Functional Location required at time of document save' TYPE 'I' DISPLAY LIKE 'E'.
    RAISE exit_from_save.
  ELSE. " Check if the Target Funcitonal location value is correct . " CRF : by Khokhar, Zeeshan N on 18-Sept-2023 Sub:FATF - Functional Location
    DATA(lv_len) = strlen( e_viqmel-zqmtxt ).
    IF lv_len < 31.
      SELECT SINGLE tplnr FROM iflot INTO @DATA(lv_tplnr) WHERE tplnr = @e_viqmel-zqmtxt(30).
      IF lv_tplnr IS INITIAL.
        MESSAGE 'Please enter correct Target Functional Location' TYPE 'I' DISPLAY LIKE 'E'.
        RAISE exit_from_save.
      ENDIF.
    ELSE.
      MESSAGE 'Please enter correct Target Functional Location' TYPE 'I' DISPLAY LIKE 'E'.
      RAISE exit_from_save.
    ENDIF.
  ENDIF.
ENDIF.

*CRF : check Cost Center company code is same as in notification
    IF   e_viqmel-kostl IS NOT INITIAL.
      SELECT SINGLE BUKRS FROM CSKS INTO @DATA(BUKRS)
  WHERE KOKRS = @e_viqmel-KOKRS and kostl = @e_viqmel-kostl and DATBI = '99991231'.
      IF sy-subrc = 0.
        IF BUKRS NE e_viqmel-bukrs.
          MESSAGE 'Cost Center pertains to different Company Code.' TYPE 'I' DISPLAY LIKE 'E'.
            RAISE exit_from_save.
        ENDIF.
      ENDIF.
    ENDIF.

*For WBS Restriction.

"Comment by Adil
*IF  E_VIQMEL-QMART = 'M7' OR E_VIQMEL-QMART = 'M8'.
*  IF E_VIQMEL-PROID IS INITIAL.
*    MESSAGE 'WBS Element required at time of document save' TYPE 'I' DISPLAY LIKE 'E'.
*    RAISE EXIT_FROM_SAVE.
*  ENDIF.
*ENDIF.
"M7" and "M8"
" BOC
*IF  E_VIQMEL-QMART = 'M7' OR E_VIQMEL-QMART = 'M8'.
IF E_VIQMEL-PROID IS INITIAL
AND E_VIQMEL-KOSTL IS INITIAL.
  MESSAGE 'Please maintain Work Breakdown Structure Element or Cost Center' TYPE 'I' DISPLAY LIKE 'E'.


  RAISE EXIT_FROM_SAVE.
ENDIF.
*ENDIF.
"EOC


IF E_VIQMEL-PROID IS NOT INITIAL.
  SELECT SINGLE PBUKR FROM PRPS INTO @DATA(LV_BUKRS)
    WHERE PSPNR = @E_VIQMEL-PROID.
  IF SY-SUBRC = 0.
    if LV_BUKRS ne E_VIQMEL-BUKRS.
      MESSAGE 'WBS pertains to different Company Code.' TYPE 'I' DISPLAY LIKE 'E'.
      RAISE EXIT_FROM_SAVE.
  ENDIF.
ENDIF.
ENDIF.


*Restrict Order Createion Based on User Status
BREAK AC_ADNAN.
ASSIGN ('(SAPLIQS0)RIWO00-ASTXT') TO <FS>.
IF <FS> IS ASSIGNED.
  IF I_TQ80-AUART IS NOT INITIAL.
    IF SY-UCOMM = 'WEIT' AND I_VIQMEL-QMART = 'T4' AND <FS> <> 'APPR'.
      MESSAGE 'Notification status is not APPR.' TYPE 'I' DISPLAY LIKE 'E'.
      RAISE EXIT_FROM_SAVE.
    ENDIF.
  ENDIF.
ENDIF.

*For Restriction of Activity Type
"IF SYSTEM_STATUS_LINE = 'NOCO'.
*IF E_VIQMEL-ILART IS INITIAL.
*  MESSAGE 'Maintenance activity type required at time of document save' TYPE 'I' DISPLAY LIKE 'E'.
*  RAISE EXIT_FROM_SAVE.
*  "  ENDIF..
*ENDIF.
IF SY-TCODE = 'IW21' OR SY-TCODE = 'IW31' OR SY-TCODE = 'IP30'   OR SY-TCODE = 'IP41' OR SY-TCODE = 'IP10'.
  E_VIQMEL-QMNAM = SY-UNAME.
ENDIF.

*BREAK-POINT. Commit by adnan khan as per PM User may use in future.
"Comment by Adil as this doesnot servce the purpose Date: 27012023
"BOC
*IF  E_VIQMEL-PROID IS NOT  INITIAL.
*********  DATA:LV_OUTPUT TYPE STRING.
*********  CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
*********    EXPORTING
*********      INPUT  = E_VIQMEL-PROID
*********    IMPORTING
*********      OUTPUT = LV_OUTPUT.
*
*
*  DATA : LV_COUNT TYPE I.
*  CLEAR LV_COUNT.
*
*  SELECT  * FROM ZPM_NOT_WBS INTO TABLE @DATA(LT_ACT)
*    WHERE QMART = @E_VIQMEL-QMART
*    AND ( PROID = @E_VIQMEL-PROID  ).
***    AND ( PROID = @LV_OUTPUT  ).
*  LV_COUNT = LINES( LT_ACT ).
*
*  IF LV_COUNT <= 0.
*    MESSAGE 'Structure Element (WBS Element) is restrict'   TYPE 'I' DISPLAY LIKE 'E'.
*    RAISE EXIT_FROM_SAVE.
*  ENDIF.
*ENDIF.
""Comment by Adil as this doesnot servce the purpose Date: 27012023
"EOC



*----- Trigger Notification Workflow -----*
***IF SY-TCODE EQ 'IW21' OR SY-TCODE EQ 'IW31'.
***  DATA: I_WF_ID   TYPE CHAR10,
***        PARAMETER TYPE STANDARD TABLE OF SPAR,
***        LV_ANS    TYPE CHAR01.
***
***  SELECT SINGLE ARBPL FROM CRHD INTO @DATA(LV_ARBPL)
***    WHERE OBJID = @E_VIQMEL-ARBPL.
***
***  IF ( ( E_VIQMEL-QMART EQ 'M1' OR E_VIQMEL-QMART EQ 'M2' )  AND  E_VIQMEL-INGRP <> 'PRD'  AND  LV_ARBPL(2) <> 'FA' ).
***    I_WF_ID = 'WF-1.1'.
***  ELSEIF ( ( E_VIQMEL-QMART EQ 'M1' OR E_VIQMEL-QMART EQ 'M2' )  AND  E_VIQMEL-INGRP EQ 'PRD'  AND  LV_ARBPL(2) <> 'FA' ).
***    I_WF_ID = 'WF-1.2'.
***  ELSEIF ( E_VIQMEL-QMART EQ 'M1'  AND  E_VIQMEL-INGRP <> 'PRD'  AND  LV_ARBPL(2) EQ 'FA' ).
***    I_WF_ID = 'WF-1.3'.
***  ELSEIF ( E_VIQMEL-QMART EQ 'M1'  AND  E_VIQMEL-INGRP EQ 'PRD'  AND  LV_ARBPL(2) EQ 'FA' ).
***    I_WF_ID = 'WF-1.4'.
***  ELSEIF ( E_VIQMEL-QMART EQ 'M8'  AND  E_VIQMEL-INGRP EQ 'MNT'  AND  LV_ARBPL(3) EQ 'MNT' ).
***    I_WF_ID = 'WF-3'.
***  ELSEIF ( E_VIQMEL-QMART EQ 'M8'  AND  E_VIQMEL-INGRP EQ 'MNT'  AND  LV_ARBPL(3) EQ 'MNT'   AND E_VIQMEL-ILART EQ 'ERX' ).
***    I_WF_ID = 'WF-4'.
***  ELSEIF ( E_VIQMEL-QMART EQ 'T4'  AND  E_VIQMEL-INGRP EQ 'MNT'  AND  LV_ARBPL(3) EQ 'MNT' ).
***    I_WF_ID = 'WF-5'.
***  ELSEIF E_VIQMEL-QMART EQ 'M7'.
***    I_WF_ID = 'WF-7'.
***  ENDIF.
***
***  SELECT SINGLE ZACTIVE FROM ZPM_WF INTO @DATA(LV_ACTIVE)
***    WHERE WF_ID = @I_WF_ID.
***
***  BREAK: AC_WF1, AC_ADNAN.
***  IF LV_ACTIVE EQ 'X'.
***    CLEAR LV_ANS.
***    CALL FUNCTION 'POPUP_TO_CONFIRM'
***      EXPORTING
***        TEXT_QUESTION         = |Workflow { I_WF_ID } is idetified, Do you want to proceed furthur?|
***        TEXT_BUTTON_1         = 'Yes'
***        TEXT_BUTTON_2         = 'NO'
***        DEFAULT_BUTTON        = '1'
***        DISPLAY_CANCEL_BUTTON = 'X'
***      IMPORTING
***        ANSWER                = LV_ANS
***      TABLES
***        PARAMETER             = PARAMETER
***      EXCEPTIONS
***        TEXT_NOT_FOUND        = 1.
***
***    IF LV_ANS EQ '1'.
***      CALL FUNCTION 'ZPM_FM_NOTIF_WF'
***        EXPORTING
***          IS_NEW_VIQMEL = E_VIQMEL
***          I_WF_ID       = I_WF_ID.
***    ELSE.
***      MESSAGE 'Choose yes to continue' TYPE 'I' DISPLAY LIKE 'E'.
***      RAISE EXIT_FROM_SAVE.
***    ENDIF.
***
***  ELSE.
***    CLEAR LV_ANS.
***    CALL FUNCTION 'POPUP_TO_CONFIRM'
***      EXPORTING
***        TEXT_QUESTION         = | Workflow { I_WF_ID } is Inactive. Do you want to save?|
***        TEXT_BUTTON_1         = 'Yes'
***        TEXT_BUTTON_2         = 'NO'
***        DEFAULT_BUTTON        = '1'
***        DISPLAY_CANCEL_BUTTON = 'X'
***      IMPORTING
***        ANSWER                = LV_ANS
***      TABLES
***        PARAMETER             = PARAMETER
***      EXCEPTIONS
***        TEXT_NOT_FOUND        = 1.
***    IF LV_ANS EQ '1'.
***    ELSE.
***      RAISE EXIT_FROM_SAVE.
***    ENDIF.
***  ENDIF.
***ENDIF.
