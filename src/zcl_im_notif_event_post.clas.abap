class ZCL_IM_NOTIF_EVENT_POST definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_NOTIF_EVENT_POST .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_NOTIF_EVENT_POST IMPLEMENTATION.


  METHOD IF_EX_NOTIF_EVENT_POST~CHECK_DATA_AT_POST.
**********Restrict Notificaton
*********    BREAK AC_ADNAN.
*********    DATA:SYSTEM_STATUS_LINE TYPE BSVX-STTXT.
*********    IMPORT SYSTEM_STATUS_LINE TO SYSTEM_STATUS_LINE FROM MEMORY ID 'SYSTEM_STATUS_LINE'.
*********    IF SYSTEM_STATUS_LINE = 'NOCO' AND (
*********    " IS_NEW_VIQMEL-QMART = 'M3'
*********    "  OR IS_NEW_VIQMEL-QMART = 'T3'
*********    "  OR IS_NEW_VIQMEL-QMART = 'M7'
*********    "  OR IS_NEW_VIQMEL-QMART = 'M8'
*********      IS_NEW_VIQMEL-QMART = 'M1'
*********      OR IS_NEW_VIQMEL-QMART = 'M2' ).
*********      FIELD-SYMBOLS:<FS> TYPE ANY.
*********      ASSIGN ('(SAPLIQS0)VIQMFE-OTGRP') TO <FS>.
*********      IF <FS> IS ASSIGNED.
*********        IF <FS> IS INITIAL.
*********          MESSAGE 'Object Parts required at time of document complete' TYPE 'I' DISPLAY LIKE 'E'.
**********          RAISE EXIT_FROM_SAVE.
*********        ENDIF.
*********      ENDIF.
*********      UNASSIGN <FS>.
*********
*********      ASSIGN ('(SAPLIQS0)VIQMFE-OTEIL') TO <FS>.
*********      IF <FS> IS ASSIGNED.
*********        IF <FS> IS INITIAL.
*********          MESSAGE 'Part of Object required at time of document complete' TYPE 'E'.
*********        ENDIF.
*********      ENDIF.
*********      UNASSIGN <FS>.
*********
*********      ASSIGN ('(SAPLIQS0)VIQMFE-FEGRP') TO <FS>.
*********      IF <FS> IS ASSIGNED.
*********        IF <FS> IS INITIAL.
*********          MESSAGE 'Code Group required at time of document complete' TYPE 'E'.
*********        ENDIF.
*********      ENDIF.
*********      UNASSIGN <FS>.
*********
*********      ASSIGN ('(SAPLIQS0)VIQMFE-FECOD') TO <FS>.
*********      IF <FS> IS ASSIGNED.
*********        IF <FS> IS INITIAL.
*********          MESSAGE 'Damage Code required at time of document complete' TYPE 'E'.
*********        ENDIF.
*********      ENDIF.
*********      UNASSIGN <FS>.
*********    ENDIF.
*********
**********For Restriction Type M8
*********    IF  IS_NEW_VIQMEL-QMART = 'M8'. "IS_NEW_VIQMEL-QMART = 'M3' OR IS_NEW_VIQMEL-QMART = 'T3' OR IS_NEW_VIQMEL-QMART = 'M7' OR
*********      IF IS_NEW_VIQMEL-ZQMTXT IS INITIAL.
*********        MESSAGE 'Target Functional Location required at time of document save' TYPE 'E'.
*********      ENDIF.
*********    ENDIF.
*********
**********For WBS Restriction.
*********    IF  IS_NEW_VIQMEL-QMART = 'M7' OR IS_NEW_VIQMEL-QMART = 'M8'.
*********      IF IS_NEW_VIQMEL-PROID IS INITIAL.
*********        MESSAGE 'WBS Element required at time of document save' TYPE 'E'.
*********      ENDIF.
*********    ENDIF.
*********    "M7" and "M8"
*********
**********For Restriction of Activity Type
*********    "IF SYSTEM_STATUS_LINE = 'NOCO'.
*********    IF IS_NEW_VIQMEL-ILART IS INITIAL.
*********      MESSAGE 'Maintenance activity type required at time of document save' TYPE 'E'.
*********      "  ENDIF..
*********    ENDIF.

    SELECT SINGLE * FROM ZPM_NOT_WF_RPT
      INTO @DATA(LS_CHECK_DATA)
      WHERE QMNUM = @IS_NEW_VIQMEL-QMNUM.
    IF SY-SUBRC <> 0.

      DATA:SYSTEM_STATUS_LINE TYPE BSVX-STTXT.
      BREAK AC_ADNAN.
      CHECK SY-TCODE = 'IW21' OR  SY-TCODE = 'IW22'." OR  SY-TCODE = 'IW31' OR  SY-TCODE = 'IW32'  OR  SY-TCODE = 'IW34'.
      IMPORT SYSTEM_STATUS_LINE TO SYSTEM_STATUS_LINE FROM MEMORY ID 'SYSTEM_STATUS_LINE'.

