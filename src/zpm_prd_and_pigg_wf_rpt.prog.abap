*&---------------------------------------------------------------------*
*& Report ZPM_PRD_AND_PIGG_WF_RPT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZPM_PRD_AND_PIGG_WF_RPT.

DATA: LC_WF     TYPE REF TO ZCL_PM_PRD_AND_PIGG_WF_ZMF,
      LV_WF_ID  TYPE ZPM_ROT-WF_ID,
      LS_WF_HST TYPE ZPM_WF_HST,
      LS_AUFK   TYPE AUFK.

SELECTION-SCREEN: BEGIN OF BLOCK B1 WITH FRAME.
  PARAMETERS: P_AUFNR TYPE AUFK-AUFNR.
SELECTION-SCREEN: END OF BLOCK B1.

AT SELECTION-SCREEN.
  "  PERFORM CHECK_SCREEN.

********* TRIGGER WORKFLOW *********
*  CREATE OBJECT LC_WF
*    EXPORTING
*      WF_KEY = P_AUFNR.
*
*  CALL METHOD LC_WF->TRIGGER_WF(
*    EXPORTING
*      WF_KEY = P_AUFNR ).
  PERFORM TRIGGER_WORKFLOW.

  PERFORM UPDATE_HISTORY.
*  MESSAGE 'Workflow is working' TYPE 'S'.
********* TRIGGER WORKFLOW *********



*&---------------------------------------------------------------------*
*& Form check_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_SCREEN .

  SELECT SINGLE *
    FROM AUFK
    INTO LS_AUFK
    WHERE AUFNR EQ P_AUFNR.
  IF SY-SUBRC <> 0.
    MESSAGE 'Work order does not exist' TYPE 'E'.
  ELSE.
    LV_WF_ID = SWITCH #( LS_AUFK-AUART WHEN 'YBA4' THEN |WF-6.1|
                                       WHEN 'YBA6' THEN |WF-6.2| ).

    SELECT SINGLE ZACTIVE
      FROM ZPM_WF
      INTO @DATA(LV_STATUS)
    WHERE WF_ID EQ @LV_WF_ID.
    IF LV_STATUS <> 'X'.
      MESSAGE 'Work Flow ID is inactive' TYPE 'E'.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form UPDATE_HISTORY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM UPDATE_HISTORY .


  DATA: LV_WF_ID  TYPE ZPM_ROT-WF_ID,
        GV_CAUFVD TYPE CAUFVD.
  IMPORT CAUFVD TO GV_CAUFVD FROM MEMORY ID 'MEMORY_CAUFVD'.
**  SELECT SINGLE *
**    FROM ZPM_SET_V1
**    INTO @DATA(LS_ZPM_SET_V1)
**    WHERE WF_ID EQ @LV_WF_ID
**    AND LEVELS EQ '1'.
**  IF SY-SUBRC EQ 0.

  LV_WF_ID = SWITCH #( GV_CAUFVD-AUART WHEN 'YBA4' THEN |WF-6.1|
                                        WHEN 'YBA9' THEN |WF-6.2| ).


  SELECT MAX( HST_ID ) FROM ZPM_WF_HST INTO @DATA(LV_HST_ID).
  LV_HST_ID = LV_HST_ID + 1.

  LS_WF_HST-HST_ID = LV_HST_ID.
  LS_WF_HST-WF_ID = LV_WF_ID.
  LS_WF_HST-LEVELS = '1'.
  LS_WF_HST-AUFNR = GV_CAUFVD-AUFNR.
  LS_WF_HST-OBJNR = GV_CAUFVD-OBJNR.
  LS_WF_HST-C_STAT = 'WSCH'.
  LS_WF_HST-ERNAM = SY-UNAME.
  LS_WF_HST-OBJ_DATE = SY-DATUM.
  LS_WF_HST-APP_REJ = '1'.

  MODIFY ZPM_WF_HST FROM LS_WF_HST.

**  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form TRIGGER_WORKFLOW
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM TRIGGER_WORKFLOW .

  DATA: LV_OBJTYPE          TYPE SIBFTYPEID VALUE 'ZCL_PM_PRD_AND_PIGG_WF_ZMF',
        LV_EVENT            TYPE SIBFEVENT VALUE 'TRIGGER',
        LV_OBJKEY           TYPE SIBFINSTID,
        LV_PARAM_NAME       TYPE SWFDNAME,
        LV_ID               TYPE CHAR12,
        LR_EVENT_PARAMETERS TYPE REF TO IF_SWF_IFS_PARAMETER_CONTAINER
        .

* Instantiate an empty event container
  CALL METHOD CL_SWF_EVT_EVENT=>GET_EVENT_CONTAINER
    EXPORTING
      IM_OBJCATEG  = CL_SWF_EVT_EVENT=>MC_OBJCATEG_CL
      IM_OBJTYPE   = LV_OBJTYPE
      IM_EVENT     = LV_EVENT
    RECEIVING
      RE_REFERENCE = LR_EVENT_PARAMETERS.

* Set up the name/value pair to be added to the container
  LV_PARAM_NAME  = 'WF_KEY'.  "PARAMETER NAME OF THE EVENT
  LV_ID          = P_AUFNR.

* Add the name/value pair to the event conainer
  TRY.
      CALL METHOD LR_EVENT_PARAMETERS->SET
        EXPORTING
          NAME  = LV_PARAM_NAME
          VALUE = LV_ID.

    CATCH CX_SWF_CNT_CONT_ACCESS_DENIED .
    CATCH CX_SWF_CNT_ELEM_ACCESS_DENIED .
    CATCH CX_SWF_CNT_ELEM_NOT_FOUND .
    CATCH CX_SWF_CNT_ELEM_TYPE_CONFLICT .
    CATCH CX_SWF_CNT_UNIT_TYPE_CONFLICT .
    CATCH CX_SWF_CNT_ELEM_DEF_INVALID .
    CATCH CX_SWF_CNT_CONTAINER .
  ENDTRY.

  LV_OBJKEY = P_AUFNR.
* Raise the event passing the prepared event container
  TRY.
      CALL METHOD CL_SWF_EVT_EVENT=>RAISE
        EXPORTING
          IM_OBJCATEG        = CL_SWF_EVT_EVENT=>MC_OBJCATEG_CL
          IM_OBJTYPE         = LV_OBJTYPE
          IM_EVENT           = LV_EVENT
          IM_OBJKEY          = LV_OBJKEY
          IM_EVENT_CONTAINER = LR_EVENT_PARAMETERS.
    CATCH CX_SWF_EVT_INVALID_OBJTYPE .
    CATCH CX_SWF_EVT_INVALID_EVENT .
  ENDTRY.

*  COMMIT WORK.

ENDFORM.
