class ZCL_IM_NOTIF_EVENT_SAVE definition
  public
  final
  create public .

public section.

  interfaces IF_EX_NOTIF_EVENT_SAVE .
protected section.
private section.
ENDCLASS.



CLASS ZCL_IM_NOTIF_EVENT_SAVE IMPLEMENTATION.


  METHOD IF_EX_NOTIF_EVENT_SAVE~CHANGE_DATA_AT_SAVE.

*----- TRIGGER NOTIFICATION WORKFLOW -----*
break-point.
IF SY-TCODE EQ 'IW21' OR SY-TCODE EQ 'IW31'.
    DATA: I_WF_ID   TYPE CHAR10,
          PARAMETER TYPE STANDARD TABLE OF SPAR,
          LV_ANS    TYPE CHAR01.

    SELECT SINGLE ARBPL FROM CRHD INTO @DATA(LV_ARBPL)
      WHERE OBJID = @CS_VIQMEL-ARBPL.

    IF ( ( CS_VIQMEL-QMART EQ 'M1' OR CS_VIQMEL-QMART EQ 'M2' )  AND  CS_VIQMEL-INGRP <> 'PRD'  AND  LV_ARBPL(2) <> 'FA' ).
      I_WF_ID = 'WF-1.1'.
    ELSEIF ( ( CS_VIQMEL-QMART EQ 'M1' OR CS_VIQMEL-QMART EQ 'M2' )  AND  CS_VIQMEL-INGRP EQ 'PRD'  AND  LV_ARBPL(2) <> 'FA' ).
      I_WF_ID = 'WF-1.2'.
    ELSEIF ( CS_VIQMEL-QMART EQ 'M1'  AND  CS_VIQMEL-INGRP <> 'PRD'  AND  LV_ARBPL(2) EQ 'FA' ).
      I_WF_ID = 'WF-1.3'.
    ELSEIF ( CS_VIQMEL-QMART EQ 'M1'  AND  CS_VIQMEL-INGRP EQ 'PRD'  AND  LV_ARBPL(2) EQ 'FA' ).
      I_WF_ID = 'WF-1.4'.
    ELSEIF ( CS_VIQMEL-QMART EQ 'M8'  AND  CS_VIQMEL-INGRP EQ 'MNT'  AND  LV_ARBPL(3) EQ 'MNT' ).
      I_WF_ID = 'WF-3'.
    ELSEIF ( CS_VIQMEL-QMART EQ 'M8'  AND  CS_VIQMEL-INGRP EQ 'MNT'  AND  LV_ARBPL(3) EQ 'MNT'   AND CS_VIQMEL-ILART EQ 'ERX' ).
      I_WF_ID = 'WF-4'.
    ELSEIF ( CS_VIQMEL-QMART EQ 'T4'  AND  CS_VIQMEL-INGRP EQ 'MNT'  AND  LV_ARBPL(3) EQ 'MNT' ).
      I_WF_ID = 'WF-5'.
    ELSEIF CS_VIQMEL-QMART EQ 'M7'.
      I_WF_ID = 'WF-7'.
    ENDIF.

    SELECT SINGLE ZACTIVE FROM ZPM_WF INTO @DATA(LV_ACTIVE)
      WHERE WF_ID = @I_WF_ID.

    BREAK: AC_WF1, AC_ADNAN.
    IF LV_ACTIVE EQ 'X'.
      CLEAR LV_ANS.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TEXT_QUESTION         = |Workflow { I_WF_ID } is idetified, Do you want to proceed furthur?|
          TEXT_BUTTON_1         = 'Yes'
          TEXT_BUTTON_2         = 'NO'
          DEFAULT_BUTTON        = '1'
          DISPLAY_CANCEL_BUTTON = 'X'
        IMPORTING
          ANSWER                = LV_ANS
        TABLES
          PARAMETER             = PARAMETER
        EXCEPTIONS
          TEXT_NOT_FOUND        = 1.

      IF LV_ANS EQ '1'.
        CALL FUNCTION 'ZPM_FM_NOTIF_WF'
          EXPORTING
            IS_NEW_VIQMEL = CS_VIQMEL
            I_WF_ID       = I_WF_ID.
      ELSE.
        MESSAGE 'Choose yes to continue' TYPE 'I' DISPLAY LIKE 'E'.
        RAISE PROCESS_DETERMINATION.
      ENDIF.

    ELSE.
      CLEAR LV_ANS.
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          TEXT_QUESTION         = | Workflow { I_WF_ID } is Inactive. Do you want to save?|
          TEXT_BUTTON_1         = 'Yes'
          TEXT_BUTTON_2         = 'NO'
          DEFAULT_BUTTON        = '1'
          DISPLAY_CANCEL_BUTTON = 'X'
        IMPORTING
          ANSWER                = LV_ANS
        TABLES
          PARAMETER             = PARAMETER
        EXCEPTIONS
          TEXT_NOT_FOUND        = 1.
      IF LV_ANS EQ '1'.
      ELSE.
        RAISE PROCESS_DETERMINATION.
      ENDIF.
    ENDIF.
  ENDIF.


ENDMETHOD.
ENDCLASS.