*----- Trigger Notification Workflow -----*
*    IF SY-TCODE EQ 'IW21' OR SY-TCODE EQ 'IW31'.
      IF SYSTEM_STATUS_LINE = 'NOPR'.
        DATA: I_WF_ID   TYPE CHAR10,
              PARAMETER TYPE STANDARD TABLE OF SPAR,
              LV_ANS    TYPE CHAR01.

        SELECT SINGLE ARBPL FROM CRHD INTO @DATA(LV_ARBPL)
          WHERE OBJID = @IS_NEW_VIQMEL-ARBPL.

        IF ( ( IS_NEW_VIQMEL-QMART EQ 'M1' OR IS_NEW_VIQMEL-QMART EQ 'M2' )  AND  IS_NEW_VIQMEL-INGRP <> 'PRD'  AND  LV_ARBPL(2) <> 'FA' ).
          I_WF_ID = 'WF-1.1'.
        ELSEIF ( ( IS_NEW_VIQMEL-QMART EQ 'M1' OR IS_NEW_VIQMEL-QMART EQ 'M2' )  AND  IS_NEW_VIQMEL-INGRP EQ 'PRD'  AND  LV_ARBPL(2) <> 'FA' ).
          I_WF_ID = 'WF-1.2'.
        ELSEIF ( IS_NEW_VIQMEL-QMART EQ 'M1'  AND  IS_NEW_VIQMEL-INGRP <> 'PRD'  AND  LV_ARBPL(2) EQ 'FA' ).
          I_WF_ID = 'WF-1.3'.
        ELSEIF ( IS_NEW_VIQMEL-QMART EQ 'M1'  AND  IS_NEW_VIQMEL-INGRP EQ 'PRD'  AND  LV_ARBPL(2) EQ 'FA' ).
          I_WF_ID = 'WF-1.4'.
        ELSEIF ( IS_NEW_VIQMEL-QMART EQ 'M8'  AND  IS_NEW_VIQMEL-TPLNR(3) EQ IS_NEW_VIQMEL-ZQMTXT(3) )."IS_NEW_VIQMEL-INGRP EQ 'MNT'  AND  IS_NEW_VIQMEL-ARBPL(3) EQ 'MNT' ).
          I_WF_ID = 'WF-3'. "Inter Concession
        ELSEIF ( IS_NEW_VIQMEL-QMART EQ 'M8'  AND  IS_NEW_VIQMEL-TPLNR(3) NE IS_NEW_VIQMEL-ZQMTXT(3) ).
          I_WF_ID = 'WF-4'. "Intra Concession
        ELSEIF ( IS_NEW_VIQMEL-QMART EQ 'T4'  AND  IS_NEW_VIQMEL-INGRP EQ 'MNT'  AND  LV_ARBPL(3) EQ 'MNT' ).
          I_WF_ID = 'WF-5'.
        ELSEIF IS_NEW_VIQMEL-QMART EQ 'M7'.
          I_WF_ID = 'WF-7'.
        ENDIF.

        SELECT SINGLE ZACTIVE FROM ZPM_WF INTO @DATA(LV_ACTIVE)
          WHERE WF_ID = @I_WF_ID.

*/**** Check the Workflow is deactivated on the Table.
        SELECT SINGLE ZACTIVE FROM ZTPM0003 INTO @DATA(LV_DEACTIVATE)
          WHERE WF_ID = @I_WF_ID AND WORKCENTER = @LV_ARBPL.
        IF LV_ACTIVE EQ 'X' AND LV_DEACTIVATE IS INITIAL.
          CLEAR LV_ANS.
***          CALL FUNCTION 'POPUP_TO_CONFIRM'
***            EXPORTING
***              TEXT_QUESTION         = |Workflow { I_WF_ID } is idetified, Do you want to proceed furthur?|
***              TEXT_BUTTON_1         = 'Yes'
***              TEXT_BUTTON_2         = 'NO'
***              DEFAULT_BUTTON        = '1'
***              DISPLAY_CANCEL_BUTTON = 'X'
***            IMPORTING
***              ANSWER                = LV_ANS
***            TABLES
***              PARAMETER             = PARAMETER
***            EXCEPTIONS
***              TEXT_NOT_FOUND        = 1.
***          IF LV_ANS EQ '1'.
***            CALL FUNCTION 'ZPM_FM_NOTIF_WF'
***              EXPORTING
***                IS_NEW_VIQMEL = IS_NEW_VIQMEL
***                I_WF_ID       = I_WF_ID.
***          ELSE.
***          ENDIF.
          MESSAGE |Workflow is identified and will be triggered on release of notification| TYPE 'I'.
          CALL FUNCTION 'ZPM_FM_NOTIF_WF'
            EXPORTING
              IS_NEW_VIQMEL = IS_NEW_VIQMEL
              I_WF_ID       = I_WF_ID.

        ELSE.
*/*** if workflow is deactivated than intimate the user through warning message
          MESSAGE |No workflow exists for the selected Work Cener| TYPE 'I'.
***          CLEAR LV_ANS.
***          CALL FUNCTION 'POPUP_TO_CONFIRM'
***            EXPORTING
***              TEXT_QUESTION         = | Workflow { I_WF_ID } is Inactive. Do you want to save?|
***              TEXT_BUTTON_1         = 'Yes'
***              TEXT_BUTTON_2         = 'NO'
***              DEFAULT_BUTTON        = '1'
***              DISPLAY_CANCEL_BUTTON = 'X'
***            IMPORTING
***              ANSWER                = LV_ANS
***            TABLES
***              PARAMETER             = PARAMETER
***            EXCEPTIONS
***              TEXT_NOT_FOUND        = 1.
***          IF LV_ANS EQ '1'.
***          ELSE.
****      RAISE EXIT_FROM_SAVE.
***          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.



  ENDMETHOD.
ENDCLASS.
